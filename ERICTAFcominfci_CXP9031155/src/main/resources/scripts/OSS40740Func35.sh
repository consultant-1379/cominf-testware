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
#file3="/tmp/file1"
#file4="/tmp/file2"

#########################################
#check ntp ip in NEDSS server is SMRS IP
#########################################

function checkNtpvIpInNedss ()
{
	SMRS_IP=`grep smrs_master /etc/hosts | awk '{print $1}'`
	if [ $SMRS_IP == "" ]
	then
		log "ERROR: Cannot get SMRS IP from /etc/hosts. Smrs configuration was not completed."
	else
		NEDSS_NTP_IP=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss cat /etc/inet/ntp.conf | grep ^server | awk '{print $2}'`
		if [ $NEDSS_NTP_IP == "" ]
		then
			log "ERROR: Cannot get NTP IP from /etc/inet/ntp.conf. NTP was not correctly configured in NEDSS."
		else
			if [ $SMRS_IP == $NEDSS_NTP_IP ] 
			then
				log "SUCCESS: NEDSS NTP IP is same as SMRS MASTER IP."
			else
				log "ERROR: NEDSS NTP IP is not same as SMRS MASTER IP."
			fi
		fi
	fi

}

#####################################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::checking if omsrvm ip is used as NEDSS NTP ip"
   checkNtpvIpInNedss
 fi
 
 } 
 
 
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking if omsrvm ( smrs_master ) ip is used as NEDSS NTP ip
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC