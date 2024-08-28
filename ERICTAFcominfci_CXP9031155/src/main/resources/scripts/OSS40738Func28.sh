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
#SCRIPT="/ericsson/sdee/bin/manage_COM.bsh"

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        SCRIPT=/ericsson/opendj/bin/manage_COM.bsh
	PATH_DIR=/ericsson/opendj
else
        SCRIPT=/ericsson/sdee/bin/manage_COM.bsh
	PATH_DIR=/ericsson/sdee
fi


file1="/tmp/user99.txt"
file2="/tmp/importfile2.txt"
file3="/tmp/importfile3.txt"
###################################
#this function is for verifying TR HT96627 
##################################



prepareImportFile ()
{
	echo 'DOMAIN vts.com
ROLE designer,tester,manager
ALIAS alias_designer manager,tester' > $file2
}

prepareImportFile_alias ()
{
	echo 'DOMAIN vts.com
ROLE tester,designer
ALIAS alias_designer manager,designer
ALIAS alias_tester manager,tester' > $file3
}

prepareUserFile ()
{
	echo 'user99:COM_OSS::::password::*::designer:*::alias_designer' > $file1
}

function precon ()
{
	
	prepareImportFile
	EXPCMD="$SCRIPT -a import -d vts.com -f $file2 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	EXPCMD="$SCRIPT -l role"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file1
	if [ `grep -c designer /tmp/file1` == 1 -a `grep -c tester /tmp/file1` == 1 -a `grep -c manager /tmp/file1` == 1 ]; then
		log "SUCCESS:$FUCNAME:: Added required roles designer,tester,manager"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add required roles designer,tester,manager"
	fi
	
	prepareUserFile
	EXPCMD="${PATH_DIR}/bin/add_user.sh -f $file1 -d vts.com"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user99"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file2
	if [ `grep -c "*:designer" /tmp/file2` == 1 ]; then
		log "SUCCESS:$FUCNAME:: Added user user99 with target qualified role *:designer"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add user user99 witht target qualified role *:designer"
	fi
}
removeAlias ()
{
	#Removing alias from container
	EXPCMD="$SCRIPT -r alias -A alias_designer -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	#Checking the user list for alias_designer
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user99"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file3
	
	if [ `grep -c "*:alias_designer" /tmp/file3` == 0 ]; then
		log "SUCCESS:$FUCNAME:: Alias *:alias_designer was deleted from user user99"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Alias *:alias_designer was not deleted from user user99"
	fi
	
	#Checking the role list in domain for alias alias_designer
	EXPCMD="${PATH_DIR}/bin/manage_COM.bsh -l alias"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file4
	
	if [ `grep -c "alias_designer" /tmp/file4` == 0 ]; then
		log "SUCCESS:$FUCNAME:: Alias alias_designer was deleted from domain"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Alias alias_designer was not deleted from domain"
	fi
	
}

function removeRole ()
{
	#Removing role from container
	EXPCMD="$SCRIPT -r role -R designer -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	#Checking the user list for designer
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user99"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file5
	
	if [ `grep -c "*:designer" /tmp/file5` == 0 ]; then
		log "SUCCESS:$FUCNAME:: Role *:designer was deleted from user user99"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Role *:designer was not deleted from user user99"
	fi
	
	#Checking the role list in domain for role designer
	EXPCMD="${PATH_DIR}/bin/manage_COM.bsh -l role"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file6
	
	if [ `grep -c "designer" /tmp/file6` == 0 ]; then
		log "SUCCESS:$FUCNAME:: Role designer was deleted from domain"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Role designer was not deleted from domain"
	fi
	
}
precon_2 ()
{
	prepareImportFile_alias
	EXPCMD="$SCRIPT -a import -d vts.com -f $file3 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	EXPCMD="$SCRIPT -l role"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file7
	if [ `grep -c designer /tmp/file7` == 1 -a `grep -c tester /tmp/file7` == 1 -a `grep -c manager /tmp/file7` == 1 ]; then
		log "SUCCESS:$FUCNAME:: Added required roles designer,tester,manager"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add required roles designer,tester,manager"
	fi
	
	EXPCMD="$SCRIPT -l alias"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file8
	if [ `grep -c alias_designer /tmp/file8` == 1 -a `grep -c alias_tester /tmp/file8` == 1 ]; then
		log "SUCCESS:$FUCNAME:: Added required aliases alias_designer alias_tester"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add required aliases alias_designer alias_tester"
	fi
	
}


removeAliasWithMutipleTargets ()
{

	#Add target qualified aliases  *:alias_tester, target:alias_designer to user99
	#Removing role from container
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -a alias -A *:alias_tester,target:alias_designer -u user99 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP

	#Checking the added target qualified roles in user list
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user99"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file9
	if [ `grep -c "*:alias_tester" /tmp/file9` == 1 -a `grep -c "target:alias_designer" /tmp/file9` == 1 -a `grep -c "target" /tmp/file9` == 2 -a `grep -c "*" /tmp/file9` == 2 ]; then
		log "SUCCESS:$FUCNAME:: User user99 is added with target qualified roles *:tester, target:manager and targets *,target are added"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add target qualified roles *:tester, target:manager to user user99"
	fi

	#Removing role from container
	EXPCMD="$SCRIPT -r alias -A alias_tester -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	#Checking the user list for tester
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user99"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file10
	
	if [ `grep -c "*:alias_tester" /tmp/file10` == 0 -a `grep -c "target:alias_designer" /tmp/file10` == 1 -a `grep -c "*" /tmp/file10` == 1 -a `grep -c "target" /tmp/file10` == 2 ]; then
		log "SUCCESS:$FUCNAME:: Alias *:alias_tester was deleted from user user99. Other entries exists"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Alias *:alias_tester was not deleted from user user99 Or Other entries are deleted."
	fi
	
	#Checking the role list in domain for alias alias_tester
	EXPCMD="${PATH_DIR}/bin/manage_COM.bsh -l alias"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file11
	
	if [ `grep -c "alias_tester" /tmp/file11` == 0 ]; then
		log "SUCCESS:$FUCNAME:: Alias alias_tester was deleted from domain"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Alias alias_tester was not deleted from domain"
	fi
	
}

removeRoleWithMutipleTargets ()
{

	#Add target qualified roles *:tester, target:manager to user99
	#Removing role from container
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -a role -R *:tester,target:manager -u user99 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP

	#Checking the added target qualified roles in user list
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user99"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file12
	if [ `grep -c "*:tester" /tmp/file12` == 1 -a `grep -c "target:manager" /tmp/file12` == 1 -a `grep -c "target" /tmp/file12` == 1 -a `grep -c "*" /tmp/file12` == 3 ]; then
		log "SUCCESS:$FUCNAME:: User user99 is added with target qualified roles *:tester, target:manager and targets *,target are added"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to Add target qualified roles *:tester, target:manager to user user99"
	fi

	#Removing role from container
	EXPCMD="$SCRIPT -r role -R tester -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	#Checking the user list for tester
	EXPCMD="${PATH_DIR}/bin/manage_COM_privs.bsh -l -u user99"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file13
	
	if [ `grep -c "*:tester" /tmp/file13` == 0 -a `grep -c "target:manager" /tmp/file13` == 1 -a `grep -c "*" /tmp/file13` == 2 -a `grep -c "target" /tmp/file13` == 1 ]; then
		log "SUCCESS:$FUCNAME:: Role *:tester was deleted from user user99. Other entries exists"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Role *:tester was not deleted from user user99 Or Other entries are deleted."
	fi
	
	#Checking the role list in domain for role tester
	EXPCMD="${PATH_DIR}/bin/manage_COM.bsh -l role"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP >  /tmp/file14
	
	if [ `grep -c "tester" /tmp/file14` == 0 ]; then
		log "SUCCESS:$FUCNAME:: Role tester was deleted from domain"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Role tester was not deleted from domain"
	fi
	
}




function clearAll ()
{
	EXPCMD="$SCRIPT -r role -R manager,tester -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	EXPCMD="$SCRIPT -r alias -A alias_designer -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	EXPCMD="${PATH_DIR}/bin/del_user.sh -n user99 -y"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	
	rm -f $file1 $file2 /tmp/listAliasFile 
	rm -f /tmp/file1 /tmp/file2 /tmp/file3 /tmp/file4 /tmp/file5 /tmp/file6 /tmp/file7 /tmp/file8 /tmp/file9 /tmp/file10 /tmp/file11 /tmp/file12 /tmp/file13 /tmp/file14 
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME::Removed all the input files,roles and aliases"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error in removing input files,roles and aliases"
	fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
	l_action=$1

	if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::Executing preconditions:Adding Required roles,aliases. Adding user user99 with role *:designer"
	precon
	fi

	if [ $l_action == 2 ]; then
	log "INFO:$FUNCNAME::Removing role designer from domain"
	removeRole
	fi

	if [ $l_action == 3 ]; then
	log "INFO:$FUNCNAME::Remove role tester from domain, and check that tester was alone deleted from user user99"
	removeRoleWithMutipleTargets
	fi

	if [ $l_action == 4 ]; then
	log "INFO:$FUNCNAME::Removing alias alias_designer from domain"
	removeAlias
	fi

	if [ $l_action == 5 ]; then
	log "INFO:$FUNCNAME::Add alias alias_tester to domain and user . Remove alias alias_tester from domain, and check that alias_tester was alone deleted from user user99"
	precon_2
	removeAliasWithMutipleTargets
	fi
	
	if [ $l_action == 6 ]; then
	log "INFO:$FUNCNAME::clearing all the input files,roles and aliases"
	clearAll
	fi

}
#########
##MAIN ##
#########

# Executing preconditions:
executeAction 1

#Remove role designer from domain
executeAction 2

#Remove role tester from domain, and check that tester was alone deleted from user user99
executeAction 3

#Remove alias alias_designer from domain
executeAction 4

#Add alias alias_tester to domain and user . Remove alias alias_tester from domain, and check that alias_tester was alone deleted from user user99
executeAction 5

#clearing all the input files,roles and aliases
executeAction 6

#Final assertion of TC, this should be the final step of tc
evaluateTC
