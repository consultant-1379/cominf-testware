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
script="/ericsson/ocs/bin/ai_manager.sh"

###################################
#This Function is used to create,delete nets,clients as root user
#################################

function preCon () {
	l_cmd=`$script -init > /dev/null`
    l_cmd1=`ls /usr/local/etc/dhcpd.conf  > file2`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::DHCP server is configured "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in configuring DHCP server output is $l_cmd"
	fi
	
}

	

function precon2 () {
	
	l_cmd=`$script -list nets |grep $1`
	if [ $? == 0 ]; then
	l_cmd=`$script -delete net -a $1 -q`
	fi
}

function precon3 () {

	l_cmd=`$script -list hosts |grep $1`
	if [ $? == 0 ]; then
	l_cmd=`$script -delete client -i $1 -q`
	fi
}
	            

function AddNet () {

 	i=0
	while [ $i -le 30 ]; do
             IP4_STAT=`svcs -H -o STATE svc:/network/dhcp/server:ipv4`
             if [ $IP4_STAT != "online" ] ; then
                sleep 10
                continue;
             else
                break;
             fi
	     i=`expr $i + 1`
        done
	
	l_cmd=`$script -add net -a $1 -m 255.255.255.0 -r $2 -d athtem.eei.ericsson.se  -n "159.107.163.3,10.42.33.198" -q`
	test=$?
	if [ $test == 0 ]; then
		log "SUCCESS:$FUNCNAME::network $1 added successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to add network $1 output is $l_cmd"
	fi
}

function listNet () {
	l_cmd=`$script -list nets |grep $1`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified network $1 in the network list successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::network $1 is not updated in the network list output is $l_cmd"
	fi
}

function deleteNet () {
	l_cmd=`$script -delete net -a $1 -q`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME:: network $1 deleted successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::network $1 is not deleted output is $l_cmd"
	fi
}

function deleteNetwithClient () {
	l_cmd=` $script -delete net -a $1 -q`
	echo 'All clients on the current network will no longer be supported. Remove all clients on this network using ai_manager.sh -delete. Continue
y '  > $$INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified:message is displayed as :All clients on the current network will no longer be supported. Remove all clients on this network using ai_manager.sh -delete."
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::network $1 is not deleted output is $l_cmd"
	fi
}

function addClient () {
	l_cmd=`$script -add client -a $1 -h $2 -i $3 -s  10.11.12.13 -p /var/tmp/ -q`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME:: client $3 : $1  added successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to add client $3 : $1 output is $l_cmd"
	fi
}

function deleteClient () {

	l_cmd=`$script -delete client -i $1 -q`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME:: client  $1  deleted successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to delete client $1 output is $l_cmd"
	fi
}

function checkingClient () {
	
	l_cmd=`grep $1 /ericsson/ocs/etc/aif_hosts`
	if [ $? != 0 ]; then
		log "SUCCESS:$FUNCNAME:: client  $1  removed successfully from /ericsson/ocs/etc/aif_hosts"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to delete client  $1 from /ericsson/ocs/etc/aif_hosts output is $l_cmd "
	fi
}

function checkdeletenetwork () {

	l_cmd=`$script -list nets |grep $1`
	if [ ${PIPESTATUS[0]} != 0 ]; then
		log "SUCCESS:$FUNCNAME::verified network $1 is removed the network list "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::network $1 is not removed in the network list output is $l_cmd"
	fi
}	
	
function deleteNonExistingNet () {
	l_cmd=`$script -delete net -a $1 -q | tee -a /tmp/file1`
	if [ ${PIPESTATUS[0]} != 0 ]; then
		l_cmd=`cat /tmp/file1`
		log "SUCCESS:$FUNCNAME:: verified mesaage network $1 does not exist  "
		rm /tmp/file1
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::non-existing network $1 is  deleted output is $l_cmd "
	fi
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 0 ]; then
   log "INFO:$FUNCNAME::Executing preconditions"
   preCon
   precon2 "12.12.12.0"
   precon2 "13.13.13.0"
   precon2 "14.14.14.0"
   precon3 "client1"
   precon3 "client2"
   log "INFO:$FUNCNAME::Executed preconditions"
 fi
 
 
 if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::Adding networks"
   AddNet "12.12.12.0" "12.12.12.1"
   AddNet "13.13.13.0" "13.13.13.1"
   
 fi
 
 if [ $l_action == 2 ]; then
   log "INFO:$FUNCNAME:: verifing network in the network list"
   listNet "12.12.12.0"
   listNet "13.13.13.0"
 fi

 if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME:: adding clients to the network"
	addClient "12.12.12.3" "hostname1" "client1"
	addClient "12.12.12.4" "hostname2" "client2"
	
 fi

  if [ $l_action == 4 ]; then
   log "INFO:$FUNCNAME::deleting network with client"
   deleteNet "12.12.12.0"
 fi
 
 
 if [ $l_action == 5 ]; then
   log "INFO:$FUNCNAME::deleting clients"
   deleteClient "client1"
   deleteClient "client2" 
 fi
 
 if [ $l_action == 6 ]; then
   log "INFO:$FUNCNAME::checking the removal of client"
   checkingClient "client1"
   checkingClient "client2" 
  fi
  
 if [ $l_action == 7 ]; then
   log "INFO:$FUNCNAME::deleting network without client"
   deleteNet "13.13.13.0"
 fi
 
  if [ $l_action == 8 ]; then
   log "INFO:$FUNCNAME::checking the deleted network in the network list"
   checkdeletenetwork "12.12.12.0"
   checkdeletenetwork "13.13.13.0"
 fi
 
 if [ $l_action == 9 ]; then
   log "INFO:$FUNCNAME::deleting the non-existing network"
   deleteNonExistingNet "14.14.14.0"
 fi
 }
 
 #########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions
# starting the DHCP service
#Sol11
#l_cmd=`/etc/rc2.d/S96dhcpd start`
#DHCP_SVC=`svcs | grep dhcp | awk '{ print $3 }'`
DHCP_SVC=`svcs -H -o STATE svc:/network/dhcp/server:ipv4`
if [ $DHCP_SVC == "disabled" ] ; then
	DHCP_SVC="svc:/network/dhcp/server:ipv4"
	svcadm enable $DHCP_SVC
fi
#Sol11

#main Logic should be in executeActions subroutine with numbers in order.

#Adding networks
executeAction 1

#verifing network in the network list
executeAction 2

#adding clients to the network
executeAction 3

#deleting network with client
executeAction 4

#deleting client
executeAction 5

#checking the removal of client
executeAction 6

#deleting network without client
executeAction 7

#checking the deleted network in the network list
executeAction 8

#deleting the non-existing network
executeAction 9

#Final assertion of TC, this should be the final step of tc
evaluateTC

