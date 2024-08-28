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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4678

##TC VARIABLE##

G_COMLIB=commonFunctions.lib
#source the commonFunctions.
source $G_COMLIB
G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
G_OCS_BACKUP_SCRIPT=/ericsson/ocs/bin/ocs_backup.sh
G_OCS_RESTORE_SCRIPT=/ericsson/ocs/bin/ocs_restore.sh
G_OCS_BACKUP_TAR_PATH=/var/tmp/ocs_backup_omsas.tar.gz
G_PRIMARY_IP=$(getent hosts omsrvm | nawk '{print $1}')
G_SECONDARY_IP=$(getent hosts omsrvs| nawk '{print $1}')
XPGGREP=/usr/xpg4/bin/grep
CP=/usr/bin/cp
MV=/usr/bin/mv
ECHO=/usr/bin/echo

if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log

function prepareOMSAStoBackupAndRestore ()
{
	log "Executing pre-configuration setps on OMSAS server"
	[[ $($XPGGREP "\<$G_PRIMARY_IP\>" /etc/inet/hosts) ]] || {
			l_string_to_add="$(getent hosts omsrvm)"
			$CP /etc/inet/hosts /etc/inet/hosts.$$ 2>/dev/null
			log "Adding O&M Primary entry to OMSAS /etc/hosts file"
			$ECHO $l_string_to_add >> /etc/inet/hosts.$$
			$MV /etc/inet/hosts.$$ /etc/inet/hosts
			unset l_string_to_add
	}
	[[ $($XPGGREP "\<$G_SECONDARY_IP\>" /etc/inet/hosts) ]] || {
			l_string_to_add="$(getent hosts omsrvs)"
			$CP /etc/inet/hosts /etc/inet/hosts.$$ 2>/dev/null
			log "Adding O&M Secondary entry to OMSAS /etc/hosts file"
			$ECHO $l_string_to_add >> /etc/inet/hosts.$$
			$MV /etc/inet/hosts.$$ /etc/inet/hosts
			unset l_string_to_add
	}
}


function executeOcsBackupOnOMSAS ()
{
    log "Executing OCS_BACKUP on OMSAS server"
	EXPCMD="$G_OCS_BACKUP_SCRIPT"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo "Enter the Primary O&M Infra IP Address
$G_PRIMARY_IP
Enter the Secondry O&M Infra IP Address
$G_SECONDARY_IP
LDAP Directory Manager password
ldappass
Enter absolute path of directory to store the migration tar file
/var/tmp
Continue to create /var/tmp/ocs_backup_omsas.tar.gz
y" > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP 
ret=$?
if [ $ret == 0 ] ; then
	log "INFO: OCS_RESTORE on OMSAS server successful."
else 
	G_PASS_FLAG=1
	log "ERROR: OCS_RESTORE on OMSAS server failed."
fi
}

function executeOcsRestoreOnOMSAS ()
{
    log "Executing OCS_RESTORE on OMSAS server"
	EXPCMD="$G_OCS_RESTORE_SCRIPT -f $G_OCS_BACKUP_TAR_PATH"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo "Continue to extract /var/tmp/ocs_backup_omsas.tar.gz
y
Enter the O&M Services Primary IP Address
$G_PRIMARY_IP
Do you want the script to continue with existing entry
n
Enter the O&M Services Primary Host Name
omsrvm
Enter the O&M Services Secondary IP Address
$G_SECONDARY_IP
Do you want the script to continue with existing entry
n
Enter the O&M Services Secondary Host Name
omsrvs" > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP 
ret=$?
if [ $ret == 0 ] ; then
	log "INFO: OCS_RESTORE on OMSAS server successful."
else 
	G_PASS_FLAG=1
	log "ERROR: OCS_RESTORE on OMSAS server failed."
fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 1 ]; then
                log "INFO:$FUNCNAME::verifying OCS backup script on OMSAS"
                executeOcsBackupOnOMSAS
        fi
		
		if [ $l_action == 2 ]; then
                log "INFO:$FUNCNAME::verifying OCS restore script on OMSAS"
                executeOcsRestoreOnOMSAS
        fi
}

#########
##MAIN ##
#########

log "Starting OCS backup and resotre actions"
#if preconditions execute pre conditions
#prepareOMSAStoBackupAndRestore
#main Logic should be in executeActions subroutine with numbers in order.

#To take OCS backup
log "ACTION 1 Started"
#executeAction 1
log "ACTION 1 Completed"

#To restore OCS backup data
log "ACTION 2 Started"
#executeAction 2
log "ACTION 2 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC


