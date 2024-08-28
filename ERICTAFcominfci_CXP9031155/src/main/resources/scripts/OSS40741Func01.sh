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
function prepareExpects ()
{

        EXPCMD="$SMRS_DIR/configure_smrs.sh add aif"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Enter Network Type
WRAN
What is the name for this user
usr_TC01
What is the password for this user
@password
Please confirm the password for this user
@password
Would you like to create autoIntegration FtpService for that user
yes
Please enter number of required option
1
Do you wish to restart BI_SMRS_MC on the OSS master if required
yes' > $INPUTEXP
}

function prepareExpects1 ()
{

        EXPCMD="$SMRS_DIR/configure_smrs.sh add aif"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Enter Network Type
LRAN
What is the name for this user
usr_TC02
What is the password for this user
@password
Please confirm the password for this user
@password
Would you like to create autoIntegration FtpService for that user
yes
Please enter number of required option
1
Do you wish to restart BI_SMRS_MC on the OSS master if required
yes' > $INPUTEXP
}

function prepareExpects2 ()
{

        EXPCMD="$SMRS_DIR/configure_smrs.sh delete aif"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'What is the name for this user
usr_TC01
Would you like to remove autoIntegration FtpService for that user
no
Are you sure you want to delete this user
yes' > $INPUTEXP
}

function prepareExpects3 ()
{

        EXPCMD="$SMRS_DIR/configure_smrs.sh delete aif"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'What is the name for this user
usr_TC02
Would you like to remove autoIntegration FtpService for that user
no
Are you sure you want to delete this user
yes' > $INPUTEXP
}

function  addingAIFUser()
{
	log "INFO::$FUNC:: Adding Aif users"
	prepareExpects
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
     executeExpect $OUTPUTEXP
	 ret=$?
	 if [ $ret == 0 ] ; then
		log "INFO::$FUNC: Added usr_TC01 WRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR::$FUNC: Failed to add usr_TC01 aif user"
	fi
	 
	 prepareExpects1
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
     executeExpect $OUTPUTEXP
	 ret=$?
	 if [ $ret == 0 ] ; then
		log "INFO::$FUNC: Added usr_TC02 LRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR::$FUNC: Failed to add usr_TC02 aif user"
	fi
	
	
}

function deletingAIFUser()
 {
 
	log "INFO::$FUNC:: Deleting the added AIF users"
	 prepareExpects2
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
     executeExpect $OUTPUTEXP
	 ret=$?
	 if [ $ret == 0 ] ; then
		log "INFO::$FUNC: Deleted usr_TC01 WRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR::$FUNC: Failed  to delete usr_TC01 aif user"
	fi
	
	 
	 prepareExpects3
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
     executeExpect $OUTPUTEXP
	 ret=$?
	 if [ $ret == 0 ] ; then
		log "INFO::$FUNC: Deleted usr_TC02 LRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR::$FUNC: Failed to delete usr_TC02 aif user"
	fi
		

}

function deletingARNEimports()
{	
	
	l_cmd=`/opt/ericsson/arne/bin/import.sh -val:rall -f /var/opt/ericsson/arne/FTPServices/usr_TC01_WRAN_nedssv4_AIF_DEL.xml`
	l_cmd1=`/opt/ericsson/arne/bin/import.sh -import -i_nau -f /var/opt/ericsson/arne/FTPServices/usr_TC01_WRAN_nedssv4_AIF_DEL.xml`
	 if [ $ret == 0 ] ; then
		log "INFO::$FUNC: Deleted ARNE imports related to usr_TC01 WRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR::$FUNC: Failed to Delete ARNE imports related to usr_TC01 WRAN Aif user"
	fi
	
	l_cmd2=`/opt/ericsson/arne/bin/import.sh -val:rall -f /var/opt/ericsson/arne/FTPServices/usr_TC02_LRAN_nedssv4_AIF_DEL.xml`
	l_cmd3=`/opt/ericsson/arne/bin/import.sh -import -i_nau -f /var/opt/ericsson/arne/FTPServices/usr_TC02_LRAN_nedssv4_AIF_DEL.xml`
	if [ $ret == 0 ] ; then
		log "INFO::$FUNC: Deleted ARNE imports related to usr_TC02 LRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR::$FUNC: Failed to Delete ARNE imports related to usr_TC02 LRAN Aif user"
	fi
	
}
	
###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
 
	if [ $l_action == 1 ]; then
		log "INFO:$FUNCNAME::Adding Aif users"
		addingAIFUser
        
        fi
	
	if [ $l_action == 2 ]; then
		log "INFO:$FUNCNAME::Deleting Aif users"
		deletingAIFUser
        
    fi
	
	if [ $l_action == 3 ]; then
		log "INFO:$FUNCNAME::Deleting ARNE imports after the test case is executed"
		deletingARNEimports
        
    fi
	
	
}

#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Adding AIF users
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Deleting AIF users
log "ACTION 2 Started"
executeAction 2
log "ACTION 2 Completed"


#Deleting ARNE imports
log "ACTION 3 Started"
executeAction 3
log "ACTION 3 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC



