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
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log

function prepareExpects ()
{

       EXPCMD="ssh-keygen -t rsa -b 2048"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
       echo 'Enter file in which to save the key
\r
Enter passphrase
\r
Enter same passphrase again
\r ' > $INPUTEXP
}

function prepareExpects1 () {
		EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ossmaster"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'Password
shroot12
#
su - comnfadm
#
mkdir -p /home/comnfadm/.ssh
#
exit
#
scp root@omsrvm:/root/.ssh/id_dsa.pub /home/comnfadm/.ssh/OMINFServer.pub
Password
shroot12
#
cd /home/comnfadm/.ssh
#
cat OMINFServer.pub >> authorized_keys2
#
rm OMINFServer.pub
#
chown -R comnfadm:other /home/comnfadm/.ssh/
#
chmod -R 0700 /home/comnfadm/.ssh/
#
exit' > $INPUTEXP

}

function prepareExpects2 () {
		EXPCMD="ssh -o StrictHostKeyChecking=no -l comnfadm ossmaster"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo '#
exit' > $INPUTEXP

}

function prepareExpects3 () {
		EXPCMD="ssh-keygen -t rsa -b 2048"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'Enter file in which to save the key
\r
Overwrite
yes
Enter passphrase
\r
Enter same passphrase again
\r' > $INPUTEXP

}



function  sshKeys () {

	mkdir /root/.ssh
	chmod 0700 /root/.ssh
	cd /root/.ssh
	prepareExpects
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
    executeExpect $OUTPUTEXP
	ret=$?
	if [ $ret == 0 ] ; then
		log "INFO::SSH Keys generated "
	else
		G_PASS_FLAG=1
		log "ERROR::SSH Keys not generated"
	fi
}



function passwordLessLogin() {

		prepareExpects1
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		prepareExpects2
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO::Passwordless connection sucess between omsermaster and OSS master"
			else
				G_PASS_FLAG=1
				log "ERROR:Passwordless connection not sucess between omsermaster and OSS master"
			fi
}

function sshKeysGeneration() {

if [ -d /root/.ssh ] ; then
	log "INFO:: /root/.ssh directory exiists "
else
	log "INFO:: Creating /root/.ssh  directory"
	sshKeys
fi

	if [ ! -f /root/.ssh/id_rsa.pub ] ; then
		cd /.ssh
		prepareExpects3
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
	fi
	
	passwordLessLogin
		

}


###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME::Generating the ssh keys and passwordless login from omsrvm to ossmaster with user comnfadm"
   sshKeysGeneration
   log "INFO:Completed ACTION 1"
 fi

}


#########
##MAIN ##
#########	
		
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Generating the ssh keys
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
