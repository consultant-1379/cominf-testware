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
UNAME=/usr/bin/uname
HOST_VER=`$UNAME -r`

###################################
#check ntp4 service is online
#################################

function prepareExpects ()

{
	EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsas svcs svc:/network/ntp4:default |awk -F' ' '{print $1}' |grep -v STATE "
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
}



function checkNtpv4Service ()
{
#Sol11
	#serviceStateMaster=`svcs svc:/network/ntp4:default |awk -F' ' '{print $1}' |grep -v STATE`
	serviceStateMaster=`svcs svc:/network/ntp:default |awk -F' ' '{print $1}' |grep -v STATE`
#Sol11
	if [ "$serviceStateMaster" == "online" ] ; then
		log "SUCCESS:$FUNCNAME::${NTP_SERVICE} service is in online state in om_serv_master"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::${NTP_SERVICE} service is in $serviceStateMaster state in om_serv_master"
	fi
	
	serviceStateSlave=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvs svcs ${NTP_SERVICE} |awk -F' ' '{print $1}' |grep -v STATE`
	if [ "$serviceStateSlave" == "online" ] ; then
		log "SUCCESS:$FUNCNAME::${NTP_SERVICE} service is in online state in om_serv_slave "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::${NTP_SERVICE} service is in $serviceStateSlave state in om_serv_slave"
	fi
	
	prepareExpects 
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > $file3
	l_cmd=`grep online $file3`
	if [ $? == 0 ] ; then
		log "SUCCESS:$FUNCNAME::${NTP_SERVICE} service is in online state in omsas"
		rm $file3
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::${NTP_SERVICE} service is not in online state in omsas"
		rm $file3
	fi
	
	
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
	if [ "${HOST_VER}" == "5.11" ]; then
		NTP_SERVICE="svc:/network/ntp:default"
	else
		NTP_SERVICE="svc:/network/ntp4:default"
	fi
	log "INFO:$FUNCNAME::checking ntp4 service state in om_serv_master,om_serv_slave and in infra_omsas"
	checkNtpv4Service
 fi
 
 } 
 
 
 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking ntp4 service state in om_serv_master,om_serv_slave,infra_omsas 
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
