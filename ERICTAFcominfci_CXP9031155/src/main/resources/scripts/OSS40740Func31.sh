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
Var=0
Var2=0
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
         mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log

###################################
# Functions to Verify SGSN in nodeinfo.xml 
#################################

function CheckSGSNNode ()
{
	l_cmd=`grep "SGSN" /etc/opt/ericsson/nms_bismrs_mc/nodeinfo.xml`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME::Verified SGSN node in nodeinfo.xml"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error SGSN node is not found in nodeinfo.xml"
	fi 
}
##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
	l_action=$1
	if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::verifying SGSN node in nodeinfo.xml"
	CheckSGSNNode
	fi
}
#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Verifying SGSN node in nodeinfo.xml
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC


