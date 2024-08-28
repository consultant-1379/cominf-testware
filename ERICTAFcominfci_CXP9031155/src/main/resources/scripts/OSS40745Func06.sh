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



##########################################################
#this function is for verifying the citrix patch 68 update
##########################################################
function checkCTXSmf () {
		
		
		#l_cmd=`pkginfo -l CTXSmf | grep PSE400SOLX068`
		l_cmd=`pkginfo -l CTXSmf | egrep "PSE400SOLX068|PSE400SOLX070|PSE400SOLX071"`
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO:: Citrix Patch 68 has been updated successfully"
			else
				G_PASS_FLAG=1
				log "ERROR:: Patch 68 is not updated"
				fi
		
}
###############################
#Execute the action to be performed
#####################################

function executeAction ()
{
 	log "INFO:: Started ACTION "
	checkCTXSmf
	log "INFO:: Completed ACTION "
   

}

#########
##MAIN ##
#########


# Executing preconditions:Adding Required roles
executeAction


#Final assertion of TC, this should be the final step of tc
evaluateTC

