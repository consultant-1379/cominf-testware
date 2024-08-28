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
#file3="/tmp/file1"
#file4="/tmp/file2"

#########################################
#check Java version in omsrvm, omsrvs and nedss
#########################################

function checkjavaversion ()
{

#Checking in omsrvm
ssh smrs_master '[ -d /usr/jdk/instances/java1.7.0 ]'

if [ $? -eq 0 ]; then
     ssh smrs_master '/usr/jdk/instances/java1.7.0/bin/java -version &> /tmp/java_version'
     scp smrs_master:/tmp/java_version /tmp/ > /dev/null

     if [ `cat /tmp/java_version | grep version | grep -c "1.7.0"` -ne 1 ]; then
           G_PASS_FLAG=1
           log "ERROR:$FUNCNAME::Java version 1.7.0 is missing in smrs_master."
     else
           log "SUCCESS:$FUNCNAME::Java 1.7.0 is available in smrs_master."
     fi

else
     log "ERROR:$FUNCNAME::Java directory /usr/jdk/instances/java1.7.0 is missing in smrs_master."
	G_PASS_FLAG=1
fi

#Checking in nedss
ssh smrs_master ssh nedss '[ -d /opt/sun/jdk/java1.7.0 ]'

if [ $? -eq 0 ]; then
     ssh smrs_master ssh nedss '/opt/sun/jdk/java1.7.0/bin/java -version &> /tmp/javaversion'
     scp smrs_master:/tmp/javaversion /tmp/

     #if [ `cat /tmp/javaversion | grep version | grep -c "1.7.0"` -ne 1 ]; then
     if [ `cat /tmp/javaversion | grep version | grep  "1.7.0" > /dev/null; echo $?` -ne 1 ]; then
           #G_PASS_FLAG=1
           #log "ERROR:$FUNCNAME::Java version 1.7.0 is missing in nedss."
	   log "SUCCESS:$FUNCNAME::Java 1.7.0 is available in nedss."
     else
           #log "SUCCESS:$FUNCNAME::Java 1.7.0 is available in nedss."
	   G_PASS_FLAG=1
           log "ERROR:$FUNCNAME::Java version 1.7.0 is missing in nedss."
     fi

else
     log "ERROR:$FUNCNAME::Java directory /opt/sun/jdk/java1.7.0 is missing in  nedss."
	G_PASS_FLAG=1
fi

}

#####################################
#Execute the action to be performed
#####################################
function executeAction ()
{
l_action=$1

if [ $l_action == 1 ]; then
	log "INFO:$FUNCNAME::checking java version in omsrvm and nedss."
	checkjavaversion
fi
} 
 
 
#########
##MAIN ##
#########


#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking whether java 1.7.0 is updated in omsrvm, omsrvs and nedss
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
