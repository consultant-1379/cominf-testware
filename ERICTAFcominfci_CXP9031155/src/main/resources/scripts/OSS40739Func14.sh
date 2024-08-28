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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4679
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
#############################################################################

function cronentry_check () {
   dhcp_cron_entry=`crontab -l|egrep -i /ericsson/ocs/bin/dhcp_check.sh|awk -F' ' '{print $9}'`
  if [ "$dhcp_cron_entry" == "2>&1" ]; then
         log "crontab entry (/ericsson/ocs/bin/dhcp_check.sh) is properly redirected to /dev/null and the entry is  01,31 * * * * /ericsson/ocs/bin/dhcp_check.sh > /dev
/null 2>&1"
        else
                G_PASS_FLAG=1
            log "FAILED:: crontab entry (/ericsson/ocs/bin/dhcp_check.sh) is NOT  properly redirected to /dev/null, (2>&1 is missing after /dev/null)"
        fi
}
###############################
#Execute the action to be performed
#####################################

function executeAction () {
        l_action=$1

        if [[ "$l_action" == 1 ]] ; then
                log "INFO:: Checking whether crontab entry (/ericsson/ocs/bin/dhcp_check.sh) is properly redirected to /dev/null or not? "
               cronentry_check
        fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking whether crontab entry (/ericsson/ocs/bin/dhcp_check.sh) is properly redirected to /dev/null or not?
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC
