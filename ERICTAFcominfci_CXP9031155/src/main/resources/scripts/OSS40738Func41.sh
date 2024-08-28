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
#logfile="/ericsson/sdee/adminlogs/moss_event_log"

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        path="/ericsson/opendj/bin"
	logfile="/ericsson/opendj/adminlogs/moss_event_log"
else
        path="/ericsson/sdee/bin"
	logfile="/ericsson/sdee/adminlogs/moss_event_log"
fi


testfile="/var/tmp/test123"
bulkfile=/var/tmp/bulk_promote
###################################
# Functions to verify bulk user promotion
#################################

preparePromoteUser ()
{
        EXPCMD="$path/promote_user.sh -f $bulkfile -d vts.com"
        EXITCODE=5
        INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
echo 'LDAP Directory Manager password
ldappass' > $INPUTEXP
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
    executeExpect $OUTPUTEXP >  $testfile
}

function testFileEmpty() {
        touch $bulkfile
        l_cmd=`$path/promote_user.sh -f $bulkfile -d vts.com`
        l_cmd=`grep "is empty" $logfile`
        if [ $? == 0 ] ; then
                log "SUCCESS:$FUCNAME:: Successfully verified ERROR for passed bulk file is empty.please Refer to $logfile"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME:: Failed to verify ERROR for passed bulk file is empty.please Refer to $logfile"
        fi
}

function testFileExistence() {
        l_cmd=`$path/promote_user.sh -f /var/tmp/bulk_promote123 -d vts.com`
        l_cmd=`grep "doesn't exist" $logfile`
        if [ $? == 0 ] ; then
                log "SUCCESS:$FUCNAME:: Successfully verified ERROR for non-existence of bulk file.please Refer to $logfile"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME:: Failed to verify ERROR for non-existence of bulk file.please Refer to $logfile"
        fi
}

function testDomainFile() {
        echo "test_user" > $bulkfile
        l_cmd=`$path/promote_user.sh -f $bulkfile`
        l_cmd=`grep "must be passed with -f option" $logfile`
        if [ $? == 0 ] ; then
                log "SUCCESS:$FUCNAME:: Successfully verified ERROR if -d <domain> is not passed with -f <bulk_file>.please Refer to $logfile"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME:: Failed to verify ERROR if -d <domain> is not passed with -f <bulk_file>.please Refer to $logfile"
        fi
}

function PromoteUser() {
        preparePromoteUser
        l_cmd=`grep "is not migrated to use the GD" $testfile`
                if [ $? == 0 ] ; then
                log "SUCCESS:$FUCNAME:: Successfully verified promote_user.sh script flow if -d <domain> is  passed with -f <bulk_file>"
        else
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME:: Failed to verify promote_user.sh script flow if -d <domain> is  passed with -f <bulk_file>"
        fi
        rm $bulkfile $testfile
}

##############################
#Execute the action to be performed
#####################################
function executeAction ()
{
        l_action=$1

        if [ $l_action == 1 ]; then
        log "INFO:$FUNCNAME::Verifying:Error for passed bulk file is empty or not"
        testFileEmpty
        fi

        if [ $l_action == 2 ]; then
        log "INFO:$FUNCNAME::Verifying:Error for non-existence of bulk file"
        testFileExistence
        fi

        if [ $l_action == 3 ]; then
        log "INFO:$FUNCNAME::verifying:Error if -d <domain> is not passed with -f <bulk_file>"
        testDomainFile
        fi

        if [ $l_action == 4 ]; then
        log "INFO:$FUNCNAME::Verifying the promote_user.sh script flow if -d <domain> is  passed with -f <bulk_file>"
        PromoteUser
        fi
}
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Verifying:Error for passed bulk file is empty or not
executeAction 1

#Verifying:Error for non-existence of bulk file
executeAction 2

#verifying:Error if -d <domain> is not passed with -f <bulk_file>
executeAction 3

#Verifying the promote_user.sh script flow if -d <domain> is  passed with -f <bulk_file>
executeAction 4


#Final assertion of TC, this should be the final step of tc
evaluateTC
