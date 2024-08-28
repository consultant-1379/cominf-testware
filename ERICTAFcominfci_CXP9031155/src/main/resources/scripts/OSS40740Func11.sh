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

function checkNfsMount () {
	l_count=0
	while [ $l_count -lt $nfsCount ]; do
                    if [ $l_count -le 3 ];then
                        if [ $nfsshares/${network[$l_count]} == ${nfsMounts[$l_count]} ];then
							log "SUCCESS:$FUNCNAME::$nfsshares/${network[$l_count]} verified "
						else
							G_PASS_FLAG=1
							log "ERROR:$FUNCNAME::failed $nfsshares/{$network[$l_count]} verified "
						fi
					elif [ $l_count -ge 4 -a $l_count -le 7 ];then
						if [ $nfsshares/${network[$l_count]}/nedssv4 == ${nfsMounts[$l_count]} ];then
							log "SUCCESS:$FUNCNAME::$nfsshares/{$network[$l_count]}/nedss4 verified "
						else
							G_PASS_FLAG=1
							log "ERROR:$FUNCNAME::failed $nfsshares/${netowrk[$l_count]}/nedssv4 verified "
						fi
					else 
						if [ $nfsshares/${network[$l_count]}/nedssv6 == ${nfsMounts[$l_count]} ];then
							log "SUCCESS:$FUNCNAME::$nfsshares/${network[$l_count]}/nedssv6 verified "
						else
							G_PASS_FLAG=1
							log "ERROR:$FUNCNAME::failed $nfsshares/{$network[$l_count]}/nedssv6 verified "
						fi
					fi
	let l_count+=1
    done
	l_cmd=`grep smrsstore  /etc/mnttab |grep omsrvm`
	if [ $? != 0 ]; then
        log "SUCCESS:$FUNCNAME::verified : hostname of the SMRS Master(NESS) should NOT appear in the /etc/mnttab file"
    else
		G_PASS_FLAG=1
        log "ERROR:$FUNCNAME::hostname of the SMRS Master(NESS) appears in the /etc/mnttab file"
     fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1

	if [ $l_action == 11 ]; then
		log "INFO:$FUNCNAME::checking nfs mounts"
		checkNfsMount    
    fi

}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#verifying the Network directories are mounted on /export folder on SMRS MASTER
log "ACTION 11 Started"
executeAction 11
log "ACTION 11 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC
