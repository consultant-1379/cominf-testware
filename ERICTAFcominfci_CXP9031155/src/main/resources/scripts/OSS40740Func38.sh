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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4700
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
function coreftp_services () {
  if [ `hostname` == "ossmaster" ]; then
     c_back_count=`/opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep -c c-back*`
      /opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep -iw c-back*|awk -F',' '{print $3}' > /tmp/back.txt
      cat  /tmp/back.txt|awk -F'=' '{print $2}'| sed "N;s/\n/,/" > /tmp/back2.txt
    c_swstore_count=`/opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep -c c-swstore*`
     /opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep -iw c-swstore*|awk -F',' '{print $3}' > /tmp/swstore.txt
      cat  /tmp/swstore.txt|awk -F'=' '{print $2}'| sed "N;s/\n/,/" > /tmp/swstore2.txt

                if [[ "$c_back_count" == 0 ]]; then
                                G_PASS_FLAG=1
                                log "ERROR:$FUNCNAME:: c_back_ type core network FTP services NOT created"
                elif [[ "$c_swstore_count" == 0 ]]; then
                                G_PASS_FLAG=1
          log "ERROR:$FUNCNAME:: c_swstore_ type core network FTP services NOT created"
                else
                   log "SUCCESS:$FUNCNAME:: core network FTP services `cat /tmp/back2.txt` and `cat /tmp/swstore2.txt` are created"
                   rm -rf /tmp/back.txt
                   rm -rf /tmp/back2.txt
                   rm -rf /tmp/swstore.txt
                   rm -rf /tmp/swstore2.txt
                fi
 fi
}

###############################
###############################
#Execute the action to be performed
#####################################

function executeAction () {
        l_action=$1

        if [[ "$l_action" == 1 ]] ; then
                log "INFO:: Checking core network ftp services creatred or not "
                coreftp_services
        fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking core network ftp services creatred or not.
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"
#Final assertion of TC, this should be the final step of tc
evaluateTC
