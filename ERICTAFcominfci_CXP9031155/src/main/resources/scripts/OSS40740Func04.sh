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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/1364
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

prepareNedssTempalte ()
{
	echo '#created from ci
NEDSS_TRAFFIC_HOSTNAME=nedss
NEDSS_TRAFFIC_IP=192.168.0.8
NEDSS_PRIMARY_TRAFFIC_IP=' > $G_NEDSS_TEMPLATE
}


function prepareExpects()
{
  EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12
#
passwd root
New Password:
sh;root
Re-enter new Password:
sh;root
#
exit' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}

function prepareExpects3()
{
  EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
sh;root
#
passwd root
New Password:
shroot12
Re-enter new Password:
shroot12
#
exit' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}
function ConfigNedss1()
{
  prepareNedssTempalte
	EXPCMD="$G_CONFIG_SCRIPT add nedss -f $G_NEDSS_TEMPLATE"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'What is the root account password of NEDSS
sh;root' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
	getSMRSLogs "add_nedss.sh"
        ERROR_STG="ERROR"
        l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
		if [ $? != 0 ]; then
                log "SUCCESS:$FUNCNAME::NEDSS added successfully. Please refer to $ERIC_LOG"
				else
			    G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::Failed to add nedss"
		fi
		
}
function prepareExpects1()
{
  EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss sed -e 's/^#MINSPECIAL=0/MINSPECIAL=0/' /etc/default/passwd > /tmp/func1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
sh;root' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}

function prepareExpects2()
{
  EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss mv /tmp/func1 /etc/default/passwd"
    EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
sh;root' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}

function prepareExpects4()
{
  EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss sed -e 's/^MINSPECIAL=0/#MINSPECIAL=0/' /etc/default/passwd > /tmp/func1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}
function prepareExpects5()
{
  EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss mv /tmp/func1 /etc/default/passwd"
    EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}

function nedssDeletion()
{        
       EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete nedss"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Please enter number of required option
1
Are you sure you want to delete this NEDSS
yes
' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        ret=$?
	getSMRSLogs "delete_nedss.sh"
                                        if [ $ret != 0 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::Failed to Delete NEDSS, check log $ERIC_LOG"
                                                else
                                                log "SUCCESS:$FUNCNAME::Deleted NEDSS"
                                        fi							
 }
 
function ConfigNedss()
{
	prepareNedssTempalte
	EXPCMD="$G_CONFIG_SCRIPT add nedss -f $G_NEDSS_TEMPLATE"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'What is the root account password of NEDSS
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
	getSMRSLogs "add_nedss.sh"
        ERROR_STG="ERROR"
        l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
		if [ $? != 0 ]; then
                log "SUCCESS:$FUNCNAME::NEDSS added successfully. Please refer to $ERIC_LOG"
				else
			    G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::Failed to add nedss"
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


###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
 
	if [ $l_action == 4 ]; then 
	     prepareExpects
		log "INFO:$FUNCNAME::Configuring NEDSS giving root password of nedss with special character ';'"
		ConfigNedss1
		prepareExpects1
		prepareExpects2
		prepareExpects3
		prepareExpects4
		prepareExpects5
		log "INFO:$FUNCNAME::Deleting NEDSS"
		nedssDeletion
		log "INFO:$FUNCNAME::Configuring NEDSS giving correct password "
		ConfigNedss
		verifyAdd "NEDSS_TRAFFIC_IP"
	fi 

}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.


#Configuring NEDSS
log "ACTION 4 Started"
executeAction 4
log "ACTION 4 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC
