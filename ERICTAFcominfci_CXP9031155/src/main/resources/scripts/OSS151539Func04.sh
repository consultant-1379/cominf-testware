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

	###################################
	# This function is to create inputs
	# for expect function. Add the expect string
	# and send string  in sequence.
	prepareExpects ()
	{
	        EXPCMD=/var/tmp/cominf/cominf_pre_migrate_verification_tasks.bsh
		        EXITCODE=5
			        INPUTEXP=/tmp/${SCRIPTNAME}.in
				        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
					        echo 'LDAP Directory Manager password
						ldappass
						' > $INPUTEXP
						}
						###############################
						#Execute the action to be performed
						#####################################
						executeAction ()
						{
						l_action=$1
						log "Performing COMINF premigration health checks."
						if [ $l_action == "1" ]; then
						prepareExpects
						createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
						executeExpect $OUTPUTEXP
						evaluate $? "COMINF premigration health checks failed" "$EXITCODE"
						fi

						}
						#########
						##MAIN ##
						#########

						log "Start of TC"
						#if preconditions execute pre conditions

						#main Logic should be in executeActions subroutine with numbers in order.
						executeAction 1
						#executeAction 2

						#Final assertion of TC, this should be the final step of tc
						evaluateTC



