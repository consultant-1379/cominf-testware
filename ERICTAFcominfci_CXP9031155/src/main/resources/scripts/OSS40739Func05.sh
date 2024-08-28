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

## TC TAFTM Link :http://taftm.lmera.ericsson.se
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
OCS_DIR=/ericsson/ocs/bin


function addingpubapps()
{
 stop_cmd=` /opt/CTXSmf/sbin/ctxsrv stop all`
 l_cmd=`/ericsson/ocs/bin/conf_citrix_appl_server.sh`
  ret=$?
        if [ $ret == 0 ] ; then
                log "INFO::Added published applications without changing existing customer application preferences"
        else
                G_PASS_FLAG=1
                log "ERROR::Errors during adding published applications"
        fi
}
function changingConfigFile ()
{
if [[  `grep ServerFQDN /var/CTXSmf/ctxxmld.cfg | awk -F= '{print $2}'` == uas1 ]] ; then
        sed 's/ServerFQDN=uas1/ServerFQDN=uas1.vts.com/g' /var/CTXSmf/ctxxmld.cfg > /var/tmp/ctxxmld_cfg.tmp
        mv /var/tmp/ctxxmld_cfg.tmp /var/CTXSmf/ctxxmld.cfg
        /opt/CTXSmf/sbin/ctxsrv stop all
        /opt/CTXSmf/sbin/ctxsrv start all
fi
}



###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO: Changing citrix config file"
    changingConfigFile
   log "INFO:$FUNCNAME:: Updating Citrix published applications list without changing customer preferences of existing pub apps"
   addingpubapps
   log "INFO:Completed ACTION 1"
 fi

 }


#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

# Checking the usage and ERROR message if -d option is not given
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
