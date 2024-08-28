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
G_COMLIB=commonFunctions.lib
#source the commonFunctions.
source $G_COMLIB
G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
smrsConfig="/etc/opt/ericsson/nms_bismrs_mc/smrs_config"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
path="/opt/ericsson/nms_bismrs_mc/bin"
###################################
#This fucntion is for verifying -s option when deleting user using /opt/ericsson/nms_bismrs_mc/bin/del_aif.sh script
#################################
function addAif ()
{
	l_cmd=`$path/add_aif.sh -n WRAN -a $1 -p shroot12 -f`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME::added user $1 on both slave services"
	else
		G_PASS_FLAG=1
        log "ERROR:$FUNCNAME::Error in adding aif user $1"
    fi    
}


function delAifSpecificSlave ()
{
	addAif "useron2slave1"
	addAif "useron2slave2"
	if [ `cat $smrsConfig |grep -c useron2slave1` == 2 ] ;then
		l_cmd=`$path/del_aif.sh -a useron2slave1 -f`
		if [ `cat $smrsConfig |grep -c useron2slave1` == 0 ] ;then
			log "SUCCESS:$FUNCNAME::verified:deleted user useron2slave1 on both the slave services when -s option is not specified"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in deleting useron2slave1 the user when -s option is not specified"
		fi
	else 
		log "SUCCESS:$FUNCNAME::useron2slave1 is not updated properly in smrs_config file"
	fi
	
	if [ `cat $smrsConfig |grep -c useron2slave2` == 2 ] ;then
		l_cmd=`$path/del_aif.sh -a useron2slave2 -s nedssv4 -f`
		if [ `cat $smrsConfig |grep -c useron2slave2` == 1 ] ;then
			log "SUCCESS:$FUNCNAME::verified:deleted user useron2slave2 under one slave service when -s option is mentioned"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in deleting the user useron2slave2 under one slave service when -s option is mentioned"
		fi
	else 
		log "SUCCESS:$FUNCNAME::useron2slave2 is not updated properly in smrs_config file"
	fi
	
	l_cmd=`$path/del_aif.sh -a useron2slave2  -f`
	if [ `cat $smrsConfig |grep -c useron2slave2` == 0 ] ;then
		log "SUCCESS:$FUNCNAME::verified:deleted user useron2slave2"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in deleting the user useron2slave2"
	fi
	
	l_cmd=`$path/del_aif.sh -a useron2slave2 -f > /tmp/file2`
	l_cmd=` grep -w "ERROR Failed to delete AIF account" /tmp/file2`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME::verified:Error while trying to delete non-existing user :useron2slave2"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::deleting the non-existing user :useron2slave2"
	fi
	rm /tmp/file2
}
	
###############################
#Execute the action to be performed
#####################################

function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME::verifying -s option when deleting user using del_aif.sh script"
   delAifSpecificSlave
   log "INFO:Completed ACTION 1"
 fi
}
#########
##MAIN ##
#########

#verifying -s option when deleting user using del_aif.sh script 
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
