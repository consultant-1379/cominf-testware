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

#http://taftm.lmera.ericsson.se/#tm/viewTC/5140
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
#SDSE_DIR=/ericsson/sdee/bin

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        PATH_DIR=/ericsson/opendj
        SCRIPT_DIR=/ericsson/opendj/bin
else
        SCRIPT_DIR=/ericsson/sdee/bin
        PATH_DIR=/ericsson/sdee
fi

Domain_Name=`grep LDAP_DOMAIN ${PATH_DIR}/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
importfile=/var/tmp/importfile1.txt

prepareImportFile () {
	echo 'DOMAIN vts.com
ROLE ERICSSON_SUPPORT,EricssonSupport'> $importfile
} 

function createRoles()
{

		EXPCMD="$SCRIPT_DIR/manage_COM.bsh -a import -d $Domain_Name -f $importfile"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
Continue to import COM node file
Yes' > $INPUTEXP

		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::created the roles which differ by "_""
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in creating the roles which differ by "_""
		fi 
}

function deleteRoles () {	
		EXPCMD="$SCRIPT_DIR/manage_COM.bsh -r role -R ERICSSON_SUPPORT,EricssonSupport"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass
Please confirm that you want to proceed with requested actions
Yes' > $INPUTEXP
	
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	}

###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO:preparing import file"
    prepareImportFile
	log "INFO:Roles Importing"
	createRoles
fi

if [ $l_action == "2" ]; then
	log "INFO:Deleting the Roles added."	
	deleteRoles
	fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.
#Importing roles using file
executeAction 1

#Deleting roles added
executeAction 2

#Final assertion of TC, this should be the final step of tc
evaluateTC
