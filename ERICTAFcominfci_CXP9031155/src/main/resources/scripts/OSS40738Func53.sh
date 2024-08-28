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

####Check whether pwdMustChange attribute is TRUE. If it is FALSE, then make it as TRUE

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

must_change=`ldapsearch -D "cn=directory manager" -w ldappass -b "cn=SecurityPolicy,dc=vts,dc=com" objectclass=ldapsubentry |grep pwdMustChange |awk '{print $2}'`

if [ $must_change != "TRUE" ]; then

        log "INFO: pwdMustChange value is not TRUE"
        log "INFO: Making pwdMustChange value to TRUE"

ldapmodify -D "cn=directory manager" -w ldappass -av << EOF
dn: cn=SecurityPolicy,dc=vts,dc=com
changetype: modify
replace: pwdMustChange
pwdMustChange: TRUE
EOF
ret=$?

else
        log "INFO: pwdMustChange value is true, TC PASSED"
fi
