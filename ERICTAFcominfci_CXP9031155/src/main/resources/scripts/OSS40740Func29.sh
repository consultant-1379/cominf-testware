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

function createAifUsers_chusr () {

	     
        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -n WRAN -a chusr -p eric@1234`
	ret=$?
	getSMRSLogs "add_aif.sh"
        if [ $ret == 3 ]; then
        	log "SUCCESS::TR HR56479 verified AIF chusr cannot be added. Please refer to $ERIC_LOG"
        else
                G_PASS_FLAG=1
                log "ERROR: TR HR56479 fix failed .AIF chusr is added without any error. Please refer to $ERIC_LOG"
        fi
				
				
}
###############################
#Execute the action to be performed
#####################################
executeAction ()
{
log "INFO:Configuring aif user chusr "
    createAifUsers_chusr
}
#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#TR HR56479 
log "HR56479 verification Started"
executeAction 
log "HR56479 verification Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC

