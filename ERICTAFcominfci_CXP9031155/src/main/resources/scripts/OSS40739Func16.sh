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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4691
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

NAMED=/var/named

function ipv6ZoneFileExistance ()
{
        log "INFO:Checking IPV6 parameter in /ericsson/config/omsrvm/omsrvm_jmp_cfg.txt"
                l_cmd=`cat /ericsson/config/omsrvm/omsrvm_jmp_cfg.txt | grep -w IPV6_PARAMETER | awk -F'=' '{ print $2 } '`
                l_cmd1=`ssh omsrvs cat /ericsson/config/omsrvs/omsrvs_jmp_cfg.txt | grep -w IPV6_PARAMETER | awk -F'=' '{ print $2 } '`
        if [[ "$l_cmd" = "YES" &&  "$l_cmd1" = "YES" ]]  ; then
                log "INFO:Checking the scritp /ericsson/ocs/bin/setup_dns.bsh is executed or not"
                        if [[ `ls -l /ericsson/ocs/log/setup_dns.bsh*` ]] ; then
                                log "INFO: Checking the IPV6 zone files existance"
                                if [[ `ls -l $NAMED/*ip6revzone` && `ssh omsrvs ls -l $NAMED/*ip6revzone`  ]] ; then
                                        log "INFO: IPV6 dns file  file exitson infra slave and master"
                                else
                                        G_PASS_FLAG=1
                                        log "ERROR: IPV6 dns file  file exits on infra slave and master"
                                fi
                        else
                                G_PASS_FLAG=1
                                log "ERROR: /ericsson/ocs/bin/setup_dns.bsh is not executed"
                        fi
        else
                G_PASS_FLAG=1
                log "ERROR: IPV6 is not configured in the server"
        fi
}



###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
   log "INFO: Testcase regarding the TR:HR36122"
   log "INFO:$FUNCNAME::Checking the IPV6 zone files existance"
   ipv6ZoneFileExistance
   log "INFO:Completed ACTION 1"
 fi

}
#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking the IPV6 zone files existance
executeAction 1


#Final assertion of TC, this should be the final step of tc
evaluateTC


