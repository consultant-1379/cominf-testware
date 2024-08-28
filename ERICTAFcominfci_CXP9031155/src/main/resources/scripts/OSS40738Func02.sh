
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
SDSE_DIR=/ericsson/sdee/bin
builkUserFile=/var/tmp/bulkUsers.txt
Domain_Name=`grep LDAP_DOMAIN /ericsson/sdee/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
userTypeFile=/var/tmp/userTypes

prepareUserTypes () {
	
	echo 'OSS_ONLY
COM_ONLY
COM_APP
COM_OSS' > $userTypeFile
}

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
prepareBulkUsersFile



function prepareExpects ()
{

        EXPCMD="$SDSE_DIR/reset_user_password.sh -d $Domain_Name"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass
Local user name
usr_TC0
Do you want to reset user usr_TC0 password
y' > $INPUTEXP
}

function prepareExpects1 ()
{

        EXPCMD="$SDSE_DIR/reset_user_password.sh -a -d $Domain_Name"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass
Do you want to reset all user password
y' > $INPUTEXP
}
function prepareExpects2 ()
{

        EXPCMD="$SDSE_DIR/add_user.sh -d $Domain_Name -f $builkUserFile"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
}

function prepareExpects3 ()
{

        EXPCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@uas1"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Password
password
New Password
eric@123
Re-enter new Password
eric@123
>
exit' > $INPUTEXP

}

function prepareExpects4 ()
{

        EXPCMD="$SDSE_DIR/reset_user_password.sh -d $Domain_Name -t $user_type"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass
Do you want to reset all
y' > $INPUTEXP
}

function addBulkUsers () {
		
		log "INFO:: Creating bulk users"
		prepareExpects2
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		
		ret=$?
			if [ $ret == 0 ] ; then
				log "INFO:: Bulk users created Sucessfully"
			else
				G_PASS_FLAG=1
				log "ERROR:: Bulk users are not created Sucessfully"
			fi
}

function resetPasswordUsage () {
	log "INFO:: Usage for the script $SDSE_DIR/reset_user_password.sh "
	$SDSE_DIR/reset_user_password.sh -h > /var/tmp/resetUsage.txt
	ret=$?
		if [ $ret == 0 ] ; then
				log "INFO:: Usage printed"
			else
				G_PASS_FLAG=1
				log "ERROR:: Usage not printed"
			fi
	
}

function resetUserPassword() {
	prepareExpects
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /var/tmp/output.txt
	l_cmd=`grep "INFO: Password Reset Applied for Local User \[usr_TC0\] of Type \[OSS_ONLY\] in domain \[vts.com\]" /var/tmp/output.txt`
		ret=$?
		if [ $ret == 0 ] ; then
			log "INFO:: Password for user usr_TC0 is reset sucessfully"
		else
			G_PASS_FLAG=1
			log "ERROR:: Password for user usr_TC0 is not reset sucessfully"
		fi
	prepareExpects1
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /var/tmp/output1.txt
	users=(usr_TC0 usr_TC1 usr_TC2 usr_TC3 usr_TC6 usr_TC4 usr_TC7 usr_TC5 usr_TC8)
		for  user in "${users[@]}"    
			do
				if [ $user == nmsadm ] ; then
					l_cmd=`grep "INFO: Password Reset Applied for Local User \[$user\] of Type " /var/tmp/output1.txt`
						ret=$?
							if [ $ret == 0 ] ; then
								G_PASS_FLAG=1
								log "ERROR:: Password for $user is reset "
							else
								
								log "INFO::  Password for $user not reset sucessfully"
							fi
				else
					
						l_cmd=`grep "INFO: Password Reset Applied for Local User \[$user\] of Type " /var/tmp/output1.txt`
					
							ret=$?
								if [ $ret == 0 ] ; then
									log "INFO:: Password for $user reset sucessfully"
								else
									G_PASS_FLAG=1
									log "ERROR:: Password for $user not reset sucessfully"
								fi
				fi
		done
		
			
}

function resetForParticularUserType() {
	
	userTypes=( `cat "$userTypeFile"` )
	for user_type in "${userTypes[@]}"
	
	do
		prepareExpects4
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
			l_cmd=`grep $user_type /var/tmp/bulkUsers.txt | awk -F':' '{print $1}'`
			users=( `cat "/var/tmp/array.txt"`)
			for user in "${users[@]}"
			do
				l_cmd=`grep "INFO: Password Reset Applied for Local User \[$user\] of Type " /var/tmp/output1.txt`
					ret=$?
						if [ $ret == 0 ] ; then
							log "INFO:: Password for $user reset sucessfully"
						else
							G_PASS_FLAG=1
							log "ERROR:: Password for $user not reset sucessfully"
						fi
			done
	done
}


function loginToUAS ()
{

	l_cmd=`sed -e '/^#/d' -e '/COM_APP/d' /var/tmp/bulkUsers.txt | awk -F':' '{print $1}' > /var/tmp/uasLoginUsers.txt`
		users=( `cat /var/tmp/uasLoginUsers.txt` )	
		for user in ${users[@]}
		do
			prepareExpects3
			createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
			executeExpect $OUTPUTEXP
				if [ $? == 0 ]; then
					
					log "INFO:: Able to reset the password for $user"
                else
					G_PASS_FLAG=1
					log "ERROR: Unable to reset the password for $user "
                fi
		done
}

function deleteUser () {
		EXPCMD="$SDSE_DIR/del_user.sh -n $users -y"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	}
	
function delete () {
		
		l_cmd=`cat $builkUserFile | awk -F':' '{print $1}'`
		for users in ${l_cmd[@]}
		do
			deleteUser
		done
}

function removeTempFiles() {


	rm -f /var/tmp/resetUsage.txt
	rm -f /var/tmp/output.txt
	rm -f /var/tmp/output1.txt
	rm -f /var/tmp/uasLoginUsers.txt

	}

function sshToOssmaster () {

        prepareExpects8
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP

}

function prepareExpects8 () {

	EXPCMD="ssh -o StrictHostKeyChecking=no comnfadm@ossmaster"
	EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo '#
exit' > $INPUTEXP 
}


###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME:: To print Usage for reset password script  "
   resetPasswordUsage
   log "INFO:Completed ACTION 1"
  fi
  
   if [ $l_action == 2 ]; then
   log "INFO:Started ACTION 2"
   log "INFO:$FUNCNAME:: Add bulk users  "
   addBulkUsers
   log "INFO:Completed ACTION 2"
  fi
  
  if [ $l_action == 3 ]; then
   log "INFO:Started ACTION 3"
   log "INFO:$FUNCNAME:: Reset password for single and all users  "
   resetUserPassword
   log "INFO:Completed ACTION 3"
  fi
  
  if [ $l_action == 4 ]; then
   log "INFO:Started ACTION 4"
   log "INFO:$FUNCNAME:: Reset password for particular Type of users  "
   resetForParticularUserType
   log "INFO:Completed ACTION 4"
  fi
    if [ $l_action == 5 ]; then
   log "INFO:Started ACTION 5"
   log "INFO:$FUNCNAME:: Login to the UAS with the users  "
   loginToUAS
   log "INFO:Completed ACTION 5"
  fi
  
    if [ $l_action == 6 ]; then
   log "INFO:Started ACTION 6"
   log "INFO:$FUNCNAME:: Deleting the added bulk users "
   delete
   log "INFO:Completed ACTION 6"
  fi
}



#########
##MAIN ##
#########	
		
#if preconditions execute pre conditions

log "INFO:: login to ossmaster with comnfadm user"
sshToOssmaster
log "INFO::  logged out from ossmaster with comnfadm user"

#main Logic should be in executeActions subroutine with numbers in order.

# To print Usage for reset password script
executeAction 1

# Add bulk users
executeAction 2

# Reset password for single and all users 
executeAction 3

#Reset password for particular Type of users
executeAction 4

# Login to the UAS with the users 
executeAction 5

# Deleting the added bulk users
executeAction 6

#Removing the temporary files
removeTempFiles



#Final assertion of TC, this should be the final step of tc
evaluateTC




