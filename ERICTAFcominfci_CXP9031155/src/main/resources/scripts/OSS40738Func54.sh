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

####If pwdMustChange attribute value is true, then add users (types OSS-ONLY, COM-OSS, COM_ONLY, COM_APP

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

adduser_comapp()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
         spawn /ericsson/opendj/bin/add_user.sh -t COM_APP -n comapp
         expect {Password:}
         send "$pass\r"
         expect {user name:*}
         send "\r"
         expect {Start of uidNumber*}
         send "\r"
         expect {End of uidNumber*}
         send "\r"
         expect {local user uidNumber*}
         send "\r"
         expect {user password*}
         send "com@1234\r"
         expect {password*}
         send "com@1234\r"
         expect {user description}
         send "\r"
         expect {[y]}
         send "y\r"
         expect {test}
EOF
}

adduser_comonly()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
         spawn /ericsson/opendj/bin/add_user.sh -t COM_ONLY -n comonly
         expect {Password:}
         send "$pass\r"
         expect {user name:*}
         send "\r"
         expect {Start of uidNumber*}
         send "\r"
         expect {End of uidNumber*}
         send "\r"
         expect {local user uidNumber*}
         send "\r"
         expect {user password*}
         send "com@1234\r"
         expect {password*}
         send "com@1234\r"
         expect {user description}
         send "\r"
         expect {[y]}
         send "y\r"
         expect {test}
EOF
}

add_role()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/manage_COM.bsh -a role
         expect {Password:}
         send "$pass\r"
         expect {Enter COM role names as a comma separated list:*}
         send "role2\r"
         expect {Please confirm that you want to proceed with requested actions - Yes or No [No]*}
         send "Yes\r"
         expect {test}
EOF
}

add_alias()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/manage_COM.bsh -a alias
         expect {Password:}
         send "$pass\r"
         expect {Enter COM role alias name:*}
         send "alias2\r"
         expect {Enter COM role names as a comma separated list:*}
         send "role2\r"
         expect {Please confirm that you want to proceed with requested actions - Yes or No [No]*}
         send "Yes\r"
         expect {test}
EOF
}

adduser_comoss()
{
echo "comoss:COM_OSS:4002:ass_ope:COM_OSS user:password:target1,target2:target1::role2:target1::alias2" >/tmp/bulkfile
pass="ldappass"
/usr/local/bin/expect<<EOF
         spawn /ericsson/opendj/bin/add_user.sh -d vts.com -f /tmp/bulkfile
         expect {Password:}
         send "$pass\r"
         expect {test}
EOF
}

adduser_ossrc()
{
set timeout 500
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/add_user.sh -n ossrc
         expect {Password:}
         send "$pass\r"
         expect {user name:*}
         send "\r"
         expect {Start of uidNumber*}
         send "\r"
         expect {End of uidNumber*}
         send "\r"
         expect {local user uidNumber*}
         send "\r"
         expect {user password*}
         send "oss@1234\r"
         expect {password*}
         send "oss@1234\r"
         expect {user category*}
         send "\r"
         expect {user description}
         send "\r"
         expect {[y]}
         send "y\r"
         expect {test}
EOF
}

###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO: Adding COM_APP user"
       adduser_comapp
elif [ $l_action == "2" ]; then
    log "INFO: Adding COM_ONLY user"
       adduser_comonly
elif [ $l_action == "3" ]; then
    log "INFO: Adding Role"
      add_role
elif [ $l_action == "4" ]; then
    log "INFO: Adding alias"
        add_alias
elif [ $l_action == "5" ]; then
    log "INFO: Adding COM_OSS user."
      adduser_comoss
elif [ $l_action == "6" ]; then
    log "INFO: Adding OSS_RC user"
        adduser_ossrc
fi

}

#########
##MAIN ##
#########

log "Start of TC"

executeAction 1
executeAction 2
executeAction 3
executeAction 4
executeAction 5
executeAction 6
#Final assertion of TC, this should be the final step of tc
evaluateTC
