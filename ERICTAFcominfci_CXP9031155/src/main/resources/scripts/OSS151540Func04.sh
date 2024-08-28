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

########################
#Checks the SMRS mounts
########################
function get_infra_type() {
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

function check_mounts() 
{
 for i in `grep nfs /etc/vfstab|awk '{print$3}'`
 do
	mount=" df -h $i "
	if [[ $? -ne 0 ]]; then
		log " Error:$FUNCNAME:: $i not mounted"
		G_PASS_FLAG=1
	fi
 done
	log "COMPLETED $FUNCNAME"
}

###############################
#Execute the action to be performed
#####################################

function executeAction ()
{
  l_action=$1
	
	if [ $l_action == 1 ]; then
		get_infra_type
		
		if [[ $G_SERV_TYPE == "om_serv_master" || $G_SERV_TYPE == "smrs_slave" ]]; then
            check_mounts
        fi
	fi
}

#########
##MAIN ##
#########

#Check mounts
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC

