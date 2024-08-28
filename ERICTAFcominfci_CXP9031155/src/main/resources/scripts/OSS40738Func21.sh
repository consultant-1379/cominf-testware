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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4671
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
SDSE_DIR=/ericsson/sdee/bin
#############################################################################

function bin_permissions () {
 bindir_permissions=`ls -lrt /ericsson/sdee/|grep -w bin|awk '{print $1}'`
 if [ "$bindir_permissions" == "drwxrwxrwx" ]; then
                       G_PASS_FLAG=1
                log "FAILED:: The /ericsson/sdee/bin folder has 777 permissions, which are wrong permissions."
        else
              log " /ericsson/sdee/bin folder did not have 777 permissions"
        fi
}
###############################
#Execute the action to be performed
#####################################

function executeAction () {
        l_action=$1

        if [[ "$l_action" == 1 ]] ; then
                log "INFO:: Checking the /ericsson/sdee/bin folder permissions "
                bin_permissions
        fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking the /ericsson/sdee/bin folder permissions.
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC
