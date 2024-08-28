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
        mkdir $LOG_DIR || {
	  G_PASS_FLAG=1
	  evaluateTC
        }
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
file3="/tmp/file1"
SMRS_BIN=/opt/ericsson/nms_bismrs_mc/bin

###################################
#Creating aif users pre-migration
#################################
function addAifUser ()
{
	for i in GRAN CORE LRAN WRAN
	do
		for j in nedssv4 nedssv6
		do
			${SMRS_BIN}/add_aif.sh -l | grep -i test_${i}_${j}
			if [[ $? -eq 0 ]];then
				log "Skipping the user creation of test_${i}_${j} as the user already exists.."
			else
				${SMRS_BIN}/add_aif.sh -n ${i} -a test_${i}_${j} -p Shroot@12 -s ${j} > /dev/null 2>&1
				if [[ $? -eq 0 ]];then
					log "SUCCESS:$FUNCNAME::Successfully created the AIF user: test_${i}_${j}"
				else
					G_PASS_FLAG=1
					log "ERROR:$FUNCNAME::Failed to create AIF user: test_${i}_${j}"
				fi
			fi
		done
	done
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::Creating AIF Users...."
   addAifUser
 fi
 
 } 
  
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Verify om_serv_master ,om_serv_slave are in time sync
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
