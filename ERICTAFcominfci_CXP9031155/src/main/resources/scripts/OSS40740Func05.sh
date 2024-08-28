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

prepareSSV4Tempalte ()
{
	echo '#created from ci
SMRS_SLAVE_SERVICE_NAME=nedssv4
SMRS_SLAVE_NEDSS_IP=192.168.0.8
SMRS_SLAVE_ENABLE_GRAN=yes
SMRS_SLAVE_ENABLE_CORE=yes
SMRS_SLAVE_ENABLE_WRAN=yes
SMRS_SLAVE_ENABLE_LRAN=yes
PERFORM_ARNEIMPORTS=yes
RESTART_BISMRS_MC=yes' > $G_SSV4_TEMPLATE
}

function ConfigSlaveServ1()
{
	prepareSSV4Tempalte
	EXPCMD="$G_CONFIG_SCRIPT add slave_service -f $G_SSV4_TEMPLATE"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'What is the password for the local accounts
shroot12
Please confirm the password for the local accounts
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
		ret=$?	
		if [ $ret == 0 ]; then
                log "SUCCESS:$FUNCNAME::slave Service nedssv4 added successfully. Please refer to $ERIC_LOG"
				else
			    G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::Failed to add slave service:nedssv4"

		fi
}

function verifyAdd()
{
l_cmd=` grep $1 $smrsConfig`
ret=$?
    if [ $ret == 0 ]; then
	log "SUCCESS:$FUNCNAME::verified in the smrs_config file : $1"
    else
	G_PASS_FLAG=1
        log "ERROR:$FUNCNAME::details are not updated in config file  : $1 "
    fi
}


function NetworkCheck () {
	networkEnabledSlave=`grep SMRS_SLAVE_SERVICE_ENABLED_NETWORKS  $smrsConfig |tail -1 | awk -F'=' '{print $2}'`
	if [ $networkEnabled == $networkEnabledSlave ]; then
		log "SUCCESS:$FUNCNAME::Networks Enabled on slave  updated in smrs_config file:$networkEnabledSlave"
    else
        G_PASS_FLAG=1
        log "ERROR:$FUNCNAME::Failed to update Networks Enabled on slave in smrs_config file"
	fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1

	if [ $l_action == 5 ]; then 
		log "INFO:$FUNCNAME::Configuring slave_service nedssv4"
		ConfigSlaveServ1
		verifyAdd "nedssv4"
		NetworkCheck
	fi 
 
}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Configuring slave_service nedssv4
log "ACTION 5 Started"
executeAction 5
log "ACTION 5 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC
