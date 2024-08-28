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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/5850

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

function checkDependencySmrs ()
{
l_cmd=`svcs -d svc:/ericsson/smrs/smrs_AIServices:default | grep svc:/network/service:default`
if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: smrs_AIService has dependency on svc:/network/service:default on smrs_master"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: smrs_AIService do not have dependency on svc:/network/service:default on smrs_master"
	fi
}	
	
function checkDependencyNedss ()
{

l_cmd=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss svcs -d svc:/ericsson/smrs/smrs_slave_AIServices:default | grep svc:/network/service:default`
if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: smrs_slave_AIService has dependency on svc:/network/service:default on Nedss"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: smrs_slave_AIService do not have dependency on svc:/network/service:default on Nedss"
	fi
	}

###############################
#Execute the action to be performed
#####################################
executeAction()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO:Checking dependency of smrs_AIService on smrs_master"
     checkDependencySmrs
fi

if [ $l_action == "2" ]; then
	log "INFO:Checking dependency of smrs_slave_AIService services on nedss"	
	checkDependencyNedss
	fi

}
#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.
#Checking dependency of smrs_AIService service on smrs_master
executeAction 1

#Checking dependency of smrs_slave_AIService services on nedss
executeAction 2


#Final assertion of TC, this should be the final step of tc
evaluateTC
