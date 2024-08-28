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
##
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

function addAifAsRoot ()
{
        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -n WRAN -a usr_TC_12 -p shroot@123`
        ssh smrs_master grep usr_TC_12 /etc/passwd
                        ret=$?
			getSMRSLogs "add_aif.sh"

                        if [ $ret == 0 ] ; then

                                log "INFO: Added the aif user usr_TC_12"
                        else
                                G_PASS_FLAG=1
                                log "ERROR : Filed to add the aif user usr_TC_12 refer $ERIC_LOG"
                        fi
}


function addAifAsNmsadm() {

        EXPCMD="su - nmsadm"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo '$
/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -n WRAN -a usr_TC_13 -p shroot@123
$
exit'  > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        ssh smrs_master grep usr_TC_13 /etc/passwd
         ret=$?
	 getSMRSLogs "add_aif.sh"
                        if [ $ret == 0 ] ; then

                                log "INFO: Added the aif user usr_TC_13"
                        else
                                G_PASS_FLAG=1
                                log "ERROR : Failed to add the aif user usr_TC_13 $ERIC_LOG"
                        fi
}


function deleteAifRoot () {

        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/del_aif.sh -a usr_TC_13`
        ssh smrs_master grep usr_TC_13 /etc/passwd
             ret=$?
	     getSMRSLogs "del_aif.sh"
                        if [ $ret == 0 ] ; then
                                G_PASS_FLAG=1
                                log "ERROR: Failed to delete the aif user usr_TC_13 refer $ERIC_LOG"
                        else
                                log "INFO: Deleted the aif user usr_TC_13"
                        fi

}

function deleteAifNmsadm () {
        EXPCMD="su - nmsadm"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo '$
cd /opt/ericsson/nms_bismrs_mc/bin
$
./del_aif.sh -a usr_TC_12
$
exit'  > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        ssh smrs_master grep usr_TC_12 /etc/passwd
        ret=$?
	getSMRSLogs "del_aif.sh"
                        if [ $ret == 0 ] ; then
                                G_PASS_FLAG=1
                                log "ERROR: Failed to delete the aif user usr_TC_12 refer $ERIC_LOG"
                        else
                                log "INFO: Deleted the aif user usr_TC_12"
                        fi
}


###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 1 ]; then
                log "INFO:::Adding Aif users as ROOT user"
                addAifAsRoot

    fi

        if [ $l_action == 2 ]; then
                log "INFO:: Adding Aif users as nmsadm user"
                addAifAsNmsadm

    fi


        if [ $l_action == 3 ]; then
                log "INFO::NAME::Deleting aif user after the purpose of test case is completed"
                deleteAifRoot

    fi


        if [ $l_action == 4 ]; then
                log "INFO::NAME::Deleting aif user after the purpose of test case is completed"
                deleteAifNmsadm

    fi

}

#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Adding AIF as root user
#log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Adding aif user as nmsadm user
log "ACTION 2 Started"
executeAction 2
log "ACTION 2 Completed"

#Deleting added aif user as root user 
log "ACTION 3 Started"
executeAction 3
log "ACTION 3 Completed"

#Deleting aif users as nmsadm user
log "ACTION 4 Started"
executeAction 4
log "ACTION 4 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC


