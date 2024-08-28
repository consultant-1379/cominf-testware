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
Var=0
Var2=0
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


file1="/tmp/add_roles"
file2="/tmp/add_user_file"
file2="/tmp/batchFile2"
file3="/tmp/batchFile3"
#file4="/tmp/batchFile4"
#file5="/tmp/batchFile5"
#file6="/tmp/batchFile6"
file7="/tmp/log_listUser"
file8="/tmp/log_addUser"
###################################
# Functions to add/remove priveleges to users using manage_COM_privs.bsh script with -f <batch_file> option
#################################
prepare_add_roleFile () {
echo 'DOMAIN vts.com
ROLE SystemAdministrator,SystemSecurityAdministrator,EricssonSupport,CpRole0' > $file1
}
prepare_add_userFile ()
{
echo 'HT22877:COM_OSS::ass_ope:example_description:password::VCZ20U::SystemAdministrator,VCZ20U::SystemSecurityAdministrator,VCZ20U::EricssonSupport,VCZ20U::CpRole0,VCZ20U_1::SystemAdministrator,VCZ20U_1::SystemSecurityAdministrator,VCZ20U_1::EricssonSupport,VCZ20U_1::CpRole0:' > $file2
}
prepare_Batch_File ()
{
echo 'DOMAIN vts.com
ACTION remove
OBJECT target
HT22877 VCZ20U' > $file3
}

prepareAddUser ()
{
        prepare_add_userFile
        EXPCMD="$path/add_user.sh -f $file2 -d vts.com"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
}

function precon ()
{

        prepare_add_roleFile
        EXPCMD="$path/manage_COM.bsh -a import -d vts.com -f $file1  -y"
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

        prepareAddUser
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP > $file8
        l_cmd=`grep -c "INFO: successfully added HT22877" $file8`
        if [ $? == 0 ] ;then
                log "SUCCESS:$FUNCNAME:: added required user:HT22877"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Error in adding required user:HT22877"
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
        executeExpect $OUTPUTEXP > /tmp/file9
}

function addRemovePrivs ()
{
        EXPCMD="$path/manage_COM_privs.bsh $1 $2 -d vts.com -f $3 -y"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        listprivs "HT22877"
}

function remove_Target ()
{
        prepare_Batch_File
        addRemovePrivs "-r" "target" "$file3"
        if [ `grep -c "VCZ20U_1:SystemAdministrator" /tmp/file9` == 0 ] ;then
                log "ERROR::Similar targets to VCZ20U are also removed"
                G_PASS_FLAG=1
        else

                log "SUCCESS::Only target VCZ20U is removed"
        fi
}


function clearAll () {

        EXPCMD="$path/del_user.sh -n HT22877 -y"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        if [ $? == 0 ] ;then
                        log "SUCCESS:$FUNCNAME::deleted user HT22877"
        else
        				G_PASS_FLAG=1
                        log "ERROR:$FUNCNAME::Error in deleting user HT22877"
        fi
        l_cmd=`rm -f $file1 $file2 $file3 $file8 /tmp/file9`
        if [ $? == 0 ] ;then
        	log "SUCCESS:$FUNCNAME::removed all the input files"
        else
        	G_PASS_FLAG=1
        	log "ERROR:$FUNCNAME::Error in removing the input files"
        fi
        EXPCMD="$path/manage_COM.bsh -r role -R SystemAdministrator,SystemSecurityAdministrator,EricssonSupport,CpRole0 -y"
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
        	G_PASS_FLAG=1
        	log "ERROR:$FUNCNAME::Error in removing roles and aliases"
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
        log "INFO:Adding a user HT22877 and assigning a target qualified roles VCZ20U:SystemAdministrator,VCZ20U:SystemSecurityAdministrator,VCZ20U:EricssonSupport,VCZ20U:CpRole0,VCZ20U_1:SystemAdministrator,VCZ20U_1:SystemSecurityAdministrator,VCZ20U_1:EricssonSupport,VCZ20U_1:CpRole0 to user HT22877  using add_user with -f <batch_file> option"
        precon
        fi
        l_action=$1

        if [ $l_action == 2 ]; then
        log "INFO:Removing a target VCZ20U of HT22877  using manage_COM_privs.bsh script "
        remove_Target
        fi

        if [ $l_action == 3 ]; then
        log "INFO:Deleting all remaining privilges of user HT22877, and deleting the user HT22877."
        clearAll
        fi


}
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.


#Adding a user HT22877 and assigning a target qualified roles VCZ20U:SystemAdministrator,VCZ20U:SystemSecurityAdministrator,VCZ20U:EricssonSupport,VCZ20U:CpRole0,VCZ20U_1:SystemAdministrator,VCZ20U_1:SystemSecurityAdministrator,VCZ20U_1:EricssonSupport,VCZ20U_1:CpRole0 to user HT22877 using add_user with -f <batch_file> option
executeAction 1

#Removing a target VCZ20U of HT22877 using manage_COM_privs.bsh script
executeAction 2

#Deleting all remaining privilges of user HT22877 , and deleting the user tuser1.
executeAction 3

#Final assertion of TC, this should be the final step of tc
evaluateTC
