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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/1346
##TC VARIABLE##

G_COMLIB=commonFunctions.lib
#source the commonFunctions.
source $G_COMLIB
G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
aifCmd=/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh
listAif=( `/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -l|sed 1d|sed '/^$/d'|uniq` )
aifCount=${#listAif[*]}
lranAif=aiflran3
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
smoFtpUserNedss=( `ssh smrs_master ssh -o StrictHostKeyChecking=no $nedssIP grep smo /etc/passwd | awk -F':' '{ print $1 }' `)
smoFtpUserNedss1=( `ssh smrs_master ssh -o StrictHostKeyChecking=no $nedssIP  grep smo /etc/shadow | awk -F':' '{ print $1 }' `)
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
shroot12
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
shroot12' > $INPUTEXP
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

                l_count=0
                while [ $l_count -lt $aifCount ]; do
                                        l_cmd=`/opt/ericsson/nms_bismrs_mc/bin/del_aif.sh -a ${listAif[$l_count]} -f `
                                        l_cmd1=`/opt/ericsson/nms_bismrs_mc/bin/add_aif.sh -l > /tmp/func07`
					l_cmd2=`grep -w "${listAif[$l_count]}" /tmp/func07`
                                        ret=$?
                                        if [ $ret != 0 ]; then
						log "SUCCESS:$FUNCNAME::Removed aif user :${listAif[$l_count]}"
                                        else
						G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::Failed to remove aif user :${listAif[$l_count]}"

                                        fi
                                        let l_count+=1
                done
				rm /tmp/func07
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
				set -x
                l_count=0
                while [ $l_count -lt $aifCount ]; do
                                        l_cmd=`ssh $1 grep ${listAif[$l_count]} /etc/passwd `
                                        ret=$?
                                        if [ $ret == 0 ]; then
                                                G_PASS_FLAG=1
                                                log "ERROR:$FUNCNAME::still aif user :${listAif[$l_count]} is not removed from /etc/passwd"
                                        else
                                                log "SUCCESS:$FUNCNAME::aif user :${listAif[$l_count]} removed from /etc/passwd"
                                        fi
                                        let l_count+=1
                done

				set +x
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

function expects1 () {
				EXPCMD="CHECK_NO_GRAN_FILESYSTEM 192.168.0.4"
				EXPCMD1="CHECK_NO_LRAN_FILESYSTEM 192.168.0.4"
				EXPCMD2="CHECK_NO_WRAN_FILESYSTEM 192.168.0.4"
				EXPCMD3="CHECK_NO_CORE_FILESYSTEM 192.168.0.4"
                EXITCODE=5
                INPUTEXP=/tmp/${SCRIPTNAME}.in
                OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
                echo 'Password
shroot12' > $INPUTEXP
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
				createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
				executeExpect $OUTPUTEXP
        log "INFO:$FUNCNAME::checking File Systems LRAN"
				createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD1"
				executeExpect $OUTPUTEXP
        log "INFO:$FUNCNAME::checking File Systems WRAN"
				createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD2"
				executeExpect $OUTPUTEXP
        log "INFO:$FUNCNAME::checking File Systems CORE"
				createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD3"
				executeExpect $OUTPUTEXP


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
  log " SKIPPING $FUNCNAME :: NO NEDSS IS CONFIGURED"
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
  log " SKIPPING $FUNCNAME :: NO SMRS is configureds"
fi
}

function smrsmasterDetails () {


AuthorizedKeys_DIR="/.ssh/authorized_keys"
l_cmd=`grep smrs_master $AuthorizedKeys_DIR`
ret=$?
if [ $ret == 0 ] ; then
    G_PASS_FLAG=1
    log "ERROR:$FUNCNAME:: SMRS_MASTER references(hostname) are not deleted from  $AuthorizedKeys_DIR on OSSMASTER"
else
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
log "networks are  $networkDirectories "
        for  l_nw in "${networkDirectories[@]}"
                do
            networkDirectoryDetails=`[ "$(ls -A "/var/opt/ericsson/smrsstore/$l_nw")" ] && echo "Not Empty" || echo "Empty"`
	    	ls -ltr /var/opt/ericsson/smrsstore/$l_nw >> /var/tmp/ssss.txt	
                if [[ $networkDirectoryDetails == "Empty" ]] ; then
                    log "SUCESS::$FUNCNAME: $l_nw related files deleted after complete dismantle"
                else
                    #G_PASS_FLAG=1
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

function deleteNonExistinguser ()
{
	EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh delete aif"
	EXITCODE=5
	INPUTEXP=/tmp/${SCRIPTNAME}.in
	OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
	echo 'What is the name for this user
func01_usr
Would you like to remove autoIntegration FtpService for that user
yes
Are you sure you want to delete this user
yes' > $INPUTEXP
	createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
	executeExpect $OUTPUTEXP > /tmp/file
	l_cmd=`grep -w "ERROR Failed to delete AIF account" /tmp/file`
	if [ $? == 0 ] ;then
		log "SUCCESS:$FUNCNAME::verified:Error while trying to delete the Non-existing aif user"
	else
		G_PASS_FLAG=1
        log "ERROR:$FUNCNAME::Not throwing error while trying to delete the Non-existing user"
    fi  
	rm  /tmp/file
} 

###################################
#check ntp4 service is online
#################################

function checkNtpv4Service ()
{
	serviceState_smrs_master=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
	if [ $? -ne 0 ]
	then
		log "ERROR:Unable to connect to omsrvm from ossmaster"
	else
	
		if [ "$serviceState_smrs_master" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::NTPV service is in online state in om_serv_master"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::NTPV service is in $serviceState_smrs_master state in om_serv_master"
		fi
	fi
	
	serviceState_nedss=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o  UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
	if [ $? -ne 0 ]
	then
		log "ERROR:Unable to connect to Nedss from om_serv_master"
	else
		if [ "$serviceState_nedss" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::NTPV4 service is in online state in NEDSS "
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::NTPV4 service is in $serviceState_nedss state in NEDSS"
		fi
	fi
	
}

###################################
#check ntp service is in disabled state 
#################################

function checkNtpService ()
{
	serviceState_smrs_master=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
	if [ $? -ne 0 ]
	then
		log "ERROR: Unable to connect to om_serv_master from Ossmaster"
	else
		if [ "$serviceState_smrs_master" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::NTP service is in $serviceState_smrs_master state in om_serv_master"
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::NTP service is in $serviceState_smrs_master state in om_serv_master"
		fi
	fi
	
	serviceState_nedss=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss svcs svc:/network/ntp:default |tail -1 | awk '{print $1}'`
	if [ $? -ne 0 ]
	then
		log "ERROR: Unableto connect to Nedss from om_serv_master"
	else
		if [ "$serviceState_nedss" == "online" ] ; then
			log "SUCCESS:$FUNCNAME::NTP service is in $serviceState_nedss state in NEDSS "
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::NTP service is in $serviceState_nedss state in NEDSS"
		fi
	fi
	
	
}

#########################################
#check ntp ip in NEDSS server is SMRS IP
#########################################

function checkNtpvIpInNedss ()
{
	SMRS_IP=`grep smrs_master /etc/hosts | awk '{print $1}'`
	if [ $SMRS_IP == "" ]
	then
		log "ERROR: Cannot get SMRS IP from /etc/hosts. Smrs configuration was not completed."
	else
		NEDSS_NTP_IP=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no smrs_master ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss cat /etc/inet/ntp.conf | grep ^server | awk '{print $2}'`
		if [ $NEDSS_NTP_IP == "" ]
		then
			log "ERROR: Cannot get NTP IP from /etc/inet/ntp.conf. NTP was not correctly configured in NEDSS."
		else
			if [ $SMRS_IP == $NEDSS_NTP_IP ] 
			then
				log "SUCCESS: NEDSS NTP IP is same as SMRS MASTER IP."
			else
				log "ERROR: NEDSS NTP IP is  $NEDSS_NTP_IP not same as SMRS MASTER IP  $SMRS_IP."
			fi
		fi
	fi

}


###################################
#Verify oss_master, om_serv_master , NEDSS are in time sync
#################################

function timeCheck ()
{
		
		OSS_time=`date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		SMRS_time=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		NEDSS_time=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nedss date | awk -F' ' '{print $4}' | awk -F':' '{print $1 $2}'`
		
		if [ $OSS_time == $SMRS_time -a $SMRS_time == $NEDSS_time ]
		then
			log "SUCCESS:$FUCNAME:: Verified: OSS_MASTER, om_serv_master, and NEDSS are in time sync"
			
		else
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME::OSS_MASTER, om_serv_master, and NEDSS are not in time sync"
			
		fi
		
}
function ntpCheck ()
{
	time=`date | awk -F' ' '{print $4}'`
	sec=`echo $time | awk -F':' '{print $3}'`
	min=`echo $time | awk -F':' '{print $2}'`
	if [ $sec -lt 50 -a $min -lt 58 ] ;
	then
		timeCheck
	elif [ $sec -ge 50 -a $min -lt 58 ] ;
	then
		l_cmd=`sleep 20`
		timeCheck
	elif [ $min -ge 58 ] ;
	then
		l_cmd=`sleep 120`
		timeCheck
	else 
		log "ERROR:$FUNCNAME::Error in checking time sync"
	fi
	
}

function checkUpgradelog ()
{
	getSMRSLogs "upgrade_smrs.sh"
    ERROR_STG="ERROR"
    l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
    if [ $? == 0 ]; then
        G_PASS_FLAG=1
		log "ERROR:$FUNCNAME:: SMRS Upgrade is not successfull. Please refer $ERIC_LOG"
    else
        log "SUCCESS:$FUNCNAME::verified: SMRS Upgrade successfull"
    fi
	
	getSMRSLogs "upgrade_smrs.sh"
	ERROR_STG="SMRS successfully upgraded"
	l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
    if [ $? != 0 ]; then
        G_PASS_FLAG=1
        log "ERROR:$FUNCNAME:: SMRS Upgrade is not successfull. Please refer $ERIC_LOG"
    else
        log "SUCCESS:$FUNCNAME::verified: SMRS Upgrade successfull"
		log "Changing the /etc/default/passwd file in smrs_master and upgrading"
		ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' smrs_master "sed -e 's/^#MINUPPER=0/MINUPPER=2/' /etc/default/passwd > /tmp/func1"
		ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' smrs_master "mv /tmp/func1 /etc/default/passwd"
		ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' smrs_master "userdel back-oss1"
		l_cmd=`userdel back-oss1`
		EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh upgrade"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'What is the root account password
shroot12
Please set password for the New local accounts created during upgrade,named as FTPServices
shroot12
Please confirm the password for the New local accounts created during upgrade,named as FTPServices
shroot12
Perform ARNE import of new SMRS FtpServices
yes	
Do you want BI_SMRS_MC to be restarted
yes' > $INPUTEXP
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP  
		getSMRSLogs "upgrade_smrs.sh"
		ERROR_STG_PASSWD="ERROR Failed to set password"
		l_cmd_passwd=`grep -w "${ERROR_STG_PASSWD}" $ERIC_LOG`
		if [ $? == 0 ]; then
			l_ftpservice=`grep -w "${ERROR_STG_PASSWD}" $ERIC_LOG | awk '{print $9}'`
			log "SUCCESS:$FUNCNAME:: SMRS Upgrade is not successful because password was not set to $l_ftpservice.Please refer $ERIC_LOG"
			l_cmd_check=`cat /etc/passwd | grep '^$l_ftpservice'`
				if [ $? == 0 ]; then
					G_PASS_FLAG=1
					log "ERROR:$FUNCNAME:: FTP service $l_ftpservice for which password was not set is not deleted from OSS Master."
				else
                    log "SUCCESS:$FUNCNAME::verified: FTP service $l_ftpservice for which password was not set got deleted from OSS Master."
					l_cmd_check_smrs=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no omsrvm cat /etc/passwd | grep '^$l_ftpservice'`
					if [ $? == 0 ]; then
						G_PASS_FLAG=1
						log "ERROR:$FUNCNAME:: FTP service $l_ftpservice for which password was not set is not deleted from SMRS Master."
					else 
					    log "SUCCESS:$FUNCNAME::verified: FTP service $l_ftpservice for which password was not set got deleted from SMRS Master."
					fi
                fi
        else
		    G_PASS_FLAG=1
        	log "ERROR:$FUNCNAME:: SMRS Upgrade is successfull. Please refer $ERIC_LOG"
        fi
		log "reverting back the changes in /etc/default/passwd file in smrs_master and upgrading"
		ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' smrs_master "sed -e 's/^MINUPPER=2/#MINUPPER=0/' /etc/default/passwd > /tmp/func1"
		ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' smrs_master "mv /tmp/func1 /etc/default/passwd"
		EXPCMD="/opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh upgrade"
		EXITCODE=5
		INPUTEXP=/tmp/${SCRIPTNAME}.in
		OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
		echo 'What is the root account password
shroot12
Please set password for the New local accounts created during upgrade,named as FTPServices
shroot12
Please confirm the password for the New local accounts created during upgrade,named as FTPServices
shroot12
Perform ARNE import of new SMRS FtpServices
yes	
Do you want BI_SMRS_MC to be restarted
yes' > $INPUTEXP
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP  
		getSMRSLogs "upgrade_smrs.sh"
		ERROR_STG="ERROR"
		l_cmd=`grep -w "${ERROR_STG}" $ERIC_LOG`
		if [ $? == 0 ]; then
			G_PASS_FLAG=1
			log "ERROR:$FUNCNAME:: SMRS Upgrade is not successfull. Please refer $ERIC_LOG"
		else
			log "SUCCESS:$FUNCNAME::verified: SMRS Upgrade successfull"
		fi
	fi	
}

check_smrsupgradetaks_log ()
{

        l_cmd=`ls -ltr /var/opt/ericsson/log | grep -c "smrs_upgrade_tasks"`
        if [ $l_cmd == 0 ]
        then
                log "INFO: Log file smrs_upgrade_tasks was not found."
        else
                getSMRSLogs "smrs_upgrade_tasks"
                ERROR_STG="Failed to find nmsrole defined in"
                l_cmd=`grep -c "${ERROR_STG}" $ERIC_LOG"`
                if [ $l_cmd != 0 ]; then
                        G_PASS_FLAG=1
                        log "ERROR:$FUNCNAME:: smrs_upgrade_taks was not successfull. Please refer $ERIC_LOG"
                else
                        log "SUCCESS:$FUNCNAME::verified: smrs_upgrade_tasks successfull"
                fi
        fi
}

check_rsa_key_existence ()
{
		l_cmd=`grep -c "$( cat /home/nmsadm/.ssh/id_rsa.pub )" /home/nmsadm/.ssh/authorized_keys`
        if [ $l_cmd -ge 1 ]
        then
                log "INFO: id_rsa.pub key exists in authorized_keys file."
        else
                log "ERROR: id_rsa.pub key does not exist in authorized_keys file"   
                G_PASS_FLAG=1      
        fi
}

prepareExpect_admin ()
{

EXPCMD="su - nmsadm"
       EXITCODE=5
       INPUTEXP=/tmp/${SCRIPTNAME}.in
       OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
           echo '$
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ossmaster
$
exit
Connection to ossmaster closed
exit
' > $INPUTEXP

}	

check_ssh_admin_admin ()
{
		prepareExpect_admin
		createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
		executeExpect $OUTPUTEXP
        if [[ $? -ne 0 ]]; then
                log " ERROR :: Passwordless login from OSS to OSS with nmsadm user failed"
                G_PASS_FLAG=1
        else
                log " SUCESS :: Passwordless connection is successfull"
        fi
		
		
}


check_ssh_omsrvm_omsrvs ()
{

		ssh -q omsrvm ssh -q omsrvs exit
		if [[ $? -eq 0 ]]
		then
			log "SUCCESS:: Passwordless connection exists from omsrvm to omsrvs"
		else
			log "ERROR:: Passwordless connection doesnot exist between omsrvm and omsrvs"
			G_PASS_FLAG=1
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
  log "INFO:$FUNCNAME::verifying the Error while trying to delete the Non-existing aif user"
  deleteNonExistinguser
 fi
 
 if [ $l_action == 5 ]; then
    log "INFO:Started ACTION 5"
  log "INFO:$FUNCNAME::Checking AIF in Arne after deleting"
  #checkAif
 fi

 if [ $l_action == 6 ]; then
    log "INFO:Started ACTION 6"
  log "INFO:$FUNCNAME::Checking AIF /etc/passwd files in SMRS_MASTER "
  checkAifPwd smrs_master
 fi

  if [ $l_action == 7 ]; then
     log "INFO:Started ACTION 7"
  log "INFO:$FUNCNAME::Checking AIF /etc/passwd files in NEDSS"
  checkAifPwd "smrs_master ssh nedss"
 fi

   if [ $l_action == 8 ]; then
      log "INFO:Started ACTION 8"
   log "INFO:$FUNCNAME::Checking AIF not to perform sftp after deletion"
   sftpAif
 fi

 if [ $l_action == 9 ]; then
    log "INFO:Started ACTION 9"
   log "INFO:$FUNCNAME::checking the ALL File Systems GRAN,LRAN,WRAN,CORE"
   checkFileSystems "Before"
 fi

 if [ $l_action == 10 ]; then
     log "INFO:Started ACTION 10"
  log "INFO:$FUNCNAME::Trying to delete NEDSS without deleting Slave services anf AIF users"
  deletingNedssBeforeDeletingSlave
 fi

 if [ $l_action == 11 ]; then
  if [ ! -z $nedssIP ]; then \
     log "INFO:Started ACTION 11"
  log "INFO:$FUNCNAME::Trying to delete NESS without deleting Slave services "
     deleteNessBeforeDeletingSlave
  else
     log "INFO:$FUNCNAME::SKIPPING to delete NESS without deleting Slave services "
 fi
 fi

  if [ $l_action == 12 ]; then
       log "INFO:Started ACTION 12"
   log "INFO:$FUNCNAME::Dismantle Slave Service"
   delSlaveService "1"
   verifySlaveDelete "nedssv6"
 fi

   if [ $l_action == 13 ]; then
        log "INFO:Started ACTION 13"
   log "INFO:$FUNCNAME::Dismantle Slave Service without interaction"
   delSlaveService "0"
   verifySlaveDelete "nedssv4"
 fi

 if [ $l_action == 15 ]; then
         log "INFO:Started ACTION 15"
   log "INFO:$FUNCNAME::Deleting SMRS_MASTER before deleting NEDSS"
   deletingNessBeforeDeletingNedss
 fi

 if [ $l_action == 16 ]; then
         log "INFO:Started ACTION 16"
   log "INFO:$FUNCNAME::Listing the available NEDSS"
   NedssList
 fi

 if [ $l_action == 17 ]; then
         log "INFO:Started ACTION 17"
   log "INFO:$FUNCNAME::Deleting the NEDSS"
   nedssDeletion
 fi

 if [ $l_action == 18 ]; then
 if [ ! -z $nedssIP ]; then
          log "INFO:Started ACTION 18"
   log "INFO:$FUNCNAME::Checking NEDSS IP in SMRS config and /etc/hosts file"
   checkNedssDetails
 else
          log "INFO:SKIPPING ACTION 17"
         log "INFO:$FUNCNAME::SKIPPING AS NO NEDSS IS CONFIGURED"
 fi

 fi

 if [ $l_action == 19 ]; then
        log "INFO:Started ACTION 19"
   log "INFO:$FUNCNAME::checking the ALL File Systems GRAN,LRAN,WRAN after dismantling the slave services"
   checkFileSystems "After"
 fi

 if [ $l_action == 20 ]; then
         log "INFO:Started ACTION 20"
   log "INFO:$FUNCNAME::Deleting the NESS"
   smrsMasterDeletion
 fi

 if [ $l_action == 21 ]; then
         log "INFO:Started ACTION 21"
   log "INFO:$FUNCNAME::Checking for SMRS_MASTER hostname in /.ssh/authorized_keys directory"
   smrsmasterDetails
 fi

  if [ $l_action == 22 ]; then
           log "INFO:Started ACTION 22"
   log "INFO:$FUNCNAME::Checking for network MOUNTS after dismantle"
  sleep 25
   networkMountAfterDismantle
  #sleep 15
 fi

  if [ $l_action == 23 ]; then
           log "INFO:Started ACTION 23"
   log "INFO:$FUNCNAME::Checking for SMO users on OSS MASTER"
   checkSmoUsers "oss"
 fi

   if [ $l_action == 24 ]; then
              log "INFO:Started ACTION 24"
   log "INFO:$FUNCNAME::Checking for SMO users on SMRS MASTER"
   checkSmoUsers "smrs_master"
 fi

    if [ $l_action == 25 ]; then
                      log "INFO:Started ACTION 25"
   log "INFO:$FUNCNAME::Checking for SMO users on NEDSS"
   checkSmoUsers "nedss"
 fi


   if [ $l_action == 14 ]; then
                      log "INFO:Started ACTION 14"
   log "INFO:$FUNCNAME::check sftp of FTP users after dismantling of slave service"
   sftpslaveService
 fi
 
	if [ $l_action == 26 ]; then
					  log "INFO:Started ACTION 26"
	log "INFO:$FUNCNAME::Checking whether SMRS Upgrade is successfull or not"
	checkUpgradelog
	fi
	
	if [ $l_action == 27 ]; then
					  log "INFO:Started ACTION 27"
	log "INFO:$FUNCNAME::Checking whether NTPV4 is ONLINE or not on omsrvm, NEDSS"
	checkNtpv4Service
	fi
	
	if [ $l_action == 28 ]; then
					  log "INFO:Started ACTION 28"
	log "INFO:$FUNCNAME::Checking whether NTP is ONLINE or not on omsrvm, NEDSS"
	checkNtpService
	fi
	
	if [ $l_action == 29 ]; then
					  log "INFO:Started ACTION 29"
	log "INFO:$FUNCNAME::Checking whether NEDSS NTP IP is same as SMRS IP"
	checkNtpvIpInNedss
	fi
	
	if [ $l_action == 30 ]; then
					  log "INFO:Started ACTION 30"
	log "INFO:$FUNCNAME::Checking whether OSS, omsrvm, and NEDSS are in time sync or not"
	ntpCheck
	fi
	
	if [ $l_action == 31 ]; then
                log " INFO:Started ACTION 31"
                log " INFO:$FUNCNAME:: Checking for the existence of smrs_upgrade_tasks log in /var/opt/ericsson/log"
                log " INFO:$FUNCNAME:: Checking for the error statement if smrs_upgrade_tasks log exists"
                check_smrsupgradetaks_log
    fi
    
	if [ $l_action == 32 ]; then
                log " INFO:Started ACTION 32"
                log " INFO:$FUNCNAME:: Checking the id_rsa.pub key existence in authorized_keys file."
                check_rsa_key_existence
    fi
	
	if [ $l_action == 33 ]; then
                log " INFO:Started ACTION 33"
                log " Checking passwordless authentication from oss to oss for nmsadm user"
                check_ssh_admin_admin
    fi
    
    if [ $l_action == 34 ]; then
    			log " INFO:Started ACTION 34"
    			log " Checking passwordless authentication from omsrvm to omsrvs for root user"
    			check_ssh_omsrvm_omsrvs
    fi
    
	
}
#########
##MAIN ##
#########
if [ ! -z $smrsIP ]; then

#if preconditions execute pre conditions
#main Logic should be in executeActions subroutine with numbers in order.

#Checking whether SMRS Upgrade is successfull or not
executeAction 26

#Check whether smrs_upgrade_tasks.sh is not exiting if there is no nmsrole entry in /etc/user_attr
executeAction 31

#Checking the id_rsa.pub file exists in authorized_keys file.
executeAction 32

#Checking passwordless authentication from oss to oss for nmsadm user
executeAction 33

#Checking passwordless authentication from omsrvm to omsrvs for root user
executeAction 34

#Checking whether NTP is ENABLED or not on omsrvm, NEDSS
executeAction 28

#Checking whether NEDSS NTP IP is same as SMRS IP
executeAction 29

#Checking whether OSS, omsrvm, and NEDSS are in time sync or not
executeAction 30


log "Starting Dismantle "

#checking the delete slave service when aif users exist
executeAction 1


#Trying to delete NEDSS without deleting Slave services anf AIF users
executeAction 2

#List the AIF users and delete aif users.
executeAction 3

#verifying the Error while trying to delete the Non-existing aif user
executeAction 4

#Check if AIF account is removed from arne
#executeAction 5

#Check if AIF account is removed from passwd file of smrsMaster
executeAction 6

#Check if AIF account is removed from passwd file of nedss
executeAction 7

#Check if AIF account should not permorm sftp
executeAction 8

#checking the ALL File Systems GRAN,LRAN,WRAN
executeAction 9

#Trying to delete NEDSS without deleting Slave services anf AIF users
executeAction 10

#Trying to delete NESS without deleting Slave services
executeAction 11

#Dismantling Slave Service with invalid option and continue with valid option
executeAction 12

sleep 5

#Dismantling Slave Service with invalid option and continue with valid option
executeAction 13
sleep 5
#check sftp of FTP users after dismantling of slave service
executeAction 14

#Deleting SMRS_MASTER before deleting NEDSS
executeAction 15

#Listing the available NEDSS
executeAction 16

#Deleting the NEDSS
executeAction 17
sleep 5

#After NEDSS deletion checking for NEDSS IP in SMRS config and /etc/hosts file
executeAction 18

sleep 5
#Deleting the NESS
executeAction 20

#checking the ALL File Systems GRAN,LRAN,WRAN after dismantling the slave services
executeAction 19

#Checking for SMRS_MASTER hostname in /.ssh/authorized_keys directory
executeAction 21

#Checking for network MOUNTS after dismantle
executeAction 22

#Checking for SMO users on OSS MASTER after dismantle
executeAction 23

#Checking for SMO users on SMRS MASTER after dismantle
executeAction 24

#Checking for SMO users on NEDSS after dismantle
executeAction 25

#Final assertion of TC, this should be the final step of tc
evaluateTC
else
log "SKIPPING TESTCASE as there is NO SMRS MASTER IS CONFIGURED "
exit 0
fi

