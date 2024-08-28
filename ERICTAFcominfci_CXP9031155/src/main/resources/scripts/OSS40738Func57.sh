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

#####. Check pwdReset attribute values. Now pwdReset attribute value should not TRUE for OSS-ONLY, COM-OSS users

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

ossrc_verify=`ldapsearch -D "cn=directory manager" -w ldappass -b "uid=ossrc,ou=people,dc=vts,dc=com" objectclass=* pwdPolicysubentry pwdReset |sed -n '4,5p' |awk '{print $2}'`
comoss_verify=`ldapsearch -D "cn=directory manager" -w ldappass -b "uid=comoss,ou=people,dc=vts,dc=com" objectclass=* pwdPolicysubentry pwdReset |sed -n '4,5p' |awk '{print $2}'`

if [[ $ossrc_verify == "" ]]; then

        if [[ $comoss_verify == "" ]]; then

                log "INFO : pwdReset value for both ossrc and comoss users became null, TC passed"

        fi

else

log "ERROR : pwdReset value is not null, TC failed"

fi
