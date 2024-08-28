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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/
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

function dhcpDetails () {

CONFIG_FILE=/ericsson/config/config.ini
DHCP_CHECK=/ericsson/ocs/bin/dhcp_check.sh
LOG_DIR=/ericsson/ocs/log

	if [ -f $CONFIG_FILE ] ; then

        l_cmd=`grep DHCP_CONF $CONFIG_FILE | awk -F'=' '{print $2}'`

            if [ $l_cmd == "yes" ] ; then

#Sol11
		dhcpproc=`ps -eaf | grep dhcpserv | head -1`
		ret=$?
		 if [ $ret == 0 ] ; then
		   DHCP_SVC=`svcs | grep dhcp | awk '{print $3}'`
			if [ "$DHCP_SVC" != "" ] ; then
                        	svcadm disable $DHCP_SVC
                        	log "INFO::DHCP service Disabled "
			else
				log "INFO::No DHCP Service Identified"
			fi
		 fi
	    fi
#Sol11
	else

        log "INFO:: No $CONFIG_FILE file present"

	fi

	sleep 50

        l_cmd1=`crontab -l | grep /ericsson/ocs/bin/dhcp_check.sh`
        ret=$?
        if [ $ret == 0 ] ; then
                log "INFO::$FUNCNAME: cron entry exits for $DHCP_CHECK"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNCNAME: No cron entry for $DHCP_CHECK"
        fi

}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 15 ]; then
                log "INFO:$FUNCNAME::verifying the DHCP Serivce on OMSERV Master"
                dhcpDetails
        fi
}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#To stop the DHCP serivce
log "ACTION 15 Started"
executeAction 15
log "ACTION 15 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC


