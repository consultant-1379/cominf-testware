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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/4672
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

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
                
		function prepareExpects ()
		{
			EXPCMD="/ericsson/opendj/bin/prepSSL.sh"
			EXITCODE=5
			INPUTEXP=/tmp/${SCRIPTNAME}.in
			OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
			echo 'LDAP Directory Manager password:
ldappass
Choose an operation
2
Enter the location to the root ca certificate file
\r
Enter the location to the root ca certificate file
\003'> $INPUTEXP

}
        
else
		function prepareExpects ()
		{
			EXPCMD="/ericsson/sdee/bin/prepSSL.sh"
			EXITCODE=5
			INPUTEXP=/tmp/${SCRIPTNAME}.in
			OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
			echo 'LDAP Directory Manager password:
ldappass
Choose an operation
3
Enter the location to the root ca certificate file
\r
Enter the location to the root ca certificate file
\003'> $INPUTEXP

}

fi



function executeprepssl()
{

prepareExpects
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP > /var/tmp/test.txt

        grep "Cannot find certificate in the location given"  /var/tmp/test.txt


        if [[ $? == 0 ]] ; then
                log "INFO: This is the  testcase for TR:HR80589."
                log "INFO:: rootca.cer certificate doesnot exist."

        else

               log " INFO: This is the  testcase for TR:HR80589."
                G_PASS_FLAG=1
                log "Warning::Script is accepting empty location"
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
   log "INFO:$FUNCNAME::Executing prepSSL.sh"
   executeprepssl
   log "INFO:Completed ACTION 1"
 fi

}


#########
##MAIN ##
#########

#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#Execute prepSSL.sh
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
