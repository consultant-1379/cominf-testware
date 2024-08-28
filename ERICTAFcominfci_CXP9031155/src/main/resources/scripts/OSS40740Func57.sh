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
G_MAXSTARTUP=50:70:510
#smrsConfig="/etc/opt/ericsson/nms_bismrs_mc/smrs_config"
#nedssIP=`grep NEDSS_TRAFFIC_IP $smrsConfig |awk -F= '{print $2}'`
#smrsIP=`grep SMRS_MASTER_IP $smrsConfig |awk -F= '{print $2}'`

#########################################
#check MaxStartups updated in omsrvm and nedss
#########################################

function checkMaxStartups ()
{
maxstartup_smrsMaster=( `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master grep MaxStartups /etc/ssh/sshd_config | awk -F" " '{print $2}'` )

if [ $maxstartup_smrsMaster == $G_MAXSTARTUP ]; then
	log "SUCCESS: MaxStartups value is updated in omsrvm."
	M_STATUS=0
else
	log "ERROR: MaxStartups value is not updated in omsrvm."
	M_STATUS=1
fi

maxstartup_nedss=( `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o  UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss grep MaxStartups /etc/ssh/sshd_config | awk -F" " '{print $2}'` )

if [ $maxstartup_nedss == $G_MAXSTARTUP ]; then
        log "SUCCESS: MaxStartups value is updated in nedss."
	S_STATUS=0
else
        log "ERROR: MaxStartups value is not updated in nedss."
	S_STATUS=1
fi

if [ $M_STATUS -eq 0 -a $S_STATUS -eq 0 ]; then
	G_PASS_FLAG=0
else
	G_PASS_FLAG=1
fi
}

#####################################
#Execute the action to be performed
#####################################
function executeAction ()
{
l_action=$1

if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::checking whether MaxStartups value is updated in omsrvm and nedss"
	checkMaxStartups
fi
} 
 
#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking whether MaxStartups value is updated in omsrvm and nedss
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
