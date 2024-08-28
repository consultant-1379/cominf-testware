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
#file5="/tmp/file3"
#file6="/tmp/file4"

###################################
#check ntp service is in disabled state 
#################################

function checkNtpService ()
{
	#serviceState_smrs_master=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
	#if [ $? -ne 0 ]
	#then
	#	log "ERROR: Unable to connect to om_serv_master from Ossmaster"
	#else
	#	if [ "$serviceState_smrs_master" == "disabled" ] ; then
	#		log "SUCCESS:$FUNCNAME::NTP service is in $serviceState_smrs_master state in om_serv_master"
	#	else
	#		G_PASS_FLAG=1
	#		log "ERROR:$FUNCNAME::NTP service is in $serviceState_smrs_master state in om_serv_master"
	#	fi
	#fi
	
	serviceState_nedss=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
	if [ $? -ne 0 ]
	then
		log "ERROR: Unableto connect to Nedss from om_serv_master"
	else
		if [ "$serviceState_nedss" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::NTP service is in $serviceState_nedss state in NEDSS "
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::NTP service is in $serviceState_nedss state in NEDSS"
		fi
	fi
	
	
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::checking NTP service is in disabled state in om_serv_master, and in Nedss"
   checkNtpService
 fi
 
 } 
 
 
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking ntp service state is in disabled state in om_serv_master, and Nedss
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC