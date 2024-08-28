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
        SCRIPT=/ericsson/opendj/bin/manage_COM.bsh
else
        SCRIPT=/ericsson/sdee/bin/manage_COM.bsh
fi
 
file1="/tmp/importfile.txt"
file2="/tmp/importfile2.txt"
###################################
#this function is for verifying the adding target qualified roles to alias 
##################################
prepareImportFile () 
{
	echo 'DOMAIN vts.com
ROLE cirole3,cirole4
ALIAS cialias3 target3:cirole3,cirole3
ALIAS cialias4 target4:cirole4,cirole4' > $file1
}

prepareImportFile2 ()
{
	echo 'DOMAIN vts.com
ALIAS cialias3 target4:cirole4,cirole4
ALIAS cialias4 target3:cirole3,cirole3' > $file2
}

function precon () 
{
	EXPCMD="$SCRIPT -a role -R cirole1,cirole2 -y"
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
	if [ `grep -c cirole1 /tmp/file` -a `grep -c cirole2 /tmp/file` == 1 ] ;then
		log "SUCCESS:$FUCNAME:: Added required roles cirole1,cirole2"
	else
		log "ERROR:$FUNCNAME:: Failed to Add required roles cirole1,cirole2"
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
	AddAlias "cialias1" "target:cirole1"
	listAlias "cialias1"
	l_cmd=`grep target:cirole1 /tmp/listAliasFile`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: Added alias with target qualified role"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add alias with target qualified role"
	fi
}

function AlaisWithROleTArgetRole ()
{
	AddAlias "cialias2" "cirole2,target:cirole2"
	listAlias "cialias2"
	if [ ` grep -c "^cirole2" /tmp/listAliasFile` -a `grep -c target:cirole2 /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME:: Added alias(cialias2)  with role (cirole2) and target qualified role (target:cirole2)"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add alias(cialias2)  with role (cirole2) and target qualified role (target:cirole2)"
	fi
}

function  AliasInBulkImportAppendMode () 
{
	prepareImportFile
	EXPCMD="$SCRIPT -a import -f $file1 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listAlias "cialias3"
	if [ `grep -c "^cirole3" /tmp/listAliasFile` -a `grep -c target3:cirole3 /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added alias(cialias3) with role(cirole3) and target qualified role (target3:cirole3) using import option in append mode"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add alias(cialias3) with role(cirole3) and target qualified role (target3:cirole3) using import option in append mode"
	fi
	listAlias "cialias4"
	if [ ` grep -c "^cirole4" /tmp/listAliasFile` -a `grep -c target4:cirole4 /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added alias(cialias4) with role(cirole4) and target qualified role (target4:cirole4) using import option in append mode"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add alias(cialias4) with role(cirole4) and target qualified role (target4:cirole4) using import option in append mode"
	fi
}

function AliasInBulkOverwriteMode ()
{
	prepareImportFile2
	EXPCMD="$SCRIPT -a import -f $file2 -d vts.com -o -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listAlias "cialias3"
	if [ ` grep -c "^cirole4" /tmp/listAliasFile` -a `grep -c target4:cirole4 /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME:: modified alias(cialias3) by adding role(cirole4) and target qualified role (target4:cirole4) using import option in overwrite mode"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to modify alias(cialias3) by adding role(cirole4) and target qualified role (target4:cirole4) using import option in overwrite mode"
	fi
	listAlias "cialias4"
	if [ `grep -c "^cirole3" /tmp/listAliasFile` -a `grep -c target3:cirole3 /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME:: modified alias(cialias4) by adding role(cirole3) and target qualified role (target3:cirole3) using import option in overwrite mode"
		else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to modify alias(cialias4) by adding role(cirole3) and target qualified role (target3:cirole3) using import option in overwrite mode"
	fi

}
function clearAll () 
{
	EXPCMD="$SCRIPT -r role -R cirole1,cirole2,cirole3,cirole4 -y"
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

