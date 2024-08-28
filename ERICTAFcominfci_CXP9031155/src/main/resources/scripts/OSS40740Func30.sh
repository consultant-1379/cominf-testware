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
# This function is to create inputs
# for expect function. Add the expect string
# and send string  in sequence.

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
l_action=$1
        if [ $l_action == "1" ]; then
		log "Checking the smrs_AIServices smf service status on smrs_master."
                status=`svcs -H svc:/ericsson/smrs/smrs_AIServices:default | awk '{ print $1 }'`
                if [ $status == "online" ]; then
                        log "SUCESS::smrs_AIServices smf service is online on smrs_master"
                else
                        G_PASS_FLAG=1
                        log "ERROR::smrs_AIServices smf service is not online on smrs_master $status"
                fi
        fi
		if [ $l_action == "2" ]; then	
  
			log "Checking the smrs_slave_AIServices smf service status on nedss"
			ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' nedss "echo" > /dev/null 2>&1
			PASSWORDLESS_CONNECTION=$?
			[ $PASSWORDLESS_CONNECTION != 0 ] && {
                                                log "ERROR :- Passwordless connection doesnot exist between SMRS and Nedss"
                                                G_PASS_FLAG=1
                                         }
			[ $PASSWORDLESS_CONNECTION == 0 ] && {

			status1=`ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' nedss svcs -H svc:/ericsson/smrs/smrs_slave_AIServices:default | awk '{ print $1 }'`

			if [ $status1 == "online" ]; then
                log "SUCESS::smrs_slave_AIServices smf service is online on nedss"
			else
                 G_PASS_FLAG=1
                log "ERROR::smrs_slave_AIServices smf service is not online on smrs_master $status1"
			fi
			}
		fi
}



#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#Checking the smrs_AIServices smf service status on smrs_master.
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"
#Checking the smrs_slave_AIServices smf service status on nedss.

slave1=`cat /ericsson/smrs/etc/smrs_config | grep SMRS_SLAVE_SERVICE_NAME | cut -d'=' -f2 | head -1`
slave2=`cat /ericsson/smrs/etc/smrs_config | grep SMRS_SLAVE_SERVICE_NAME | cut -d'=' -f2 |tail -1`

if [[ "$slave1" == "nedssv4" || "$slave1" == "nedssv6" ]] && [[ "$slave2" == "nedssv4" || "$slave2" == "nedssv6" ]]; then

	log "ACTION 2 started"
	executeAction 2
	log "ACTION 2 completed"
	
else

	log "Slaveservice is not attached to nedss"
	G_PASS_FLAG=1
fi

#Final assertion of TC, this should be the final step of tc
evaluateTC

