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

####Apply patch_pwd_policy first

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


pass=ldappass
/usr/local/bin/expect<<EOF
                          set timeout 1800
              spawn /ericsson/opendj/bin/patch_pwd_policy.sh
              expect {LDAP Directory Manager password:*}
              send "$pass\r"
              expect {Enter omsas root password:*}
              send "shroot12\r"
              expect {
                          eof {exit}
                          default {error}
                          }
EOF

return_val=$?

#########
##MAIN ##
#########
if [ $return_val != 0 ]; then

        log "ERROR: Patch Password Policy not applied successfully, TC failed"
else
        log "INFO: Patch Password Policy applied successfully, TC passed"
fi
