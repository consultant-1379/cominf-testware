 
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


##TC VARIABLE###

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
      	path=/ericsson/opendj/bin 
else
       	path=/ericsson/sdee/bin 
fi
 
file1="/tmp/adduser123.txt"
file2="/tmp/importfile123.txt"
file3="/tmp/bulkfile123.txt"
file4="/tmp/userList"
file7="/tmp/bulkfile1234.txt"
file9="/tmp/bulkfile12345.txt"
###################################
# Functions to add/remove priveleges to users using manage_COM_privs.bsh script with -b  option
#################################
prepareBulkUserfile () {
echo 'vuser1:OSS_ONLY::::password
vuser2:OSS_ONLY::::password
vuser3:COM_OSS::::password::role1,role2:
vuser4:COM_APP:::password:::alias1,alias2
vuser5:COM_ONLY:::password::target::role2:
vuser6:OSS_ONLY::::password' > $file1
}

prepareImportFile () {
echo 'DOMAIN vts.com
ROLE role1,role2,role3
ALIAS alias1 role1,role2
ALIAS alias2 role2,role3' > $file2
	}

prepareBulkFile () {
echo 'DOMAIN vts.com
ACTION add
OBJECT alias
vuser1 alias1,alias2

ACTION add
OBJECT role
vuser2 role1,role2

ACTION remove
OBJECT alias
vuser4 alias1,alias2

ACTION remove
OBJECT role
vuser3 role1,role2' > $file3
	}

prepareBulkfile2 () {
echo 'DOMAIN vts.com
ACTION add
OBJECT role
vuser4 target:role1

ACTION remove
OBJECT role
vuser5 target:role2' > $file7
}

prepareBulkFile3 ()
{
echo 'DOMAIN vts.com
#ACTION remove
#OBJECT target
#vuser6 *

#ACTION remove
#OBJECT role
#vuser6 *:role1


#ACTION remove
#OBJECT alias
#vuser6 *:alias1

ACTION add
OBJECT target
vuser4 *

ACTION add
OBJECT role
vuser5 *:role2

ACTION add
OBJECT alais
vuser5 *:alias2' > $file9
}


function listUsers () {
	EXPCMD="$path/list_users"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > $file4
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
	prepareBulkUserfile
	listUsers
	userList=( ` cat $file1 | awk -F':' '{print $1}'` )
	userCount=${#userList[*]}
	ListofUsers=( `cat  $file4 | awk -F'|' '{print $1}' > /tmp/users` )
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
	EXPCMD="$path/manage_COM.bsh -a import -d vts.com -f  $file2 -o  -y"
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

function listprivs() {
	EXPCMD="$path/manage_COM_privs.bsh -l -u $1"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file6
}

function AddRemovePrivs () {
	prepareBulkFile
	EXPCMD="$path/manage_COM_privs.bsh -b $file3 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file5
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME::Added & removed privileges (targets/role/aliases) to the multiple users"
	else
		log "ERROR:$FUNCNAME::Error in Adding & removing privileges (targets/role/aliases) to the multiple users"
	fi
	if [ `grep -c "User \[vuser3\] has been reverted to type OSS_ONLY" /tmp/file5` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: removed privileges roles:role1,role 2 to the vuser3 and User vuser3 has been reverted to type OSS_ONLY from type COM_OSS"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in removing privileges (roles) to the vuser3"
	fi

	listprivs "vuser1"
	if  [ `grep -c "User \[vuser1\] has been updated to type COM_OSS" /tmp/file5` == 1 ] ;then
		if [ `grep -c alias1 /tmp/file6` -a `grep -c alias2 /tmp/file6` == 1 ] ;then
				log "SUCCESS:$FUNCNAME:: added aliases:alias1 and alias2 to vuser1 and has been updated to type COM_OSS"
		fi
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding aliases to the vuser1"
	fi

	listprivs "vuser2"
	if [ `grep -c role1 /tmp/file6` -a `grep -c role2 /tmp/file6` == 1 ] ;then
				log "SUCCESS:$FUNCNAME:: added roles:role1 and role2 to vuser2"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding roles to the vuser2"
	fi

	listprivs "vuser4"
	if [ `grep -c alias1 /tmp/file6` -a `grep -c alias2 /tmp/file6` == 0 ] ;then
				log "SUCCESS:$FUNCNAME:: removed aliases alias1 and alias2 to vuser4"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in removing aliases to the vuser4"
	fi
}

function AddRemoveTargetRoles () {
	prepareBulkfile2
	EXPCMD="$path/manage_COM_privs.bsh -b $file7 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	listprivs "vuser4"
	if [ `grep -c "target:role1" /tmp/file6` == 1 ] ;then
					log "SUCCESS:$FUNCNAME:: added target qualified role:target:role1 to vuser4"
	else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in adding target qualified role:target:role1 to vuser4"
	fi
	listprivs "vuser5"
	if [ `grep -c "target:role2" /tmp/file6` == 0 ] ;then
					log "SUCCESS:$FUNCNAME:: removed target qualified role:target:role2 to vuser5"
	else
					G_PASS_FLAG=1
					log "ERROR:$FUNCNAME::Error in removing target qualified role:target:role2 to vuser5"
	fi
}

function clearAll () {
	
	listUsers
	userList=( ` cat $file1 | awk -F':' '{print $1}'` )
	userCount=${#userList[*]}
	ListofUsers=( `cat  $file4 | awk -F'|' '{print $1}' > /tmp/users` )
	l_count=0
	while [ $l_count -lt $userCount ]; do

			if [ `grep -c -w ${userList[$l_count]}  /tmp/users` == 1 ] ;then
			{
					deleteUser "${userList[$l_count]}"
			}
			fi
	let l_count+=1
	done
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
	l_cmd=`rm -f $file1 $file2 $file3 $file4 /tmp/file5 /tmp/file6 $file7 $file9 /tmp/file7`
	if [ $? == 0 ] ;then
	log "SUCCESS:$FUNCNAME::removed all the input files"
	else
	log "ERROR:$FUNCNAME::Error in removing the input files"
	fi

}

function addAndRemove*Target ()
{
	
	EXPCMD="$path/manage_COM_privs.bsh -a target -T * -u vuser6 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file7 
	l_cmd=`grep "has been updated to type COM_OSS" /tmp/file7`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME:: Adding target * to vuser6 updated the user to type COM_OSS"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in converting vuser6 type COM_OSS"
	fi
	listprivs "vuser6"
	if [ `grep -c "Target \| \*" /tmp/file6` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: Added target * to vuser6"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target * to vuser6"
	fi
	EXPCMD="$path/manage_COM_privs.bsh -a role -R *:role1 -u vuser6 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	listprivs "vuser6"
	if [ `grep -c "Role   \| \*:role1" /tmp/file6` -a `grep -c "Target \| \*" /tmp/file6` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: Added target qualified role *:role1 to vuser6"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target qualified role *:role1 to vuser6"
	fi
	EXPCMD="$path/manage_COM_privs.bsh -a alias -A *:alias1 -u vuser6 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP 
	listprivs "vuser6"
	if [ `grep -c "Alias  \| \*:alias1" /tmp/file6` -a `grep -c "Target \| \*" /tmp/file6` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: Added target qualified alias *:alias1 to vuser6"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target qualified alias *:alias1 to vuser6"
	fi
	prepareBulkFile3
	EXPCMD="$path/manage_COM_privs.bsh -b $file9 -d vts.com -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file5
	listprivs "vuser5"
	if [ `grep -c "Role   \| \*:role2" /tmp/file6` -a `grep -c "Target \| \*" /tmp/file6` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: added target qualified role *:role2 to vuser5"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target qualified role *:role2 to vuser5"
	fi
	if [ `grep -c "Alias  \| \*:alias2" /tmp/file6` -a `grep -c "Target \| \*" /tmp/file6` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: added target qualified alias *:alias2 to vuser5"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target qualified alias *:alias2 to vuser5"
	fi
	#listprivs "vuser6"
	#if [ `grep -c "\*:role1" /tmp/file6` == 0 ] ;then
	#	log "SUCCESS:$FUNCNAME:: Removed target qualified role *:role2 to vuser6"
	#else
	#	G_PASS_FLAG=1
	#	log "ERROR:$FUNCNAME::Error in removing target qualified role *:role2 to vuser6"
	#fi
	#if [ `grep -c "\*:alias1" /tmp/file6` == 0 ] ;then
	#	log "SUCCESS:$FUNCNAME:: Removed target qualified alias *:alias2 to vuser6"
	#else
	#	G_PASS_FLAG=1
	#	log "ERROR:$FUNCNAME::Error in removing target qualified alias *:alias2 to vuser6"
	#fi
	listprivs "vuser4"
	if [ `grep -c "Target \| \*" /tmp/file6` == 1 ] ;then
		log "SUCCESS:$FUNCNAME:: Added target * to vuser4 using batch file"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in adding target * to vuser4 using batch file"
	fi
}

##############################
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
	log "INFO:$FUNCNAME::verifying:Adding & removing privileges (targets/role/aliases) to the multiple users of different types with -b option"
	AddRemovePrivs
	fi

	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::verifying:Adding & removing target qualified roles to the multiple users of different types with -b option"
	AddRemoveTargetRoles
	fi
	
	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::verifying:Adding & removing target qualified roles to the multiple users of different types with -b option and with target as *"
	addAndRemove*Target
	fi
	
	if [ $l_action == 5 ]; then
	log "INFO:$FUNCNAME::deleting all users and input files and privileges"
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

#verifying:Adding & removing privileges (targets/role/aliases) to the multiple users of different types with -b option
executeAction 2

#verifying:Adding & removing target qualified roles to the multiple users of different types with -b option
executeAction 3

#verifying:Adding & removing target qualified roles to the multiple users of different types with -b option and with target as *
executeAction 4

#deleting all users and input files
#executeAction 5

#Final assertion of TC, this should be the final step of tc
evaluateTC
