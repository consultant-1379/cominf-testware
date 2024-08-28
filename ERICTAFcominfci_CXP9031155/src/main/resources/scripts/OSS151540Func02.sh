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


#################################
#Check services are online
#################################

function get_server_type() {
        SERVER_CONFIG_TYPE_FILE=/ericsson/config/ericsson_use_config

        # Check server config type file exists
        if [ ! -f "$SERVER_CONFIG_TYPE_FILE" ]; then
                log "ERROR: Failed to locate $SERVER_CONFIG_TYPE_FILE\n"
                G_PASS_FLAG=1
        fi

        G_SERV_TYPE=`grep "config" $SERVER_CONFIG_TYPE_FILE | awk -F= '{print $2}'` 2>/dev/null

        if [[ -z $G_SERV_TYPE ]] ;then
          G_PASS_FLAG=1
        fi
}

function checkNtpService ()
{
	serviceState=`svcs svc:/network/ntp:default |awk -F' ' '{print $1}' |grep -v STATE`
	if [ "$serviceState" == "online" ] ; then
		log "SUCCESS:$FUNCNAME::ntp service is in online state in $G_SERV_TYPE"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::ntp service is in $serviceState state in $G_SERV_TYPE"
	fi
}

function checkOpenDJService ()
{
	serviceState=`svcs svc:/network/opendj:default |awk -F' ' '{print $1}' |grep -v STATE`
	if [ "$serviceState" == "online" ] ; then
		log "SUCCESS:$FUNCNAME::OpenDJ service is in online state in $G_SERV_TYPE"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::OpenDJ service is in $serviceState state in $G_SERV_TYPE"
	fi
}

function checkDNSService ()
{
	if [[ $G_SERV_TYPE == "om_serv_master" || $G_SERV_TYPE == "om_serv_slave" ]]; then
		serverService=`svcs svc:/network/dns/server:default |awk -F' ' '{print $1}' |grep -v STATE`
		if [ "$serverService" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::DNS service is in online state in $G_SERV_TYPE"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::DNS service is in $serverService state in $G_SERV_TYPE"
		fi
	else 
		clientService=`svcs svc:/network/dns/client:default |awk -F' ' '{print $1}' |grep -v STATE`
		if [ "$clientService" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::DNS service is in online state in $G_SERV_TYPE"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::DNS service is in $clientService state in $G_SERV_TYPE"
		fi
	fi
}

function checkDHCPService ()
{
	if [[ ! -f /ericsson/config/config.ini ]];then
            log "ERROR:$FUNCNAME::/ericsson/config/config.ini is not present"
            G_PASS_FLAG=1
        fi

	dhcp_conf=$(grep "DHCP_CONF" /ericsson/config/config.ini | awk -F= '{print $2}')
	 if [[ $dhcp_conf == "N/A" ]];then
		log "DHCP is not configured. Skipping DHCP Service check"
         else
        	serverService=`svcs svc:/network/dhcp/server:ipv4 |awk -F' ' '{print $1}' |grep -v STATE`
        	if [ "$serverService" == "online" ] ; then
            		log "SUCCESS:$FUNCNAME::DHCP service is in online state in $G_SERV_TYPE"
        	else
            		G_PASS_FLAG=1
            		log "ERROR:$FUNCNAME::DHCP service is in $serverService state in $G_SERV_TYPE"
        	fi
 	 fi
}

function checkSMRSAIService ()
{
	if [[ $G_SERV_TYPE == "om_serv_master" ]]; then
		serviceState=`svcs svc:/ericsson/smrs/smrs_AIServices:default |awk -F' ' '{print $1}' |grep -v STATE`
		if [ "$serviceState" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::smrs_AIServices is in online state in $G_SERV_TYPE"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::smrs_AIServices is in $serviceState state in $G_SERV_TYPE"
		fi
	fi
	
	if [[ $G_SERV_TYPE == "smrs_slave" ]]; then
		serviceState=`svcs svc:/ericsson/smrs/smrs_slave_AIServices:default |awk -F' ' '{print $1}' |grep -v STATE`
		if [ "$serviceState" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::smrs_slave_AIServices is in online state in $G_SERV_TYPE"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::smrs_slave_AIServices is in $serviceState state in $G_SERV_TYPE"
		fi
	fi
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
	get_server_type

	if [[ $G_SERV_TYPE == "om_serv_master" ]]; then
        checkNtpService
	checkDNSService
	checkDHCPService
	checkSMRSAIService
	checkOpenDJService
    elif [[ $G_SERV_TYPE == "om_serv_slave" ]]; then
        checkNtpService
	checkDNSService
	checkDHCPService
	checkOpenDJService
    elif [[ $G_SERV_TYPE == "smrs_slave" ]]; then
        checkNtpService
	checkDNSService
	checkSMRSAIService
    elif [[ $G_SERV_TYPE == "infra_omsas" ]]; then
        checkNtpService
	checkDNSService
	checkOpenDJService
    fi
fi

} 
 
 
##########
##MAIN ##
##########

#checking services state on om_serv_master,om_serv_slave,infra_omsas 
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
