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
file3="/tmp/file1"
###################################
#check ntp4 service is online
#################################

function prepareExpects ()
{
	EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm date"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
}


function checkNtpv4Service ()
{
	serviceStateMaster=`svcs svc:/network/ntp4:default |awk -F' ' '{print $1}' |grep -v STATE`
	if [ "$serviceStateMaster" == "online" ] ; then
		log "SUCCESS:$FUNCNAME::ntp4 service is in online state in uas after upgrade"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ntp4 service is in $serviceStateMaster state in uas after upgrade"
	fi
}

function checkNtpService ()
{
	serviceStateMaster=`svcs svc:/network/ntp:default |awk -F' ' '{print $1}' |grep -v STATE`
	if [ "$serviceStateMaster" == "disabled" ] ; then
		log "SUCCESS:$FUNCNAME::ntp service is in $serviceStateMaster state in uas after upgrade"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ntp service is in $serviceStateMaster state in uas after upgrade"
	fi
}
function timeCheck ()
{
		
		time1=`date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		prepareExpects
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP > $file3
		time2=`tail -1 $file3 | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		if [ $time1 == $time2 ] ;then
			log "SUCCESS:$FUCNAME:: Verified:om_serv_master and UAS are in time sync after upgrade"
			rm $file3 
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::om_serv_master and UAS are not in time sync after upgrade"
			rm $file3 
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
##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

	if [ $l_action == 1 ]; then
		log "INFO:$FUNCNAME::checking ntp4 service state in uas after upgrade"
		checkNtpv4Service
	fi
	
	if [ $l_action == 2 ]; then
		log "INFO:$FUNCNAME::checking ntp service state is in disabled state in uas after upgrade"
		checkNtpService
	fi
	

	if [ $l_action == 3 ]; then
		log "INFO:$FUNCNAME::checking Time sync after upgrade"
		ntpCheck
	fi
 
 } 
  
 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking ntp4 service state in uas
#executeAction 1

#checking ntp service state is in disabled state in uas
#executeAction 2


#Verify om_serv_master and UAS are in time sync
#executeAction 3

#Final assertion of TC, this should be the final step of tc
evaluateTC
