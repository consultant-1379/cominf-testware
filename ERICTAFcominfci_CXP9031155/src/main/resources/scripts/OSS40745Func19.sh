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

OSVER=""
if [ `uname -r` = "5.10" ]; then
     OSVER="SOL10"
else
	 OSVER="SOL11"
fi

G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log



####################################
#checking firefox version
#################################

function checkfirefoxversion ()
{
    if [ $OSVER == "SOL10" ] ; then
        `/opt/firefox/bin/firefox -v > /var/tmp/fire.txt`
        res=`grep 38.7.1 /var/tmp/fire.txt`
                if [ $? == 0 ]; then
                        log "SUCCESS:$FUCNAME:TestCase sucess"
                else
                        log "FAILED:$FUCNAME:TestCase failed"
                        G_PASS_FLAG=1
                fi
        rm /var/tmp/fire.txt

    elif [ $OSVER == "SOL11" ] ; then

	if [ -f /opt/firefox/bin/firefox ]; then
              log "SUCCESS:$FUCNAME:TestCase sucess"
	else
              log "FAILED:$FUCNAME:TestCase failed"
	      G_PASS_FLAG=1
	fi 
    else
    	log "FAILED:$FUCNAME:TestCase failed"
	G_PASS_FLAG=1
    fi
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::checking firefox version in uas"
   checkfirefoxversion
 fi

 }


 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking ntp4 service state in om_serv_master,om_serv_slave,infra_omsas
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC

