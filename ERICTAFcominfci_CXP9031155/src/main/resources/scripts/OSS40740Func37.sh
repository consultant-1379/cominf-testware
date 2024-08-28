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


##############################################################################

function SMCrsync () {

  if [ `hostname` == "ossmaster" ]; then
  on_ossmaster=`pkginfo -l SMCrsync |grep -i VERSION|awk -F: '{print $2}'`
  in_etc_folder=`pkginfo -l -d /opt/ericsson/nms_bismrs_mc/etc/SMCrsync.pkg |grep -i VERSION|awk -F: '{print $2}'`
      if [ "$on_ossmaster" == "$in_etc_folder" ]; then
                 log "SMCrsync package VERSION installed on OSS Master and SMCrsync package version delivered in ERICbismrs package are same version."
        else
                        G_PASS_FLAG=1
                log "FAILED:: The SMCrsync package VERSION installed on OSS master and SMCrsync package version delivered in ERICbismrsmc package are NOT same version."

        fi

  fi

}

###############################
#Execute the action to be performed
#####################################

function executeAction () {
        l_action=$1

        if [[ "$l_action" == 1 ]] ; then
                log "INFO:: Checking SMCrsync package version installed on OSS master and SMCrsync package version delivered in ERICbismrsmc package "
                SMCrsync
        fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking installed SMCrsync package version on OSS master and SMCrsync package version delivered in ERICbismrsmc package.
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC

