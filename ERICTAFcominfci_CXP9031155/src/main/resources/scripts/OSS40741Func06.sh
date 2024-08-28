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

createAifUsers_alreadyExistingOnNedss()
{
        l_cmd=`ssh smrs_master ssh nedss useradd user10`
        if [ $? != 0 ]; then
                log "ERROR: Passwordless connection doesnot exist between oss-smrs/smrs-nedss"
                G_PASS_FLAG=1
        else
                log "INFO: Local user user10 is created in nedss server"
        fi


        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -n WRAN -a user10 -p eric@1234`
        getSMRSLogs "add_aif.sh"
        ERROR_STG="ERROR"
        l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
        if [ $? == 0 ]; then
                log "SUCCESS::TR HS32591 verified AIF. User cannot be added as already exisiting on NEDSS. Please refer to $ERIC_LOG."
                l_cmd=`ssh smrs_master ssh nedss userdel user10`
                if [ $? != 0 ]; then
                        log "ERROR: Unable to delte local user"
                        G_PASS_FLAG=1
                else
                        log "INFO: Local user user10 deleted."
                fi
        else
                G_PASS_FLAG=1
                log "ERROR: TR HS32591 fix failed .AIF user which is already existing on NEDSS is added without any error.Please refer to $ERIC_LOG."
                l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/del_aif.sh -a user10`
                if [ $? != 0 ]; then
                        log "ERROR: Unable to delete aif user"
                        G_PASS_FLAG=1
                else
                        log "INFO: Aif user user10 is deleted"
                fi
        fi


}
###############################
#Execute the action to be performed
#####################################
executeAction()
{
log "INFO:Configuring aif user chusr "
createAifUsers_alreadyExistingOnNedss
}
#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#TR HS32591
log "HS32591 verification Started"
executeAction
log "HS32591 verification Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC
