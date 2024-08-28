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
authenticate()
{

#ACTION1:-
#Checking for passwordless authentication b/w OSS and SMRS.

ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' smrs_master "echo" > /dev/null 2>&1
PASSWORDLESS_COONECTION=$?
[ "$PASSWORDLESS_COONECTION"  -ne 0 ] && {
                                                log "ERROR :- Passwordless connection doesnot exist between OSS and SMRS"
                                                G_PASS_FLAG=1
                                         }
[ "$PASSWORDLESS_COONECTION"  -eq 0 ] && log "SUCCESS :- Passwordless connection exists between OSS and SMRS"


}
smrs_upgrade()
{

#ACTION2 :-
#Checking whether SMRS upgrade is successfull or not in logs /var/opt/ericsson/log/ folder.

getSMRSLogs "upgrade_smrs.sh"
ERROR_STG="SMRS successfully upgraded"
l_cmd=`grep -c "${ERROR_STG}" $ERIC_LOG`


[ "$l_cmd" -ne 1 ] && {
                                log "ERROR :- SMRS Upgrade was not successfull. "
                                G_PASS_FLAG=1
                        }

[ "$l_cmd" -eq 1 ] && log "SUCCESS :- SMRS upgrade was successfull "


}
rsa_keys_2048()
{

#ACTION3 :-
#Checking whether OSS, SMRS, NEDSS server contains 2048 rsa keys or not.

OS_VER=`uname -r`

if [[ "$OS_VER" = "5.11" ]]; then
#Sol11
	#In OSS:-
	rsa_size=`ssh-keygen -l -f /root/.ssh/id_rsa | awk '{ print $1 }'`
	[ "$rsa_size" -ne 2048 ] && {
		G_PASS_FLAG=1
		log "ERROR:- OSS server doesnot contain 2048 size rsa keys"
		}

	#In SMRS MASTER:-
	rsa_size_smrs=`ssh smrs_master ssh-keygen -l -f /root/.ssh/id_rsa | awk '{ print $1 }'`
	[ "$rsa_size_smrs" -ne 2048 ] && {
		G_PASS_FLAG=1
		log "ERROR:- SMRS server doesnot contain 2048 size rsa keys"
		}

	#In NEDSS:-
	rsa_size_nedss=`ssh smrs_master ssh nedss ssh-keygen -l -f /root/.ssh/id_rsa | awk '{ print $1 }'`
	[ "$rsa_size_nedss" -ne 2048 ] && {
		G_PASS_FLAG=1
		log "ERROR:- NEDSS server doesnot contain 2048 size rsa keys"
		}

else
#Sol10
	#In OSS:-
	rsa_size=`ssh-keygen -l -f /.ssh/id_rsa | awk '{ print $1 }'`
	[ "$rsa_size" -ne 2048 ] && {
		G_PASS_FLAG=1
		log "ERROR:- OSS server doesnot contain 2048 size rsa keys"
		}

	#In SMRS MASTER:-
	rsa_size_smrs=`ssh smrs_master ssh-keygen -l -f /.ssh/id_rsa | awk '{ print $1 }'`
	[ "$rsa_size_smrs" -ne 2048 ] && {
		G_PASS_FLAG=1
		log "ERROR:- SMRS server doesnot contain 2048 size rsa keys"
		}

	#In NEDSS:-
	rsa_size_nedss=`ssh smrs_master ssh nedss ssh-keygen -l -f /.ssh/id_rsa | awk '{ print $1 }'`
	[ "$rsa_size_nedss" -ne 2048 ] && {
		G_PASS_FLAG=1
		log "ERROR:- NEDSS server doesnot contain 2048 size rsa keys"
		}
fi

}

#########
##MAIN ##
#########

log "Start of TC"

ls /etc/opt/ericsson/nms_bismrs_mc/smrs_config > /dev/null 2>&1
CONFIG_EXISTS=$?
UPGRADE_LOG_FILE=`ls /var/opt/ericsson/log/ | grep -c upgrade_smrs.sh`
if ([ $CONFIG_EXISTS -eq 0 ] && [ $UPGRADE_LOG_FILE -ge 1 ])
then
		authenticate
		smrs_upgrade
		rsa_keys_2048

else
		log "ERROR: SMRS Configuration / Upgrade is not yet completed "
fi
				
#Final assertion of TC, this should be the final step of tc
evaluateTC

