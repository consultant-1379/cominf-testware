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
file5="/tmp/file3"
UNAME=/usr/bin/uname
HOST_VER=`$UNAME -r`

###################################
#check ntp service is in disabled state 
#################################

function prepareExpects ()
{
	EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsas svcs svc:/network/ntp:default |awk -F' ' '{print $1}' |grep -v STATE "
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
}



function checkNtpService ()
{
	serviceStateMaster=`svcs svc:/network/ntp:default |awk -F' ' '{print $1}' |grep -v STATE`
	if [ "$serviceStateMaster" == "disabled" ] ; then
		log "SUCCESS:$FUNCNAME::ntp service is in $serviceStateMaster state in om_serv_master"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ntp service is in $serviceStateMaster state in om_serv_master"
	fi
	
	serviceStateSlave=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvs svcs svc:/network/ntp:default |awk -F' ' '{print $1}' |grep -v STATE`
	if [ "$serviceStateSlave" == "disabled" ] ; then
		log "SUCCESS:$FUNCNAME::ntp service is in $serviceStateSlave state in om_serv_slave "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ntp service is in $serviceStateSlave state in om_serv_slave"
	fi
	
	prepareExpects 
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > $file5
	l_cmd=`grep disabled $file5`
	if [ $? == 0 ] ; then
		log "SUCCESS:$FUNCNAME::ntp service is in disabled state in omsas"
		rm $file5
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ntp service is not in disabled state in omsas"
		rm $file5
	fi
	
	
}

#############################
#Execute the action to be performed
####################################
function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
	if [ "${HOST_VER}" == "5.11" ]; then
		return 0
	else
		log "INFO:$FUNCNAME::checking ntp service state is in disabled state in om_serv_master,om_serv_slave,infra_omsas "
		checkNtpService
	fi
 fi
 
} 
 
 
 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking ntp service state is in disabled state in om_serv_master,om_serv_slave
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
