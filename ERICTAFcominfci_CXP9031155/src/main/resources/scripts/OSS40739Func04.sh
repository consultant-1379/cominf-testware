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
#This Function is used to create,delete nets,clients as bsim user
#################################

function preCon () {
	l_cmd=`$script -init > /dev/null`

#Sol11
    #l_cmd=`ls /usr/local/etc/dhcpd.conf  > file2`
    l_cmd=`ls /etc/inet/dhcpd4.conf  > file2`
#Sol11
	
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::DHCP server is configured "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in configuring DHCP server"
	fi
	
}

function createBsim () {

	l_cmd=`grep bsim  /etc/passwd /etc/user_attr`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::bsim user already exists:SKIPPING "
	else
		EXPCMD="/ericsson/ocs/bin/create_bsim.sh"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'New Password
shroot12
Re-enter new Password
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::bsim user is created  "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in creating bsim user"
	fi
fi
}

function checkBsim () {

	l_cmd=`grep bsim  /etc/passwd /etc/user_attr `
	if [ $? == 0 ]; then
		
		log "SUCCESS:$FUNCNAME::verified the contents of /etc/passwd /etc/user_attr for bsim user details  "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error:contents of /etc/passwd /etc/user_attr are not properly updated with bsim user details"
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
	
	l_cmd=`su - bsim -c "$script -add net -a $1 -m 255.255.255.0 -r $2 -d athtem.eei.ericsson.se  -n "159.107.163.3,10.42.33.198" -q"`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::network $1 added successfully "
		
	else
		
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to add network $1"
		
	fi

}

function listNet () {
	l_cmd=`su - bsim -c "$script -list nets |grep $1"`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified network $1 in the network list successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::network $1 is not updated in the network list "
	fi
}

function deleteNet () {
	l_cmd=`$script -delete net -a $1 -q`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME:: network $1 deleted successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::network $1 is not deleted "
	fi
}


function addClient () {
	l_cmd=`su - bsim -c "$script -add client -a $1 -h $2 -i $3 -s  10.11.12.13 -p /var/tmp/ -q"`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME:: client $3 : $1  added successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to add client $3 : $1 "
	fi
}

function deleteClient () {

	l_cmd=`su - bsim -c "$script -delete client -i $1 -q"`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME:: client  $1  deleted successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to delete client $1 "
	fi
}

function addLteClient () {
	l_cmd=`su - bsim -c "$script -add lte_client -a $1 -h $2 -i $3 -s 15.14.13.12 -p /var/tmp/ -t "159.104.172.13,134.156.175.12" -u 32546783 -q"`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME:: lte client  $1:$3  added successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to add lteclient $1:$3 "
	fi
}
	
function listClients () {
	l_cmd=`su - bsim -c "$script -list hosts |grep $1"`
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::verified client $1 in the client list successfully "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::client $1 is not updated in the client list "
	fi

}
function checkingClient () {
	
	l_cmd=`su - bsim -c "grep $1 /ericsson/ocs/etc/aif_hosts"`
	if [ $? != 0 ]; then
		log "SUCCESS:$FUNCNAME:: client  $1  removed successfully from /ericsson/ocs/etc/aif_hosts"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::failed to delete client  $1 from /ericsson/ocs/etc/aif_hosts "
	fi
}

function checkdeletenetwork () {

	l_cmd=`su - bsim -c "$script -list nets |grep $1"`
	if [ $? != 0 ]; then
		log "SUCCESS:$FUNCNAME::verified network $1 is removed the network list "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::network $1 is not removed in the network list "
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
   precon2 "15.15.15.0"
   precon3 "cli_1"
   precon3 "lte1"
   log "INFO:$FUNCNAME::Executed preconditions"
 fi
 
if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::creating bsim user"
   createBsim
 fi
 
if [ $l_action == 2 ]; then
   log "INFO:$FUNCNAME::checking the contents of  /etc/passwd and /etc/user_attr files for bsim user"
   checkBsim
   
fi

if [ $l_action == 3 ]; then
   log "INFO:$FUNCNAME::adding network  as BSIM user "
   AddNet "15.15.15.0" "15.15.15.1"
   
fi 

if [ $l_action == 4 ]; then
   log "INFO:$FUNCNAME::adding client  as BSIM user "
   addClient "15.15.15.3" "hostname3" "cli_1"
   
fi 

if [ $l_action == 5 ]; then
   log "INFO:$FUNCNAME::adding lteclient  as BSIM user "
   addLteClient "15.15.15.7" "host123" "lte1"
   
fi 

if [ $l_action == 6 ]; then
   log "INFO:$FUNCNAME::listing net  as BSIM user "
   listNet  "15.15.15.0"
fi 

if [ $l_action == 7 ]; then
   log "INFO:$FUNCNAME::listing clients  as BSIM user "
   listClients "cli_1" 
   listClients "lte1"
fi 

if [ $l_action == 8 ]; then
   log "INFO:$FUNCNAME::deleting clients  as BSIM user "
   deleteClient "cli_1" 
   deleteClient "lte1"
fi 

if [ $l_action == 9 ]; then
   log "INFO:$FUNCNAME::deleting network "
   deleteNet "15.15.15.0"
fi

if [ $l_action == 10 ]; then
   log "INFO:$FUNCNAME::checking the deleted client"
   checkingClient "cli_1"
   checkingClient "lte1"
fi

if [ $l_action == 11 ]; then
   log "INFO:$FUNCNAME::checking the deleted network as BSIM user"
   checkdeletenetwork  "15.15.15.0"
fi
 }
 #########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Executing preConditions
executeAction 0

#creating bsim user
executeAction 1

#checking the contents of  /etc/passwd and /etc/user_attr files for bsim user
executeAction 2

#adding network  as BSIM user 
executeAction 3

#adding client as BSIM user
executeAction  4


#adding lte client as BSIM user
executeAction 5

#listing nets as BSIM user
executeAction 6

#listing clients as BSIM user
executeAction 7

#deleting clients as BSIM user
executeAction 8

#deleting network
executeAction 9

#checking the deleted clients in the list as BSIM user
executeAction 10

#checking the deleted network as BSIM user
executeAction 11



#Final assertion of TC, this should be the final step of tc
evaluateTC
