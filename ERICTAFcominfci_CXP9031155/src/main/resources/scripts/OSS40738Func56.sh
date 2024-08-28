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

####Login users via UAS OSS-ONLY, COM-OSS and change password

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

pass=oss@1234
/usr/local/bin/expect<<EOF
              spawn ssh ossrc@uas1
              expect {Password:}
              send "$pass\r"
              expect {New Password:*}
              send "new@1234\r"
              expect {Re-enter new Password:*}
              send "new@1234\r"
                          expect {ossrc@uas1-*>*}
                          send "exit\r"
              expect {test}
EOF

unset pass
pass=password
/usr/local/bin/expect<<EOF
              spawn ssh comoss@uas1
              expect {Password:}
              send "$pass\r"
              expect {New Password:*}
              send "new@1234\r"
              expect {Re-enter new Password:*}
              send "new@1234\r"
                          expect {comoss@uas1-*>*}
                          send "exit\r"
              expect {test}
EOF
