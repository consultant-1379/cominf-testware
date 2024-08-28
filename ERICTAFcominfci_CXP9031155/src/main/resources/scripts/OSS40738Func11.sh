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


###################################
#this function is for verifying the adding target qualified roles to alias with invalid target names
##################################
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

function precon () 
{
	EXPCMD="$SCRIPT -a role -R ci_role1,ci_role2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listRole
	if [ `grep -c ci_role1 /tmp/file` -a `grep -c ci_role2 /tmp/file` == 1 ] ;then
		log "SUCCESS:$FUCNAME:: Added required roles ci_role1,ci_role2"
	else
		log "ERROR:$FUNCNAME:: Failed to Add required roles ci_role1,ci_role2"
	fi
	if [ `grep -c ci_role3 /tmp/file` == 1 ] ;then
		EXPCMD="$SCRIPT -r role -R ci_role3 -y"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		listRole
		if [ `grep -c "^ci_role3" /tmp/file` == 0 ] ;then
			log "SUCCESS:$FUCNAME::removed role ci_role3"
		else
			log "ERROR:$FUNCNAME:: Failed to remove  role ci_role3"
		fi
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


function TargetSpecialchars ()
{
	AddAlias "ci_alias1" "tar@get:ci_role1,tar#get:ci_role2"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="Successfully added COM role"
    l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Added target qualified role to the alias with special characters in the target . Please refer to $LOG_PATH"
		else
			log "SUCCESS:$FUNCNAME::verified:ERROR in Adding target qualified role to the alias with special characters in the target.Please refer to $LOG_PATH"
		fi
}

function SpecialcharsEnd ()
{
	AddAlias "ci_alias2" "target-:ci_role1,target_:ci_role2"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="Successfully added COM role"
    l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Added target qualified role to the alias with special characters at the end of target name. Please refer to $LOG_PATH"
		else
			log "SUCCESS:$FUNCNAME::verified:ERROR in Adding target qualified role to the alias with special characters at the end of target name.Please refer to $LOG_PATH"
		fi
}

function InvalidRole ()
{
	AddAlias "ci_alias3" "target:ci_role3"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="does not exist as a role"
    l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			log "SUCCESS:$FUNCNAME::verified:ERROR in Adding target qualified role to the alias where role does not exist in the role list.Please refer to $LOG_PATH"
		else
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Added target qualified role to the alias where role  does not exist in the role list.Please refer to $LOG_PATH"
		fi
}

function AddTargetInvalidRole ()
{
	AddAlias "ci_alias4" "ci_role2:target"
	${LOG_FN} "manage_COM.bsh"
    ERROR_STG="does not exist as a role"
    l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			log "SUCCESS:$FUNCNAME::verified:ERROR in Adding target qualified role to the alias as (role:target).Please refer to $LOG_PATH"
		else
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Added target qualified role to the alias as (role:target).Please refer to $LOG_PATH"
		fi
}

function clearAll ()
{
	EXPCMD="$SCRIPT -r role -R ci_role1,ci_role2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listRole 
	if [ `grep -c ci_role1 /tmp/file` -a `grep -c ci_role2 /tmp/file` == 0 ] ;then
			log "SUCCESS:$FUNCNAME::Removed all the roles"
	else
			log "ERROR:$FUNCNAME::Error in removing all the roles"
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
	log "INFO:$FUNCNAME::verifying the error while Adding target qualified roles to the alias with special characters in the target"
	TargetSpecialchars
	fi
	
	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::verifying the error while Adding target qualified roles to the alias with special characters at the end of the target names"
	SpecialcharsEnd
	fi
	
	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::verifying the error while Adding target qualified role to the alias where role does not exist in the role list"
	InvalidRole
	fi
	
	if [ $l_action == 5 ]; then
	log "INFO:$FUNCNAME::verifying the error while Adding target qualified role to the alias as (role:target)"
	AddTargetInvalidRole
	fi
	
	if [ $l_action == 6 ]; then
	log "INFO:$FUNCNAME::removing all the input roles"
	clearAll
	fi
	
}
#########
##MAIN ##
#########


# Executing preconditions:Adding Required roles
executeAction 1

#verifying the error while Adding target qualified roles to the alias with special characters in the target 
executeAction 2

#verifying the error while Adding target qualified roles to the alias with special characters at the end of the target names 
executeAction 3

#verifying the error while Adding target qualified role to the alias where role does not exist in the role list
executeAction 4

#verifying the error while Adding target qualified role to the alias as (role:target)
executeAction 5

#clearing all the roles
executeAction 6

#Final assertion of TC, this should be the final step of tc
evaluateTC

