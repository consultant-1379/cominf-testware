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
listAif=( `/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -l|sed 1d|sed '/^$/d'|uniq` )
aifCount=${#listAif[*]}
lranAif=aiflran
arneScript=/opt/ericsson/arne/bin/export.sh
smrsConfig="/etc/opt/ericsson/nms_bismrs_mc/smrs_config"
nedssIP=`grep NEDSS_TRAFFIC_IP $smrsConfig |awk -F= '{print $2}'`
smrsIP=`grep SMRS_MASTER_IP $smrsConfig |awk -F= '{print $2}'`
smoFtpOss=(` grep smo /etc/passwd | awk -F':' '{ print $1 }' ` )

if [ ! -z $smrsIP ]; then
smoFtpUserSM=( `ssh smrs_master grep smo /etc/passwd | awk -F':' '{ print $1 }' ` )
smoFtpUserSM1=( `ssh smrs_master grep smo /etc/shadow | awk -F':' '{ print $1 }' ` )
else
smoFtpUserSM=""
smoFtpUserSM1=""
fi

if [ ! -z $nedssIP ]; then
smoFtpUserNedss=( `ssh smrs_master ssh $nedssIP grep smo /etc/passwd | awk -F':' '{ print $1 }' `)
smoFtpUserNedss1=( `ssh smrs_master ssh $nedssIP  grep smo /etc/shadow | awk -F':' '{ print $1 }' `)
else
smoFtpUserNedss=""
smoFtpUserNedss1=""
fi

LOG_DIR=/var/tmp/CILogs/
if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log
networkDirectories=`ls -l /var/opt/ericsson/smrsstore/`
sftpList=( `grep nedssv4 /etc/passwd |awk -F':' '{print $1}'`)
sftpCount=${#sftpList[*]}
SSlist=( `grep SMRS_SLAVE_SERVICE_NAME $smrsConfig | awk -F'=' '{print $2}'` )
ssCount=${#SSlist[*]}
NOSLAVE=0

###################################
#This fucntion will delete all the aif
#users avaliable in system.
#################################
function prepareExpects ()
{

           EXPCMD="sftp $1@192.168.0.8"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Password
shroot12
sftp
exit' > $INPUTEXP
}

function prepareExpects2 ()
{

           EXPCMD="sftp $1@192.168.0.4"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Password
shroot12
sftp
exit' > $INPUTEXP
}
function prepareExpects3 ()
{

        EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete nedss"
        EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'Please enter number of required option
1
Are you sure you want to delete this NEDSS
yes' > $INPUTEXP

}

function prepareExpects4 ()
{

        EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete smrs_master"
        EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
        OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
        echo 'Do you wish to continue?
yes
Do you wish to completely dismantle the SMRS Master Service on the SMRS Master Server
yes' > $INPUTEXP

}

function prepareExpects5 ()
{
EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete nedss "
EXITCODE=5
INPUTEXP=/tmp/${SCRIPTNAME}.in
OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
echo 'Please enter number of required option
1
Are you sure you want to delete this NEDSS
no' > $INPUTEXP
}
 function sftpslaveService ()
{

                l_count=0
                while [ $l_count -lt $sftpCount ]; do

                prepareExpects2 ${sftpList[$l_count]}
                createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
                executeExpect $OUTPUTEXP
                if [ $? == 0 ]; then
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::After FTP user ${sftpList[$l_count]} is deleted sftp was successful"
                else
                log "SUCCESS:$FUNCNAME::FTP user ${sftpList[$l_count]}  sftp is removed"
                fi
                let l_count+=1
                done

}

function prepareExpects6 () {
	   EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete nedss"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	   echo 'Please enter number of required option
1
Are you sure you want to delete this NEDSS
yes
' > $INPUTEXP
}

function prepareExpects7 () {
	   EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete smrs_master"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	   echo 'Do you wish to continue
yes
Do you wish to completely dismantle the SMRS Master Service on the SMRS Master Server
yes
What is the root account password of the SMRS Master
shroot
Would you like to remove SMO FtpServices in ONRM
yes' > $INPUTEXP
}
function prepareExpects8 ()
{

           EXPCMD1="scp root@$smrsIP:/etc/passwd /tmp/passwd.smrs_master"
           EXPCMD2="scp root@$smrsIP:/etc/shadow /tmp/shadow.smrs_master"
           EXPCMD3="scp root@$nedssIP:/etc/passwd /tmp/passwd.nedss"
           EXPCMD4="scp root@$nedssIP:/etc/shadow /tmp/shadow.nedss"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo 'Password
shroot' > $INPUTEXP
}
function SsDelWhenAifExp ()
{
                EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete slave_service"
                EXITCODE=5
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
                echo 'Please enter number of required option
1' > $INPUTEXP
}
	
function aifDelete ()
{
aifCount=${#listAif[*]}
                l_count=0
                while [ $l_count -lt $aifCount ]; do
                                        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/del_aif.sh -a ${listAif[$l_count]} -f `
                                        ret=$?
                                        if [ $ret != 0 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::Failed to remove aif user :${listAif[$l_count]}"
                                        else
                                          log "SUCCESS:$FUNCNAME::Removed aif user :${listAif[$l_count]}"
                                        fi
                                        let l_count+=1
                done
}

function checkAif ()
{
   l_cmd=`$arneScript | grep  $lranAif`
        ret=$?
                                        if [ $ret == 0 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::$lranAif account not deleted in ARNE"
                                                else

                                                log "SUCCESS:$FUNCNAME::$lranAif is deleted"
                                        fi
}

function checkAifPwd ()
{

                l_count=0
                while [ $l_count -lt $aifCount ]; do
                                        l_cmd=`ssh $1 grep ${listAif[$l_count]} /etc/passwd `
                                        ret=$?
                                        if [ $ret != 1 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::still aif user :${listAif[$l_count]} is not removed from /etc/passwd"
                                        else
                                                log "SUCCESS:$FUNCNAME::aif user :${listAif[$l_count]} removed from /etc/passwd"
                                        fi
                                        let l_count+=1
                done

}

function sftpAif ()
{
                l_count=0
                while [ $l_count -lt $aifCount ]; do

                prepareExpects ${listAif[$l_count]}
                createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
                executeExpect $OUTPUTEXP
                if [ $? == 0 ]; then
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME::After AIF user ${listAif[$l_count]} is deleted sftp was successful"
                else
                log "SUCCESS:$FUNCNAME::AIF user ${listAif[$l_count]}  sftp is removed"
                fi
                let l_count+=1
                done

}


function createSSExp ()
{
       EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete slave_service"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           SSlist=( `grep SMRS_SLAVE_SERVICE_NAME $smrsConfig | awk -F'=' '{print $2}'` )
       ssCount=${#SSlist[*]}
           if [ $ssCount == "0" ]; then
           log "SKIPPING:$FUNCNAME::No Slave Services To delete"
           NOSLAVE=1
           fi
           if [ $ssCount -eq  2 ]; then
           echo 'Please enter number of required option
3
Please enter number of required option
2
Are you sure you want to delete the slave service
yes
Would you like to remove the slave FtpServices
yes
Do you wish to restart BI_SMRS_MC on the OSS master
yes' > $INPUTEXP
else
           echo 'Please enter number of required option
2
Please enter number of required option
1
Are you sure you want to delete the slave service
yes
Would you like to remove the slave FtpServices
yes
Do you wish to restart BI_SMRS_MC on the OSS master
yes' > $INPUTEXP
fi
}

function delSlaveService ()
{
  if [ $1 != 0 ]; then
        createSSExp
        if [ $NOSLAVE == "0" ]; then
        createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
        executeExpect $OUTPUTEXP
        ret=$?
                                        if [ $ret != 0 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::Failed to Delete Slave Service"
                                                else
                                                log "SUCCESS:$FUNCNAME::Deleted Slave Service"
                                        fi
        fi
 else
 if [ $NOSLAVE == "0" ]; then
                SSlist=( `grep SMRS_SLAVE_SERVICE_NAME $smrsConfig | awk -F'=' '{print $2}'` )
        if [ `echo ${SSlist[*]} | grep nedssv4` ]; then
                value=nedssv4
        else
                value=nedssv6
        fi
    l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/delete_smrs_slave.sh -s $value -o ossmaster -a -b`
        ret=$?
                                        if [ $ret != 0 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::Failed to Delete Slave Service  : $value "
                                                else
                                                log "SUCCESS:$FUNCNAME::Deleted Slave Service : $value"
                                        fi

        fi
 fi
}
function SsDelWhenAif ()
{
	SsDelWhenAifExp
	if [ $aifCount -ne 0 -a $ssCount -ne 0 ]; then
	{	
    createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
    executeExpect $OUTPUTEXP
	getSMRSLogs "configure_smrs.sh"
	ERROR_STG="ERROR AIF account"
	l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
    if [ $? != 0 ]; then
                G_PASS_FLAG=1
                log "ERROR:$FUNCNAME:: Slave service deleted when AIF user exists. Please refer to $ERROR_STG"
                else
                log "SUCCESS:$FUNCNAME::verified: Proper message for delete slave service when aif users exist"
    fi     
    } 
	else 
		log "INFO:$FUNCNAME::SKIPPING can not verify delete slave service when aif users. NO AIF USERS avaliable."
	fi
}
function checkFileSystems ()
{
    if [ $1 == "Before" ]; then
        log "INFO:$FUNCNAME::checking File Systems GRAN"
        CHECK_GRAN_FILESYSTEM smrs_master
         log "INFO:$FUNCNAME::checking File Systems LRAN"
        CHECK_LRAN_FILESYSTEM smrs_master
        log "INFO:$FUNCNAME::checking File Systems WRAN"
        CHECK_WRAN_FILESYSTEM smrs_master
		log "INFO:$FUNCNAME::checking File Systems CORE"
		CHECK_CORE_FILESYSTEM smrs_master
		
    else
        log "INFO:$FUNCNAME::checking File Systems GRAN"
        CHECK_NO_GRAN_FILESYSTEM 192.168.0.4
        log "INFO:$FUNCNAME::checking File Systems LRAN"
        CHECK_NO_LRAN_FILESYSTEM 192.168.0.4
        log "INFO:$FUNCNAME::checking File Systems WRAN"
        CHECK_NO_WRAN_FILESYSTEM 192.168.0.4
		log "INFO:$FUNCNAME::checking File Systems CORE"
        CHECK_NO_CORE_FILESYSTEM 192.168.0.4


        fi
        }

verifySlaveDelete ()
{
l_cmd=` grep $1 $smrsConfig`
ret=$?
                                        if [ $ret == 0 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::slave_service details are not removed from config file  : $1 "
                                                else
                                                log "SUCCESS:$FUNCNAME::Deleted Slave Service : $1"
                                        fi
}


function deletingNedssBeforeDeletingSlave ()
{
prepareExpects3
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP > /var/tmp/output.txt
error_message=`/usr/xpg4/bin/grep -e 'Remove the slave service' -e 'before deleting the NEDSS'  /var/tmp/output.txt`
ret=$?
		if [ $? != 0 ]; then
            G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Failed to get the ERROR message while deleting NEDSS before deleting Slave Services "
            else
            log "SUCCESS:$FUNCNAME:: ERROR message present while deleting NEDSS before deleting Slave Services "
		fi

}

function deleteNessBeforeDeletingSlave()
{

l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete smrs_master > /var/tmp/output.txt`
error_message=`/usr/xpg4/bin/grep -e 'slave service' -e 'must be removed before disconnecting the OSS'  /var/tmp/output.txt`
ret=$?
		if [ $? != 0 ]; then
            G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Failed to get the ERROR message while deleting SMRS_MASTER before deleting NEDSS and Slave Services"
            else
            log "SUCCESS:$FUNCNAME:: ERROR message present while deleting SMRS_MASTER before deleting NEDSS and Slave Services "
		fi
}

function deletingNessBeforeDeletingNedss ()

{
if [ ! -z $nedssIP ]; then
prepareExpects4
createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
executeExpect $OUTPUTEXP > /var/tmp/output.txt
error_message=`/usr/xpg4/bin/grep -e 'The following NEDSS servers are still configured' -e 'Delete these NEDSS before continuing'  /var/tmp/output.txt`
ret=$?
		if [ $? != 0 ]; then
            G_PASS_FLAG=1
            log "ERROR:$FUNCNAME::Failed to get the ERROR message while deleting SMRS_MASTER before deleting NEDSS "
            else
            log "SUCCESS:$FUNCNAME:: ERROR message present while deleting SMRS_MASTER before deleting NEDSS "
		fi
else
		log "SKIPPING:$FUNCNAME:: NO NEDSS IS Configured "	
fi 
}

function NedssList ()

{

	prepareExpects5
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /var/tmp/output.txt

	nedss_list=` grep -w nedss /var/tmp/output.txt | awk -F')' '{print $2}' | awk '{print $1}'`
 
	nedss_list_from_SMRS_CONFIG=`grep -w "NEDSS_TRAFFIC_HOSTNAME" $smrsConfig | awk -F'=' '{print $2}'`
 
	if [[ "$nedss_list" == "$nedss_list_from_SMRS_CONFIG" ]] ; then
		log " SUCESS::$FUCNAME:: Listed the available NEDSS "
	else
		G_PASS_FLAG=1
		log " ERROR::$FUCNAME:: Failed to list the available NEDSS"
	fi
}

function nedssDeletion () {
if [ ! -z $nedssIP ]; then
	prepareExpects6
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
 	ret=$?
					if [ $ret != 0 ]; then
						G_PASS_FLAG=1
						log "ERROR:$FUNCNAME::Failed to Delete NEDSS"
						else 			
						log "SUCCESS:$FUNCNAME::Deleted NEDSS"
					fi
else
  log "	SKIPPING $FUNCNAME :: NO NEDSS IS CONFIGURED"
fi
}
function checkNedssDetails () {

l_cmd=`grep $nedssIP $smrsConfig`
ret=$?
if [ $? != 0 ]; then
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::NEDSS IP is present in smrs_config file"
		else
		log "SUCCESS:$FUNCNAME::Nedss IP deleted in smrs_config file "
fi

l_cmd=`grep $nedssIP /etc/hosts`
ret=$?
if [ $? != 0 ]; then
		G_PASS_FLAG=1
		log "ERROR:$FUNCNAME::NEDSS IP is present in /etc/host file"
		else
		log "SUCCESS:$FUNCNAME::Nedss IP deleted in /etc/hosts file "
	fi

}

function smrsMasterDeletion () {
if [ ! -z $smrsIP ]; then
	prepareExpects7
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP
 	ret=$?
					if [ $ret != 0 ]; then
						G_PASS_FLAG=1
						log "ERROR:$FUNCNAME::Failed to Delete SMRS MASTER"
						else 			
						log "SUCCESS:$FUNCNAME::Deleted SMRS MASTER"
					fi
else
  log "	SKIPPING $FUNCNAME :: NO SMRS is configureds"
fi
}

function smrsmasterDetails () {


AuthorizedKeys_DIR="/.ssh/authorized_keys"
l_cmd=`grep omsrvm $AuthorizedKeys_DIR`
ret=$?
if [ $ret == 0 ] ; then
    log "ERROR:$FUNCNAME:: SMRS_MASTER references(hostname) are not deleted from  $AuthorizedKeys_DIR on OSSMASTER"
else
	G_PASS_FLAG=1
	log "SUCESS:$FUNCNAME:: SMRS_MASTER references(hostname) are deleted from  $AuthorizedKeys_DIR on OSSMASTER"
fi


l_cmd=`grep 192.168.0.4 /etc/mnttab`
ret=$?
if [ $ret == 0 ] ; then
	G_PASS_FLAG=1
	log "ERROR::$FUNCNAME: SMRS_MASTER details are not removed from /etc/mnttab directory on OSSMASTER"
else
	log "SUCESS::$FUNCNAME: SMRS_MASTER details are removed from /etc/mnttab directory on OSSMASTER "

fi

}

function networkMountAfterDismantle () {

l_cmd=`ls -l /var/opt/ericsson/smrsstore/ | tail -4 | awk -F' ' '{print $9}' > /var/tmp/array.txt`
networkDirectories=( `cat "/var/tmp/array.txt"`)
        for  l_nw in "${networkDirectories[@]}"
		do
            networkDirectoryDetails=`[ "$(ls -A "/var/opt/ericsson/smrsstore/$l_nw")" ] && echo "Not Empty" || echo "Empty"`
                if [[ $networkDirectoryDetails == "Empty" ]] ; then
                    log "SUCESS::$FUNCNAME: $l_nw related files deleted after complete dismantle"
                else
					G_PADD_FLAG=1
                    log "ERROR::$FUNCNAME: $l_nw related files are not deleted after complete dismantle"
                fi
        done
}
function checkSmoUsers () {
if [ $1 != "oss" ]; then
        if [ $1 = "smrs_master" ]; then
                        IP=$smrsIP
                        if [ ! -z $smrsIP ] ; then
                                smoCount=${#smoFtpUserSM[*]}
                                smoCount1=${#smoFtpUserSM1[*]}
                                prepareExpects8
                                createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD1"
                                executeExpect $OUTPUTEXP

                                prepareExpects8
                                createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD2"
                                executeExpect $OUTPUTEXP

                                l_count=0
                                while [ $l_count -lt $smoCount ]; do

                                        l_cmd=`grep ${smoFtpUserSM[$l_count]} /tmp/passwd.smrs_master`
                                        ret=$?
                                        if [ $ret == 0 ] ; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME:: Failed to remove SMO user from SMRS MASTER"
                                        else
                                                log "SUCESS:$FUCNAME:: SMO users removed from SMRS MASTER"
                                        fi
                                        l_cmd=`grep ${smoFtpUserSM1[$l_count]} /tmp/shadow.smrs_master`
                                        ret=$?
                                        if [ $ret == 0 ] ; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME:: Failed to remove SMO user from SMRS MASTER"
                                        else
                                                log "SUCESS:$FUCNAME:: SMO users removed from SMRS MASTER"
                                        fi
                                        let l_count+=1
                                done

                        else
                                log "SKIPPING:$FUNCNAME::No SMRS MASTER Configured."
                        fi
        else
        IP=$nedssIP
        if [ ! -z $nedssIP ]; then
                smoCount=${#smoFtpUserNedss[*]}
                smoCount=${#smoFtpUserNedss1[*]}
                IP=$nedssIP
                prepareExpects8
                createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD3"
                executeExpect $OUTPUTEXP

                prepareExpects8
                createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD4"
                executeExpect $OUTPUTEXP

                l_count=0
                while [ $l_count -lt $smoCount ]; do

                                l_cmd=`grep ${smoFtpUserNedss[$l_count]} /tmp/passwd.nedss`
                                        ret=$?
                                        if [ $ret == 0 ] ; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME:: Failed to remove SMO user"
                                        else
                                                log "SUCESS:$FUCNAME:: SMO users removed "
                                        fi
                                l_cmd=`grep ${smoFtpUserNedss1[$l_count]} /tmp/shadow.nedss`
                                        ret=$?
                                        if [ $ret == 0 ] ; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME:: Failed to remove SMO user"
                                        else
                                                log "SUCESS:$FUCNAME:: SMO users removed "
                                        fi
                        let l_count+=1
                done
        else
        log "SKIPPING:$FUNCNAME::No Slave Services To delete"
        fi
 fi
 else   # code running on ossmaster
      l_count=0
                smoCount=${#smoFtpOss[*]}
                while [ $l_count -lt $smoCount ]; do
                                l_cmd=`grep ${smoFtpOss[$l_count]} /etc/passwd `
                                        ret=$?
                                        if [ $ret == 0 ] ; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME:: Failed to remove SMO user from OSSMASTER"
                                        else
                                                log "SUCESS:$FUCNAME:: SMO users removed SMO user from OSSMASTER"
                                        fi
                                    l_cmd=`grep ${smoFtpOss[$l_count]} /etc/shadow `
                                        ret=$?
                                        if [ $ret == 0 ] ; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME:: Failed to remove SMO user from OSSMASTER"
                                        else
                                                log "SUCESS:$FUCNAME:: SMO users removed from OSSMASTER"
                                        fi
                        let l_count+=1
                done

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
   log "INFO:$FUNCNAME::verifying the deletion slave service when aif users exist"
   SsDelWhenAif
   log "INFO:Completed ACTION 1"
 fi

 if [ $l_action == 2 ]; then
    log "INFO:Started ACTION 2"
  log "INFO:$FUNCNAME::Trying to delete NEDSS without deleting Slave services anf AIF users"
  deletingNedssBeforeDeletingSlave
 fi
 
 if [ $l_action == 3 ]; then
    log "INFO:Started ACTION 3"
  log "INFO:$FUNCNAME::Listing Aif Users.."
  aifDelete
 fi

 if [ $l_action == 4 ]; then
    log "INFO:Started ACTION 4"
  log "INFO:$FUNCNAME::Checking AIF in Arne after deleting"
  checkAif
 fi

 if [ $l_action == 5 ]; then
    log "INFO:Started ACTION 5"
  log "INFO:$FUNCNAME::Checking AIF /etc/passwd files in SMRS_MASTER "
  checkAifPwd smrs_master
 fi

  if [ $l_action == 6 ]; then
     log "INFO:Started ACTION 6"
  log "INFO:$FUNCNAME::Checking AIF /etc/passwd files in NEDSS"
  checkAifPwd "smrs_master ssh nedss"
 fi

   if [ $l_action == 7 ]; then
      log "INFO:Started ACTION 7"
   log "INFO:$FUNCNAME::Checking AIF not to perform sftp after deletion"
   sftpAif
 fi

 if [ $l_action == 8 ]; then
    log "INFO:Started ACTION 8"
   log "INFO:$FUNCNAME::checking the ALL File Systems GRAN,LRAN,WRAN,CORE"
   checkFileSystems "Before"
 fi

 if [ $l_action == 9 ]; then
     log "INFO:Started ACTION 9"
  log "INFO:$FUNCNAME::Trying to delete NEDSS without deleting Slave services anf AIF users"
  deletingNedssBeforeDeletingSlave
 fi
 
 if [ $l_action == 10 ]; then
  if [ ! -z $nedssIP ]; then \
     log "INFO:Started ACTION 10"
  log "INFO:$FUNCNAME::Trying to delete NESS without deleting Slave services "
     deleteNessBeforeDeletingSlave
  else
     log "INFO:$FUNCNAME::SKIPPING to delete NESS without deleting Slave services "
 fi
 fi
 
  if [ $l_action == 11 ]; then
       log "INFO:Started ACTION 11"
   log "INFO:$FUNCNAME::Dismantle Slave Service"
   delSlaveService "1"
   verifySlaveDelete "nedssv6"
 fi

   if [ $l_action == 12 ]; then
        log "INFO:Started ACTION 12"
   log "INFO:$FUNCNAME::Dismantle Slave Service without interaction"
   delSlaveService "0"
   verifySlaveDelete "nedssv4"
 fi
 
 if [ $l_action == 14 ]; then
         log "INFO:Started ACTION 14"
   log "INFO:$FUNCNAME::Deleting SMRS_MASTER before deleting NEDSS"
   deletingNessBeforeDeletingNedss
 fi
 
 if [ $l_action == 15 ]; then
         log "INFO:Started ACTION 15"
   log "INFO:$FUNCNAME::Listing the available NEDSS"
   NedssList
 fi
 
 if [ $l_action == 16 ]; then
         log "INFO:Started ACTION 16"
   log "INFO:$FUNCNAME::Deleting the NEDSS"
   nedssDeletion
 fi
 
 if [ $l_action == 17 ]; then
 if [ ! -z $nedssIP ]; then
          log "INFO:Started ACTION 17"
   log "INFO:$FUNCNAME::Checking NEDSS IP in SMRS config and /etc/hosts file"
   checkNedssDetails
 else
          log "INFO:SKIPPING ACTION 17"
	 log "INFO:$FUNCNAME::SKIPPING AS NO NEDSS IS CONFIGURED"
 fi
 
 fi
 
 if [ $l_action == 18 ]; then
        log "INFO:Started ACTION 18"
   log "INFO:$FUNCNAME::checking the ALL File Systems GRAN,LRAN,WRAN after dismantling the slave services"
   checkFileSystems "After"
 fi
 
 if [ $l_action == 19 ]; then
         log "INFO:Started ACTION 19"
   log "INFO:$FUNCNAME::Deleting the NESS"
   smrsMasterDeletion
 fi
 
 if [ $l_action == 20 ]; then
         log "INFO:Started ACTION 20"
   log "INFO:$FUNCNAME::Checking for SMRS_MASTER hostname in /.ssh/authorized_keys directory"
   smrsmasterDetails
 fi
  
  if [ $l_action == 21 ]; then
           log "INFO:Started ACTION 21"
   log "INFO:$FUNCNAME::Checking for network MOUNTS after dismantle"
   networkMountAfterDismantle
 fi
 
  if [ $l_action == 22 ]; then
           log "INFO:Started ACTION 22"
   log "INFO:$FUNCNAME::Checking for SMO users on OSS MASTER"
   checkSmoUsers "oss"
 fi
 
   if [ $l_action == 23 ]; then
              log "INFO:Started ACTION 23"
   log "INFO:$FUNCNAME::Checking for SMO users on SMRS MASTER"
   checkSmoUsers "smrs_master"
 fi
 
    if [ $l_action == 24 ]; then
	              log "INFO:Started ACTION 24"
   log "INFO:$FUNCNAME::Checking for SMO users on NEDSS"
   checkSmoUsers "nedss"
 fi
 
  
   if [ $l_action == 13 ]; then
   	              log "INFO:Started ACTION 13"
   log "INFO:$FUNCNAME::check sftp of FTP users after dismantling of slave service"
   sftpslaveService
 fi
}
#########
##MAIN ##
#########
if [ ! -z $smrsIP ]; then
log "Starting Dismantle "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#checking the delete slave service when aif users exist

executeAction 1


#Trying to delete NEDSS without deleting Slave services anf AIF users
executeAction 2

#List the AIF users and delete aif users.
executeAction 3

#Check if AIF account is removed from arne
executeAction 4

#Check if AIF account is removed from passwd file of smrsMaster
executeAction 5

#Check if AIF account is removed from passwd file of nedss
executeAction 6

#Check if AIF account should not permorm sftp
executeAction 7

#checking the ALL File Systems GRAN,LRAN,WRAN
executeAction 8

#Trying to delete NEDSS without deleting Slave services anf AIF users
executeAction 9

#Trying to delete NESS without deleting Slave services 
executeAction 10

#Dismantling Slave Service with invalid option and continue with valid option
executeAction 11

sleep 5

#Dismantling Slave Service with invalid option and continue with valid option
executeAction 12
sleep 5
#check sftp of FTP users after dismantling of slave service
executeAction 13

#Deleting SMRS_MASTER before deleting NEDSS
executeAction 14

#Listing the available NEDSS
executeAction 15

#Deleting the NEDSS
executeAction 16
sleep 5

#After NEDSS deletion checking for NEDSS IP in SMRS config and /etc/hosts file
executeAction 17

#checking the ALL File Systems GRAN,LRAN,WRAN after dismantling the slave services  
#executeAction 18
sleep 5
#Deleting the NESS
executeAction 19

#Checking for SMRS_MASTER hostname in /.ssh/authorized_keys directory
executeAction 20

#Checking for network MOUNTS after dismantle
executeAction 21

#Checking for SMO users on OSS MASTER after dismantle
executeAction 22

#Checking for SMO users on SMRS MASTER after dismantle
executeAction 23

#Checking for SMO users on NEDSS after dismantle
executeAction 24

#Final assertion of TC, this should be the final step of tc
evaluateTC
else
log "SKIPPING TESTCASE as there is NO SMRS MASTER IS CONFIGURED "
exit 0
fi

