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

####Batch file execution of manage_COM_privs

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
         spawn /ericsson/opendj/bin/add_user.sh -t COM_APP -n lilly
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
         expect {Continue to create user type [COM_APP] user [lilly] (y/n)?* [y]}
         send "y\r"
         expect {test}
EOF
}

adduser_comonly()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
         spawn /ericsson/opendj/bin/add_user.sh -t COM_ONLY -n lotus
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

adduser_ossrc()
{
set timeout 3600
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/add_user.sh -n rose
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

add_role()
{
pass=ldappass
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/manage_COM.bsh -a role
        expect {LDAP Directory Manager password:*}
        send "$pass\r"
        expect {Enter COM role names as a comma separated list:*}
        send "CpRole7\r"
        expect {Please confirm that you want to proceed with requested actions - Yes or No [No]*}
        send "Yes\r"
        expect {test}
        expect {test}
EOF
}

prepare_add_roleFile () {
cat > /tmp/testfile<<EOF
DOMAIN vts.com
ACTION add
OBJECT role
lilly BRN323:CpRole7
lotus BRN323:CpRole7
jasmine BRN323:CpRole7
rose BRN323:CpRole7
EOF
}

assign_role()
{
set timeout 3600
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/manage_COM_privs.bsh -d vts.com -b /tmp/testfile
        expect {Password:}
        send "$pass\r"
        expect {Continue using file [/tmp/testfile] - Yes or No [No]*}
        send "Yes\r"
        expect {* Yes or No [No]*}
        send "Yes\r"
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
    log "INFO: Adding OSS_RC user"
        adduser_ossrc
elif [ $l_action == "4" ]; then
    log "INFO: Adding role"
        add_role
elif [ $l_action == "5" ]; then
    log "INFO: Preparing role file"
        prepare_add_roleFile
elif [ $l_action == "6" ]; then
    log "INFO: Assigning roles to user"
        assign_role
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

