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
G_MASTER_TEMPLATE="/etc/opt/ericsson/nms_bismrs_mc/smrsMaster_ci.template"
G_MASTER_TEMPLATE_WITHOUT_ARNE_imports="/etc/opt/ericsson/nms_bismrs_mc/smrsMasterWithoutARNE_ci.template"
G_NEDSS_TEMPLATE="/etc/opt/ericsson/nms_bismrs_mc/nedss_ci.template"
G_SSV4_TEMPLATE="/etc/opt/ericsson/nms_bismrs_mc/ssv4_ci.template"
G_SSV6_TEPMPLATE="/etc/opt/ericsson/nms_bismrs_mc/ssv6_ci.template"
G_CONFIG_SCRIPT="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh"
smrsConfig="/etc/opt/ericsson/nms_bismrs_mc/smrs_config"
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
aifUsers=( aifwran aiflran aifgran aifcore aifwranIP6 aiflranIP6 aifgranIP6 aifcoreIP6 )
aifNetwork=( WRAN LRAN GRAN CORE WRAN LRAN GRAN CORE )
aifUsersCount=${#aifUsers[*]}
networkEnabled=( GRAN,CORE,LRAN,WRAN )
sftpList=( `grep nedssv4 /etc/passwd |awk -F':' '{print $1}'`)
sftpCount=${#sftpList[*]}
smoList=( `grep smo /etc/passwd |awk -F':' '{print $1}'` )
smoCount=${#smoList[*]}
nfsMounts=( `grep smrsstore  /etc/mnttab |awk -F' ' '{print $2}'` )
nfsCount=${#nfsMounts[*]}
nfsshares="/var/opt/ericsson/smrsstore"
network=( GRAN CORE LRAN WRAN GRAN CORE LRAN WRAN GRAN CORE LRAN WRAN )

function networkMounts ()
{

if [ $1 = "smrs_master" ] ; then


		l_cmd1=`ssh smrs_master df -h | grep nedss >/var/tmp/mounts1.txt`
        l_cmd=`grep nedss /var/tmp/mounts1.txt`
        ret=$?
                if [ $ret != 0 ] ; then
                        G_PASS_FLAG=1
                        log "ERROR::$FUNCNAME: Network directories are not mounted on /export folder"
                else
                        log "SUCESS::$FUNCNAME: Network directories are mounted on /export folder"
                fi

else
        l_cmd=`ssh smrs_master ssh -o StrictHostKeyChecking=no nedss df -h | grep nedss >/var/tmp/mounts.txt`
        l_cmd1=`grep nedss /var/tmp/mounts.txt`
        ret=$?
                if [ $ret != 0 ] ; then
                        G_PASS_FLAG=1
                        log "ERROR::$FUNCNAME: Network directories are not mounted on /export folder"
                else
                        log "SUCESS::$FUNCNAME: Network directories are mounted on /export folder"
                fi
fi


}
###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
 
	if [ $l_action == 13 ]; then
		log "INFO:$FUNCNAME::verifying the Network directories are mounted on /export folder on NEDSS"
		networkMounts "nedss"
	fi
}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#verifying the Network directories are mounted on /export folder on NEDSS
log "ACTION 13 Started"
executeAction 13
log "ACTION 13 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC
