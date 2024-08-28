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

### TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/1352
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
#${PATH_DIR}=/ericsson/sdee/bin

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        PATH_DIR=/ericsson/opendj
else
        PATH_DIR=/ericsson/sdee
fi

builkUserFile=/var/tmp/bulkUsers.txt
Domain_Name=`grep LDAP_DOMAIN ${PATH_DIR}/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
inValidUsers=/var/tmp/inValidUsers.txt
emptyFile=/var/tmp/emptyFile.txt
touch $emptyFile
repetitiveUsersFile=/var/tmp/repetitiveUsersFile.txt



function prepareExpects () {

	EXPCMD="${PATH_DIR}/bin/reset_user_password.sh -d $Domain_Name -f /var/tmp/example.txt"
	EXPCMD2="${PATH_DIR}/bin/reset_user_password.sh -d $Domain_Name -f $emptyFile"
	EXPCMD3="${PATH_DIR}/bin/reset_user_password.sh -u nmsadm"
	EXPCMD4="${PATH_DIR}/bin/add_user.sh -d $Domain_Name -f $builkUserFile"
	EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
    echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
}

function prepareExpects2 () {

	EXPCMD="${PATH_DIR}/bin/reset_user_password.sh -d $Domain_Name -f $repetitiveUsersFile"
	EXPCMD1="${PATH_DIR}/bin/reset_user_password.sh -d $Domain_Name -f $inValidUsers"
	EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
    echo 'LDAP Directory Manager password
ldappass
Do you want to continue reset password for remaining users
y' > $INPUTEXP
}


prepareBulkUsersFile ()
{
	echo 'usr_TC0:::::password


usr_TC2:OSS_ONLY::::password


usr_TC3:COM_ONLY:::password:::

usr_TC4:COM_APP:::password:::


usr_TC5:COM_OSS::::password:Target1::' > $builkUserFile

}

prepareBulkUsersFile

prepareRepetitiveUsersFile ()
{
	echo 'usr_TC0


usr_TC2
usr_TC2

usr_TC4
usr_TC4

usr_TC0' > $repetitiveUsersFile

}

prepareRepetitiveUsersFile

prepareBulkInvalidUsersFile ()
{
	echo 'usTC0
123

usr@TC2


!usr_TC3

usr_TC3

usr_TC5
usr_TC5
user_testcase' > $inValidUsers

}

prepareBulkInvalidUsersFile

function addBulkUsers () {
		
		log "INFO:: Creating bulk users"
		prepareExpects
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD4"
		executeExpect $OUTPUTEXP
		
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO:: Bulk users created Sucessfully"
			else
				G_PASS_FLAG=1
				log "ERROR:: Bulk users are not created Sucessfully"
			fi
}



function domainCheck() {

	l_cmd=`${PATH_DIR}/bin/reset_user_password.sh -d ld@p.c0m > /var/tmp/inCorrectDomain1.txt`
	l_cmd1=`grep "ERROR: Invalid domain \[ld@p.c0m\], domain name may only contain alphanumeric characters, hyphen(-), underscore(_) or period(.)" /var/tmp/inCorrectDomain1.txt`
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO: error message with invalid domain name details is displayed"
			else
				G_PASS_FLAG=1
				log "ERROR: error message with invalid domain details is not displayed"
			fi
	l_cmd2=`${PATH_DIR}/bin/reset_user_password.sh -u test_0 -d ldap.com > /var/tmp/inCorrectDomain2.txt`
	l_cmd3=`grep "ERROR: Domain \[ldap.com\] does not exist in LDAP" /var/tmp/inCorrectDomain2.txt`
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO: error message with invalid domain name details is displayed"
			else
				G_PASS_FLAG=1
				log "ERROR: error message with invalid domain details is not displayed"
			fi
}
			
function inValidFileCheck () {			

		prepareExpects
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP > /var/tmp/incorrectBulkUsersFile.txt
		
		l_cmd4=`grep "ERROR: File \[/var/tmp/example.txt\] doesn't exist" /var/tmp/incorrectBulkUsersFile.txt`
			ret=$?
			if [ $ret == 0 ] ; then
				log "INFO: error message with invalid file name details is displayed"
			else
				G_PASS_FLAG=1
				log "ERROR: error message with invalid filename details is not displayed"
			fi
}

function inValidUsersCheck () {

		
		prepareExpects2
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD1"
		executeExpect $OUTPUTEXP > /var/tmp/inValidUsersFile.txt
		
		l_cmd5=`grep "WARNING: Following user name(s) does not exist/invalid, password reset will not be applied" /var/tmp/inValidUsersFile.txt`
				ret=$?
			if [ $ret == 0 ] ; then
				log "INFO: error message with invalid users in $inValidUsers file is displayed"
			else
				G_PASS_FLAG=1
				log "ERROR: error message with invalid users in $inValidUsers file is not displayed"
			fi
}

function emptyFileCheck () {
		
		prepareExpects
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD2"
		executeExpect $OUTPUTEXP > /var/tmp/emptyFileCheck.txt
		l_cmd6=`grep "ERROR: File \[$emptyFile\] is empty" /var/tmp/emptyFileCheck.txt`
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO: Message saying that $emptyFile file is empty is present"
			else
				G_PASS_FLAG=1
				log "ERROR:  Message saying that $emptyFile file is not empty is present"
			fi
}

function passwdResetForNmsadmUser () {
			
		prepareExpects
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD3"
		executeExpect $OUTPUTEXP > /var/tmp/nmsadmCheck.txt
		l_cmd6=`grep "ERROR: User name nmsadm is not supported" /var/tmp/nmsadmCheck.txt`
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO: Message saying that User name nmsadm is not supported is present"
			else
				G_PASS_FLAG=1
				log "ERROR:  Message saying that User name nmsadm is not supported is not present"
			fi
	
}

function userTypeCheck () {

		l_cmd7=`${PATH_DIR}/bin/reset_user_password.sh -t abdc -d $Domain_Name`
				ret=$?
			if [ $ret != 0 ] ; then
				log "INFO: User type is not a supported one "
			else
				G_PASS_FLAG=1
				log "ERROR: Accepted unsupported user type"
			fi
}

function repetetiveUsersPsswdResetCheck () {
			
		prepareExpects2
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP > /var/tmp/RepetitiveUsers.txt
		
		l_cmd8=`cat $repetitiveUsersFile |  awk -F':' '{print $1}' | sed '/^#/d' > /var/tmp/USERS.txt`
		USERS=( `cat /var/tmp/USERS.txt` )
		for user in ${USERS[@]}
			do
				l_cmd9=`grep $user /var/tmp/RepetitiveUsers.txt | wc -l`
					if [ $l_cmd9 != 1 ] ; then
						G_PASS_FLAG=1
						log "ERROR:: Password for $user is reset more than once"
					else
						log "INFO:: Password for $user is reset only once"
					fi
		done
}

function usageCheckForAllOptions () {
			
			ret=$?
			l_cmd10=`${PATH_DIR}/bin/reset_user_password.sh -h -d $Domain_Name > /var/tmp/usage.txt`
				usage_present=`grep Usage /var/tmp/usage.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
			l_cmd11=`${PATH_DIR}/bin/reset_user_password.sh -h -a > /var/tmp/usage1.txt`
				usage_present=`grep Usage /var/tmp/usage1.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
			l_cmd12=`${PATH_DIR}/bin/reset_user_password.sh -h -u usr_TC0 > /var/tmp/usage2.txt`
			usage_present=`grep Usage /var/tmp/usage2.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
			l_cmd13=`${PATH_DIR}/bin/reset_user_password.sh -h -f $repetitiveUsersFile > /var/tmp/usage3.txt`
			usage_present=`grep Usage /var/tmp/usage3.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
			l_cmd14=`${PATH_DIR}/bin/reset_user_password.sh -h -t COM_APP   > /var/tmp/usage4.txt`
			usage_present=`grep Usage /var/tmp/usage4.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
			l_cmd15=`${PATH_DIR}/bin/reset_user_password.sh -h -t COM_OSS  > /var/tmp/usage5.txt`
			usage_present=`grep Usage /var/tmp/usage5.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
				
			l_cmd16=`${PATH_DIR}/bin/reset_user_password.sh -h -t COM_ONLY  > /var/tmp/usage6.txt`
			usage_present=`grep Usage /var/tmp/usage6.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
			l_cmd17=`${PATH_DIR}/bin/reset_user_password.sh -h -t COM_ONLY  > /var/tmp/usage7.txt`
			usage_present=`grep Usage /var/tmp/usage7.txt`
				if [ $ret == 0 ] ; then
				log "INFO: Usage is present "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not present"
			fi
			
		}
			
function inValidOptionCombination () {

			ret=$?
			l_cmd18=`${PATH_DIR}/bin/reset_user_password.sh -a -u usr_TC0  > /var/tmp/usage8.txt`
				usage_error=`grep "ERROR: Invalid option usage" /var/tmp/usage8.txt`
					if [ $ret == 0 ] ; then
				log "INFO: Usage is displayed "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not displayed"
			fi
			l_cmd18=`${PATH_DIR}/bin/reset_user_password.sh -a -f repetitiveUsersFile  > /var/tmp/usage9.txt`
				usage_error=`grep "ERROR: Invalid option usage" /var/tmp/usage9.txt`
					if [ $ret == 0 ] ; then
				log "INFO: Usage is displayed "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not displayed"
			fi
			l_cmd19=`${PATH_DIR}/bin/reset_user_password.sh -f $repetitiveUsersFile -t COM_APP > /var/tmp/usage10.txt`
			usage_error=`grep "ERROR: Invalid option usage" /var/tmp/usage10.txt`
					if [ $ret == 0 ] ; then
				log "INFO: Usage is displayed "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not displayed"
			fi
			l_cmd20=`${PATH_DIR}/bin/reset_user_password.sh -a -t COM_APP > /var/tmp/usage11.txt`
			usage_error=`grep "ERROR: Invalid option usage" /var/tmp/usage11.txt`
					if [ $ret == 0 ] ; then
				log "INFO: Usage is displayed "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not displayed"
			fi
			l_cmd21=`${PATH_DIR}/bin/reset_user_password.sh -d  -G $Domain_Name > /var/tmp/usage12.txt`
			usage_error=`grep "ERROR: Invalid option usage" /var/tmp/usage12.txt`
					if [ $ret == 0 ] ; then
				log "INFO: Usage is displayed "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not displayed"
			fi
			l_cmd21=`${PATH_DIR}/bin/reset_user_password.sh -f $repetitiveUsersFile -u usr_TC0 > /var/tmp/usage13.txt`
			usage_error=`grep "ERROR: Invalid option usage" /var/tmp/usage13.txt`
					if [ $ret == 0 ] ; then
				log "INFO: Usage is displayed "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not displayed"
			fi
			l_cmd21=`${PATH_DIR}/bin/reset_user_password.sh -u usr_TC0 -t COM_APP > /var/tmp/usage14.txt`
			usage_error=`grep "ERROR: Invalid option usage" /var/tmp/usage14.txt`
					if [ $ret == 0 ] ; then
				log "INFO: Usage is displayed "
			else
				G_PASS_FLAG=1
				log "ERROR: Usage is not displayed"
			fi
}
				
	            
function deleteUser () 
{
		EXPCMD="${PATH_DIR}/bin/del_user.sh -n $users -y"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
}
	
function delete () 
{
		
		l_cmd=`cat $builkUserFile | sed '/^#/d' | awk -F':' '{print $1}'`
		for users in ${l_cmd[@]}
		do
			deleteUser
		done
}

function removeTempFiles () {
			
		rm -f /var/tmp/inCorrectDomain1.txt
		rm -f /var/tmp/inCorrectDomain2.txt
		rm -f /var/tmp/incorrectBulkUsersFile.txt
		rm -f /var/tmp/inValidUsersFile.txt
		rm -f /var/tmp/emptyFileCheck.txt
		rm -f /var/tmp/nmsadmCheck.txt
		rm -f /var/tmp/RepetitiveUsers.txt
		rm -f /var/tmp/USERS.txt
		rm -f /var/tmp/usage*
		
}
		

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME:: Adding users for the test case  "
   addBulkUsers
   log "INFO:Completed ACTION 1"
  fi
  
  
 if [ $l_action == 2 ]; then
   log "INFO:Started ACTION 2"
   log "INFO:$FUNCNAME:: Reset user's passwords for invalid domain name"
   domainCheck
   log "INFO:Completed ACTION 2"
  fi
  
  if [ $l_action == 3 ]; then
   log "INFO:Started ACTION 3"
   log "INFO:$FUNCNAME:: Checking password reset for user's when invalid file is given as input file "
   inValidFileCheck
   log "INFO:Completed ACTION 3"
  fi
  
   if [ $l_action == 4 ]; then
   log "INFO:Started ACTION 4"
   log "INFO:$FUNCNAME:: Checking password reset for invalid users "
   inValidUsersCheck
   log "INFO:Completed ACTION 4"
  fi
  
  if [ $l_action == 5 ]; then
   log "INFO:Started ACTION 5"
   log "INFO:$FUNCNAME:: Checking when empty file is given  "
   emptyFileCheck
   log "INFO:Completed ACTION 5"
  fi
   if [ $l_action == 6 ]; then
   log "INFO:Started ACTION 6"
   log "INFO:$FUNCNAME:: Verifiying to reset password for user nmsadm  "
   passwdResetForNmsadmUser
   log "INFO:Completed ACTION 6"
  fi
  
  if [ $l_action == 7 ]; then
   log "INFO:Started ACTION 7"
   log "INFO:$FUNCNAME:: Verifiying to reset user's password when invalid user type is given "
   userTypeCheck
   log "INFO:Completed ACTION 7"
  fi
  
  if [ $l_action == 8 ]; then
   log "INFO:Started ACTION 8"
   log "INFO:$FUNCNAME:: Verifiying to Reset user's password only once when valid user names are given more than once in the file "
   repetetiveUsersPsswdResetCheck
   log "INFO:Completed ACTION 8"
  fi

if [ $l_action == 9 ]; then
   log "INFO:Started ACTION 9"
   log "INFO:$FUNCNAME::To print usage for different combinations "
   usageCheckForAllOptions
   log "INFO:Completed ACTION 9"
  fi
  
  if [ $l_action == 9 ]; then
   log "INFO:Started ACTION 9"
   log "INFO:$FUNCNAME:: To print usage for different invalid combinations "
   inValidOptionCombination
   log "INFO:Completed ACTION 9"
  fi
  
  if [ $l_action == 10 ]; then
   log "INFO:Started ACTION 10"
   log "INFO:$FUNCNAME:: To delete the users that are added as a part of test case "
   delete
   log "INFO:Completed ACTION 10"
  fi
  
 } 

#########
##MAIN ##
#########	
		
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

# Adding users for the test case
executeAction 1

#  Reset user's passwords for invalid domain name
executeAction 2

# Checking password reset for user's when invalid file is given as input file 
executeAction 3

#Checking password reset for invalid users
executeAction 4

#  Checking when empty file is given
executeAction 5

# Verifiying to reset password for user nmsadm
executeAction 6

# Verifiying to reset user's password when invalid user type is given 
executeAction 7

#Verifiying to reset user's password only once when valid user names are given more tahn once in the file
executeAction 8

#To print usage for different invalid combinations
executeAction 9

#To delete the users that are added as a part of test case 
executeAction 10

#Removing the temporary files
removeTempFiles

#Final assertion of TC, this should be the final step of tc
evaluateTC            
