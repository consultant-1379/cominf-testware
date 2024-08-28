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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4662
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

function cronCheck ()
{
l_cmd=`crontab -l | grep /ericsson/ocs/bin/dhcp_check.sh  > /dev/null 2>&1`
        ret=$?
        if [ $ret == 0 ] ; then
                 log "INFO::$FUNCNAME:dhcp_check.sh script output is redirected to /dev/null "
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNCNAME: dhcp_check.sh script output is Not redirected to /dev/null "
        fi
l_cmd=`crontab -l | grep /ericsson/ocs/bin/dhcp_restart.sh > /dev/null 2>&1`
        ret=$?
        if [ $ret == 0 ] ; then
                 log "INFO::$FUNCNAME:dhcp_restart.sh script output is redirected to /dev/null  "
        else
                G_PASS_FLAG=1
                 log "ERROR::$FUNCNAME: dhcp_restart.sh script output is Not redirected to /dev/null "
        fi

}
###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
   log "INFO: Testcase regarding the TR:HS39928"
   log "INFO:$FUNCNAME::Checking the  dhcp script outputs are redirected to /dev/null  in crontab "
   cronCheck
   log "INFO:Completed ACTION 1"
 fi
}
#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking the dhcp scripts output are redirected to /dev/null in crontab
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
        