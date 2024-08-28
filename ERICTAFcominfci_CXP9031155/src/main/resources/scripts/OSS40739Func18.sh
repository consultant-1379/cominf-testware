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

## TC TAFTM Link : http://taftm.lmera.ericsson.se/#tm/viewTC/4698
##TC VARIABLE##
#
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
CONFIG_FILE=/ericsson/config/config.ini

function verification()
{
   		G_NTP_IP=`grep NTP_IP ${CONFIG_FILE} | awk -F= '{print$2}'`
		log "Value of NTP IP is [${G_NTP_IP}] before verification"
 		/ericsson/ocs/bin/setup_isc_dhcp.sh
		if [[ $? -eq 0 ]]; then
		log_file_raw=`ls -ltr /ericsson/ocs/log/ | grep sys_setup_isc_dhcp_ | tail -1` 	
		log_file=`echo ${log_file_raw}| awk -F" " '{print $9}'`
			grep "completed" /ericsson/ocs/log/${log_file}
			result=$?
			[[ ${result} -eq 0 ]] && {
				log "INFO:Test case passed."
				[[ -f /tmp/config_original_$$ ]] && mv /tmp/config_original_$$ ${CONFIG_FILE}
				[[ -f /tmp/config_original_$$ ]] && rm -rf /tmp/config_original_$$
				[[ -f /tmp/config_modified_$$ ]] && rm -rf /tmp/config_modified_$$
			}
			[[ ${result} -eq 0 ]] || {
				log "INFO:Test case failed."
				[[ -f  /tmp/config_original_$$ ]] && mv /tmp/config_original_$$ ${CONFIG_FILE}
				[[ -f /tmp/config_original_$$ ]] && rm -rf /tmp/config_original_$$
				[[ -f /tmp/config_modified_$$ ]] && rm -rf /tmp/config_modified_$$
				G_PASS_FLAG=1
			}
		else
			log "Warning: Script did not execute properly"
			[[ -f  /tmp/config_original_$$ ]] && mv /tmp/config_original_$$ ${CONFIG_FILE}
			[[ -f /tmp/config_original_$$ ]] && rm -rf /tmp/config_original_$$
			[[ -f /tmp/config_modified_$$ ]] && rm -rf /tmp/config_modified_$$
			G_PASS_FLAG=1

		fi	
}
###############################
#Execute the action to be performed
#####################################

function executeAction ()
{
 l_action=$1
 
 if [[ "${l_action}" -eq 1 ]]; then
   log "INFO: Test case for TR:HQ32401"
   log "INFO: Executing action [${l_action}]"
   log "INFO: Fetching NTP_IP value from file [${CONFIG_FILE}]"
   G_NTP_IP=`grep NTP_IP ${CONFIG_FILE} | awk -F= '{print$2}'`
   log "INFO: Fetched value of NTP_IP is [${G_NTP_IP}]"
   [[ -z "${G_NTP_IP}" ]] && {
	log "INFO: precondition failed. value of NTP_IP is set to null."
	G_PASS_FLAG=1
	return 0
	}
   log "INFO: Reproducing the issue reported in TR:HQ32401"
   	if [[ "${G_NTP_IP}" == "N/A" ]]; then
		verification
	else
		cp ${CONFIG_FILE} /tmp/config_original_$$
		grep -v NTP_IP ${CONFIG_FILE} > /tmp/config_modified_$$
		echo "NTP_IP=N/A" >> /tmp/config_modified_$$
		cp /tmp/config_modified_$$ ${CONFIG_FILE} 
		verification
	fi
fi
}
#########
##MAIN ##
#########	
		
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Reproduction of the issue in TR and verification 
executeAction 1
#Final assertion of TC, this should be the final step of tc
evaluateTC
