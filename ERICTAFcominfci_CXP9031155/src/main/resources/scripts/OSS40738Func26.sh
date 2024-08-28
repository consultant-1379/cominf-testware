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

#http://taftm.lmera.ericsson.se/#tm/viewTC/5196
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

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
      	PATH_DIR=/ericsson/opendj
else
       	PATH_DIR=/ericsson/sdee
fi																


function bsimuserUIDVerification()
{
		l_cmd=`grep bsimuser ${PATH_DIR}/etc/reserved_users | awk '{print $2}'`
		uID_1=55001
		if [[ ${l_cmd} == $uID_1 ]] ; then
			log "INFO :: bsimuser with $uID_1 is present in ${PATH_DIR}/etc/reserved_users file "
		else
			G_PASS_FLAG=1
			log "ERROR :: bsimuser with $uID_1 is not present in ${PATH_DIR}/etc/reserved_users file "
		fi
}	



###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO: Verifying bsimuser $uID_1 in ${PATH_DIR}/etc/reserved_users file "
	bsimuserUIDVerification
fi

}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.
#Verifying bsimuser uID_1 in ${PATH_DIR}/etc/reserved_users file
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC

