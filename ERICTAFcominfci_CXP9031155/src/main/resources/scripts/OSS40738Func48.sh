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

pkginfo ERICodj 2> /dev/null
ret=$?
if [[ $ret == 0 ]]; then
        PATH_DIR=/ericsson/opendj
else
        PATH_DIR=/ericsson/sdee
fi

master_service()
{
a=`svcs -a | grep svc:/network/dns/server:default | cut -d " " -f 1`

if [[ $a == "online" ]]
then
        log "INFO :: DNS service is online in INFRA MASTER."
else
        G_PASS_FLAG=1
        echo "ERROR :: DNS service is offline in INFRA MASTER."
fi
}

slave_service()
{
b=`ssh omsrvs svcs -a | grep svc:/network/dns/server:default | cut -d " " -f 1`

if [[ $b == "online" ]]
then
        log "INFO :: DNS service is online in INFRA SLAVE."
else
        G_PASS_FLAG=1
        echo "ERROR :: DNS service is offline in INFRA SLAVE."
fi
}

omsas_service()
{
/usr/local/bin/expect<<EOF
        set timeout 30
        spawn -noecho ssh -o StrictHostKeyChecking=no -t omsas svcs -a | grep svc:/network/dns/server:default | cut -d' ' -f1 > /var/nitin
        expect {Password:}
        send "shroot12\r"
        puts "*************"
        expect
        set LOG $expect_out(buffer)
        spawn -noecho sftp omsas:/var/nitin /var/nitin
        expect {Password:}
        send "shroot12\r"
        puts "*************"
        sleep 5
EOF

c=`cat /var/nitin`

if [[ $c == "online" ]]
then
        G_PASS_FLAG=1
         log "ERROR :: DNS service is online in OMSAS."
else
        log "INFO :: DNS service is offline in OMSAS."
fi
}


###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO: Verifying DNS service in INFRA MASTER"
        master_service
elif [ $l_action == "2" ]; then
    log "INFO: Verifying DNS service in INFRA SLAVE"
        slave_service
elif [ $l_action == "3" ]; then
    log "INFO: Verifying DNS service in OMSAS"
        omsas_service
fi

}

#########
##MAIN ##
#########

log "Start of TC"

executeAction 1
executeAction 2
executeAction 3

#Final assertion of TC, this should be the final step of tc
evaluateTC

