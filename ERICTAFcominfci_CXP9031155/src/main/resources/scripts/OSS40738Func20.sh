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
file22="/tmp/add_user_file"
file3="/tmp/batchFile3"
file4="/tmp/batchFile4"
file8="/tmp/log_addUser"
###################################
# Functions to add/remove priveleges to users using manage_COM_privs.bsh script with -f <batch_file> option
#################################
prepare_add_roleFile () {
echo 'DOMAIN vts.com
ROLE role1,role2' > $file1
}
prepare_add_userFile ()
{
echo 'HT23821:COM_OSS::ass_ope:example_description:password:p1_1::' > $file22
}
prepare_Batch_File_one ()
{
echo 'DOMAIN vts.com
ACTION add
OBJECT target
HT23821 p1.1' > $file3
}

prepare_Batch_File_two ()
{
echo 'DOMAIN vts.com
ACTION add
OBJECT target
HT23821 p1-1' > $file4
}

prepareAddUser ()
{
        prepare_add_userFile
        EXPCMD="$path/add_user.sh -f $file22 -d vts.com"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
}

function precon ()
{

        prepare_add_roleFile
        EXPCMD="$path/manage_COM.bsh -a import -d vts.com -f  $file1  -y"
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
        l_cmd=`grep -c "INFO: successfully added HT23821" $file8`
        if [ $? == 0 ] ;then
                log "SUCCESS:$FUNCNAME:: added required user:HT23821"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Error in adding required user:HT23821"
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
        listprivs "HT23821"
}

function add_Target_one ()
{
        prepare_Batch_File_one
        addRemovePrivs "-a" "target" "$file3"
        if [ `grep -c p1[.]1 /tmp/file9` == 0 ] ;then
                G_PASS_FLAG=1
                log "ERROR::Dot character(.) in target is handled as regular expression"
        else

                log "SUCCESS::p1.1 added sucessfully"
        fi
}

function add_Target_two ()
{
        prepare_Batch_File_two
        addRemovePrivs "-a" "target" "$file4"
        if [ `grep -c p1[-]1 /tmp/file9` == 0 ] ;then
                G_PASS_FLAG=1
                log "ERROR::Target having (-) character cannot be added"
        else

                log "SUCCESS::p1-1 added sucessfully"
        fi
}

function clearAll () {

        EXPCMD="$path/del_user.sh -n HT23821 -y"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        if [ $? == 0 ] ;then
                        log "SUCCESS:$FUNCNAME::deleted user HT23821"
        else
        				G_PASS_FLAG=1
                        log "ERROR:$FUNCNAME::Error in deleting user HT23821"
        fi
        l_cmd=`rm $file1 $file22 $file3 $file4 $file8 /tmp/file9`
        if [ $? == 0 ] ;then
        		log "SUCCESS:$FUNCNAME::removed all the input files"
        else
        		G_PASS_FLAG=1
        		log "ERROR:$FUNCNAME::Error in removing the input files"
        fi
        EXPCMD="$path/manage_COM.bsh -r role -R role1,role2 -y"
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
        log "INFO:Adding a user HT23821 and assigning a target p1_1 to user HT23821  using add_user with -f <batch_file> option"
        precon
        fi

        if [ $l_action == 2 ]; then
        log "INFO:Adding a target p1.1 to user HT23821  using manage_COM_privs.bsh script  "
        add_Target_one
        fi

        if [ $l_action == 3 ]; then
        log "INFO:Adding a target p1-1 to user HT23821  using manage_COM_privs.bsh script  "
        add_Target_two
        fi

        if [ $l_action == 4 ]; then
        log "INFO:Deleting all remaining privilges of user HT23821, and deleting the user HT23821"
        clearAll
        fi


}
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.


#Adding a user HT23821 and assigning a target p1_1 to user HT23821  using add_user with -f <batch_file> option
executeAction 1

#Adding a target p1.1 to user HT23821  using manage_COM_privs.bsh script
executeAction 2

#Adding a target p1-1 to user HT23821 using manage_COM_privs.bsh script.
executeAction 3

#Deleting all remaining privilges of user HT23821, and deleting the user HT23821.
executeAction 4

#Final assertion of TC, this should be the final step of tc
evaluateTC
