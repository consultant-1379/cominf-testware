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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/8293
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
OCS_DIR=/ericsson/ocs/bin


function code_check()
{
 `cp /ericsson/ocs/etc/ssopam/pam.conf.updated /etc/pam.conf`
 l_cmd=`egrep -i 'auth sufficient         libpam_eric_sso.so' /etc/pam.conf`
 l_string="#other   auth sufficient         libpam_eric_sso.so cntfile=/var/tmp/counter keyfile=/var/tmp/masterkey"
        if [ "$l_cmd" == "$l_string" ] ; then
                log "INFO::HT83333 code fix is avaialble"
        else
                G_PASS_FLAG=1
                log "ERROR::HT83333 code fix is not avaialble"
        fi
}
###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME:: Checking whether TR HT83333 code fix is available or not"
   code_check
   log "INFO:Completed ACTION 1"
 fi

 }


#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

# Checking the usage and ERROR message if -d option is not given
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
