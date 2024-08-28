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

###################################
#check ntp4 service is online
#################################

function checkNtpv4_NtpService ()
{
	
nedss_os_ver=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o  UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss uname -r`

if [[ "${nedss_os_ver}" = "5.10" ]]; then
#Sol10
	ntp4serviceState_nedss=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o  UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss svcs svc:/network/ntp4:default |tail -1 | awk '{print $1}'`
	
	if [ $? -ne 0 ]; then
		G_PASS_FLAG=1
           log "ERROR:Unable to connect to Nedss from om_serv_master"
        else
            if [ "$ntp4serviceState_nedss" == "online" ] ; then
               log "SUCCESS:$FUNCNAME::NTP4 service is in online state in NEDSS "
            else
               G_PASS_FLAG=1
               log "ERROR:$FUNCNAME::NTP4 service is in $ntp4serviceState_nedss state in NEDSS"
            fi
        fi
	
	ntpserviceState_nedss=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
		
	if [ $? -ne 0 ]; then
		G_PASS_FLAG=1
           log "ERROR: Unableto connect to Nedss from om_serv_master"
        else
           if [ "$ntpserviceState_nedss" == "disabled" ] ; then
              log "SUCCESS:$FUNCNAME::NTP service is in $ntpserviceState_nedss state in NEDSS "
           else
              G_PASS_FLAG=1
              log "ERROR:$FUNCNAME::NTP service is in $ntpserviceState_nedss state in NEDSS"
           fi
        fi

else
#Sol11
	ntpserviceState_nedss=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
		
	if [ $? -ne 0 ]; then
		G_PASS_FLAG=1
           log "ERROR: Unableto connect to Nedss from om_serv_master"
        else
            if [ "$ntpserviceState_nedss" == "online" ] ; then
               log "SUCCESS:$FUNCNAME::NTP service is in $ntpserviceState_nedss state in NEDSS "
            else
               G_PASS_FLAG=1
               log "ERROR:$FUNCNAME::NTP service is in $ntpserviceState_nedss state in NEDSS"
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
   log "INFO:$FUNCNAME::checking NTP service state in Nedss"
   #checkNtpv4Service
   checkNtpv4_NtpService
 fi
 
 } 
 
 
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking ntp4 service state in om_serv_master, and in Nedss
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
