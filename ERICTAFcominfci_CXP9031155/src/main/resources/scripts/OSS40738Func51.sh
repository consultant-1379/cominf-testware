#!/bin/bash

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

set_default()
{
/usr/local/bin/expect<<EOF
spawn -noecho /ericsson/opendj/bin/manage_cipher.sh -n
expect {LDAP Directory Manager password:}
send "ldappass\r"
puts "*************"
expect {[y]}
send "y\r"
expect {test}
EOF
ret=$?

if [[ $ret != 0 ]]
then
        G_PASS_FLAG=1
        log "ERROR ::Failed to set the cipher list to default."
fi
}

set()
{
/usr/local/bin/expect<<EOF
spawn -noecho /ericsson/opendj/bin/manage_cipher.sh -a
expect {LDAP Directory Manager password:}
send "ldappass\r"
puts "*************"
expect {[y]}
send "y\r"
expect {test}
EOF
ret=$?

if [[ $ret != 0 ]]
then
        G_PASS_FLAG=1
        log "ERROR ::Failed to set the cipher list to OSS-RC recommended ciphers"
fi
}

list()
{
w=0
 OIFS=${IFS}

 IFS=$'\n'

CIPHER_SUITE=`/opt/opendj/bin/dsconfig --hostname localhost --port 4444 --trustAll  --bindDN "cn=directory manager" -w ldappass --no-prompt get-connection-handler-prop --handler-name "LDAPS Connection Handler" --property ssl-cipher-suite | sed "1,2d"`

IFS=${OIFS}

for i in $(echo $CIPHER_SUITE | sed "s/:/ /g")
do
if [ $i != "ssl-cipher-suite" ]
then
w=$((w+1))
if [[ ($i == "SSL_RSA_WITH_RC4_128_SHA,") || ($i == "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,") || ($i == "TLS_ECDH_ECDSA_WITH_RC4_128_SHA,") || ($i == "TLS_ECDH_RSA_WITH_RC4_128_SHA,") || ($i == "TLS_KRB5_WITH_RC4_128_SHA,") || ($i == "TLS_RSA_WITH_AES_128_CBC_SHA256") || ($i == "SSL_RSA_WITH_3DES_EDE_CBC_SHA,") || ($i == "TLS_RSA_WITH_AES_128_CBC_SHA,") ]]
then
      echo "INFO ::$i cipher is present in cipher list."
else
        G_PASS_FLAG=1
        log "ERROR ::Failed to set the cipher list to OSS-RC recommended ciphers"
fi
fi
done

if [ $w != 8 ]
then
        G_PASS_FLAG=1
        log "ERROR ::Failed to set the cipher list to OSS-RC recommended ciphers"
fi

}

###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO: setting cipher list to default."
       set_default
elif [ $l_action == "2" ]; then
    log "INFO: Setting OSS-RC recommended ciphers to cipher list."
        set
elif [ $l_action == "3" ]; then
    log "INFO: Verifying cipher list is set to OSS-RC recommended ciphers."
       list
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
