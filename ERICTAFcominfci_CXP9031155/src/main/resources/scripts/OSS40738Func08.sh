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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/1352
##TC VARIABLE##

G_COMLIB=commonFunctions.lib
#source the commonFunctions.
source $G_COMLIB
G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
file1="/tmp/batchfile1"
file2="/tmp/batchfile2"
file3="/tmp/batchfile3"
#SCRIPT=/ericsson/sdee/bin/manage_COM_privs.bsh


pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        LOG_FN=getOPENDJLogs
	SCRIPT=/ericsson/opendj/bin/manage_COM_privs.bsh
		
else
        LOG_FN=getSDEELogs
	SCRIPT=/ericsson/sdee/bin/manage_COM_privs.bsh
		
fi



LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
		mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
###################################
#this function is for verifying the 
#validation of domain by /ericsson/sdee/bin/manage_COM_privs.bsh script
#################################

prepareWithouDomain () {
	echo 'ACTION add
OBJECT target
testu1 target1' > $file1
}

prepareInvalidDomain () {
	echo 'DOMAIN xyz@123
ACTION add
OBJECT target
testu1 target1' > $file2
}

prepareTwoDomain () {
	echo 'DOMAIN vts.com abc123
ACTION add
OBJECT target
testu1 target1' > $file3
}

function prepareExpects () {
	   EXPCMD="$SCRIPT -b $1 -d $2"
	   EXITCODE=5
	   INPUTEXP=/tmp/${SCRIPTNAME}.in
	   OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	   echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
}


function invalidManageCom () {
	l_cmd=`$SCRIPT -l -u testu2 -d @xyz.com`
	${LOG_FN} "manage_COM_privs"
	ERROR_STG="does not exist in LDAP"
	l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH` 
	ret=$?
	if [ $ret == 0 ] ; then
		log "SUCCESS:$FUCNAME:: Successfully verified ERROR for invalid domain name with -d option.please Refer to $LOG_PATH"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to verify ERROR for invalid domain name with -d option.please Refer to $LOG_PATH"
	fi
	 
}

function WithoutDomain ()
{
	prepareWithouDomain
	prepareExpects "$file1" "vts.com"
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	rm -f $file1
	${LOG_FN} "manage_COM_privs"
	ERROR_STG="Unable to locate/parse DOMAIN line in batch file"
	l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH` 
	ret=$?
	if [ $ret == 0 ] ; then
		log "SUCCESS:$FUCNAME:: Successfully verified ERROR for non-existence of DOMAIN in batch file.please Refer to $LOG_PATH"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to verify ERROR for non-existence of DOMAIN in batch file.please Refer to $LOG_PATH"
	fi
}

function InvalidDomain ()
{
	prepareInvalidDomain
	prepareExpects "$file2" "vts.com"
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	${LOG_FN} "manage_COM_privs"
	ERROR_STG="in batch file does not match domain"
	l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH` 
	ret=$?
	if [ $ret == 0 ] ; then
		log "SUCCESS:$FUCNAME:: Successfully verified ERROR for INVALID DOMAIN in batch file when calling with valid domain.please Refer to $LOG_PATH"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to verify ERROR for INVALID DOMAIN in batch file when calling with valid domain.please Refer to $LOG_PATH"
	fi
	prepareExpects "$file2" "xyz@123"
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	${LOG_FN} "manage_COM_privs"
	ERROR_STG="does not exist in LDAP"
	l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH` 
	ret=$?
	if [ $ret == 0 ] ; then
		log "SUCCESS:$FUCNAME:: Successfully verified ERROR for INVALID DOMAIN in batch file when calling with same Invalid domain as in batch file.please Refer to $LOG_PATH"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to verify ERROR for INVALID DOMAIN in batch file when calling with same Invalid domain as in batch file .please Refer to $LOG_PATH"
	fi
	
}

function TwoDomain ()
{
	prepareTwoDomain
	prepareExpects "$file3" "vts.com"
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	rm -f $file3
	${LOG_FN} "manage_COM_privs"
	ERROR_STG="invalid lines in batch file"
	l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH` 
	ret=$?
	if [ $ret == 0 ] ; then
		log "SUCCESS:$FUCNAME:: Successfully verified ERROR for passing two domains in batch file.please Refer to $LOG_PATH"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to verify ERROR for paassing two domains in batch file.please Refer to $LOG_PATH"
	fi
}
###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
	if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::Verify invalid domain name with -d option while passing parameter to manage_COM_privs.bsh"
	invalidManageCom
	fi
 
	if [ $l_action == 2 ]; then
	log "INFO:$FUNCNAME::Verify missing domain name in batch file "
	WithoutDomain 
	fi
 
	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::Verify invalid domain name in batch file "
	InvalidDomain 
	fi

	
	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::verify giving two domain names in the batch file"
	TwoDomain 
	fi


}
#########
##MAIN ##
#########


# Verify invalid domain name with -d option while passing parameter to manage_COM_privs.bsh
executeAction 1

#Do not mention the DOMAIN name in the batch file  and check to add priveleges to user 
executeAction 2

#Give different domain names in the batch f	ile (invalid domain name)
executeAction 3

#Give two domain names in the batch file and check to add priveleges to user using the script
executeAction 4

#Final assertion of TC, this should be the final step of tc
evaluateTC

