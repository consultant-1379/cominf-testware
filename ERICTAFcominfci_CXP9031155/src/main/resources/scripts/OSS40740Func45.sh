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
path="/ericsson/smrs/bin"
###################################
# To verify the functionality of update_ntp_conf.sh script
#################################

function AddNtpPeer()
{
	l_cmd=`cp /etc/inet/ntp.conf /etc/inet/ntp.conf_tmp_test1`
	l_cmd=`$path/update_ntp_conf.sh -s "$1 $2" -p "$3 $4" `
	if [ ` grep -c "server $1" /etc/inet/ntp.conf` -a `grep -c "server $2" /etc/inet/ntp.conf`  -a `grep -c "peer $3" /etc/inet/ntp.conf` -a `grep -c "peer $4" /etc/inet/ntp.conf` == 1 ] ;then
		log "SUCCESS:$FUCNAME::Added Multiple NTP servers $1 $2 and Multiple Peers $3 $4 to /etc/inet/ntp.conf file"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Failed to Add Multiple NTP servers $1 $2 and Multiple Peers $3 $4 to /etc/inet/ntp.conf file"
	fi
	l_cmd=`mv /etc/inet/ntp.conf_tmp_test1 /etc/inet/ntp.conf`
	l_cmd=`svcadm restart svc:/network/ntp4:default`
	
}

function InvalidIp()
{
	l_cmd=`cp /etc/inet/ntp.conf /etc/inet/ntp.conf_tmp_test2`
	l_cmd=`$path/update_ntp_conf.sh -s "$1" ` > /tmp/invalid.txt
	l_cmd=`grep "Invalid IP" /tmp/invalid.txt`
	if [ $? == 1 ] ;then
		log "SUCCESS:$FUCNAME::Invalid IP is not added to /etc/inet/ntp.conf file"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Invalid IP is  added to /etc/inet/ntp.conf file"
	fi
	rm /tmp/invalid.txt
	l_cmd=`mv /etc/inet/ntp.conf_tmp_test2 /etc/inet/ntp.conf`
	
}

function DuplicateIp ()
{
	l_cmd=`cp /etc/inet/ntp.conf /etc/inet/ntp.conf_tmp_test3`
	l_cmd=`$path/update_ntp_conf.sh -s "$1 $2" ` > /tmp/duplicate.txt
	l_cmd=`grep "duplicated" /tmp/duplicate.txt` 
	if [ $? == 1 ] ;then
		log "SUCCESS:$FUCNAME::Dupliacted NTP IPs are not added to /etc/inet/ntp.conf file"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Dupliacted NTP IPs are added to /etc/inet/ntp.conf file"
	fi
	rm /tmp/duplicate.txt
	l_cmd=`mv /etc/inet/ntp.conf_tmp_test3 /etc/inet/ntp.conf`
	
}

function DuplicatePeerIp ()
{
	l_cmd=`cp /etc/inet/ntp.conf /etc/inet/ntp.conf_tmp_test4`
	l_cmd=`$path/update_ntp_conf.sh -p "$1 $2" ` > /tmp/duplicatePeer.txt
	l_cmd=`grep "duplicated" /tmp/duplicatePeer.txt`
	if [  $? == 1 ] ;then
		log "SUCCESS:$FUCNAME::Dupliacted PEER IPs are not added to /etc/inet/ntp.conf file"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Dupliacted PEER IPs are added to /etc/inet/ntp.conf file"
	fi
	rm /tmp/duplicatePeer.txt
	l_cmd=`mv /etc/inet/ntp.conf_tmp_test4 /etc/inet/ntp.conf`
	
}

function DuplicateNtpPeerIp ()
{
	l_cmd=`cp /etc/inet/ntp.conf /etc/inet/ntp.conf_tmp_test5`
	l_cmd=`$path/update_ntp_conf.sh -p "$1 $2" ` > /tmp/duplicateNtpPeer.txt
	l_cmd=`grep -i "cannont be same as PEER" /tmp/duplicateNtpPeer.txt`
	if [  $? == 1  ] ;then
		log "SUCCESS:$FUCNAME::Verified:PEER IP and NTP IP can not be same"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Adding the Peer Ip and NTP Ip to /etc/inet/ntp.conf even if they are same"
	fi
	rm /tmp/duplicateNtpPeer.txt
	l_cmd=`mv /etc/inet/ntp.conf_tmp_test5 /etc/inet/ntp.conf`
	l_cmd=`svcadm restart svc:/network/ntp4:default`
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
	l_action=$1

	if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::Adding the Multiple NTP servers and MUltiple Peer servers to /etc/inet/ntp.conf file"
	AddNtpPeer "10.11.202.33" "10.11.202.44" "10.11.202.55" "10.11.202.66"
	fi
	
	if [ $l_action == 2 ]; then
	log "INFO:$FUNCNAME::Verifying the addition of Invalid Ip to /etc/inet/ntp.conf file"
	InvalidIp "10.45.1234."
	fi
	
	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::Verifying the Dupliacted NTP IPs are not added to /etc/inet/ntp.conf file"
	DuplicateIp "10.45.202.10" "10.45.202.10" 
	fi
	
	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::Verifying:Dupliacted PEER IPs are not added to /etc/inet/ntp.conf file"
	DuplicatePeerIp "10.45.202.10" "10.45.202.10" 
	fi
	
	if [ $l_action == 5 ]; then
	log "INFO:$FUNCNAME::Verifying:Addition of PEER IP and NTP IP can not be same"
	DuplicateNtpPeerIp "10.45.202.10" "10.45.202.10" 
	fi
}



#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Adding the Multiple NTP servers and MUltiple Peer servers to /etc/inet/ntp.conf file
#executeAction 1

#Verifying the addition of Invalid Ip to /etc/inet/ntp.conf file
#executeAction 2

#Verifying the Dupliacted NTP IPs are not added to /etc/inet/ntp.conf file
#executeAction 3

#Verifying:Dupliacted PEER IPs are not added to /etc/inet/ntp.conf file
#executeAction 4

#Verifying:Addition of PEER IP and NTP IP can not be same
#executeAction 5

#Final assertion of TC, this should be the final step of tc
evaluateTC
