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
SMRS_DIR=/opt/ericsson/nms_bismrs_mc/bin/

function checkMounts()
 {

        log "INFO::$FUNC:: Checking mounts owner permission on NEDSS server"

        ########################CORE ##################################################

        if [[ $(ls -ltr /export/CORE | grep nedssv4 | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: Nedssv4 has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/CORE | grep nedssv4 | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: Nedssv4 has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct user permissions"
        fi

        if [[ $(ls -ltr /export/CORE | grep CommonPersistent | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: CommonPersistent has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/CORE | grep CommonPersistent | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: CommonPersistent has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct user permissions"
        fi

        ###WRAN##################################################################################


        if [[ $(ls -ltr /export/WRAN | grep nedssv4 | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: Nedssv4 has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/WRAN| grep nedssv4 | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: Nedssv4 has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct user permissions"
        fi

        if [[ $(ls -ltr /export/WRAN | grep CommonPersistent | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: CommonPersistent has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/WRAN | grep CommonPersistent | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: CommonPersistent has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct user permissions"
        fi


        ####################### LRAN ################################################################

        if [[ $(ls -ltr /export/LRAN | grep nedssv4 | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: Nedssv4 has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/LRAN | grep nedssv4 | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: Nedssv4 has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct user permissions"
        fi

        if [[ $(ls -ltr /export/LRAN | grep CommonPersistent | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: CommonPersistent has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/LRAN | grep CommonPersistent | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: CommonPersistent has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct user permissions"
        fi

        ##################################### GRAN ####################################################

        if [[ $(ls -ltr /export/GRAN | grep nedssv4 | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: Nedssv4 has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/GRAN | grep nedssv4 | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: Nedssv4 has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: Nedssv4 doesnot have correct user permissions"
        fi

        if [[ $(ls -ltr /export/GRAN | grep CommonPersistent | awk '{print $4}') = nms ]]; then
                log "INFO::$FUNC: CommonPersistent has correct group permissions nms"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct group permissions"
        fi

        if [[ $(ls -ltr /export/GRAN | grep CommonPersistent | awk '{print $3}') = root ]]; then
                log "INFO::$FUNC: CommonPersistent has correct user permissions root"
        else
                G_PASS_FLAG=1
                log "ERROR::$FUNC: CommonPersistent doesnot have correct user permissions"
        fi



}


###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 1 ]; then
                log "INFO:$FUNCNAME::Checking mounts owner permission on NEDSS server"
                checkMounts

        fi

}

#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Checking mounts owner permission on NEDSS server
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC


