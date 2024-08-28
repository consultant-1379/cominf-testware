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

OSVER=""
if [ `uname -r` = "5.10" ]; then
     OSVER="SOL10"
else
	 OSVER="SOL11"
fi

#source the commonFunctions.
source $G_COMLIB
G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
serverList=( ossmaster omsrvm omsrvs nedss omsas uas1 )

G_IPNODE_FILE=/etc/inet/ipnodes
G_EXT_IPV6="2001:1b70:82a1:0103::5"

###################################
#This fucntion will delete all the aif
#users avaliable in system.
#################################
function getConfig (){
 log "INFO:$FUNCNAME::Getting Config Details"
CONFIG=`grep config  /ericsson/config/ericsson_use_config| awk -F= '{print $2}'`
}

function checkPing() {

if [ $CONFIG != "system" ]; then 
G_EXT_IPV6="2001:1b70:82a1:0103::5"
else
G_EXT_IPV6="2001:1b70:82a1:103::4"
fi

l_cmd=`ping -A inet6 $G_EXT_IPV6`
 ret=$?
    if [ $ret == 0 ]; then
          log "SUCCESS:$FUNCNAME::Ping to External IPV6 is OK  from $CONFIG"
    else
		  G_PASS_FLAG=1
		  log "ERROR:$FUNCNAME::Ping to External IPV6 is NOK  from $CONFIG"
    fi
 
}
function prepareExpects ()
{
	   EXPCMD="sftp $1@nedss"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	   echo 'Password
shroot12
sftp
exit' > $INPUTEXP
}

function checkIpnode () {
 getConfig
if [ $CONFIG == "om_serv_master" ]; then

    log "INFO:$FUNCNAME::Checking IPV6 in /etc/inet/ipnodes on $CONFIG"
#Sol11
    ipv6Addr=""
    ipv6Addr=`grep ${serverList[1]} /etc/inet/ipnodes | grep : | awk '{ print $1}'`
    ret=$?
    if [[ $ret == 0 && $ipv6Addr != "" ]]; then
          log "SUCCESS:$FUNCNAME::IPV6 in /etc/inet/ipnodes  on $CONFIG"
    else
		  G_PASS_FLAG=1
		  log "ERROR:$FUNCNAME::IPV6 is not exisiting in /etc/inet/ipnodes on $CONFIG "
    fi
	
  log "INFO:$FUNCNAME::Checking IPV4 in /etc/inet/ipnodes on $CONFIG"
   ipv4Addr=""
   ipv4Addr=`grep ${serverList[1]} /etc/inet/ipnodes | grep -v : | awk '{ print $1}'`
   ret=$?
    if [[ $ret == 0 && ipv4Addr != "" ]]; then
          log "SUCCESS:$FUNCNAME::IPV4 in /etc/inet/ipnodes  on $CONFIG"
    else
		  G_PASS_FLAG=1
		  log "ERROR:$FUNCNAME::IPV4 is not exisiting in /etc/inet/ipnodes on $CONFIG "
    fi 
#Sol11	
fi

}

function checkRoute () {
l_cmd=`netstat -rn | grep IPv6`
  ret=$?
    if [ $ret == 0 ]; then
          log "SUCCESS:$FUNCNAME::IPV6 route information is avaliable on $CONFING"
    else
		  G_PASS_FLAG=1
		  log "ERROR:$FUNCNAME::IPV6 route information is NOT avaliable on $CONFING"
    fi

}



###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
 l_action=$1
 if [ $l_action == 1 ]; then 
  log "INFO:$FUNCNAME::Started Checking /etc/inet/ipnodes"
  checkIpnode
 fi 
 
  if [ $l_action == 2 ]; then 
  log "INFO:$FUNCNAME::Started Checking External IPV6 PING"
  checkPing
 fi 
 
   if [ $l_action == 3 ]; then 
  log "INFO:$FUNCNAME::Started CheckingIPv6 routing is configured"
  checkRoute
 fi 
 
 
  
}
#########
##MAIN ##
#########
if [ $OSVER == "SOL10" ] ; then
     
	#IPv6 Solaris OS Configuration Check ipnodes
	executeAction 1

	#IPv6 Solaris OS Configuration Check Ping
	executeAction 2

	#IPv6 Solaris OS Configuration Check Ping
	executeAction 3

	#Final assertion of TC, this should be the final step of tc
	evaluateTC

else

	#Final assertion of TC, this should be the final step of tc
	evaluateTC

fi

