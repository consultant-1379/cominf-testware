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

## TC TAFTM Link :http://taftm.lmera.ericsson.se
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
#SDSE_DIR=/ericsson/sdee/bin/

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        LOG_FN=getOPENDJLogs
	SCRIPT_DIR="/ericsson/opendj/bin"
else
        LOG_FN=getSDEELogs
	SCRIPT_DIR="/ericsson/sdee/bin"
fi


Domain_Name=`grep LDAP_DOMAIN /ericsson/sdee/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`

function prepareExpects2 ()
{
EXPCMD="$SCRIPT_DIR/manage_COM.bsh -m alias -A DUMMY_alias -i"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass
Enter the name of the COM role name to add
Target1:DUPPY_TC8
Enter the name of the COM role name to add
' > $INPUTEXP
}


function modifyAliasrolelist()
{
   prepareExpects2 
   createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
   executeExpect $OUTPUTEXP
   ${LOG_FN} "manage_COM.bsh" 
   ERROR_STG="ERROR"
   l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? != 0 ]; then
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME:: No error message is show for error message. Please refer to $LOG_PATH"
		else
			log "SUCCESS:$FUNCNAME::verified:ERROR in Adding target qualified role to $LOG_PATH"
		fi  	

}



###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME:: Checking assigning target specified role to a alias when the role does not exist in domain"
   modifyAliasrolelist 
   log "INFO:Completed ACTION 1"
 fi
 
 }
 
 
#########
##MAIN ##
#########	
		
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

# Checking the usage and ERROR message if -d option is not given 
executeAction 1


#Final assertion of TC, this should be the final step of tc
evaluateTC



