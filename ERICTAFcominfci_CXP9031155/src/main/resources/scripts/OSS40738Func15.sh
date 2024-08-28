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

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        PATH_DIR="/ericsson/opendj/"
	LOG_PATH=OPENDJ_LOG
else
        PATH_DIR="/ericsson/sdee/"
	LOG_PATH=SDEE_LOG
		
fi

###################################
# This function is to create inputs
# for expect function. Add the expect string
# and send string  in sequence.
prepareExpects_addTarget ()
{
       EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -a target -T t1,t2,*,t3 -u user123"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
Please confirm that you want to proceed with requested actions
Yes' > $INPUTEXP
	
} 
prepareExpects_listTarget ()
{
       EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user123"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}_list.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}_list.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	
} 
prepareExpects_addTarget2 ()
{
       EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -a target -u user123"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}_add2.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}_add2.exp
        echo 'LDAP Directory Manager password
ldappass
Enter target names to add as a comma separated list
t4,t5,t6,*
Please confirm that you want to proceed with requested actions
Yes' > $INPUTEXP

}
prepareExpects3 ()
{
       EXPCMD="${PATH_DIR}/bin/del_user.sh"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}_del.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}_del.exp
	echo 'LDAP Directory Manager password
ldappass
Local user name
user123
Continue to delete local user 
y' > $INPUTEXP
	
} 
###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1
if [ $l_action == "1" ]; then
	log "Performing Add user"
	LDAP_CREATE_USER "vts.com" "user123" "shroot@1" || {
		log "Failed in LDAP_CREATE_USER with exit code $?"
	}
fi  

 
if [ $l_action == "2" ]; then
	target_give="t1 t2 t3 * "
	prepareExpects_addTarget
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/prepareExpects_addTarget.txt
	prepareExpects_listTarget
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/prepareExpect_listTarget.txt
	#target_list=`/usr/bin/grep Target  /tmp/prepareExpect_listTarget.txt | dos2unix| /usr/bin/awk '{print $3}' | /usr/bin/tr "\n" " "`	
	target_list=`/usr/bin/grep Target  /tmp/prepareExpect_listTarget.txt | /usr/bin/dos2unix| /usr/bin/awk '{print $3}' | /usr/bin/tr "\n" " "`	
	if [ "$target_give" == "$target_list" ] ;then
		log "SUCCESS:$FUCNAME:: Sucessfully added targets to \* to user123"
	else
		G_PASS_FLAG=1
	        log "ERROR:$FUNCNAME:: Failed in adding targets t1 t2 t3 *"
	fi
	#CODE SHOULD BE WRITTEN TO REMOVE THE TARGETS
fi

if [ $l_action == "3" ]; then
	target_give="t1 t2 t3 t4 t5 t6 * "
	prepareExpects_addTarget2
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/prepareExpects_addTarget2.txt
	prepareExpects_listTarget
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/prepareExpect_listTarget2.txt
	target_list=`/usr/bin/grep Target  /tmp/prepareExpect_listTarget2.txt | /usr/bin/dos2unix| /usr/bin/awk '{print $3}' | /usr/bin/tr "\n" " "`	
	if [ "$target_give" == "$target_list" ] ;then
		log "SUCCESS:$FUCNAME:: Sucessfully added targets to \* to user123"
	else
		G_PASS_FLAG=1
	        log "ERROR:$FUNCNAME:: Failed in adding targets t4, t5,t6 "
	fi
	#CODE SHOULKD BE WRITTEN TO REMOVE THE EXISTING TARGETS
fi
if [ $l_action == "4" ]; then
	prepareExpects3
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/del_user.txt
	#getSDEELogs "del_user.sh"
#	/usr/bin/grep "successfully removed" ${LOG_PATH} || {
	/usr/bin/grep "successfully removed" /tmp/del_user.txt || {
		G_PASS_FLAG=1
	        log "ERROR:$FUNCNAME:: Failed in removing the user123 check log ${LOG_PATH}"
	}
fi

}
#########
##MAIN ##
#########
#FUCNAME=OSS_4738Func15
log "Starting Pre condition"
#if preconditions execute pre conditions
executeAction 1
#main Logic should be in executeActions subroutine with numbers in order.
#executeAction 1

log "Start of TC"
executeAction 2
executeAction 3
executeAction 4
#Final assertion of TC, this should be the final step of tc
evaluateTC
