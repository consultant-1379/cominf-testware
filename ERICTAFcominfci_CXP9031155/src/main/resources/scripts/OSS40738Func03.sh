
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

## TC TAFTM Link :http://taftm.lmera.ericsson.se
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
#SDSE_DIR=/ericsson/sdee/bin/
builkUserFile=/var/tmp/bulkUsers.txt

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
     SCRIPT_DIR=/ericsson/opendj/bin
else
     SCRIPT_DIR=/ericsson/sdee/bin
fi


prepareBulkUsersFile ()
{
	echo 'usr_TC0:::::password
usr_TC1:::::password

usr_TC2:OSS_ONLY::::password


usr_TC3:COM_ONLY:::password:::
usr_TC6:COM_ONLY:::password:::
usr_TC4:COM_APP:::password:::
usr_TC7:COM_APP:::password:::

usr_TC5:COM_OSS::::password:Target1::
usr_TC8:COM_OSS::::password:Target1::' > $builkUserFile

}

function addUserUsage() {


		l_cmd=`$SCRIPT_DIR/add_user.sh -h > /var/tmp/usage.txt`
		l_cmd1=`grep "Batch file of users with all mandatory fields" /var/tmp/usage.txt`
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO:: Usage is displayed"
			else
				G_PASS_FLAG=1
				log "ERROR:: Usage is not displayed"
			fi
		l_cmd2=`$SCRIPT_DIR/add_user.sh -f $builkUserFile > /var/tmp/domainError.txt`
		
		l_cmd=`grep "ERROR: Option -f can be used only with options -d" /var/tmp/domainError.txt`
			ret=$?
			if [ $ret == 0 ] ; then
				log "INFO:: error message printed if executed without -d option"
			else
				G_PASS_FLAG=1
				log "INFO:: error message not printed if executed without -d option"
			fi
			
				
}

function removeTempFiles() {

	rm -f /var/tmp/usage.txt
	rm -f /var/tmp/domainError.txt
	
}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME:: Checking the usage and ERROR message if -d option is not given  "
   prepareBulkUsersFile
   addUserUsage
   log "INFO:Completed ACTION 1"
 fi
 
 }
 
 
#########
##MAIN ##
#########	
		
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

# Checking the usage and ERROR message if -d option is not given 
executeAction 1

#Removing the temporary files
removeTempFiles

#Final assertion of TC, this should be the final step of tc
evaluateTC


