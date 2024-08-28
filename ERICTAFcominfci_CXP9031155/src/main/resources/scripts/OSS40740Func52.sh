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
G_SSV4_TEMPLATE_NESS1="/etc/opt/ericsson/nms_bismrs_mc/ssv4_ness1_ci.template"
G_SSV4_TEMPLATE_NESS2="/etc/opt/ericsson/nms_bismrs_mc/ssv4_ness2_ci.template"
G_SSV6_TEPMPLATE="/etc/opt/ericsson/nms_bismrs_mc/ssv6_ci.template"
G_CONFIG_SCRIPT="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh"
G_DELETE_SLAVE_SCRIPT="/opt/ericsson/nms_bismrs_mc/bin/delete_smrs_slave.sh"
G_nascli="/ericsson/storage/bin/nascli"
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
nwkEnabled="gran lran wran core"
networkEnabled1=( WRAN )
networkEnabled2=( WRAN,CORE,LRAN )
storageIP="172.16.30.4 172.16.30.24 172.16.30.25 172.16.30.26 "
sftpList=( `grep nedssv4 /etc/passwd |awk -F':' '{print $1}'`)
sftpCount=${#sftpList[*]}
smoList=( `grep smo /etc/passwd |awk -F':' '{print $1}'` )
smoCount=${#smoList[*]}
nfsMounts=( `grep smrsstore  /etc/mnttab |awk -F' ' '{print $2}'` )
nfsCount=${#nfsMounts[*]}
nfsshares="/var/opt/ericsson/smrsstore"
network=( GRAN CORE LRAN WRAN GRAN CORE LRAN WRAN GRAN CORE LRAN WRAN )

prepareSSV4Tempalte_NESS1 ()
{
        echo '#created from ci
SMRS_SLAVE_SERVICE_NAME=nessv4
SMRS_SLAVE_NESS_IP=192.168.0.4
SMRS_SLAVE_ENABLE_GRAN=no
SMRS_SLAVE_ENABLE_CORE=no
SMRS_SLAVE_ENABLE_WRAN=yes
SMRS_SLAVE_ENABLE_LRAN=no
PERFORM_ARNEIMPORTS=yes
RESTART_BISMRS_MC=yes' > $G_SSV4_TEMPLATE_NESS1
}



prepareSSV4Tempalte_NESS2 ()
{
        echo '#created from ci
SMRS_SLAVE_SERVICE_NAME=nessv4
SMRS_SLAVE_NESS_IP=192.168.0.4
SMRS_SLAVE_ENABLE_GRAN=no
SMRS_SLAVE_ENABLE_CORE=yes
SMRS_SLAVE_ENABLE_WRAN=no
SMRS_SLAVE_ENABLE_LRAN=yes
PERFORM_ARNEIMPORTS=yes
RESTART_BISMRS_MC=yes' > $G_SSV4_TEMPLATE_NESS2
}

function Create_share()
{
date
        for nwk in $nwkEnabled
        do
                EXPCMD="$G_nascli create_fs oss1_SMRS 3G oss1_SMRS ${nwk}_nessv4"
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo ' Do you really want to continue (y/n)?
y' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
                ret=$?
                if [ $ret == 0 ]; then
                log "SUCCESS:$FUNCNAME::File system created successfully. Please refer to $ERIC_LOG"
                else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed to create File system:"
                fi

                for IP in $storageIP
                do
                        EXPCMD="$G_nascli add_client oss1_SMRS $IP rw,no_root_squash ${nwk}_nessv4"
                        INPUTEXP=/tmp/${SCRIPTNAME}.in
                        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
                        echo ' Do you really want to continue (y/n)?
y' > $INPUTEXP
                        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
                        executeExpect $OUTPUTEXP
                        ret=$?
                        if [ $ret == 0 ]; then
                        log "SUCCESS:$FUNCNAME::File system shared successfully. Please refer to $ERIC_LOG"
                        else
                        G_PASS_FLAG=1
                        log "ERROR:$FUNCNAME::Failed to share File system:"
                        fi

                done
        done
}


function Delete_share()
{
        for nwk in $nwkEnabled
        do
                EXPCMD="$G_nascli delete_fs oss1_SMRS ${nwk}_nessv4"
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo ' Do you really want to continue (y/n)?
y' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
                ret=$?
                if [ $ret == 0 ]; then
                log "SUCCESS:$FUNCNAME::File system deleted successfully. Please refer to $ERIC_LOG"
                else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed to delete File system:"
                fi
        done
date
}




function ConfigSlaveServ()
{
if [[ $1 = "nessv4" && $2 -eq "1" ]]
then
        prepareSSV4Tempalte_NESS1
        EXPCMD="$G_CONFIG_SCRIPT add slave_service -f $G_SSV4_TEMPLATE_NESS1"
else
        prepareSSV4Tempalte_NESS2
        EXPCMD="$G_CONFIG_SCRIPT add slave_service -f $G_SSV4_TEMPLATE_NESS2"
fi
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
                log "SUCCESS:$FUNCNAME::slave Service added successfully. Please refer to $ERIC_LOG"
                else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed to add slave service:"

                fi
}

function DeleteSlaveServ()
{
    $G_DELETE_SLAVE_SCRIPT -s $1 -o ossmaster
                ret=$?
                if [ $ret == 0 ]; then
                log "SUCCESS:$FUNCNAME::slave Service deleted successfully. Please refer to $ERIC_LOG"
                echo "SUCCESS:$FUNCNAME::slave Service deleted successfully. Please refer to $ERIC_LOG"
                else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed to delete slave service:"
                echo "ERROR:$FUNCNAME::Failed to delete slave service:"
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


function NetworkCheck1 () {
        abc=`grep "SMRS_SLAVE_SERVICE_NAME.*nessv4" $smrsConfig | awk -F'[' '{print$2}'| awk -F']' '{print $1}'`
        networkEnabledSlave=`grep "SMRS_SLAVE_SERVICE_ENABLED_NETWORKS.*$abc"  $smrsConfig | awk -F'=' '{print $2}' `
        #networkEnabledSlave=`grep 'SMRS_SLAVE_SERVICE_ENABLED_NETWORKS\[1\]'  $smrsConfig |tail -1 | awk -F'=' '{print $2}'`
        if [ $networkEnabled1 == $networkEnabledSlave ]; then
                log "SUCCESS:$FUNCNAME::Networks Enabled on slave  nessv4 updated in smrs_config file:$networkEnabledSlave"
                echo "SUCCESS:$FUNCNAME::Networks Enabled on slave  nessv4 updated in smrs_config file:$networkEnabledSlave"
    else
        G_PASS_FLAG=1
        log "ERROR:$FUNCNAME::Failed to update Networks Enabled on slave nessv4 in smrs_config file"
        fi
}

function NetworkCheck2 () {
        abc=`grep "SMRS_SLAVE_SERVICE_NAME.*nessv4" $smrsConfig | awk -F'[' '{print$2}'| awk -F']' '{print $1}'`
        networkEnabledSlave=`grep "SMRS_SLAVE_SERVICE_ENABLED_NETWORKS.*$abc"  $smrsConfig | awk -F'=' '{print $2}'`
        #networkEnabledSlave=`grep 'SMRS_SLAVE_SERVICE_ENABLED_NETWORKS\[1\]'  $smrsConfig |tail -1 | awk -F'=' '{print $2}'`
        if [ $networkEnabled2 == $networkEnabledSlave ]; then
                log "SUCCESS:$FUNCNAME::Networks Enabled on slave  nessv4 updated in smrs_config file:$networkEnabledSlave"
                echo "SUCCESS:$FUNCNAME::Networks Enabled on slave  nessv4 updated in smrs_config file:$networkEnabledSlave"
    else
        G_PASS_FLAG=1
        log "ERROR:$FUNCNAME::Failed to update Networks Enabled on slave nessv4 in smrs_config file"
        fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 5 ]; then
                Create_share
                log "INFO:$FUNCNAME::Configuring slave_service nedssv4"
                ConfigSlaveServ nessv4 1
                verifyAdd "nessv4"
                NetworkCheck1
                ConfigSlaveServ nessv4 2
                verifyAdd "nessv4"
                NetworkCheck2
                DeleteSlaveServ nessv4
                Delete_share
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

