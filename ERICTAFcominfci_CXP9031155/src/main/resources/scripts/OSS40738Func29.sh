
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
        path=/ericsson/opendj/bin
else
        path=/ericsson/sdee/bin
fi


file1="/tmp/adduser123.txt"
file2="/tmp/importfile123.txt"

###################################
# Functions to add/remove priveleges to users using manage_COM_privs.bsh script with -b  option
#################################
prepareBulkUserfile () {
echo 'user_TC0:COM_ONLY::example_description:password:PBS,PRBS::
user_TC1:COM_OSS::ass_ope:example_description:password:*:system_administrator:
user_TC2:COM_OSS::ass_ope:example_description:password:*,PRBS::
user_TC3:COM_OSS::ass_ope:example_description:password:*:*::system_administrator:
user_TC4:COM_ONLY::example_description:password:PRBS:*::system_administrator:*::alias1' > $file1
}

prepareImportFile () {
echo 'DOMAIN vts.com
ROLE system_administrator,admin
ALIAS alias1 system_administrator,admin' > $file2
}


function addUser () {

        prepareImportFile
        EXPCMD="$path/manage_COM.bsh -a import -d vts.com -f  $file2 -o  -y"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP

    prepareBulkUserfile
        EXPCMD="$path/add_user.sh -d vts.com -f $file1"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP

}
function delUser(){

        prepareBulkUserfile
        COUNT=1
        users=`wc -l $file1|awk '{print $1}'`
        while [ $COUNT -le $users ]
        do
        uname=`sed -n "$COUNT p" $file1 | awk -F":" '{print $1}'`
        EXPCMD="$path/del_user.sh -d vts.com -n $uname -y "
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        COUNT=$((COUNT +1))
        done

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

function addUsertarget ()
{

        addUser
        listprivs "user_TC0"
        if [ `grep -c "Target \| PBS" /tmp/file6` -a `grep -c "Target \| PRBS" /tmp/file6` == 1 ] ;then
                log "SUCCESS:$FUNCNAME:: Added target PBS and PRBS to user_TC0"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed in adding target PBS and PRBS to user_TC1"
        fi
        listprivs "user_TC1"
        if [ `grep -c "Target \| \*" /tmp/file6` -a `grep -c "Role   \| system_administrator" /tmp/file6` == 1 ] ;then
                log "SUCCESS:$FUNCNAME:: Added target * and Role system_administrator to user_TC1"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed in adding * and Role system_administrator to user_TC1"
        fi
        listprivs "user_TC2"
        if [ `grep -c "Target \| \*" /tmp/file6` -a `grep -c "Target \| PRBS" /tmp/file6` == 1 ] ;then
                log "SUCCESS:$FUNCNAME:: Added target * and PRBS to user_TC2"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed in adding target * and PRBS to user_TC2"
        fi

        listprivs "user_TC3"
        if [ `grep -c "Target \| \*" /tmp/file6` -a `grep -c "Role   \| \*:system_administrator" /tmp/file6` == 1 ] ;then
                log "SUCCESS:$FUNCNAME:: Added target * and Role *:system_administrator to user_TC3"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed in adding target * and Role *:system_administrator to user_TC3"
        fi

        listprivs "user_TC4"
         if [ `grep -c "Target \| PRBS" /tmp/file6` -a `grep -c "Target \| \*" /tmp/file6` -a `grep -c "Role   \| \*:system_administrator" /tmp/file6` -a `grep -c "Alias  \| \*:alias1" /tmp/file6` == 1 ] ;then
                log "SUCCESS:$FUNCNAME:: Added target PRBS target * and Role *:system_administrator and Alias *:alias1 to user_TC4"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::Failed in adding target PRBS target * and Role *:system_administrator and Alias *:alias1 to user_TC4"
        fi
}

###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1

 if [ $l_action == 1 ]; then
   log "INFO:Started ACTION 1"
   log "INFO:$FUNCNAME::Executing bulk user creation"
   addUsertarget
   log "INFO:Completed ACTION 1"
 fi

 if [ $l_action == 2 ]; then
   log "INFO:Started ACTION 2"
   log "INFO:$FUNCNAME::Executing delete users created"
   delUser
   log "INFO:Completed ACTION 2"
 fi


}



#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Execute Creation of bulk users
executeAction 1

#Execute delete Users created
executeAction 2

#Fina assertion of TC, this should beel the final step of tc
evaluateTC

