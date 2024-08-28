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

prepareSlaveListCheck ()
{
   EXPCMD="$G_CONFIG_SCRIPT add aif"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Enter Network Type
LRAN
What is the name for this user
lran_user
What is the password for this user
shroot12
Please confirm the password for this user
shroot12
Would you like to create autoIntegration FtpService for that user
yes
Please enter number of required option
1
Do you wish to restart BI_SMRS_MC on the OSS master if required
yes' > $INPUTEXP
} 


function checkSlaveservices () {
	prepareSlaveListCheck
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file1
	slaveCount=`grep -c ") nedssv" file1`
	slaveCountInConfig=`grep -c SMRS_SLAVE_SERVICE_NAME $smrsConfig`
		rm /tmp/file1
		if [ $slaveCount -eq $slaveCountInConfig ]; then         
             log "SUCCESS:$FUNCNAME::checked the list of slave services in display"
        else
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Error in the list of slave services in display"
         fi
		 
}
	

###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
 

	if [ $l_action == 8 ]; then
		log "INFO:$FUNCNAME::Checking dispaly of aif users"
		checkSlaveservices
        
    fi
	

}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking the list of slave services in display
log "ACTION 8 Started"
executeAction 8
log "ACTION 8 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC
