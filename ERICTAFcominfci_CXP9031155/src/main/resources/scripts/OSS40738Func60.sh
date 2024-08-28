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

G_COMLIB=commonFunctions.lib
source $G_COMLIB        # Source the commonFunctions
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

#  ===========  List the ciphers ==================

list_ciphers()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/manage_cipher.sh -l
        expect {Password:}
        send "$pass\r"
        expect {test}
EOF
}

#  =========== Remove one cipher ================

remove_cipher()
{
/opt/opendj/bin/dsconfig --hostname localhost --port 4444 --trustAll --bindDN "cn=directory manager" -w ldappass --no-prompt --script-friendly set-connection-handler-prop --handler-name "LDAPS Connection Handler" --remove ssl-cipher-suite:"TLS_DHE_RSA_WITH_AES_128_CBC_SHA256"

return_val1=$?
if [ $return_val1 == 0 ]; then

        log "INFO : Successfully removed DHE cipher"
else
        log "ERROR : Failed to remove DHE cipher"
fi
}

#  ============= Check the ciphers  =================

post_check()
{
        `touch /tmp/testcase/output.txt`
        `chmod 777 /tmp/testcase/output.txt`
source()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/manage_cipher.sh -l
        expect {Password:}
        send "$pass\r"
        expect {test}
EOF
} > /tmp/testcase/output.txt

source

LINES=`cat /tmp/testcase/output.txt | grep "^[S-T]" | wc -l`

if [ $LINES -eq 7 ]; then
        echo "Success. Seven ciphers are present."
else
        echo "Failed, Ciphers are not equal to 7"
fi

`rm /tmp/testcase/output.txt`

}

#  ============  Execute the action to be performed  =======

executeAction ()
{
        l_action=$1

        if [ $l_action == "1" ]; then
                log "INFO: Listing ciphers"
                list_ciphers
        elif [ $l_action == "2" ]; then
                log "INFO: Removing DHE cipher"
                remove_cipher
        elif [ $l_action == "3" ]; then
                log "INFO: Listing ciphers"
                post_check
        fi
}

##  =============  MAIN  ===========  ##

log "Start of TC"

# executeAction() function will be called with different numbers to call all the other functions

executeAction 1
executeAction 2
executeAction 3

#Final assertion of TC, this should be the final step of tc

evaluateTC

