

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


function prepareExpects3 ()
{

        EXPCMD="$SMRS_DIR/configure_smrs.sh delete aif"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'What is the name for this user
usr_TC02
Would you like to remove autoIntegration FtpService for that user
yes
Are you sure you want to delete this user
yes' > $INPUTEXP
}

function ftpServiceExistence ()
{
			l_cmd=`/opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lt FtpService | grep usr_TC02`
			ret=$?
			if [ $ret == 0 ] ; then
				log "INFO:::: FTP service present"
			else
				G_PASS_FLAG=1
				log "ERROR::::: FTP services does not present when script aborted while deleting "
			fi
}

function aifUser() {
	 
	 prepareExpects1
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
function getSMRSLogs ()
{
ERIC_LOG=""
logName=$1
l_cmd=`ls -ltr $G_ERIC_LOG | grep $1|tail -1| awk '{ print $9}'`
ERIC_LOG="$G_ERIC_LOG/$l_cmd"

}
	getSMRSLogs add_aif.sh
	 ret=$?
	 if [ $ret == 0 ] ; then
		log "INFO:::: Added usr_TC02 LRAN Aif user refer $ERIC_LOG"
	else
		G_PASS_FLAG=1
		log "ERROR:::: Failed to add usr_TC02 aif user refer $ERIC_LOG"
	fi
	
		 
}


function deletingARNEimports()
{	
	l_cmd=`/opt/ericsson/arne/bin/import.sh -val:rall -f /var/opt/ericsson/arne/FTPServices/usr_TC02_LRAN_nedssv4_AIF_DEL.xml`
	l_cmd1=`/opt/ericsson/arne/bin/import.sh -import -i_nau -f /var/opt/ericsson/arne/FTPServices/usr_TC02_LRAN_nedssv4_AIF_DEL.xml`
	if [ $ret == 0 ] ; then
		log "INFO:::: Deleted ARNE imports related to usr_TC02 LRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR:::: Failed to Delete ARNE imports related to usr_TC02 LRAN Aif user"
	fi

}
	
function deleteAif() {

	prepareExpects3
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
     executeExpect $OUTPUTEXP
	 if [ $ret == 0 ] ; then
		log "INFO:::: Deleted usr_TC02 LRAN Aif user"
	else
		G_PASS_FLAG=1
		log "ERROR:::: Failed to delete usr_TC02 aif user"
	fi
	
	}
	 
	
###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
 
	if [ $l_action == 1 ]; then
		log "INFO:::Adding Aif users and running delete aif user script with giving no option to delete aif user"
		aifUser
        
    fi
	
	if [ $l_action == 2 ]; then
		log "INFO::NAME::Cheking FTP service Existence without competing the delete aif script "
		ftpServiceExistence
        
    fi
	
	if [ $l_action == 4 ]; then
		log "INFO::NAME::Deleting the FTP serivce after the test case purpose is completed"
		deletingARNEimports
        
    fi
	if [ $l_action == 3 ]; then
		log "INFO::NAME::Deleting aif user after the purpose of test case is completed"
		deleteAif
        
    fi
	
}

#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Adding AIF  ans trying to delete user
log "ACTION 1 Started"
executeAction 1
log "ACTION 1 Completed"

#Verifying the Existence of FTP service
log "ACTION 2 Started"
executeAction 2
log "ACTION 2 Completed"

#Deleting added aif user
log "ACTION 3 Started"
executeAction 3
log "ACTION 3 Completed"

#Deleting ARNE imports
log "ACTION 4 Started"
executeAction 4
log "ACTION 4 Completed"

#Final assertion of TC, this should be the final step of tc
evaluateTC

