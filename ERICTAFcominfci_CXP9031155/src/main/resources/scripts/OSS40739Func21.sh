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


verify()
{
l_search=`svcs -a | grep ntp4:default | awk '{print $1}'`

if [[ "$l_search" != "online" ]]
then
	l_search=`ls /etc/inet/ | grep ntp.conf_bkp`
	if [[ ! -z "$l_search" ]]
	then 
		log "SUCCESS:$FUNCNAME:: TR HT82931 functionality is working."
	else
		log "ERROR:$FUNCNAME:: /etc/inet/ntp.conf_bkp is not present"
		G_PASS_FLAG=1
	fi
else
	log "INFO: checking of /etc/inet/ntp.conf_bkp is skipped as ntp4 service is online"
fi
}

###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1
log "Checkinf the existence of /etc/inet/ntp.conf_bkp"
if [ $l_action == "1" ]; then
	verify
fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.
executeAction 1


#Final assertion of TC, this should be the final step of tc
evaluateTC
