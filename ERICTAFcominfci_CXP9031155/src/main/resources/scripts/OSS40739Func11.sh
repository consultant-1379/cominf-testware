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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4647
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

function dhcp_permissions () {
   dhcpd_conf_static=`ls -lrt /usr/local/etc|grep -w dhcpd.conf_static|awk '{print $1}'`
   dhcpd_conf_subnet=`ls -lrt /usr/local/etc|grep -w dhcpd.conf_subnet|awk '{print $1}'`

   if [ "$dhcpd_conf_static" == "-rwxrwxrwx" ]; then
   log "FAILED:: in the path  /usr/local/etc/ dhcpd.conf_static file permissions is 777 which means world writable, which is wrong permissions"
    G_PASS_FLAG=1

  elif [ "$dhcpd_conf_subnet" == "-rwxrwxrwx" ]; then
      log "FAILED:: in the path  /usr/local/etc/ dhcpd.conf_subnet file permissions is 777 which means world writable, which is wrong permissions"
    G_PASS_FLAG=1
   else

      log "SUCCESS::  in the path  /usr/local/etc/ dhcpd.conf_subnet and dhcpd.conf_static both files are NOT world writable"
   fi
}

###############################
#Execute the action to be performed
#####################################

function executeAction () {
        l_action=$1

        if [[ "$l_action" == 1 ]] ; then
                log "INFO:: Checking the files dhcpd_conf_static and dhcpd_conf_subnet permissions in path  /usr/local/etc/ "
                dhcp_permissions
        fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking the files dhcpd_conf_static and dhcpd_conf_subnet permission in path  /usr/local/etc/.
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC
   