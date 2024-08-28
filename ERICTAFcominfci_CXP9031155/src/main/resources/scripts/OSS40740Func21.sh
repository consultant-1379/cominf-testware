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

 l_cmd=`/opt/ericsson/arne/bin/import.sh -import -i_nau -f /tmp/OSS40740Func21_create.xml | tee /tmp/create_log.txt`
 l_cmd1=`sed -n -e '/Import Finished/p' -e '/No Errors/p' /tmp/create_log.txt`
 ret=$?
 if [ $ret != 0 ]
 then
                G_PASS_FLAG=1
                log "FAILED:: INPUT XML file /tmp/OSS40740Func21_create.xml is not correct"

 else
        log "SUCESS:: INPUT XML file /tmp/OSS40740Func21_create.xml is correct and NODE is added sucessfully"
fi
rm /tmp/create_log.txt

}

function directoriesCheck () {

        DIR_MASTER=/var/opt/ericsson/smrsstore/GRAN/nedssv4/GRAN_MLPPP_Router_TC08
        if [ -d $DIR_MASTER/NePersistent ] ; then
                log "INFO:: Directory $DIR_MASTER/NePersistent exists"
        else
                G_PASS_FLAG=1
                log "ERROR:: Directory $DIR_MASTER/NePersistent does not exists"
        fi

        if [ -d $DIR_MASTER/NeTransientUp/PM ] ; then
                log "INFO:: Directory $DIR_MASTER/NeTransientUp/PM exists"
        else
                G_PASS_FLAG=1
                log "ERROR:: Directory $DIR_MASTER/NeTransientUp/PM does not exists"
        fi

        DIR_OTHER=/export/GRAN/nedssv4/GRAN_MLPPP_Router_TC08

        l_cmd=`ssh smrs_master ls -A $DIR_OTHER/NePersistent && echo "Not Empty" || echo "Empty"`
                if [[ $l_cmd == "Not Empty" ]] ; then
                        log "INFO:: $DIR_OTHER/NePersistent exists"
                else
                        G_PASS_FLAG=1
                        log "ERROR:: $DIR_OTHER/NePersistent does not exists"
                fi
        l_cmd1=`ssh smrs_master ls -A $DIR_OTHER/NeTransientUp/PM && echo "Not Empty" || echo "Empty"`
                if [[ $l_cmd == "Not Empty" ]] ; then
                        log "INFO:: $DIR_OTHER/NeTransientUp/PM exists"
                else
                        G_PASS_FLAG=1
                        log "ERROR:: $DIR_OTHER/NeTransientUp/PM does not exists"
                fi

        l_cmd2=`ssh smrs_master ssh nedss ls -A $DIR_OTHER/NePersistent && echo "Not Empty" || echo "Empty"`
                if [[ $l_cmd == "Not Empty" ]] ; then
                        log "INFO:: $DIR_OTHER/NePersistent exists"
                else
                        G_PASS_FLAG=1
                        log "ERROR:: $DIR_OTHER/NePersistent does not exists"
                fi
        l_cmd3=`ssh smrs_master ssh nedss ls -A $DIR_OTHER/NeTransientUp/PM && echo "Not Empty" || echo "Empty"`
                if [[ $l_cmd == "Not Empty" ]] ; then
                        log "INFO:: $DIR_OTHER/NeTransientUp/PM exists"
                else
                        G_PASS_FLAG=1
                        log "ERROR:: $DIR_OTHER/NeTransientUp/PM does not exists"
                fi
}


function deleteNode()
{

 l_cmd=`/opt/ericsson/arne/bin/import.sh -import -i_nau -f /tmp/OSS40740Func21_delete.xml | tee /tmp/delete_log.txt`
 l_cmd1=`sed -n -e '/Import Finished/p' -e '/No Errors/p' /tmp/delete_log.txt`
 ret=$?
 if [ $ret != 0 ]
 then
                G_PASS_FLAG=1
                log "FAILED:: INPUT XML file /tmp/OSS40740Func21_delete.xml is not correct"
 else
                sleep 120
                l_cmd2=`/opt/ericsson/arne/bin/export.sh -f /var/tmp/1.txt`
                l_cmd3=`grep GRAN_MLPPP_Router_TC08 /var/tmp/1.txt`
                ret=$?
                if [ $ret != 0 ] ; then
                        log "INFO:: NODE deleted "
                else
                        G_PASS_FLAG=1
                        log "ERROR:: NODE not deleted"
                fi


 fi

 }

function nodeAdditionDeletion () {

if [ `smtool -l | grep -i smrs | grep -c started` == 1 ]
then
        if [ `hostname` == "ossmaster" ]
        then
                                log "INFO:: Creating the NODE"
                                createNode
                                log "Checking the directories on OSS , SMRS Master and NEDSS"
                                directoriesCheck
                                log "INFO:: Deleting the NODE"
                                deleteNode
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



