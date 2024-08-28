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
        LOG_FN=getOPENDJLogs
	SCRIPT="/ericsson/opendj/bin/manage_COM.bsh"
else
        LOG_FN=getSDEELogs
	SCRIPT="/ericsson/sdee/bin/manage_COM.bsh"
fi


file1="/tmp/importfile"
###################################
#this function is for verifying the Inserting and removing target qualified roles from alias
##################################
prepareImportFile () {
echo 'DOMAIN vts.com
ROLE c_role1,c_role2,c_role3,c_role4
ALIAS calias1 c_role1,target:c_role1,c_role2
ALIAS calias2 c_role2,c_role3' > $file1
}

function listAliasAll ()
{
	EXPCMD="$SCRIPT -l alias"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/listAliasAll
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

function listRole () 
{
	EXPCMD="$SCRIPT -l role"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file
}

function RemoveRole ()
{
	EXPCMD="$SCRIPT -r role -R $1 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP

}
function precon () 
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
	listRole
	if [ `grep -c c_role1 /tmp/file` -a `grep -c c_role2 /tmp/file` -a `grep -c c_role3 /tmp/file` -a `grep -c c_role4 /tmp/file` == 1 ] ;then
		log "SUCCESS:$FUCNAME:: Added required roles :c_role1,c_role2,c_role3,c_role4"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add required roles :c_role1,c_role2,c_role3,c_role4"
	fi
	listAlias "calias1"
	if [ `grep -c "^c_role1" /tmp/listAliasFile` -a `grep -c "^c_role2" /tmp/listAliasFile` -a `grep -c target:c_role1 /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added required alias:calias1"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add required alias:calias1"
	fi
	listAlias "calias2"
	if [ ` grep -c "^c_role2" /tmp/listAliasFile` -a `grep -c "^c_role3" /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added required alias:calias2"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add required alias:calias2"
	fi
	if [ `grep -c c_role5 /tmp/file` == 1 ] ;then
		RemoveRole "c_role5"
		listRole
		if [ `grep -c "^c_role5" /tmp/file` == 0 ] ;then
			log "SUCCESS:$FUCNAME::removed role c_role5"
		else
			log "ERROR:$FUNCNAME:: Failed to remove  role c_role5"
		fi
	fi
}

function InsertAlias ()
{
	EXPCMD="$SCRIPT -m alias -i -A $1 -R $2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
}

function RemoveroleAlias ()
{
	EXPCMD="$SCRIPT -m alias -x -A $1 -R $2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
}

function modifyAlias ()
{
	InsertAlias "calias1" "target:c_role3"
	listAlias "calias1"
	if [  `grep -c target:c_role3 /tmp/listAliasFile`  == 1 ] ; then
		log "SUCCESS:$FUCNAME::Inserted target qualified role (target:c_role3) into alias:calias1"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Insert target qualified role (target:c_role3) into alias:calias1"
	fi	
}

function InsertRoleTargetRole ()
{
	InsertAlias "calias2" "target:c_role2"
	listAlias "calias2"
	if [  `grep -c target:c_role2 /tmp/listAliasFile`  == 1 ] ; then
		log "SUCCESS:$FUCNAME::Inserted target qualified role (target:c_role2) into alias:calias2"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Insert target qualified role (target:c_role2) into alias:calias2"
	fi	
}

function InsertTargetRoleSameAlias()
{
	InsertAlias "calias1" "target:c_role3"
	${LOG_FN} "manage_COM.bsh"
	ERROR_STG="already exists in alias"
	l_cmd=`grep -w "${ERROR_STG}" ${LOG_PATH}` 
	ret=$?
	if [ $ret == 0 ] ; then
		log "SUCCESS:$FUCNAME:: Successfully verified ERROR for inserting the existing target qualified role into same alias.please Refer to ${LOG_PATH}"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to verify ERROR for inserting the existing target qualified role into same alias.please Refer to ${LOG_PATH}"
	fi
}

function InsertTargetSpecialchars ()
{
	InsertAlias "calias1" "tar@get:c_role4"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="Successfully added COM role"
    l_cmd=`grep -w "${ERROR_STG}" ${LOG_PATH}`
	if [ $? == 0 ]; then
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Inserted target qualified role to the alias with special characters in the target.Please refer to ${LOG_PATH}"
	else
		log "SUCCESS:$FUNCNAME::verified:ERROR in Inserting target qualified role to the alias with special characters in the target.Please refer to ${LOG_PATH}"
	fi
}

function InsertSpecialcharsEnd ()
{
	InsertAlias "calias1" "target-:c_role4"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="Successfully added COM role"
    l_cmd=`grep -w "${ERROR_STG}" ${LOG_PATH}`
	if [ $? == 0 ]; then
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Inserted target qualified role to the alias with special characters at the end of target name. Please refer to ${LOG_PATH}"
	else
		log "SUCCESS:$FUNCNAME::verified:ERROR in Inserted target qualified role to the alias with special characters at the end of target name.Please refer to ${LOG_PATH}"
	fi
}

function InsertInvalidRole ()
{
	InsertAlias "calias1" "target:c_role5"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="does not exist as a role"
    l_cmd=`grep -w "${ERROR_STG}" ${LOG_PATH}`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified:ERROR in Inserting target qualified role to the alias where role does not exist in the role list.Please refer to ${LOG_PATH}"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Inserted target qualified role to the alias where role does not exist in the role list.Please refer to ${LOG_PATH}"
	fi
}

function InsertTargetInvalidRole ()
{
	InsertAlias "calias1" "c_role2:target"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="does not exist as a role"
    l_cmd=`grep -w "${ERROR_STG}" ${LOG_PATH}`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified:ERROR in Inserting target qualified role to the alias as (role:target).Please refer to ${LOG_PATH}"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Inserted target qualified role to the alias as (role:target).Please refer to ${LOG_PATH}"
	fi
}

function RemoveroleOnly ()
{
	RemoveroleAlias "calias2" "c_role2"
	listAlias "calias2"
	if [ `grep -c "^c_role2" /tmp/listAliasFile` == 0 -a `grep -c target:c_role2 /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUNCNAME::verified:Removing stand alone role from alias does not remove target qualified role from alias"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Removed target qualified role from alias when removed stand alone role from alais"
	fi
}
	
function RemoveTargetRole ()
{
	RemoveroleAlias "calias1" "target:c_role1"
	listAlias "calias1"
	if [ `grep -c target:c_role1 /tmp/listAliasFile` == 0 -a `grep -c "^c_role1" /tmp/listAliasFile` == 1 ] ;then
		log "SUCCESS:$FUNCNAME::verified:Removing target qualified role from alias does not remove stand alone role from alias"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Removed stand alone role from alias when removed target qualified role from alais"
	fi
}

function CheckRemoveRole () 
{
	RemoveRole "c_role1"
	listRole 
	if [ `grep -c "^c_role1" /tmp/file` == 0 ] ;then
		log "SUCCESS:$FUCNAME:: successfully removed role c_role1"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Error in removing role c_role1"
	fi
	listAlias "calias1"
	if [ `grep -c c_role1 /tmp/listAliasFile` == 0  ] ;then
		log "SUCCESS:$FUNCNAME::verified:Removing role from role list removes role from alias"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Removing role from role list not removed role from alias"
	fi
}	

function RemoveInvalidRole ()
{
	RemoveroleAlias "calias1" "c_role4"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="does not exist in alias"
    l_cmd=`grep -w "${ERROR_STG}" ${LOG_PATH}`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified:ERROR while removing the Role from alias  which does not exist in alias .Please refer to ${LOG_PATH}"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Removed the Role from alias which does not exist in alias.Please refer to ${LOG_PATH}"
	fi
}
	
function RemoveLastRoleAlias ()
{
	RemoveRole "c_role2"
	listRole 
	if [ `grep -c "^c_role2" /tmp/file` == 0 ] ;then
		log "SUCCESS:$FUCNAME:: successfully removed role c_role2"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Error in removing role c_role2"
	fi
	RemoveroleAlias "calias2" "c_role3"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="This action will remove the last role from alias"
    l_cmd=`grep -w "${ERROR_STG}" ${LOG_PATH}`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified:WARNING while removing the last Role from alias.Please refer to ${LOG_PATH}"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Removed the last Role from alias.Please refer to ${LOG_PATH}"
	fi
}

function RemoveAlias ()
{
	listAliasAll
	if [ `grep -c "^calias1"  /tmp/listAliasAll` == 1 -a  `grep -c "^calias2" /tmp/listAliasAll` == 1 ] ;then
		log "SUCCESS:$FUNCNAME::Listed the added aliases"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ERROR in listing the added aliases"
	fi
	EXPCMD="$SCRIPT -r alias -A calias1 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listAliasAll 
	if [ `grep -c "^calias1"  /tmp/listAliasAll` == 0 ] ;then
		log "SUCCESS:$FUNCNAME::Removed alias:calias1"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ERROR in removing the alias:calias1"
	fi
}

function clearAll ()
{
	RemoveRole "c_role3,c_role4"
	listRole 
	if [ `grep -c c_role3 /tmp/file` -a `grep -c c_role4 /tmp/file` == 0 ] ;then
			log "SUCCESS:$FUNCNAME::Removed all the roles"
	else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in removing all the roles"
	fi
	rm -f /tmp/listAliasAll /tmp/file  /tmp/listAliasFile $file1 
	if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::Removed all the input files"
	else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in removing input files"
	fi
	
	
}	
###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
	l_action=$1
 
	if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::Executing preconditions:Adding Required roles and aliases"
	precon
	fi
	
	if [ $l_action == 2 ]; then
	log "INFO:$FUNCNAME::Insert target qualified role into alias"
	modifyAlias
	fi
	
	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::Insert target qualified role(target:role) into alias where role already exists in alias"
	InsertRoleTargetRole
	fi
	
	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::Verifying the Error while inserting the existing target qualified role into the same alias"
	InsertTargetRoleSameAlias
	fi
	
	if [ $l_action == 5 ]; then
	log "INFO:$FUNCNAME::Verifying the ERROR while inserting target qualified roles in to the alias with special characters in the target"
	InsertTargetSpecialchars
	fi
	
	if [ $l_action == 6 ]; then
	log "INFO:$FUNCNAME::Verifying the ERROR while inserting target qualified roles in to the alias with special characters at the end of the target names"
	InsertSpecialcharsEnd
	fi
	
	if [ $l_action == 7 ]; then
	log "INFO:$FUNCNAME::verifying the ERROR in Inserting target qualified role to the alias where role does not exist in the role list"
	InsertInvalidRole
	fi
	
	if [ $l_action == 8 ]; then
	log "INFO:$FUNCNAME::verifying the ERROR in Inserting target qualified role to the alias as (role:target)"
	InsertTargetInvalidRole
	fi
		
	if [ $l_action == 9 ]; then
	log "INFO:$FUNCNAME::Verifying:Removing stand alone role from alias does not remove target qualified role from alias"
	RemoveroleOnly
	fi
	
	if [ $l_action == 10 ]; then
	log "INFO:$FUNCNAME::verifying:Removing target qualified role from alias does not remove stand alone role from alias"
	RemoveTargetRole
	fi
	
	if [ $l_action == 11 ]; then
	log "INFO:$FUNCNAME::verifying:Removing role from role list removes role from alias"
	CheckRemoveRole
	fi
	
	if [ $l_action == 12 ]; then
	log "INFO:$FUNCNAME::verifying:ERROR while removing the Role from alias  which does not exist in alias"
	RemoveInvalidRole
	fi
	
	if [ $l_action == 13 ]; then
	log "INFO:$FUNCNAME::verifying:WARNING while removing the last Role from alias"
	RemoveLastRoleAlias
	fi
	
	if [ $l_action == 14 ]; then
	log "INFO:$FUNCNAME::Listing the added aliases"
	log "INFO:$FUNCNAME::Removing the alias"
	RemoveAlias
	fi
	
	if [ $l_action == 15 ]; then
	log "INFO:$FUNCNAME::Removing all the created roles"
	clearAll
	fi
	
}
#########
##MAIN ##
#########


# Executing preconditions:Adding Required roles
executeAction 1

#Insert target qualified role into alias 
executeAction 2

#Insert target qualified role(target:role) into alias where role already exists in alias
executeAction 3

#Verifying the Error while inserting the existing target qualified role into the same alias
executeAction 4

#Verifying the ERROR while inserting target qualified roles in to the alias with special characters in the target
executeAction 5

#Verifying the ERROR while inserting target qualified roles in to the alias with special characters at the end of the target names
executeAction 6

#verifying the ERROR in Inserting target qualified role to the alias where role does not exist in the role list
executeAction 7

#verifying the ERROR in Inserting target qualified role to the alias as (role:target)
executeAction 8

#Verifying:Removing stand alone role from alias does not remove target qualified role from alias
executeAction 9

#verifying:Removing target qualified role from alias does not remove stand alone role from alias
executeAction 10

#verifying:Removing role from role list removes role from alias
executeAction 11

#verifying:ERROR while removing the Role from alias  which does not exist in alias
executeAction 12

#verifying:WARNING while removing the last Role from alias
executeAction 13

#Listing the added aliases and Removing the alias
executeAction 14

#Removing all the created roles
executeAction 15


#Final assertion of TC, this should be the final step of tc
evaluateTC
