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
#aifUsers=( aifwran aiflran aifgran aifcore aifwranIP6 aiflranIP6 aifgranIP6 aifcoreIP6 )
aifUsers=( aifwran aiflran aifgran aifcore )
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

function createAifUsers () {
     l_count=0
            while [ $l_count -lt $aifUsersCount ]; do
                    if [ $l_count -le 3 ]; then
                        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -n ${aifNetwork[$l_count]} -a ${aifUsers[$l_count]} -p shroot12 -b -f -s nedssv4`
                    else
                        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -n ${aifNetwork[$l_count]} -a ${aifUsers[$l_count]} -p shroot12 -b -f -s nedssv6`
                     fi
                 getSMRSLogs "add_aif.sh"
                ERROR_STG="ERROR"
				l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
				l_cmd1=`/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -l > /tmp/func07`
				l_cmd2=`grep "${aifUsers[$l_count]}" /tmp/func07`
                if [ $? == 0 ]; then
                        log "SUCCESS:$FUNCNAME::AIF added ${aifUsers[$l_count]}  successfully. Please refer to $ERIC_LOG"
                    else
                       G_PASS_FLAG=1
                     log "ERROR:$FUNCNAME::Failed to add AIF added ${aifUsers[$l_count]}. Please refer to $ERIC_LOG"
                fi
                                sleep 5
                                ConfigString=`grep SMRS_SLAVE_SERVICE_${aifNetwork[$l_count]}_AIF_FTP $smrsConfig | tail -1 | awk -F'=' '{print $2}'`
                                 if [[ "$ConfigString" == "${aifUsers[$l_count]}" ]]; then
                        log "SUCCESS:$FUNCNAME::AIF  ${aifUsers[$l_count]}  updated in smrs_config file"
                    else
                       G_PASS_FLAG=1
                       log "ERROR:$FUNCNAME::Failed  to update AIF  ${aifUsers[$l_count]}  smrs_config file"
                                fi

                let l_count+=1
                done
		rm /tmp/func07
}

###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
	
    if [ $l_action == 7 ]; then
        log "INFO:$FUNCNAME::Configuring aif users"
        createAifUsers
		
    fi

}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Configure AIF users
log "ACTION 7 Started"
executeAction 7
log "ACTION 7 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC
