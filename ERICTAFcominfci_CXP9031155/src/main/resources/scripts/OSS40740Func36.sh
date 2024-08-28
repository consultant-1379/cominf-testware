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


###################################
#Verify oss_master, om_serv_master , NEDSS are in time sync
#################################

function timeCheck ()
{
		
		OSS_time=`date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		SMRS_time=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		NEDSS_time=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		
		if [ $OSS_time == $SMRS_time -a $SMRS_time == $NEDSS_time ]
		then
			log "SUCCESS:$FUCNAME:: Verified: OSS_MASTER, om_serv_master, and NEDSS are in time sync"
			
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::OSS_MASTER, om_serv_master, and NEDSS are not in time sync"
			
		fi
		
}
function ntpCheck ()
{
	time=`date | awk -F' ' '{print $4}'`
	sec=`echo $time | awk -F':' '{print $3}'`
	min=`echo $time | awk -F':' '{print $2}'`
	if [ $sec -lt 50 -a $min -lt 58 ] ;
	then
		timeCheck
	elif [ $sec -ge 50 -a $min -lt 58 ] ;
	then
		l_cmd=`sleep 20`
		timeCheck
	elif [ $min -ge 58 ] ;
	then
		l_cmd=`sleep 120`
		timeCheck
	else 
		log "ERROR:$FUNCNAME::Error in checking time sync"
	fi
	
}

#####################################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::checking Time sync between OSS and omsrvm and NEDSS"
   ntpCheck
 fi
 
 } 
  
 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Verify om_serv_master, Nedss are in time sync
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC