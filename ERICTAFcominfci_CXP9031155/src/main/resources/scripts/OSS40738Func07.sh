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

#path="/ericsson/sdee/bin"

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        LOG_FN=getOPENDJLogs
	path="/ericsson/opendj/bin"
		
else
        LOG_FN=getSDEELogs
	path="/ericsson/sdee/bin"
		
fi

file1="/tmp/adduser1234.txt"
file2="/tmp/AddinvalidTarget.txt"
file3="/tmp/RemoveinvalidTarget.txt"
file4="/tmp/Addinvalidrole.txt"
file5="/tmp/Removeinvalidrole.txt"
file6="/tmp/AddinvalidAlias.txt"
file7="/tmp/RemoveinvalidAlias.txt"
file8="/tmp/invalidAction.txt"
file9="/tmp/invalidUser.txt"
file10="/tmp/importfile"
file11="/tmp/userList"
userList=( ci_func08 ci_func09 )

###################################
#
#################################
prepareBulkUserfile () {
	echo 'ci_usr1:COM_OSS::::password::role1:
ci_usr2:COM_OSS::::password:target::
ci_usr3:COM_APP:::password:::alias1
ci_usr4:COM_ONLY:::password::role2:' > $file1
}
prepareAddInvalidTargetFile () {
	echo 'DOMAIN vts.com
ACTION add
OBJECT target
ci_usr1 1target,target_,taget.,target@,target-' > $file2
}

prepareRemoveInvalidTargetFile () {
	echo 'DOMAIN vts.com
ACTION remove
OBJECT target
ci_usr2 target2' > $file3
}
prepareAddInvalidRoleFile () {
	echo 'DOMAIN vts.com
ACTION add
OBJECT role 
ci_usr2 1role,role_,role@,role.,role-' > $file4

}
prepareRemoveInvalidRoleFile () {
	echo 'DOMAIN vts.com
ACTION remove
OBJECT role 
ci_usr2 role2' > $file5
}


prepareAddInvalidAliasFile () {
	echo 'DOMAIN vts.com
ACTION add
OBJECT alias
ci_usr2 1alias,alias_,alias.,alias@,alias-' > $file6
}

prepareRemoveInvalidAliasFile () {
	echo 'DOMAIN vts.com
ACTION remove
OBJECT role 
ci_usr3 alias2' > $file7
}

prepareInvalidAction () {
	echo 'DOMAIN vts.com
ACTION multiply
OBJECT alias
ci_usr4 alias1,alias2

ACTION divide1
OBJECT role
ci_usr4 role1,role2' > $file8
}

prepareInvaliduser () {
	echo 'DOMAIN vts.com
ACTION add
OBJECT alias
ci_func08 alias1,alias2

ACTION remove
OBJECT role
ci_func09 role1,role2' > $file9
}

prepareImportFile () {
	echo 'DOMAIN vts.com
ROLE role1,role2,role3
ALIAS alias1 role1,role2
ALIAS alias2 role2,role3' > $file10
}

function listprivs() {
	EXPCMD="$path/manage_COM_privs.bsh -l -u $1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file12
}
function listUsers () {
		EXPCMD="$path/list_users"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > $file11
}

	function deleteUser () {
		EXPCMD="$path/del_user.sh -n $1 -y"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::deleted user $1"
		else
			log "ERROR:$FUNCNAME::Error in deleting user $1"
	fi
}
	
function precon () {
		listUsers 
		userCount=${#userList[*]}
		ListofUsers=( `cat  $file11 | awk -F'|' '{print $1}' > /tmp/users` )
		l_count=0
		while [ $l_count -lt $userCount ]; do
		
				if [ `grep -c -w ${userList[$l_count]}  /tmp/users` == 1 ] ;then
				{
					deleteUser "${userList[$l_count]}"
				}
				fi
		let l_count+=1
		done
		prepareImportFile
		EXPCMD="$path/manage_COM.bsh -a import -d vts.com -f  $file10 -o -y"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::created the required roles and aliases"
		else
			log "ERROR:$FUNCNAME::Error in creating the required roles and alias"
		fi
		
		prepareBulkUserfile
		EXPCMD="$path/add_user.sh -d vts.com -f $file1"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
		if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::created the required users"
		else
			log "ERROR:$FUNCNAME::Error in creating the required users"
		fi

}

function invalidPrivs () {
	prepareAddInvalidTargetFile
	EXPCMD="$path/manage_COM_privs.bsh -b $file2 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	listprivs "ci_usr1"
	l_cmd=`grep target /tmp/file12`
		if [ $? = 0 ] ;then
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:: added invalid target to user ci_usr1"
		else
  			log "SUCCESS:$FUNCNAME::verfied:Error in adding invalid target to the user ci-usr1"
	fi
	
	prepareRemoveInvalidTargetFile
	EXPCMD="$path/manage_COM_privs.bsh -b $file3 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
		${LOG_FN} "manage_COM_privs"
        ERROR_STG="Successfully deleted target"
        l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::removed invalid target. Please refer to $LOG_PATH"
		else
			log "SUCCESS:$FUNCNAME::verified:ERROR in removing invalid target.Please refer to $LOG_PATH"
		fi
		
	prepareAddInvalidRoleFile
	EXPCMD="$path/manage_COM_privs.bsh -b $file4 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	${LOG_FN} "manage_COM_privs"
	listprivs "ci_usr2"
	l_cmd=`grep role /tmp/file12`
		if [ $? = 0 ] ;then
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:: added invalid role to user ci_usr2.please refer to $LOG_PATH"
		else
  			log "SUCCESS:$FUNCNAME::verfied:Error in adding invalid role to the user ci-usr2.please refer to $LOG_PATH"
		fi
		
	prepareRemoveInvalidRoleFile
	EXPCMD="$path/manage_COM_privs.bsh -b $file5 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	${LOG_FN} "manage_COM_privs"
        ERROR_STG="Successfully deleted role"
        l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::removed invalid role. Please refer to $LOG_PATH"
		else
			log "SUCCESS:$FUNCNAME::verified:ERROR in removing invalid role.Please refer to $LOG_PATH"
		fi
	prepareAddInvalidAliasFile
	EXPCMD="$path/manage_COM_privs.bsh -b $file6 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	${LOG_FN} "manage_COM_privs"
	listprivs "ci_usr2"
	l_cmd=`grep alias /tmp/file12`
	
		if [ $? = 0 ] ;then
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:: added invalid alias to user ci_usr2.please refer to $LOG_PATH"
		else
  			log "SUCCESS:$FUNCNAME::verfied: Error in adding invalid alias to the user ci-usr2.please refer to  $LOG_PATH"
		fi
	
	prepareRemoveInvalidAliasFile
	EXPCMD="$path/manage_COM_privs.bsh -b $file7 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	${LOG_FN} "manage_COM_privs"
        ERROR_STG="Successfully deleted alias"
        l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::removed invalid alias. Please refer to $LOG_PATH"
		else
		    
			log "SUCCESS:$FUNCNAME::verified:ERROR in removing invalid alias.Please refer to $LOG_PATH"
		fi
}

function invalidAction () {
	prepareInvalidAction
	EXPCMD="$path/manage_COM_privs.bsh -b $file8 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	${LOG_FN} "manage_COM_privs"
        ERROR_STG="Invalid ACTION"
        l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
            log "SUCCESS:$FUNCNAME::verified:ERROR for invalid action:Please refer to $LOG_PATH"
		else
		    G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Adding/removing privileges with invalid action .Please refer to $LOG_PATH"
		fi
}

function invalidUser () {
	prepareInvaliduser
	EXPCMD="$path/manage_COM_privs.bsh -b $file9 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	${LOG_FN} "manage_COM_privs"
        ERROR_STG="Successfully"
        l_cmd=`grep -w "${ERROR_STG}" $LOG_PATH`
		if [ $? == 0 ]; then
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Adding/removing privileges to invalid user.Please refer to $LOG_PATH"
		else
		    
			log "SUCCESS:$FUNCNAME::verified:ERROR for Adding/removing privileges to invalid user.Please refer to $LOG_PATH"
		fi
}

function clearAll () {
		EXPCMD="$path/manage_COM.bsh -r role -R role1,role2,role3 -y"
				EXITCODE=5
				INPUTEXP=/tmp/${SCRIPTNAME}.in
				OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
				echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
				createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
				executeExpect $OUTPUTEXP
				if [ $? == 0 ] ;then
                        log "SUCCESS:$FUNCNAME::removed all the roles and aliases"
                else
                        log "ERROR:$FUNCNAME::Error in removing roles and aliases"
                fi
		listUsers 
		userList2=( ` cat $file1 | awk -F':' '{print $1}'` )
		userCount=${#userList2[*]}
		ListofUsers=( `cat  $file11 | awk -F'|' '{print $1}' > /tmp/users` )
		l_count=0
		while [ $l_count -lt $userCount ]; do
		
				if [ `grep -c -w ${userList2[$l_count]}  /tmp/users` == 1 ] ;then
				{
					deleteUser "${userList2[$l_count]}"
				}
				fi
		let l_count+=1
		done
		l_cmd=`rm -f $file1 $file2 $file3 $file4 $file5 $file6 $file7 $file8 $file9 $file10 $file11 /tmp/users`
		if [ $? == 0 ] ;then
			log "SUCCESS:$FUNCNAME::removed all the input files"
		else
			log "ERROR:$FUNCNAME::Error in removing the input files"
		fi
		
}

###############################
#Execute the action to be performed
#####################################

function executeAction ()
	{
	 l_action=$1
	 
	if [ $l_action == 1 ]; then
		log "INFO:$FUNCNAME::executing preconditions"
		precon 
	fi
	if [ $l_action == 2 ]; then
		log "INFO:$FUNCNAME::verifying:Adding & Removing privileges to the users of differet type with invalid targets/roles/aliases"
		invalidPrivs
	fi
	if [ $l_action == 3 ]; then
		log "INFO:$FUNCNAME::verifying:Adding & Removing privileges to the users with invalid ACTION i.e except add|remove"
		invalidAction
	fi
	
	if [ $l_action == 4 ]; then
		log "INFO:$FUNCNAME::verifying:Adding & Removing privileges to the invalid users(users which does not exist) using option -b"
		invalidUser
	fi
	
	if [ $l_action == 5 ]; then
	   log "INFO:$FUNCNAME::deleting all users,privileges and  input files"
	   clearAll
	fi
}

#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#executing preconditions
executeAction 1

#verifying:Adding & Removing privileges to the users of differet type with invalid targets/roles/aliases
executeAction 2

#verifying:Adding & Removing privileges to the users with invalid ACTION i.e except add|remove
executeAction 3

#verifying:Adding & Removing privileges to the invalid users(users which does not exist) using option -b
executeAction 4

#deleting all users and input files
executeAction 5

#Final assertion of TC, this should be the final step of tc
evaluateTC
