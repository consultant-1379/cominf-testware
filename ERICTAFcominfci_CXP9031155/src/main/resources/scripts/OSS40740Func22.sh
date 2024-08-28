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


##############################################################################
function createNode()
{

 l_cmd=`/opt/ericsson/arne/bin/import.sh -import -i_nau -f /tmp/OSS40740Func22_create.xml | tee /tmp/create_log.txt`
 l_cmd1=`sed -n -e '/Import Finished/p' -e '/No Errors/p' /tmp/create_log.txt`
 ret=$?
 if [ $ret != 0 ]
 then
                G_PASS_FLAG=1
                log "FAILED:: INPUT XML file /tmp/OSS40740Func22_create.xml is not correct"

 else
        log "SUCESS:: INPUT XML file /tmp/OSS40740Func22_create.xml is correct and NODE is added sucessfully"
fi
rm /tmp/create_log.txt

}

function prepareExpects () {
	EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh add aif"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'Enter Network Type
WRAN
What is the name for this user
wranaif
What is the password for this user
shroot@1
Please confirm the password for this user
shroot@1
Would you like to create autoIntegration FtpService for that user
yes
Please enter number of required option
1
Do you wish to restart BI_SMRS_MC on the OSS master if required?
yes' > $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
}	

function prepareExpects1 () {
	EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete aif"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'What is the name for this user
wranaif
Would you like to remove autoIntegration FtpService for that user
yes
Are you sure you want to delete this user
yes'> $INPUTEXP
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP

}

function directoriesCheck () {


        if [ -d /var/opt/ericsson/smrsstore/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 ] ; then
                log "INFO:: Directory /var/opt/ericsson/smrsstore/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 exists"
        else
                G_PASS_FLAG=1
                log "ERROR:: Directory /var/opt/ericsson/smrsstore/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 does not exists"
        fi



        l_cmd=`ssh smrs_master ls -A /export/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 && echo "Not Empty" || echo "Empty"`
                if [[ $l_cmd == "Not Empty" ]] ; then
                        log "INFO:: /export/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 exists"
                else
                        G_PASS_FLAG=1
                        log "ERROR:: /export/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 does not exists"
                fi

        l_cmd2=`ssh smrs_master ssh -o StrictHostKeyChecking=no nedss ls -A /export/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 && echo "Not Empty" || echo "Empty"`
                if [[ $l_cmd == "Not Empty" ]] ; then
                        log "INFO:: /export/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 exists"
                else
                        G_PASS_FLAG=1
                        log "ERROR:: /export/WRAN/nedssv4/AIF/WRAN/WRAN_RBS_T1 does not exists"
                fi

}


function deleteNode()
{

 l_cmd=`/opt/ericsson/arne/bin/import.sh -import -i_nau -f /tmp/OSS40740Func22_delete.xml | tee /tmp/delete_log.txt`
 l_cmd1=`sed -n -e '/Import Finished/p' -e '/No Errors/p' /tmp/delete_log.txt`
 ret=$?
 if [ $ret != 0 ]
 then
                G_PASS_FLAG=1
                log "FAILED:: INPUT XML file /tmp/OSS40740Func22_delete.xml is not correct"
 else
                sleep 120
                l_cmd2=`/opt/ericsson/arne/bin/export.sh -f /var/tmp/1.txt`
                l_cmd3=`grep WRAN_RBS_T1 /var/tmp/1.txt`
                ret=$?
                if [ $ret != 0 ] ; then
                        log "INFO:: NODE deleted "
                else
                        G_PASS_FLAG=1
                        log "ERROR:: NODE not deleted"
                fi


 fi

 rm /tmp/delete_log.txt
 }

function nodeAdditionDeletion () {

if [ `smtool -l | grep -i smrs | grep -c started` == 1 ]
then
        if [ `hostname` == "ossmaster" ]
        then
                                log "INFO:: Creating the NODE"
								prepareExpects
                                createNode
                                log "Checking the directories on OSS , SMRS Master and NEDSS"
                                directoriesCheck
                                log "INFO:: Deleting the NODE"
                                deleteNode
								prepareExpects1
                else
                        G_PASS_FLAG=1
                log "FAILED:: The server is not OSS master. Please logon to OSS"

        fi
else
                G_PASS_FLAG=1
        log "FAILED:: BISMRS_MC is not in STARTED state. Node cannot be added. "

fi

}

###############################
#Execute the action to be performed
#####################################

function executeAction () {
        l_action=$1

        if [[ "$l_action" == 1 ]] ; then
                log "INFO:: Adding and Deleting the NODE "
                nodeAdditionDeletion
        fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Adding and Deleting the NODE
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC



