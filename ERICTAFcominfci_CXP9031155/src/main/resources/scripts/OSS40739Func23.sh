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

###################################
# This function is to create inputs
# for expect function. Add the expect string
# and send string  in sequence.
createFiles ()
{

log "Creating multiple interfaces files in /etc folder"
echo "`hostname`-bnxe0 netmask + broadcast + group OM_INF deprecated -failover up addif xhkny91049 netmask + broadcast + failover up" > /etc/hostname.e1000g0.IPMP-NotUsed
echo "`hostname`" > /etc/hostname.e1000g0.org
echo "`hostname`-bnxe1 netmask + broadcast + group OM_INF deprecated -failover up" > /etc/hostname.e1000g1.IPMP-NotUsed
echo "`hostname`-bkp" > /etc/hostname.e1000g2
echo "`hostname`-bnxe4 netmask + broadcast + group OM_STOR deprecated -failover up addif xhkny91049-stor netmask + broadcast + failover up" > /etc/hostname.e1000g4
echo "`hostname`-bnxe5 netmask + broadcast + group OM_STOR deprecated -failover up" > /etc/hostname.e1000g5
echo "`hostname`-ma" > /etc/hostname.e1000g6

}

Verify()
{
l_cmd=`/ericsson/ocs/bin/setup_isc_dhcp.sh` 
l_status=`echo $?`
l_log=`ls -ltr /ericsson/ocs/log | grep "sys_setup_isc_dhcp" |tail -1 | awk '{ print $9}'`
l_search1=`grep -c "ERROR Unable to find the primary interface as more than one interfaces are using the hostname value" /ericsson/ocs/log/$l_log`
if [[ $l_search1 -ne 0 ]]
then
	if [[ $l_status -ne 1 ]]
		then
		G_PASS_FLAG=1
    		log "ERROR:$FUNCNAME::Unable to exit the script upon failure of script /ericsson/ocs/bin/setup_isc_dhcp.sh'"
	else
		log "SUCCESS:$FUNCNAME:: TR HT82353 functionality is working."
	fi
fi
l_count=`grep -c 'Cominf small upgrade has failed' /ericsson/ocs/bin/cominf_small_upgrade.sh`

if [[ $l_count -eq 3 ]]
then
	log "SUCCESS:$FUNCNAME:: TR HT82353 functionality is working."
else
	G_PASS_FLAG=1
    	log "ERROR:$FUNCNAME::Unable to exit the script upon failure of script /ericsson/ocs/bin/setup_isc_dhcp.sh'"
fi
}

DeleteFiles ()
{

log "Removing all the multiple interfaces files created"
rm /etc/hostname.e1000g0.IPMP-NotUsed /etc/hostname.e1000g0.org /etc/hostname.e1000g1.IPMP-NotUsed /etc/hostname.e1000g2 /etc/hostname.e1000g4 /etc/hostname.e1000g5 /etc/hostname.e1000g6
}
###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1
log "Performing Add user"
if [ $l_action == "1" ]; then
createFiles
Verify
DeleteFiles
fi

log "performing Delete user"
if [ $l_action == "2" ]; then
prepareExpects2
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP
evaluate $? "failed to delete user" "$EXITCODE"
fi
}
#########
##MAIN ##
#########

log "Start of TC"
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.
executeAction 1
#executeAction 2

#Final assertion of TC, this should be the final step of tc
evaluateTC
