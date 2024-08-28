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
builkUserFile=/var/tmp/bulkUsers.txt
#SOL11
#SDSE_DIR=/ericsson/sdee/bin
SDSE_DIR=/ericsson/opendj/bin

#Domain_Name=`grep LDAP_DOMAIN /ericsson/sdee/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
Domain_Name=`grep LDAP_DOMAIN /ericsson/opendj/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
#SOL11

importfile=/var/tmp/importfile.txt
finallist=/var/tmp/finallist.txt

prepareBulkUsersFile ()
{
	echo 'com_ap1:COM_APP:::eric@1234:::
#
com_ap4:COM_APP:::eric@1234:target2::

com_ap5:COM_APP:::eric@1234::role1:
com_ap6:COM_APP:::eric@1234::role2:
com_ap7:COM_APP:::eric@1234::role3:

com_ap8:COM_APP:::eric@1234:::alias1
com_ap9:COM_APP:::eric@1234:::alias2

com_ap10:COM_APP:::eric@1234:target1:role1:
com_ap13:COM_APP:::eric@1234::role2:alias2

com_ap14:COM_APP:::eric@1234:target1:role1:alias1

com_on1:COM_ONLY::description:eric@1234:target1:target2::role2:
com_on2:COM_ONLY::description:eric@1234:target1:role2:target2::alias2

com_os1:COM_OSS::nw_ope::eric@1234:target9::
com_os2:COM_OSS::sys_adm::eric@1234::role2,role3:
comoss3:COM_OSS::nw_ope::eric@1234:::alias1,alias2
com_os4:COM_OSS::appl_adm::eric@1234:role2:role2:
com_os5:COM_OSS::nw_ope::eric@1234:target1::alias1
#
com_os6:COM_OSS::sys_adm::eric@1234:role2::alias2
com_os7:COM_OSS::nw_ope::eric@1234::role1:alias1,alias2
com_os8:COM_OSS::nw_ope::eric@1234:role1:role1:alias1,alias2' > $builkUserFile
}

prepareImportFile () {
	echo 'DOMAIN vts.com
ROLE role1,role2,role3
ALIAS alias1 role1,role2
ALIAS alias2 role2,role3' > $importfile
} 

function prepareExpects ()
{

        EXPCMD="$SDSE_DIR/add_user.sh -d $Domain_Name -f $builkUserFile"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
}

function createRolesAlias ()
{

		EXPCMD="$SDSE_DIR/manage_COM.bsh -a import -d $Domain_Name -f $importfile"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
Continue to import COM node file
Yes' > $INPUTEXP

		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::created the required roles and aliases"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in creating the required roles and alias"
		fi 
}


function addBulkUsers ()
{

log "INFO:: Creating bulk users"
		prepareExpects
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
function listprivs() {
		EXPCMD="$SDSE_DIR/manage_COM_privs.bsh -l -u $users"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
} 

function list  () {
		l_cmd=`cat $builkUserFile | sed '/^#/d' | awk -F':' '{print $1}'`
		for users in ${l_cmd[@]}
		do
			echo $users
			listprivs
		done
		
}
function uasLoginexpectEx ()
{

        EXPCMD="ssh $user@uas1"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Password
eric@1234
New Password
root@123
Re-enter new Password
root@123
>
exit' > $INPUTEXP

}


function loginToUAS ()
{

		l_cmd=`sed -e '/^#/d' -e '/COM_APP/d' $builkUserFile | awk -F':' '{print $1}' > /var/tmp/uasLoginUsers.txt`
		users=( `cat /var/tmp/uasLoginUsers.txt` )	
		for user in ${users[@]}
		do
			uasLoginexpectEx
			createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
			executeExpect $OUTPUTEXP
				if [ $? == 0 ]; then
					
					log "INFO:: UAS login success for $user"
                else
					G_PASS_FLAG=1
					log "ERROR:  UAS login failed for $user"
                fi
		done
}

function changingpwdEx () {
		EXPCMD="$SDSE_DIR/chg_user_password.sh -d $Domain_Name -u $user"
        EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'LDAP Directory Manager password
ldappass
New password
root@231
Re-enter password
root@231' > $INPUTEXP
}


function changeUserPwd ()
{

		l_cmd=`sed -e '/^#/d' -e '/COM_APP/d' $builkUserFile | awk -F':' '{print $1}' > /var/tmp/uasLoginUsers.txt`
		users=( `cat /var/tmp/uasLoginUsers.txt` )	
		for user in ${users[@]}
		do
			changingpwdEx
			createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
			executeExpect $OUTPUTEXP
				if [ $? == 0 ]; then
					
					log "INFO:: Password changed for $user"
                else
					G_PASS_FLAG=1
					log "ERROR:  Password not changed for $user"
                fi
		done
}


function ldapUserSearchOnSlave() {
		l_cmd=`cat $builkUserFile | sed '/^#/d' | awk -F':' '{print $1}'`
		for users in ${l_cmd[@]}
			do
			l_cmd1=`ldapsearch -h "omsrvs" -D "cn=directory manager" -w ldappass -T -b "ou=people,dc=vts,dc=com" "objectclass=*"`
			
			l_cmd2=`grep $users /var/tmp/slaveUsers.txt`
				ret=$?
					if [ $ret == 0 ] ; then
						log "INFO:: $users present on omserv Slave"
					else
						G_PASS_FLAG=1
						log "ERROR:: $users not present on omserv Slave"
					fi
		done
		
}

function deleteUserEx () {
		EXPCMD="$SDSE_DIR/del_user.sh -n $users -y"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	
	}
	
function deleteRoles () {	
		EXPCMD="$SDSE_DIR/manage_COM.bsh -r role -R role1,role2,role3"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass
Please confirm that you want to proceed with requested actions
Yes' > $INPUTEXP
	
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	}
	
function deleteUsers () {
		
		l_cmd=`cat $builkUserFile | sed '/^#/d' | awk -F':' '{print $1}'`
		for users in ${l_cmd[@]}
		do
			deleteUserEx
		done
}


###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 $l_action=$1
 
	if [ $"$l_action" == 1 ]; then
	log "INFO:Executing Preconditions"
	log "INFO:Preparing Bulk user import file"
	prepareBulkUsersFile
	log "INFO:File importing"
	prepareImportFile
	log "INFO:Roles and Aliases adding"
	createRolesAlias
	fi
	
	if [ $"$l_action" == 2 ]; then
	log "INFO: Adding bulk users"
	addBulkUsers
	fi
	
	if [ $"$l_action" == 3 ]; then
	log "INFO:Listing User priveledges"
	list
	listprivs
	fi
	
	if [ $"$l_action" == 4 ]; then
	log "INFO:checking uas login"
	loginToUAS
	fi
	
	if [ $"$l_action" == 5 ]; then
	log "INFO:changing password"
	changeUserPwd
	fi
	
	if [ $"$l_action" == 6 ]; then
	log "INFO:checking users exits on omserv slave "
	ldapUserSearchOnSlave
	fi
	
	
	if [ $"$l_action" == 7 ]; then
	log "INFO:Deleting the added users"
	deleteUsers
	fi
	
	if [ $"$l_action" == 8 ]; then
	deleteRoles
	log "INFO:Deleting the Roles added."	
	fi
	
	

 }


#########
##MAIN ##
#########	
		
#if preconditions execute pre conditions
executeAction 1
#main Logic should be in executeActions subroutine with numbers in order.

#Adding Bulk users
executeAction 2

#Deleting created roles/alias and users
executeAction 3

#checking uas login
executeAction 4

#changing password
executeAction 5

#checking users exits on omserv slave
executeAction 6

#Deleting the added users
executeAction 7

#Deleting the Roles added.
executeAction 8

#Final assertion of TC, this should be the final step of tc
evaluateTC


