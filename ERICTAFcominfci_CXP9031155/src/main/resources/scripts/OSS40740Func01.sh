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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/1361
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
###################################
#This Function is used to configure SMRS
#################################
prepareMasterTemplateWithoutARNE ()
{
	echo '#created from ci
DEPLOYMENT_TYPE=blade
OSS_ALIAS=oss1
SMRS_MASTER_IP=192.168.0.4
SMRS_MASTER_PM_RETENTION=86400
SMRS_NAS_SYSID=oss1_SMRS
OSS_SUPPORT_GRAN=yes
OSS_SUPPORT_CORE=yes
OSS_SUPPORT_WRAN=yes
OSS_SUPPORT_LRAN=yes
OSS_GRAN_SMO_FTPSERVICE=smoftpgran
OSS_CORE_SMO_FTPSERVICE=smoftpcore
USE_OSS_NTP=yes
GEO_REDUNDANT_DEPLOYMENT=no
PERFORM_ARNEIMPORTS=no' > $G_MASTER_TEMPLATE_WITHOUT_ARNE_imports
}

function prepareExpects ()
{
   EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm sed -e 's/^#MINUPPER=0/MINUPPER=2/' /etc/default/passwd > /tmp/func1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}

function prepareExpects1 ()
{
   EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm mv /tmp/func1 /etc/default/passwd"
    EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}

function ConfigSmrsMasterWithoutARNE1 ()
{
     log "Configuring smrs_master without ARNE imports after changing /etc/default/passwd file in smrs_master"
	prepareMasterTemplateWithoutARNE
	EXPCMD="$G_CONFIG_SCRIPT add smrs_master -f $G_MASTER_TEMPLATE_WITHOUT_ARNE_imports"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'What is the root account password of the SMRS Master
shroot12
What is the password for the local accounts
shroot12
Please confirm the password for the local accounts
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
	getSMRSLogs "add_smrs_master.sh"
        SUCCESS_STG="smrs_master successfully added"
        l_cmd=`grep -w "${SUCCESS_STG}" $ERIC_LOG`
		if [ $? == 0 ]; then
		        G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Smrs Master added successfully though /etc/default/passwd file changed. Please refer to $ERIC_LOG"
				else
				log "SUCCESS:$FUNCNAME::Failed to add Smrs Master Please refer to $ERIC_LOG"
				 ERROR_STG_PASSWD="ERROR Failed to set password"
		        l_cmd_passwd=`grep -w "${ERROR_STG_PASSWD}" $ERIC_LOG`
				if [ $? == 0 ]; then
					l_ftpservice=`grep -w "${ERROR_STG_PASSWD}" $ERIC_LOG | awk '{print $9}'`
					log "SUCCESS:$FUNCNAME::Failed to add Smrs Master as password was not set for ftpservice $l_ftpservice.Please refer to $ERIC_LOG"
					l_cmd_check=`cat /etc/passwd | grep '^$l_ftpservice'`
					if [ $? == 0 ]; then
						G_PASS_FLAG=1
						log "ERROR:$FUNCNAME:: FTP service $l_ftpservice for which password was not set is not deleted from OSS Master." 
					else
					    log "SUCCESS:$FUNCNAME::verified: FTP service $l_ftpservice for which password was not set got deleted from OSS Master."
						l_cmd_check_smrs=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm cat /etc/passwd | grep '^$l_ftpservice'`
						if [ $? == 0 ]; then
							G_PASS_FLAG=1
							log "ERROR:$FUNCNAME:: FTP service $l_ftpservice for which password was not set is not deleted from SMRS Master."
						else
						    log "SUCCESS:$FUNCNAME::verified: FTP service $l_ftpservice for which password was not set got deleted from SMRS Master."
						fi
					fi
                fi
         fi		
}	

function prepareExpects2 ()
{
 EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm sed -e 's/^MINUPPER=2/#MINUPPER=0/' /etc/default/passwd > /tmp/func1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Password
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP  
}
	 
		
function ConfigSmrsMasterWithoutARNE ()
{
    log "Configuring smrs_master without ARNE imports and checking for SmoFtp serivces"
	prepareMasterTemplateWithoutARNE
	EXPCMD="$G_CONFIG_SCRIPT add smrs_master -f $G_MASTER_TEMPLATE_WITHOUT_ARNE_imports"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'What is the root account password of the SMRS Master
shroot12
What is the password for the local accounts
shroot12
Please confirm the password for the local accounts
shroot12' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
	getSMRSLogs "add_smrs_master.sh"
        SUCCESS_STG="smrs_master successfully added"
        l_cmd=`grep -w "${SUCCESS_STG}" $ERIC_LOG`
		if [ $? == 0 ]; then
                log "SUCCESS:$FUNCNAME::Smrs Master added successfully. Please refer to $ERIC_LOG"
				else
			    G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::Failed to add Smrs Master Please refer to $ERIC_LOG"			
		fi

}

function checkingSmoFtpWithoutARNE () {
log "Verifying SMOFtp details without arne"
	OSS_ALIAS_NAME=`grep -w "OSS_ALIAS" $smrsConfig | awk -F'=' '{print $2}'`
		if [ ! -z $OSS_ALIAS_NAME ] ; then
			CHECK_SMO_FTP_SERVICE_MASTER1 "$OSS_ALIAS_NAME" "y" "y" "y" "y" "y"
				ret=$?
				if [ $ret == 0 ] ; then
					G_PASS_FLAG=1
					log "ERROR::$FUNCNAME: SmoFtp Service exists"
				else
					log "SUCCESS::$FUNCNAME: SmoFtp Service doesn't exists"
				fi
		else 
			G_PASS_FLAG=1
			log "ERROR:: SMRS is not configured"
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
	fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
    if [ $l_action == 1 ]; then  
        prepareExpects
		prepareExpects1
		log "INFO:$FUNCNAME::Configuring smrs_master"
		ConfigSmrsMasterWithoutARNE1
		prepareExpects2
		prepareExpects1
		log "INFO:$FUNCNAME::Configuring smrs_master"
		ConfigSmrsMasterWithoutARNE
		log "INFO::Verifying SMRS Master Details in Config file"
		verifyAdd "SMRS_MASTER_IP"
		log "INFO:$FUNCNAME::Checking SmoFtp Service exists without ARNE"
		checkingSmoFtpWithoutARNE
	fi	
	
}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions


#Configuring smrs_master without ARNE imports and checking for SmoFtp serivces
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC

