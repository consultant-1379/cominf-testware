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
exit 0
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
file4="/tmp/file2"

###################################
#checking /etc/inet/ntp.conf file is updated with NTP_IP in /ericsson/config/config.ini in om_serv_master,om_serv_slave,infra_omsas and in uas
#################################

function prepareExpects ()

{
	EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsas grep NTP /ericsson/config/config.ini | awk -F'=' '{print $2}'"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
}

function prepareExpects1 ()

{
	EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsas cat /etc/inet/ntp.conf"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
}



function checkNtpIp ()
{
	NtpIp=`grep NTP /ericsson/config/config.ini | awk -F'=' '{print $2}'`
	l_cmd=`grep $NtpIp /etc/inet/ntp.conf`
	if [ $? == 0 ] ; then
		log "SUCCESS:$FUNCNAME::/etc/inet/ntp.conf file is updated with NTP_IP in /ericsson/config/config.ini in om_serv_master"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::NTP_IP's in /etc/inet/ntp.conf file and /ericsson/config/config.ini file are different in om_serv_master"
	fi
	
	NtpIp2=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvs grep NTP /ericsson/config/config.ini | awk -F'=' '{print $2}'`
	l_cmd=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvs cat /etc/inet/ntp.conf |grep $NtpIp2`
	if [ $? == 0 ] ; then
		log "SUCCESS:$FUNCNAME::/etc/inet/ntp.conf file is updated with NTP_IP in /ericsson/config/config.ini in om_serv_slave"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::NTP_IP's in /etc/inet/ntp.conf file and /ericsson/config/config.ini file are different in om_serv_slave"
	fi
	
	prepareExpects
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > $file3
	ntpIp=`grep NTP $file3 | awk -F'=' '{print $2}'`
	prepareExpects1
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > $file4
	ipcheck=`grep $ntpIp $file4`
	if [ $? == 0 ] ; then
		log "SUCCESS:$FUNCNAME::/etc/inet/ntp.conf file is updated with NTP_IP in /ericsson/config/config.ini in omsas"
		rm $file3 $file4
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::NTP_IP's in /etc/inet/ntp.conf file and /ericsson/config/config.ini file are different in omsas"
		rm $file3 $file4
	fi

	
	
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::checking /etc/inet/ntp.conf file is updated with NTP_IP in /ericsson/config/config.ini in om_serv_master,om_serv_slave,infra_omsas"
   checkNtpIp
 fi
 
 } 
 
 
 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking /etc/inet/ntp.conf file is updated with NTP_IP in /ericsson/config/config.ini in om_serv_master,om_serv_slave
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
