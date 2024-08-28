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
SDSE_DIR=/ericsson/sdee/bin
builkUserFile=/var/tmp/bulkUsers.txt
Domain_Name=`grep LDAP_DOMAIN /ericsson/sdee/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
importfile=/var/tmp/importfile.txt
finallist=/var/tmp/finallist.txt

prepareBulkUsersFile ()
{
	echo 'oss_on1:OSS_ONLY::ass_ope::eric@1234
oss_on2:OSS_ONLY::ass_ope::eric@1234
oss_on3:OSS_ONLY::ass_ope::eric@1234

com_ap1:COM_APP:::eric@1234:::
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


function ldapUserSearchOnSlave() {
		l_cmd=`cat $builkUserFile | sed '/^#/d' | awk -F':' '{print $1}' > /var/tmp/slaveUsers.txt`
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


###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
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
	log "INFO:checking users exits on omserv slave "
	ldapUserSearchOnSlave
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

#checking users exits on omserv slave
executeAction 3

#Final assertion of TC, this should be the final step of tc
evaluateTC
