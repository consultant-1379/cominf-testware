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

##
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
#############################################################################
function ftp_services () {
	if [ `hostname` == "ossmaster" ]; then
		c_uplink_count=`/opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep -c c-uplink*`
		w_uplink_count=`/opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep -c w-uplink*`
		l_uplink_count=`/opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep -c l-uplink*`

            if [[ "$c_uplink_count" == 0 ]]; then
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME:: c_uplink_ type core network FTP services NOT created"
            elif [[ "$w_uplink_count" == 0 ]]; then
                G_PASS_FLAG=1
          		log "ERROR:$FUNCNAME:: w_uplink_ type wran network FTP services NOT created"
			elif [[ "$l_uplink_count" == 0 ]]; then
				G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::l_uplink_ type lran network FTP services NOT created"
			else
				log "SUCCESS:$FUNCNAME:: network FTP services are created."
				
			fi
	else
		log "ERROR :  Invalid hostname "
		G_PASS_FLAG=0
	fi
}

function CHECK_DIRECTORY(){

	
local path=$1
local user=$2
local group=$3
local permissions=$4
local server=$5

if [[ -z "$server" ]]; then
result="$(pkgproto $path | cut -d ' ' -f 4-6)"
ret=$?
else
result="$(ssh -o StrictHostKeychecking=no $server pkgproto $path | cut -d ' ' -f 4-6)"
ret=$?
fi
        [ $ret -ne 0 ] &&
                {
                        G_PASS_FLAG=1;
                        log "Failed to stat $1 on $5 $cmd output is $result";
                        return 2;
                }
        [ "$result" != "$4 $2 $3" ] && {
                        G_PASS_FLAG=1;
                        log "Wrong owner/permissions got $result";
                        return 3;
                }
        return 0

}

function checkDirectoriesOnAdmin () {

CHECK_DIRECTORY /var/opt/ericsson/smrsstore/WRAN/CommonPersistent/Uplink/ root nms 0775 ||
                {
                G_PASS_FLAG=1;
                log "ERROR : Invalid WRAN Uplink";
                }
CHECK_DIRECTORY /var/opt/ericsson/smrsstore/LRAN/CommonPersistent/Uplink/ root nms 0775 ||
                {
                G_PASS_FLAG=1;
                log " ERROR : Invalid LRAN Uplink";
                }
CHECK_DIRECTORY /var/opt/ericsson/smrsstore/CORE/CommonPersistent/Uplink/ root nms 0775 ||

                {
                G_PASS_FLAG=1;
                log "ERROR : Invalid CORE Uplink";
                }
}

function checkDirectoriesOnSmrsMaster () {

CHECK_DIRECTORY /export/WRAN/CommonPersistent/Uplink/ root nms 0775 $1 ||
                {
                G_PASS_FLAG=1;
                log "Invalid WRAN Uplink";
                }
CHECK_DIRECTORY /export/LRAN/CommonPersistent/Uplink/ root nms 0775 $1 ||
                {
                G_PASS_FLAG=1;
                log "Invalid LRAN Uplink";
                }
CHECK_DIRECTORY /export/CORE/CommonPersistent/Uplink/ root nms 0775 $1 ||

                {
                G_PASS_FLAG=1;
                log "Invalid CORE Uplink";
                }
}

###############################
###############################
#Execute the action to be performed
#####################################

function executeAction () {
        l_action=$1

        if [[ "$l_action" == 1 ]] ; then
                log "INFO:: Checking CORE,WRAN,LRAN network ftp services creatred or not "
                ftp_services
        fi
		
		if [[ "$l_action" == 2 ]] ; then
                log "INFO:: Checking the directory structure is created on ossmaster "
                checkDirectoriesOnAdmin ossmaster
				log " INFO :: Directory structure is created successfully on ossmaster" 
        fi
		
		if [[ "$l_action" == 3 ]] ; then
                log "INFO:: Checking the directory structure is created on smrs_master "
                checkDirectoriesOnSmrsMaster smrs_master
				log " INFO :: Directory structure is created successfully on smrs_master"
        fi
}
#########
##MAIN  #
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking  ftp services creatred or not.
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"
#Checking the directory structure is created or not on ossmaster
log "ACTION 2 Started"
executeAction 2
log "ACTION 2 Completed"
#Checking the directory structure is created or not on smrs_master
log "ACTION 3 Started"
executeAction 3
log "ACTION 3 Completed"
#Final assertion of TC, this should be the final step of tc

evaluateTC
