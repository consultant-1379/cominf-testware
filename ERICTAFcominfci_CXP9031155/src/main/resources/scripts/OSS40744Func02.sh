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
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
SCRIPT_DIR=${PATH_DIR}/bin
G_Backup_file="/var/tmp/ldap_backup/FILE/vts.com/"
OPENDJ=0
if [ ${PATH_DIR} == "/ericsson/opendj" ]; then
	SCRIPT=${PATH_DIR}/bin/OpenDJBR.sh
	OPENDJ=1
else
	SCRIPT=${PATH_DIR}/bin/SunDSBR.sh
fi
###################################
#This fucntion will delete all the aif
#users avaliable in system.
#################################

function prepareExpects ()
{
	EXPCMD=$1
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}

function checkFileBackup ()
{
	prepareExpects "${SCRIPT} -o backup -t file"
	if [ $OPENDJ == 1 ]; then
		getOPENDJLogs "OpenDJBR.sh"
		l_cmd=`grep FILE $OPENDJ_LOG | grep successfully`
	    if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::File Backup Successful"
			FileDir=`grep stored $OPENDJ_LOG |awk '{print $11}' |awk -F'/' '{print $8}' | awk -F']' '{print $1}'`
			if [  -d /var/tmp/ldap_backup/FILE/vts.com/$FileDir ]; then 
				log "SUCCESS:$FUNCNAME::Backup Dir is avaliable at /opt/opendj/bak/ldif/FILE/vts.com/$FileDir "
			else
				G_PASS_FLAG=1
				log "SUCCESS:$FUNCNAME::Backup Dir is not Avaliable "
			fi
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:File backup not Successful "
		fi
	else
		getSDEELogs "SunDSBR.sh"
		l_cmd=`grep FILE $SDEE_LOG | grep successfully`
	    if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::File Backup Successful"	
			FileDir=`grep stored $SDEE_LOG | awk '{print $11}' |awk -F'/' {'print $7}'| awk -F']' {'print $1}'`
			if [  -d /var/tmp/ldap_backup/FILE/vts.com/$FileDir ]; then 
				log "SUCCESS:$FUNCNAME::Backup Dir is avaliable at /var/tmp/ldap_backup/FILE/vts.com/$FileDir "
			else
				G_PASS_FLAG=1
				log "SUCCESS:$FUNCNAME::Backup Dir is not Avaliable "
			fi
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:File backup not Successful "
		fi
	fi
}
 function checkExeBackup ()
 {
	prepareExpects "${SCRIPT} -o backup -t binary"
	if [ $OPENDJ == 1 ]; then
		getOPENDJLogs "OpenDJBR.sh"
		l_cmd=`grep BINARY $OPENDJ_LOG | grep successfully`
		if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::Binary Backup Successful"
			FileDir=`grep stored $OPENDJ_LOG | awk '{print $9}' |awk -F'/' '{print $6}'| awk -F']' '{print $1}'`
			if [  -d /var/tmp/ldap_backup/BINARY/$FileDir ]; then 
				log "SUCCESS:$FUNCNAME::Backup Dir is avaliable at /var/tmp/ldap_backup/BINARY/vts.com/$FileDir "
			else
				G_PASS_FLAG=1
				log "SUCCESS:$FUNCNAME::Backup Dir is not Avaliable "
			fi
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:File backup not Successful "
		fi
	else
		getSDEELogs "SunDSBR.sh"
		l_cmd=`grep BINARY $SDEE_LOG | grep successfully`
		if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::Binary Backup Successful"
			FileDir=`grep stored $SDEE_LOG | awk '{print $9}' |awk -F'/' {'print $6}'| awk -F']' {'print $1}'`
			if [  -d /var/tmp/ldap_backup/BINARY/$FileDir ]; then 
				log "SUCCESS:$FUNCNAME::Backup Dir is avaliable at /var/tmp/ldap_backup/BINARY/vts.com/$FileDir "
			else
				G_PASS_FLAG=1
				log "SUCCESS:$FUNCNAME::Backup Dir is not Avaliable "
			fi
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:File backup not Successful "
		fi
			
	fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
 l_action=$1
 if [ $l_action == 1 ]; then 
  log "INFO:$FUNCNAME::File Backup of ldap"
   checkFileBackup
 fi 
 
 if [ $l_action == 2 ]; then 
  log "INFO:$FUNCNAME::File Backup of ldap Executable"
   checkExeBackup
 fi 
 
  
}
#########
##MAIN ##
#########
#Check File databackup.
executeAction 1

#Check File databackup.
executeAction 2

#Final assertion of TC, this should be the final step of tc
evaluateTC


