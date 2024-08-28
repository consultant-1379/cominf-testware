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


function prepareExpects ()
{

        EXPCMD="su - nmsadm"
        EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo '$
ssh smrsuser@smrs_master
#
exit
$
logout' > $INPUTEXP

}

function checkForSmrsConfiguration () 
{
prepareExpects
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP 
l_cmd=`scp root@smrs_master:/smrsuser/.ssh/authorized_keys /var/tmp/authorized_keys.txt`
l_cmd1=`/usr/xpg4/bin/grep -e "nmsadm" -e "root" /var/tmp/authorized_keys.txt`
ret=$?
if [ $ret != 0 ] ; then
	G_PASS_FLAG=1
	log "ERROR::$FUNCNAME: Not able to login with nmsadm and smrsuser . SMRS MASTER is not configured properly"
else
	log "SUCESS::$FUNCNAME: Able to login with nmsadm "
fi

}

function verifyAdd()
{
l_cmd=`grep $1 $smrsConfig`
ret=$?
    if [ $ret == 0 ]; then
			log "SUCCESS:$FUNCNAME::verified in the smrs_config file : $1"
    else
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::details are not updated in config file  : $1"
			log "FAILED :: PRECONDITIONS FAILED ::"
			evaluateTC
	fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
 
	if [ $l_action == 3 ]; then 
	log "INFO:$FUNCNAME::Checking whether nmsadm is able to login or not and for SMRS MASTER configuration"
	checkForSmrsConfiguration
	fi
	
}

function prepareSSH ()
{
l_cmd=`ssh smrs_master`
        EXPCMD="ssh smrs_master"
        EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo '$
ssh smrsuser@smrs_master
#
exit
$
logout' > $INPUTEXP

}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions
# PRE CONDITION
#SMRS MASTER SHOULD BE AVALIABLE 
log "INFO::Verifying SMRS Master Details in Config file"
verifyAdd "SMRS_MASTER_IP"
PrepareSSH

#main Logic should be in executeActions subroutine with numbers in order.

#Checking whether nmsadm is able to login or not and for SMRS MASTER configuration
log "ACTION 3 Started"
executeAction 3
log "ACTION 3 Completed"



#Final assertion of TC, this should be the final step of tc
evaluateTC
