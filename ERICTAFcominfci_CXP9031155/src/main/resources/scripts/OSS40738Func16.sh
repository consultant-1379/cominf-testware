#!/bin/bash
#------------------------------------------------------------------------
#
#       COPYRIGHT (C) ERICSSON RADIO SYSTEMS AB, Sweden
#
#       The copyright to the document(s) herein is the property of
#       Ericsson Radio Systems AB, Sweden.
#
#       The document(s) may be used and/or copied only with the written
#       permission from Ericsson Radio Systems AB or in accordance with
#       the terms and conditions stipulated in the agreement/contract
#       under which the document(s) have been supplied.
#
#------------------------------------------------------------------------


##TC VARIABLE##

G_COMLIB=commonFunctions.lib
#source the commonFunctions.
source $G_COMLIB
G_PASS_FLAG=0
Var=0
Var2=0
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
	 mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
#path="/ericsson/sdee/bin"

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        path=/ericsson/opendj/bin
else
        path=/ericsson/sdee/bin
fi


file1="/tmp/ImportFile1"
file2="/tmp/batchFile2"
file3="/tmp/batchFile3"
file4="/tmp/batchFile4"
file5="/tmp/batchFile5"
file6="/tmp/batchFile6"
file7="/tmp/batchFile7"
file8="/tmp/addUser"
###################################
# Functions to add/remove priveleges to users using manage_COM_privs.bsh script with -f <batch_file> option
#################################
prepareImportFile () {
echo 'DOMAIN vts.com
ROLE role1,role2
ALIAS alias1 role1,role2' > $file1
}
prepareBatchFile1 () 
{
echo 'DOMAIN vts.com
ACTION add
OBJECT target
yuser1 *' > $file2
}
prepareBatchFile2 ()
{
echo 'DOMAIN vts.com
ACTION remove
OBJECT target
yuser1 *' > $file3
}

prepareBatchFile3 ()
{
echo 'DOMAIN vts.com
ACTION add
OBJECT role
yuser1 *:role1' > $file4
}

prepareBatchFile4 ()
{
echo 'DOMAIN vts.com
ACTION remove
OBJECT role
yuser1 *:role1' > $file5
}

prepareBatchFile5 ()
{
echo 'DOMAIN vts.com
ACTION add
OBJECT alias
yuser1 *:alias1' > $file6
}

prepareBatchFile6 ()
{
echo 'DOMAIN vts.com
ACTION remove
OBJECT alias
yuser1 *:alias1' > $file7
}
prepareAddUser ()
{
	EXPCMD="$path/add_user.sh"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
echo 'LDAP Directory Manager password
ldappass
New local user name
yuser1
Start of uidNumber search range
\r
End of uidNumber search range
\r
New local user password
password
Re-enter password
password
New local user category
\r
New local user description
\r
Continue to create local user
\r' > $INPUTEXP
}

function precon ()
{
	prepareAddUser
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > $file8
	l_cmd=`grep "successfully added yuser1" $file8`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME:: added required user:yuser1"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding required user:yuser1"
	fi
	prepareImportFile
	EXPCMD="$path/manage_COM.bsh -a import -d vts.com -f  $file1  -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::created the required roles and aliases"
	else
			log "ERROR:$FUNCNAME::Error in creating the required roles and alias"
	fi
}

function listprivs() {
	EXPCMD="$path/manage_COM_privs.bsh -l -u $1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file9
}

function addRemovePrivs ()
{
	EXPCMD="$path/manage_COM_privs.bsh $1 $2 -d vts.com -f $3 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	listprivs "yuser1"
}
function add*Target ()
{
	prepareBatchFile1
	addRemovePrivs "-a" "target" "$file2"
	if [ `grep -c "Target \| \*" /tmp/file9` == 1 ] ;then
		log "SUCCESS:$FUNCNAME::  Added target * to yuser1 using -f <batch_file> option"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target * to yuser1 uisng -f <batch_file> option"
	fi
}
function remove*Target ()
{
	prepareBatchFile2
	addRemovePrivs "-r" "target" "$file3"
	if [ `grep -c "Target \|\ *" /tmp/file9` == 0 ] ;then
		log "SUCCESS:$FUNCNAME::  Removed target * from yuser1 using -f <batch_file> option"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in removing target * from yuser1 uisng -f <batch_file> option"
	fi
}

function addRemove*TargetRole ()
{
	prepareBatchFile3
	addRemovePrivs "-a" "role" "$file4"
	if [ `grep -c "\*:role1" /tmp/file9` -a `grep -c "Target \| \*" /tmp/file9` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: added target qualified role *:role1 to yuser1  using -f <batch_file> option"
	else
		Var=1
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target qualified *:role1 to yuser1  using -f <batch_file> option"
	fi
	prepareBatchFile4
	#addRemovePrivs "-r" "role" "$file5"
	#if [ `grep -c "\*:role1" /tmp/file9` -a $Var == 0 ] ;then
#		log "SUCCESS:$FUNCNAME:: Removed target qualified role *:role1 to yuser1  using -f <batch_file> option"
#	else
#		G_PASS_FLAG=1
#		log "ERROR:$FUNCNAME::Error in Removing target qualified *:role1 to yuser1  using -f <batch_file> option"
#	fi
#	remove*Target
}

function addRemove*TargetAlias ()
{
	prepareBatchFile5
	addRemovePrivs "-a" "alias" "$file6"
	if [ `grep -c "Alias  \| \*:alias1" /tmp/file9` -a `grep -c "Target \| \*" /tmp/file9` == 1 ] ; then
		log "SUCCESS:$FUNCNAME:: added target qualified alias *:alias1 to yuser1  using -f <batch_file> option"
	else
		Var2=1
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target qualified alias *:alias1 to yuser1  using -f <batch_file> option"
	fi
	#prepareBatchFile6
#	addRemovePrivs "-r" "alias" "$file7"
#	if [ `grep -c "Alias  \| \*:alias1" /tmp/file9` -a $Var2 == 0 ] ;then
#		log "SUCCESS:$FUNCNAME:: Removed target qualified alias *:alias1 to yuser1  using -f <batch_file> option"
#	else
#		G_PASS_FLAG=1
#		log "ERROR:$FUNCNAME::Error in Removing target qualified alias *:alias1 to yuser1  using -f <batch_file> option"
#	fi
#	remove*Target
}
function clearAll () {

	EXPCMD="$path/del_user.sh -n yuser1 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::deleted user yuser1"
	else
			log "ERROR:$FUNCNAME::Error in deleting user yuser1"
	fi
	l_cmd=`rm -f $file1 $file2 $file3 $file4 $file5 $file6 $file7 $file8 /tmp/file9`
	if [ $? == 0 ] ;then
	log "SUCCESS:$FUNCNAME::removed all the input files"
	else
	log "ERROR:$FUNCNAME::Error in removing the input files"
	fi
	EXPCMD="$path/manage_COM.bsh -r role -R role1,role2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	if [ $? == 0 ] ;then
	log "SUCCESS:$FUNCNAME::removed all the roles and aliases"
	else
	log "ERROR:$FUNCNAME::Error in removing roles and aliases"
	fi
}
##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
	l_action=$1

	if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::executing preconditions"
	precon
	fi
	
	if [ $l_action == 2 ]; then
	log "INFO:$FUNCNAME::Adding target * to yuser1 using manage_COM_privs.bsh script with -f <batch_file> option"
	add*Target
	fi
	
	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::Removing target * to yuser1 using manage_COM_privs.bsh script with -f <batch_file> option"
	remove*Target
	fi
	
	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::Adding&Removing target qualified role *:role1 to yuser1  using manage_COM_privs.bsh script with -f <batch_file> option"
	addRemove*TargetRole
	fi
	
	if [ $l_action == 5 ]; then
	log "INFO:$FUNCNAME::Adding&Removing target qualified alais *:alias1 to yuser1  using manage_COM_privs.bsh script with -f <batch_file> option"
	addRemove*TargetAlias
	fi
	
	if [ $l_action == 6 ]; then
	log "INFO:$FUNCNAME::deleting all users and input files and privileges"
	clearAll
	fi
}
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#executing preconditions
executeAction 1

#Adding target * to yuser1 using manage_COM_privs.bsh script with -f <batch_file> option
executeAction 2

#Removing target * to yuser1 using manage_COM_privs.bsh script with -f <batch_file> option
#executeAction 3

#Adding&Removing target qualified role *:role1 to yuser1  using manage_COM_privs.bsh script with -f <batch_file> option
executeAction 4

#Adding&Removing target qualified alais *:alias1 to yuser1  using manage_COM_privs.bsh script with -f <batch_file> option
executeAction 5

#deleting all users and input files and privileges
executeAction 6

#Final assertion of TC, this should be the final step of tc
evaluateTC
