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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4692
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

function cdbHostnamesExistance ()
{
        
   log "INFO:Checking the scritp /ericsson/ocs/bin/setup_dns.bsh is executed or not"
           if [[ `ls -l /ericsson/ocs/log/setup_dns.bsh*` ]] ; then
                log "INFO:Checking CDP hostnames in DNS DB."
					l_cmd=`/usr/xpg4/bin/grep -e cdp1.cdps.vts.com -e cdp2.cdps.vts.com $NAMED/vts.com.ip4zone`
					ret=$?
					if [[ $ret == 0 ]] ; then
						log "INFO:CDP hostnames are presentin DNS DB"
					else
						G_PASS_FLAG=1
						log "ERROR:CDP hostnames are not present in DNS DB"
					fi
           else
                   G_PASS_FLAG=1
                   log "ERROR: /ericsson/ocs/bin/setup_dns.bsh is not executed"
           fi
}



###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
   log "INFO: Testcase regarding the TR:HR36135"
   log "INFO:$FUNCNAME::Checking CDP hostnames in DNS DB."
   cdbHostnamesExistance
   log "INFO:Completed ACTION 1"
 fi

}
#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking CDP hostnames in DNS DB.  

executeAction 1


#Final assertion of TC, this should be the final step of tc
evaluateTC


