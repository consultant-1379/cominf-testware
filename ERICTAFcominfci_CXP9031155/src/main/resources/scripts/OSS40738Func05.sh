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
script="/ericsson/sdee/bin/prepSSL.sh"

###################################
#
#################################
prepareSslCertCheck () 
{
	EXPCMD="$script"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
Choose an operation
8
Do you want to return to the main menu
n' > $INPUTEXP
}

prepareRootCertCheck ()
{
	EXPCMD="$script"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
Choose an operation
9
Do you want to return to the main menu
n' > $INPUTEXP
}

prepareCheckDelete ()
{
	EXPCMD="$script"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
Choose an operation
4
Enter cert name you wish to remove
slapd' > $INPUTEXP
}

prepareSslAssgment ()
{
	EXPCMD="$script"
    EXITCODE=5
    INPUTEXP=/tmp/${SCRIPTNAME}.in
    OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'LDAP Directory Manager password
ldappass
Choose an operation
6
Do you want to return to the main menu
n' > $INPUTEXP
}	

function SslcertCheck () {
	prepareSslCertCheck
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file2
		if [ `grep -c "2 certificate" /tmp/file2` == 1 -a  `grep -c "defaultCert" /tmp/file2` == 1 ] ;then 
			rm -f /tmp/file2
			log "SUCCESS:$FUNCNAME::verified:the list of existing server certificates enabled with sun-ds"
        else
			rm -f /tmp/file2
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Error in the list of existing server certificates enabled with sun-ds"
         fi
		 
}

function RootcertCheck () {
	prepareRootCertCheck
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file3
		if [ `grep -c "4 certificate" /tmp/file3` == 1 -a  `grep -c "defaultCert" /tmp/file3` == 1 ] ;then 
			rm -f /tmp/file3
			log "SUCCESS:$FUNCNAME::verified:the list of existing root certificates enabled with sun-ds"
        else
			rm -f /tmp/file3
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Error in the list of existing root certificates enabled with sun-ds"
         fi
		getSDEELogs "prepSSL"
        ERROR_STG="ERROR"
        l_cmd=`grep -w "${ERROR_STG}" $SDEE_LOG`
		if [ $? != 0 ]; then
                log "SUCCESS:$FUNCNAME::No error reported while listing the existing root certificates enabled with sun-ds. Please refer to $SDEE_LOG"
				else
			    G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::errors reported while listing the existing root certificates enabled with sun-ds. Please refer to $SDEE_LOG"
		fi
	 
}

function CheckDelete () {
	prepareCheckDelete
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file4
		if [ `grep -c "You cannot delete a ceritificate currently in use by SUN-DS" /tmp/file4` == 1 ] ;then
			rm -f /tmp/file4
			log "SUCCESS:$FUNCNAME::verified:message:'You cannot delete a ceritificate currently in use by SUN-DS' while trying to delete existing server certificate:slapd"
		else
			rm -f /tmp/file4
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::failed to display message:'You cannot delete a ceritificate currently in use by SUN-DS' while trying to delete existing server certificate:slapd"
		fi
		getSDEELogs "prepSSL"
        ERROR_STG="ERROR"
        l_cmd=`grep -w "${ERROR_STG}" $SDEE_LOG`
		if [ $? != 0 ]; then
                log "SUCCESS:$FUNCNAME::No error reported while trying to delete existing server certificate:slapd.Please refer to $SDEE_LOG"
				else
			    G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::errors reported while while trying to delete existing server certificate:slapd .Please refer to $SDEE_LOG"
		fi
		getSDEELogs "prepSSL"
        MESSAGE_STG="You cannot delete a ceritificate currently in use by SUN-DS"
        l_cmd=`grep -w "${MESSAGE_STG}" $SDEE_LOG`
		if [ $? == 0 ]; then
                log "SUCCESS:$FUNCNAME::message:'You cannot delete a ceritificate currently in use by SUN-DS' reported while trying to delete existing server certificate:slapd.Please refer to $SDEE_LOG"
				else
			    G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::message:'You cannot delete a ceritificate currently in use by SUN-DS' is not reported while trying to delete existing server certificate:slapd.Please refer to $SDEE_LOG"
		fi
}	
function SslAssgmentCheck () {
	prepareSslAssgment
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file5
		if [ `grep -c "current SSL assignment = \[slapd\]" /tmp/file5` == 1 ] ;then 
			rm -f /tmp/file5
			log "SUCCESS:$FUNCNAME::verified:SUN-DS is using the required SSL certificate"
        else
			rm -f /tmp/file5
			G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Error :SUN-DS is not using the required SSL certificate"
         fi 
		log "$FUNCNAME::Executing ldapsearch command using the installed SUN-DS Utilities"
		l_cmd=`/opt/SUNWdsee/dsee6/bin/ldapsearch -D "cn=directory manager" -w "ldappass" -P /var/ds/alias/slapd-cert8.db -Z -b "dc=vts,dc=com" "objectclass=*"`
		if [ $? == 0 ]; then
           		 log "SUCCESS:$FUNCNAME:: ldapsearch command returned values from the SUN-DS over SSL,SSL is configured correctly on the server"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::SSL is not configured correctly on the server"
		fi
}

function SslConfigCheck () {
	l_cmd=`ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' root@ossmaster "echo" > /dev/null 2>&1`
	ret=$?
		if [[ "$ret" == 0 ]] ; then
	
			l_cmd=`ssh ossmaster ldapsearch -h omsrvm.vts.com -P /var/ldap/cert8.db -b "dc=vts,dc=com" "objectclass=*"`
			if [ $? == 0 ]; then
        			log "SUCCESS:$FUNCNAME::verified: SSL configuration by running ldapsearch command on the Client"
			else
				G_PASS_FLAG=1
				log "ERROR:$FUNCNAME::Error is SSL configuration"
			fi
		else
			path=/var/ldap/cert8.db
			l_cmd="ssh ossmaster ldapsearch -h omsrvm.vts.com -P $path -b \"dc=vts,dc=com\" \"objectclass=*\""
			EXPCMD=$l_cmd
			EXITCODE=5
			INPUTEXP=/tmp/${SCRIPTNAME}.in
			OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
			echo 'Password
shroot12' > $INPUTEXP
			createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
			executeExpect $OUTPUTEXP > /var/tmp/search.txt
			l_cmd=`grep "dn: cn=default,ou=profile,dc=vts,dc=com" /var/tmp/search.txt`
			ret=$?
			if [ $ret == 0 ] ; then
	 		        log "SUCCESS:$FUNCNAME::verified: SSL configuration by running ldapsearch command on the Client"
                        else
                                G_PASS_FLAG=1
                                log "ERROR:$FUNCNAME::Error is SSL configuration"
                        fi	
		fi
}

function AnonymousBindCheck () {
	l_cmd=`ldapsearch -b "dc=vts,dc=com" "objectclass=*"`
	if [ $? == 0 ]; then
        log "SUCCESS:$FUNCNAME::verified:Anonymous Bind to the DS is enabled by running ldapsearch command"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::Error Anonymous Bind to the DS"
	fi
}
##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::verifying the list of existing server certificates enabled with sun-ds"
   #SslcertCheck
 fi
 
 if [ $l_action == 2 ]; then
   log "INFO:$FUNCNAME::verifying the list of root server certificates enabled with sun-ds"
   #RootcertCheck
 fi
 
 if [ $l_action == 3 ]; then
   log "INFO:$FUNCNAME::verifying the message while trying to delete existing server certificate:slapd"
   #CheckDelete
 fi
 
 if [ $l_action ==  4 ]; then
   log "INFO:$FUNCNAME::verifiying SUN-DS is using the required SSL certificate"
   #SslAssgmentCheck
 fi
 
 if [ $l_action ==  5 ]; then
   log "INFO:$FUNCNAME::verifying  SSL configuration by running  ldapsearch command on the Client"
   SslConfigCheck
 fi
 
 if [ $l_action ==  6 ]; then
   log "INFO:$FUNCNAME::Verify Anonymous Bind to the DS is enabled by running ldapsearch command"
   #AnonymousBindCheck 
 fi
 } 
 
 
 #########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#verifying the list of existing server certificates enabled with sun-ds
executeAction 1

#verifying the list of existing  root certificates enabled with sun-ds
executeAction 2

#verifying the message while trying to delete existing server certificate:slapd 
executeAction 3 

#verifying SUN-DS is using the required SSL certificate
executeAction 4

# verifying  SSL configuration by running  ldapsearch command on the Client
executeAction 5

#Verify Anonymous Bind to the DS is enabled  by running ldapsearch command
executeAction 6

#Final assertion of TC, this should be the final step of tc
evaluateTC

