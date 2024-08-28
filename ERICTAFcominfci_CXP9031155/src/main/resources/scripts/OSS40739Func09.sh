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
#Verify om_serv_master ,om_serv_slave,infra_omsas and UAS are in time sync
#################################
function prepareExpects ()
{
	EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsas date"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
}


function timeCheck ()
{
		
		time1=`date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		time2=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvs date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		prepareExpects
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP > $file3
		time3=`tail -1 $file3 | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		
		if [ $time1 == $time2 -a $time1 == $time3 ] ;then
			log "SUCCESS:$FUCNAME:: Verified:om_serv_master ,om_serv_slave,infra_omsas are in time sync"
			rm $file3 
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::om_serv_master ,om_serv_slave,infra_omsas are not in time sync"
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
   log "INFO:$FUNCNAME::checking Time sync"
   ntpCheck
 fi
 
 } 
  
 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Verify om_serv_master ,om_serv_slave are in time sync
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC