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
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
     mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
#SCRIPT="/ericsson/sdee/bin/manage_COM.bsh"

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        SCRIPT="/ericsson/opendj/bin/manage_COM.bsh"
else
        SCRIPT="/ericsson/sdee/bin/manage_COM.bsh"
fi

file1="/tmp/importfile.txt"
file2="/tmp/importfile2.txt"
file3="/tmp/importfile3.txt"
###################################
#this function is for verifying the adding target qualified roles to alias
##################################



prepareImportFile1 ()
{
	echo 'DOMAIN vts.com
ROLE trole3,trole4
ALIAS talias3 trole2
ALIAS talias4 trole2' > $file1
}

prepareImportFile2 ()
{
	echo 'DOMAIN vts.com
ROLE trole3,trole4
ALIAS talias3 *:trole3,trole3
ALIAS talias4 *:trole4,trole4' > $file2
}

prepareImportFile3 ()
{
	echo 'DOMAIN vts.com
ALIAS talias3 *:trole4,trole4
ALIAS talias4 *:trole3,trole3' > $file3
}

function precon ()
{
	EXPCMD="$SCRIPT -a role -R trole1,trole2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	EXPCMD="$SCRIPT -l role"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file
	if [ `grep -c trole1 /tmp/file` -a `grep -c trole2 /tmp/file` == 1 ] ;then
		log "SUCCESS:$FUCNAME:: Added required roles trole1,trole2"
	else
		log "ERROR:$FUNCNAME:: Failed to Add required roles trole1,trole2"
	fi
}

function AddAlias ()
{
	EXPCMD="$SCRIPT -a alias -A $1  -R $2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
}

function listAlias ()
{
	EXPCMD="$SCRIPT -l alias -A $1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/listAliasFile
}

function AliasWithTargetRole ()
{
	AddAlias "talias1" "*:trole1"
	listAlias "talias1"
	l_cmd=`grep "*:trole1" /tmp/listAliasFile`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: Added alias with target qualified role with target as *"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add alias with target qualified role with target as *"
	fi
}

function AlaisWithROleTArgetRole ()
{
	AddAlias "talias2" "trole2,*:trole2"
	listAlias "talias2"
	if [ ` grep -c "^trole2" /tmp/listAliasFile` -a `grep -c "*:trole2" /tmp/listAliasFile` == 1 ] ;then
			log "SUCCESS:$FUCNAME:: Added alias(talias2)  with role (trole2) and target qualified role (*:trole2)"
	else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:: Failed to Add alias(talias2)  with role (trole2) and target qualified role (*:trole2)"
	fi
}

function  AliasInBulkImportAppendMode ()
{
	prepareImportFile1
	EXPCMD="$SCRIPT -a import -f $file1 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listAlias "talias3"
	if [ `grep -c "trole2" /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added alias(talias3) with role(trole2)"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add alias(talias3) with role(trole2)"
	fi
	listAlias "talias4"
	if [ `grep -c "trole2" /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added alias(talias3) with role(trole2)"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add alias(talias3) with role(trole2)"
	fi
	prepareImportFile2
	EXPCMD="$SCRIPT -a import -f $file2 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listAlias "talias3"
	if [ `grep -c "^trole2" /tmp/listAliasFile` -a `grep -c "^trole3" /tmp/listAliasFile` -a `grep -c "\*:trole3" /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added role(trole3) and target qualified role (*:trole3) to alias(talias3) using import option in append mode"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to add role(trole3) and target qualified role (*:trole3) to alias(talias3) using import option in append mode"
	fi
	listAlias "talias4"
	if [ ` grep -c "^trole2" /tmp/listAliasFile` -a `grep -c "\*:trole4" /tmp/listAliasFile`  -a `grep -c "^trole4" /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added role(trole4) and target qualified role (*:trole4) to alias(talias4) using import option in append mode"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add role(trole4) and target qualified role (*:trole4) to alias(talias4) using import option in append mode"
	fi
}

function AliasInBulkOverwriteMode ()
{
	prepareImportFile3
	EXPCMD="$SCRIPT -a import -f $file3 -d vts.com -o -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listAlias "talias3"
	if [ `grep -c "^trole2" /tmp/listAliasFile` == 0 ] ;then
		if [ ` grep -c "^trole4" /tmp/listAliasFile` -a `grep -c "\*:trole4" /tmp/listAliasFile` == 1 ] ;then
			log "SUCCESS:$FUCNAME:: modified alias(talias3) by adding role(trole4) and target qualified role (*:trole4) using import option in overwrite mode"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:: Failed to modify alias(talias3) by adding role(trole4) and target qualified role (*:trole4) using import option in overwrite mode"
		fi
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to modify alias (talias3) in overwrite mode"
	fi
	
	listAlias "talias4"
	if [ `grep -c "^trole2" /tmp/listAliasFile` == 0 ] ;then
		if [ `grep -c "^trole3" /tmp/listAliasFile` -a `grep -c "\*:trole3" /tmp/listAliasFile` == 1 ] ;then
			log "SUCCESS:$FUCNAME:: modified alias(talias4) by adding role(trole3) and target qualified role (*:trole3) using import option in overwrite mode"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:: Failed to modify alias(talias4) by adding role(trole3) and target qualified role (*:trole3) using import option in overwrite mode"
		fi
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to modify alias (talias3) in overwrite mode"
	fi
}


function clearAll ()
{
	EXPCMD="$SCRIPT -r role -R trole1,trole2,trole3,trole4 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	rm -f $file1 $file2 /tmp/listAliasFile /tmp/file
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME::Removed all the input files,roles and aliases"
	else
		log "ERROR:$FUNCNAME::Error in removing input files,roles and aliases"
	fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
	l_action=$1

	if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::Executing preconditions:Adding Required roles"
	precon
	fi

	if [ $l_action == 2 ]; then
	log "INFO:$FUNCNAME::Add Alias with target qualified roles"
	AliasWithTargetRole
	fi

	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::Add Alias with stand alone role target qualified roles"
	AlaisWithROleTArgetRole
	fi

	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::Add target qualified roles to the alias in bulk using -f option in append and overwrite modes"
	AliasInBulkImportAppendMode
	AliasInBulkOverwriteMode
	fi

	if [ $l_action == 5 ]; then
	log "INFO:$FUNCNAME::clearing all the input files,roles and aliases"
	clearAll
	fi

}
#########
##MAIN ##
#########


# Executing preconditions:Adding Required roles
executeAction 1

#Add Alias with target qualified roles
executeAction 2

#Add Alias with stand alone role target qualified roles
executeAction 3

#Add target qualified roles to the alias in bulk using -f option in append and overwrite modes
executeAction 4

#clearing all the input files,roles and aliases
executeAction 5

#Final assertion of TC, this should be the final step of tc
evaluateTC
