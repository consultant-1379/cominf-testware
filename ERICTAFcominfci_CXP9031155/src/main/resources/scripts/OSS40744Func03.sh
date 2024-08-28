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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/
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

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
      	PATH_DIR=/ericsson/opendj
else
       	PATH_DIR=/ericsson/sdee
fi																


function prepareExpects () {

       EXPCMD="${PATH_DIR}/bin/add_user.sh"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
New local user name
OSS40744
Start of uidNumber search range
\r
End of uidNumber search range
\r
New local user uidNumber
\r
New local user password:
password
Re-enter password
password
New local user category
sys_adm
New local user description
\r
Continue to create local user
y' > $INPUTEXP
} 

function prepareExpects1 () {

       EXPCMD="${PATH_DIR}/bin/del_user.sh"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
       echo 'LDAP Directory Manager password
ldappass
Local user name
OSS40744
Continue to delete local user
y' > $INPUTEXP

}

function prepareExpects2 () {

	EXPCMD="ssh -o StrictHostKeyChecking=no comnfadm@ossmaster"
	EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo '#
exit' > $INPUTEXP 
}
function delUser () {

	prepareExpects1
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	prepareExpects3
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP > /var/tmp/users1.txt
	l_Cmd=`grep -w OSS40744 /var/tmp/users1.txt`

	ret=$?
	if [ $ret != 0 ] ; then
		log "INFO:: User deleted sucessfully"
	else
		G_PASS_FLAG=1
		log "ERROF:: User not deletd sucessfully"
	fi
	

}

function prepareExpects3 () {
       EXPCMD="${PATH_DIR}/bin/list_users"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
       echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP

}
	

function addUser () {

	prepareExpects
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	prepareExpects3
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP > /var/tmp/users2.txt
        l_Cmd=`grep -w OSS40744 /var/tmp/users2.txt`
	ret=$?
	if [ $ret == 0 ] ; then
		log "INFO:: User added sucessfully"
	else
		G_PASS_FLAG=1
		log "ERROF:: User not added sucessfully"
	fi
	

}
function sshToOssmaster () {

        prepareExpects2
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP

}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 1 ]; then
                log "INFO:$FUNCNAME:: Adding the user to sys_Adm group"
                addUser
		log "INFO:$FUNCNAME:: Deleting the user to sys_Adm group"
		delUser
        fi
}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

log "INFO:: login to ossmaster with comnfadm user"
sshToOssmaster
log "INFO::  logged out from ossmaster with comnfadm user"

#main Logic should be in executeActions subroutine with numbers in order.

#Adding and deleting the user to and from sys_Adm group
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

rm -rf /var/tmp/users*

#Final assertion of TC, this should be the final step of tc
evaluateTC



