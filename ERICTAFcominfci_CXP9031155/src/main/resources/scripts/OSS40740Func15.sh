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


###############################
#Execute the action to be performed
#####################################
createNode()
{

 /opt/ericsson/arne/bin/import.sh -import -i_nau -f /tmp/OSS40740Func15_create.xml | tee /tmp/HS77214_create_log.txt
 grep "Import Finished" /tmp/HS77214_create_log.txt
 if [ $? != 0 ]
 then
 		log "FAILED:- INPUT XML file /tmp/OSS40740Func15_create.xml is not correct"
 		G_PASS_FLAG=1
 else
        ls -ltr /var/opt/ericsson/smrsstore/GRAN/nedssv4/Cm/HS77214_GRAN_STN/NeTransientUp
        if [ $? != 0 ]
        then
        		log "FAILED:: NODE is not created properly. PAth /var/opt/ericsson/smrsstore/GRAN/nedssv4/Cm/HS77214_GRAN_STN/NeTransientUp is missing"
        		G_PASS_FLAG=1
        else
                cd /var/opt/ericsson/smrsstore/GRAN/nedssv4/Cm/HS77214_GRAN_STN/NeTransientUp/
                mkdir CM-Abis
                chmod 777 CM-Abis
                log "INFO:: CM-Abis is created under path /var/opt/ericsson/smrsstore/GRAN/nedssv4/Cm/HS77214_GRAN_STN/NeTransientUp/"
        fi
fi
rm /tmp/HS77214_create_log.txt

}

deleteNode()
{

 /opt/ericsson/arne/bin/import.sh -import -i_nau -f /tmp/OSS40740Func15_delete.xml | tee /tmp/HS77214_delete_log.txt
 grep "Import Finished" /tmp/HS77214_delete_log.txt
 if [ $? != 0 ]
 then
 		log "FAILED:: INPUT XML file /tmp/OSS40740Func15_delete.xml is not correct"
 		G_PASS_FLAG=1
 fi
 
 rm /tmp/HS77214_modify_log.txt

}

modifyNode()
{

 /opt/ericsson/arne/bin/import.sh -import -i_nau -f /tmp/OSS40740Func15_modify.xml | tee /tmp/HS77214_modify_log.txt
 grep "Import Finished" /tmp/HS77214_modify_log.txt
 if [ $? != 0 ]
 then
 		log "FAILED:: INPUT XML file /tmp/OSS40740Func15_modify.xml is not correct"
 		G_PASS_FLAG=1
 else
 		ls -ltr /var/opt/ericsson/smrsstore/GRAN/nedssv6/Cm/HS77214_GRAN_STN/NeTransientUp/CM-Abis
        if [ $? != 0 ]
        then
        		log "FAILED:: NODE is not modified properly. PAth /var/opt/ericsson/smrsstore/GRAN/nedssv6/Cm/HS77214_GRAN_STN/NeTransientUp/CM-Abis is missing"
        		G_PASS_FLAG=1
        else
                permissions="$(ls -ltr /var/opt/ericsson/smrsstore/GRAN/nedssv6/Cm/HS77214_GRAN_STN/NeTransientUp/ | tail -1 | cut -c -10)"
                if [ $permissions != "drwxrwxrwx" ]
                then
                		log "FAILED:: CM-Abis doesnot have the right permissions 777 . Existing permissions are 755"
                		G_PASS_FLAG=1
                else
                        log "SUCCESS:: CM-Abis is modified/copied successfully. Permissions are 777 "
                fi
        fi
 fi

rm /tmp/HS77214_modify_log.txt

}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions



if [ `smtool -l |grep -i smrs |grep -c  started` == 1 ]
then
        if [ `hostname` == "ossmaster" ]
        then
				createNode
				modifyNode
				deleteNode
		else
        	log "FAILED:: The server is not OSS master. Please logon to OSS"
        	G_PASS_FLAG=1
        fi
else
        log "FAILED:: BISMRS_MC is not in STARTED state. Node cannot be added. "
        G_PASS_FLAG=1
fi
				
#Final assertion of TC, this should be the final step of tc
evaluateTC

