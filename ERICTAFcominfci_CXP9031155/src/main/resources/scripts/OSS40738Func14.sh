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


###TC VARIABLE##


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
	VALUE="Minimum password length is 8 chars" 
else
        PATH_DIR="/ericsson/sdee/"
	VALUE="Minimum password length is 8 chars"	
fi
 
SCRIPT="${PATH_DIR}/bin/add_user.sh"  
file1="/tmp/bulkfile1"
file2="/tmp/bulkfile2"
file3="/tmp/bulkfile3"
file4="/tmp/bulkfile4"
file5="/tmp/bulkfile5"
file6="/tmp/bulkfile6"
file7="/tmp/bulkfile7"
file0="/tmp/emptyfile"
SDSE_DIR="${PATH_DIR}/bin"
Domain_Name=`grep LDAP_DOMAIN ${PATH_DIR}/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
importfile=/var/tmp/users_1.txt

#####################################################
#this function is for verifying the adding bulk users
#####################################################
prepareBulkFile1 () 
{

	 echo 'pci_usr2:COM_OSS::sys_adm::eric:target::
pci_usr1:COM_OSS::::eric@1234:::
pci_usr8:OSS_ONLY::ass_ope::' > $file1

}


prepareBulkFile2 () {

echo '
:OSS_ONLY::ass_ope::eric@1234
invalid1234:OSS_ONLY::ass_ope::eric@1234 ' > $file2

}


prepareBulkFile3 () {

echo 'pci_usr3:COM_APP:::eric@1234:target1,target1::
pci_usr4:COM_APP:::eric@1234::role2,role2:
pci_usr5:COM_APP:::eric@1234:::alias2,alias2 ' > $file3

}


prepareBulkFile4 () {

echo 'validus1:OSS_ONLY::ass_ope::eric@1234
validus1::2001:::eric@1234
validus2:OSS_ONLY:2002:ass_ope::eric@1234
kci_usr2:OSS_ONLY:2002:ass_ope::eric@1234 ' > $file4

}

prepareBulkFile5 () {

echo '123:OSS_ONLY:2002:ass_ope::eric@1234' > $file5

}

prepareBulkFile6 () {

echo 'validus1:OSS_OLY:2002:ass_ope::eric@1234' > $file6

}


prepareBulkFile7 () {

echo 'com_on2:COM_ONLY::description:eric@1234:
com_ap14:COM_APP:::eric@1234:' > $file7

}



prepareBulkFile0 () 
{
  echo '#
  #' > $file0
}


prepareImportFile3 () {
	echo 'DOMAIN vts.com
ROLE role1,role2,role3
ALIAS alias1 role1,role2
ALIAS alias2 role2,role3' > $importfile
}

function createRolesAlias ()
{

		EXPCMD="$SDSE_DIR/manage_COM.bsh -a import -d $Domain_Name -f $importfile -y"
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
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::Error in creating the required roles and alias"
		fi 
}

function emptyBulkFile ()
{
	prepareBulkFile0
	addBulkUsers $file0
	executeExpect $OUTPUTEXP > /tmp/adduser.txt
	
	
	l_cmd=`grep  "The file \[$file0\] is empty" /tmp/adduser.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified ERROR for file to be empty"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: error not verified for empty file"
	fi

	}
function addBulkUsers ()
{

        EXPCMD="$SCRIPT -d $Domain_Name -f $1"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		
}

function completeValidate ()
{

	addBulkUsers $file1
	executeExpect $OUTPUTEXP > /tmp/adduser1.txt
	l_cmd=`grep  "Atleast one privilege" /tmp/adduser1.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified ERROR for non-existence of atleast one privilege for COM_OSS user"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Not verified ERROR for non-existence of atleast one privilege for COM_OSS user"
	fi
	
	l_cmd8=`grep "Mandatory fields are missing" /tmp/adduser1.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified Adding user when password is not given. "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Not verified Adding user when password is not given."
	fi
	l_cmd1=`grep "${VALUE}" /tmp/adduser1.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified ERROR for Minimum password length is 8 chars"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Failed to verify ERROR for Minimum password length is 8 chars"
	fi 
 
	addBulkUsers $file2
	executeExpect $OUTPUTEXP > /tmp/adduser2.txt
	
	l_cmd13=`grep "The length of the user \[invalid1234\] is greater than 8" /tmp/adduser2.txt`	
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified adding user having length greater than 8 "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: The length of the user must be greater than 8"
	fi
	
	
	l_cmd7=`grep "The username field is empty" /tmp/adduser2.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified Adding user without username is not given "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: The username field should not be empty"
	fi
	
	
	addBulkUsers $file3
	executeExpect $OUTPUTEXP > /tmp/adduser3.txt
	
	l_cmd2=`grep "Duplicated Targets" /tmp/adduser3.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified ERROR for Duplicated Targets "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Duplicated Targets are not allowed"
	fi
	
	l_cmd3=`grep "Duplicated Aliases" /tmp/adduser3.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified ERROR for Duplicated Aliases "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Duplicated Aliases are not allowed"
	fi
	
	l_cmd4=`grep "Duplicated roles" /tmp/adduser3.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified ERROR for Duplicated roles "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Duplicated roles are not allowed"
	fi
	
	
	addBulkUsers $file4
	executeExpect $OUTPUTEXP > /tmp/adduser4.txt


	
		l_cmd12=`grep " The uid \[2002\] is duplicated in the file" /tmp/adduser4.txt`	
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified Duplicate the user id addition "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: User IDs  must be unique"
	fi
	
	l_cmd=`grep " The username \[validus1\] is duplicated in the file. It is repeated in the file for 2 times" /tmp/adduser4.txt`	
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified Duplicate the user addition "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: User must be unique"
	fi

	
	addBulkUsers $file5
	executeExpect $OUTPUTEXP > /tmp/adduser5.txt
	
	l_cmd10=`grep "user name must start with an alpha" /tmp/adduser5.txt`	
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified Adding users with invalid username that is with username starting with digits "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: User name must start with an alpha"
	fi


	addBulkUsers $file6
	executeExpect $OUTPUTEXP > /tmp/adduser6.txt
	
	
	l_cmd14=`grep " Invalid user type \[OSS_OLY\]" /tmp/adduser6.txt`	
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified Given invalid user type"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: Accepted invalid user type to add user "
	fi
	
	addBulkUsers $file7
	executeExpect $OUTPUTEXP > /tmp/adduser7.txt
	
	
	l_cmd5=`grep "The number of fields in the file for a COM_APP or COM_ONLY user should be 8" /tmp/adduser7.txt`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUCNAME:: verified adding COM_ONLY/COM_APP user with less number of fields "
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: COM_ONLY/COM_APP user with less number of fields is accepted"
	fi
	
	
		
	
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
	
function deleteUsers () {
		
		l_cmd=`cat $file1 | sed '/^#/d' | awk -F':' '{print $1}'`
		for users in ${l_cmd[@]}
		do
			deleteUserEx
		done
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

function removalOfTemporaryFiles()
{
	rm -f /tmp/bulkfile1
	rm -f /tmp/bulkfile2
	rm -f /tmp/bulkfile3
	rm -f /tmp/bulkfile4
	rm -f /tmp/bulkfile5
	rm -f /tmp/bulkfile6
	rm -f /tmp/bulkfile7
	rm -f /tmp/adduser.txt
	rm -f /tmp/adduser1.txt
	rm -f /tmp/adduser2.txt
	rm -f /tmp/adduser3.txt
	rm -f /tmp/adduser4.txt
	rm -f /tmp/adduser5.txt
	rm -f /tmp/adduser6.txt
	rm -f /tmp/adduser7.txt
	rm -f /tmp/emptyfile

}




###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
	l_action=$1
		
	if [[ "$l_action" == 1 ]]; then
	log "INFO:$FUNCNAME:: Checking Import file if empty"
	emptyBulkFile
	fi
	
	if [[ "$l_action" == 2 ]]; then
	log "INFO:$FUNCNAME:: Adding users from import file"
	completeValidate
	fi
	
	if [[ "$l_action" == 3 ]]; then
	log "INFO:$FUNCNAME:: deleting users if created"
	deleteUsers
	fi
	
	if [[ "$l_action" == 4 ]]; then
	log "INFO:$FUNCNAME:: Deleting created roles"
	deleteRoles
	fi
	
	}


#########
##MAIN ##
#########

#precondtion adding users and roles
#preparing the bulkfiles with valid,invalid users,user types,roles and ailas
prepareBulkFile1
prepareBulkFile2
prepareBulkFile3
prepareBulkFile4
prepareBulkFile5
prepareBulkFile6
prepareBulkFile7

# Preparing of import file for adding bulk roles and alias
prepareImportFile3

#Adding bulk roles and ailas
createRolesAlias

# Checking Import file if empty
executeAction 1

#Adding users from import file
executeAction 2

#Deleting users if created
executeAction 3

#Deleting created roles
executeAction 4

#Removing the temporary files that are added as part of the Test case
removalOfTemporaryFiles

#Final assertion of TC, this should be the final step of tc
evaluateTC
