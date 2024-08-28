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
G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
source $G_COMLIB
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
          mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
SCRIPT="/ericsson/sdee/bin/manage_COM.bsh -s role"

#source $G_COMLIB

function check ()
{
               `/ericsson/sdee/bin/manage_COM.bsh -s role > /tmp/file1`
                b=`grep doesnt /tmp/file1 | echo $?`
                if [  $b == 0 ]; then
                        log "SUCCESS:$FUCNAME:TestCase sucess"
                else
                        log "FAILED:$FUCNAME:TestCase failed"
                        G_PASS_FLAG=1
                fi

}
###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 1 ]; then
                log "INFO:$FUNCNAME::Executing the script and checking the scenario on VAPP"
                check
        fi

}
#########
##MAIN ##
#########
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Verifying:Error for passed bulk file is empty or not
executeAction 1
