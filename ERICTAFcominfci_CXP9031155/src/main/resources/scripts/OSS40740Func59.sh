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

#######################################################################
#check passwordless connection exists between ossmaster->omsrvm->nedss
########################################################################

function passwordless_conn_check ()
{

#Checking from ossmaster to smrs_master
ssh smrs_master 'exit 0' 2> /dev/null

if [ $? -eq 0 ]; then
    log "SUCCESS:$FUNCNAME::Passwordless connection exists between ossmaster and smrs_master."
else
    log "ERROR:$FUNCNAME::No passwordless connection between ossmaster and smrs_master."
    G_PASS_FLAG=1
fi

#Checking from smrs_master to smrs_slave
ssh smrs_master 'ssh nedss 'exit 0'' 2> /dev/null 

if [ $? -eq 0 ]; then
    log "SUCCESS:$FUNCNAME::Passwordless connection exists between smrs_master and smrs_slave."
else
    log "ERROR:$FUNCNAME::No passwordless connection between smrs_master and smrs_slave."
    G_PASS_FLAG=1
fi

}

#####################################
#Execute the action to be performed
#####################################
function executeAction ()
{
l_action=$1

if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::checking java version in omsrvm and nedss."
	passwordless_conn_check
fi
} 
 
 
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking whether java 1.7.0 is updated in omsrvm, omsrvs and nedss
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
