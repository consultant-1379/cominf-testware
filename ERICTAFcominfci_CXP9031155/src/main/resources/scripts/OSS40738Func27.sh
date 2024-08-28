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
SDSE_DIR=${PATH_DIR}/bin
builkUserFile=/var/tmp/bulkUsers.txt
Domain_Name=`grep LDAP_DOMAIN ${PATH_DIR}/ldap_domain_settings/*.default_domain | awk -F'=' '{print $2}'`
ciphersListFile=/var/tmp/ciphers_list
OPENDJ=0
if [ ${PATH_DIR} == "/ericsson/opendj" ]; then
	OPENDJ=1
fi


function prepareBulkUsersFile()
{
        echo 'ossrc5:OSS_ONLY::sys_adm::eric@1234' > $builkUserFile
}

function prepareExpects()
{
        prepareBulkUsersFile
        EXPCMD="$SDSE_DIR/add_user.sh -d $Domain_Name -f $builkUserFile"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
}

function uasLoginexpectEx()
{

        EXPCMD="ssh -o StrictHostKeyChecking=no ossrc5@uas1"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'Password
eric@1234
while { true } {
New Password
ldap@1234
Re-enter new Password
ldap@1234
}
>
exit' > $INPUTEXP

}

function check_Login_after_LDAP_hardening() {

                uasLoginexpectEx
                #createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
                #executeExpect $OUTPUTEXP
                if [ $? == 0 ]
                then
                        log "INFO:: UAS login success for user ossrc5"
                else
                        G_PASS_FLAG=1
                        log "ERROR:  UAS login failed for user ossrc5"
                fi
}



function ldapUserSearch() {

                        ldapsearch -h localhost -D "cn=directory manager" -w "ldappass" -b "uid=ossrc5,ou=people,dc=vts,dc=com" "objectclass=*"
                        ret=$?
                                if [ $ret == 0 ] ; then
                                        log "SUCCESS:: ldap_search is working after LDAP HARDENING applied"
                                else
                                        G_PASS_FLAG=1
                                        log "ERROR:: ldap_search is not working after LDAP HARDENING applied"
                                fi

}

function delLDAPuser() {

        EXPCMD="$SDSE_DIR/del_user.sh -n ossrc5 -y"
                EXITCODE=5
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
                echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP

        if [ $? == 0 ]
        then
                        log " INFO: LDAP user deleted successfully"
        else
                        G_PASS_FLAG=1
                        log "ERROR:: LDAP user cannot be deleted"
        fi
}

function addLDAPuser() {

                log "INFO: Creating LDAP users"
                prepareExpects
                createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
                executeExpect $OUTPUTEXP

                ret=$?
                        if [ $ret == 0 ] ; then
                                log "INFO:: LDAP user created Sucessfully"
                        else
                                G_PASS_FLAG=1
                                log "ERROR:: LDAP user cannot be created"
                        fi


}
function listCiphers() {

                EXPCMD="$SDSE_DIR/ldap_hardening.sh -l"
                EXITCODE=5
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
                echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP > $ciphersListFile

                if [ $? == 0 ]
                then
                        log "SUCCESS: Enabled Ciphers list is displayed."
                else
                        log "ERROR: Cannot list Enabled ciphers."
                        G_PASS_FLAG=1
                fi
}

function ciphers_list_ldap_hardening_enabled() {

                listCiphers
				if [ $OPENDJ == 1 ]; then
					if [ `grep -c TLS $ciphersListFile` == 11 ]
					then
                        echo "SUCCESS: LDAP HARDENING applied successfully with 11 ciphers"
					else
						echo "ERROR: LDAP HARDENING enabling is not successfull. Ciphers count is not 11 "
                        G_PASS_FLAG=1
					fi
				else
					if [ `grep -c ssl-cipher-family $ciphersListFile` == 15 ]
					then
							echo "SUCCESS: LDAP HARDENING applied successfully with 15 ciphers"
					else
							echo "ERROR: LDAP HARDENING enabling is not successfull. Ciphers count is not 15 "
							G_PASS_FLAG=1
					fi
				fi
}


function ciphers_list_ldap_hardening_disabled() {

			listCiphers
			if [ $OPENDJ == 1 ]; then
				if [ `grep -c ssl-cipher-suite $ciphersListFile` == 1 ]
				then
						echo "SUCCESS: LDAP HARDENING disabled successfully"
				else
						echo "ERROR: LDAP HARDENING disabling is not successfull. Ciphers count is not 1 "
						G_PASS_FLAG=1
				fi
			else
				if [ `grep -c ssl-cipher-family $ciphersListFile` == 1 ]
				then
						echo "SUCCESS: LDAP HARDENING disabled successfully"
				else
						echo "ERROR: LDAP HARDENING disabling is not successfull. Ciphers count is not 1 "
						G_PASS_FLAG=1
				fi
			fi
              

}

function enableLDAPhardening() {

                EXPCMD="$SDSE_DIR/ldap_hardening.sh -e"
                EXITCODE=5
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
                echo 'LDAP Directory Manager password
ldappass
Do you want to continue
y' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		sed "s/set timeout 40/set timeout 400/g" $OUTPUTEXP > /var/tmp/file
		sed "s/set timeout 300/set timeout 600/g" /var/tmp/file > /var/tmp/file123
		mv /var/tmp/file123  $OUTPUTEXP
        executeExpect $OUTPUTEXP
        ciphers_list_ldap_hardening_enabled
        ret=$?
        echo "Return status is $ret"
                if [ $ret == 0 ]
                then
                        log "SUCCESS: LDAP HARDENING applied."
                else
                        log "ERROR: Ldap hardening cannot be applied."
                        G_PASS_FLAG=1
                fi
}

function disableLDAPhardening() {

                EXPCMD="$SDSE_DIR/ldap_hardening.sh -d"
                EXITCODE=5
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
                echo 'LDAP Directory Manager password
ldappass
Do you want to continue
y' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		sed "s/set timeout 40/set timeout 400/g" $OUTPUTEXP > /var/tmp/file
		sed "s/set timeout 300/set timeout 600/g" /var/tmp/file > /var/tmp/file123
		mv /var/tmp/file123  $OUTPUTEXP
        executeExpect $OUTPUTEXP

        ciphers_list_ldap_hardening_disabled
        ret=$?
         echo "Return status is $ret"
                if [ $ret == 0 ]
                then
                        log "SUCCESS: LDAP HARDENING disabled."
                else
                        log "ERROR: Ldap hardening cannot be disabled."
                        G_PASS_FLAG=1
                fi

}
function checkDSservice() {
			if [ $OPENDJ == 1 ]; then
				service="svc:/network/opendj:default"
			else
				service="svc:/application/sun/ds:ds--var-ds"
			fi
			ds_service_status=`svcs ${service} | tail -1 | awk '{print $1}'`
			if [ $ds_service_status == "online" ]
			then
					log "SUCCESS: DS service available."
			else
					log "ERROR: DS service is unavailable."
					G_PASS_FLAG=1
			fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
l_action=$1

        if [ "$l_action" == 1 ]; then
        log "INFO: Checking whether ds service is enabled or not"
        checkDSservice
        fi


        if [ "$l_action" == 2 ]; then
        log "INFO: Enabling LDAP hardening using ldap_hardening.sh script"
        enableLDAPhardening
        fi


        if [ "$l_action" == 3 ]; then
        log "INFO: Listing all the enabled ciphers ( When LDAP hardening is enabled )"
        ciphers_list_ldap_hardening_enabled
        fi


        if [ "$l_action" == 4 ]; then
        log "INFO: Checking ldap user addition"
        addLDAPuser
        fi


        if [ "$l_action" == 5 ]; then
        log "INFO: Login to OSS and UAS with root and ldap user"
        check_Login_after_LDAP_hardening
        fi


        if [ "$l_action" == 6 ]; then
        log "INFO: Checking whether ldapsearch command is working or not "
        ldapUserSearch
        fi


        if [ "$l_action" == 7 ]; then
        log "INFO: Checking ldap user deletion "
        delLDAPuser
        fi


        if [ "$l_action" == 8 ]; then
        log "INFO: Disabling LDAP hardeining using ldap_hardening.sh script"
        disableLDAPhardening
        fi


        if [ "$l_action" == 9 ]; then
        log "INFO: Listing all the enabled ciphers  When LDAP hardening is disabled"
        ciphers_list_ldap_hardening_disabled
        fi

 }


#########
##MAIN ##
#########

#Check whether ds service is enabled or not
executeAction 1

#Enable LDAP hardening using ldap_hardening.sh script
executeAction 2


#List all the enabled ciphers ( When LDAP hardening is enabled )
executeAction 3


#Check ldap user addition
executeAction 4


#Login to OSS and UAS with root and ldap user
executeAction 5


#Check whether ldapsearch command is working or not
executeAction 6


#Check ldap user deletion
executeAction 7


#Disable LDAP hardeining using ldap_hardening.sh script
executeAction 8


#List all the enabled ciphers ( When LDAP hardening is disabled )
executeAction 9


#Final assertion of TC, this should be the final step of tc
evaluateTC

