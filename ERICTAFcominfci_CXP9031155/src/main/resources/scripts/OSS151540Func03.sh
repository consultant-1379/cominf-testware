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
aifCmd=/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh
listAifnedss4=( `/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -l|grep nedssv4|sed '/^$/d'` )
aifCountnedss4=${#listAifnedss4[*]}
listAifnedss6=( `/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -l|grep nedssv6|sed '/^$/d'` )
aifCountnedss6=${#listAifnedss6[*]}
LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log


###################################
#This fucntion will delete all the aif
#users avaliable in system.
#################################
function prepareExpects ()
{

		EXPCMD="sftp $1@$2"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'Password
shroot@12
sftp
exit' > $INPUTEXP
}


 function sftpslaveServicenedssv4 ()
{

	l_count=0
	while [ $l_count -lt $aifCountnedss4 ]; do

	prepareExpects ${listAifnedss4[$l_count]} "nedss"
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::FTP user ${listAifnedss4[$l_count]} sftp was successful"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::FTP user ${listAifnedss4[$l_count]} sftp was not successful"
	fi
	let l_count+=1
	done
}

 function sftpslaveServicenedssv6 ()
{

	l_count=0
	while [ $l_count -lt $aifCountnedss4 ]; do

	prepareExpects ${listAifnedss6[$l_count]} "2001:1b70:82a1:0103::8"
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
	if [ $? == 0 ]; then
		log "SUCCESS:$FUNCNAME::FTP user ${listAifnedss6[$l_count]} sftp was successful"
	else
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::FTP user ${listAifnedss6[$l_count]} sftp was not successful"
	fi
	let l_count+=1
	done
}
	


function sftpAif ()
{
    sftpslaveServicenedssv4         
	#sftpslaveServicenedssv6
}



###############################
#Execute the action to be performed
#####################################
function executeAction ()
{
 l_action=$1
 
 if [ $l_action == 1 ]; then
   log "INFO:$FUNCNAME::Checking AIF to perform sftp after restoring data"
   sftpAif
 fi

   
}
#########
##MAIN ##
#########

#Check if AIF account should not permorm sftp
executeAction 1


#Final assertion of TC, this should be the final step of tc
evaluateTC


