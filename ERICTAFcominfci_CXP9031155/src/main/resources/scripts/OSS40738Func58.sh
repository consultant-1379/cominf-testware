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
#create a proxy user and check whether pwdReset value is null or not

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
        SCRIPT=/ericsson/opendj/bin/manage_COM.bsh
else
        SCRIPT=/ericsson/sdee/bin/manage_COM.bsh
fi

pass=ldappass
/usr/local/bin/expect<<EOF
              spawn /ericsson/opendj/bin/manage_COM.bsh -a proxy -P testproxy
              expect {LDAP Directory Manager password:*}
              send "$pass\r"
              expect {Enter password for COM proxyagent - testproxy:*}
              send "test@1234\r"
              expect {Re-enter password:*}
              send "test@1234\r"
              expect {Please confirm that you want to proceed with requested actions - Yes or No [No]*}
              send "Yes\r"
              expect {test}
EOF

proxy_verify=`ldapsearch -D "cn=directory manager" -w ldappass -b "cn=testproxy,ou=proxyagent,ou=com,dc=vts,dc=com" objectclass=* pwdPolicysubentry pwdReset |sed -n '4,4p'`

if [[ $proxy_verify != "" ]]; then

        log "INFO: testproxy user pwdReset value is not null, TC failed"

else

        log "INFO: testproxy user pwdReset value is null, TC PASSED"

fi
