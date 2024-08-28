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


a="Nitin1:OSS_ONLY:5001:ass_ope:OSS-RC user:password"
#b="Nitin2:COM_OSS:5002:ass_ope:COM_OSS user:password:target1,target2:target1::role1:target1::alias1"
#c="Nitin3:COM_ONLY:5003:COM_ONLY user:password:target1:target1::role1,target2::role2:target1::alias1,target2::alias2"
#d="Nitin4:COM_APP:5004:COM_APP user:password:target1:target2::role1:target1::alias1"


touch /var/tmp/user.txt

echo $a >> /var/tmp/user.txt
#echo $b >> /var/tmp/user.txt
#echo $c >> /var/tmp/user.txt
#echo $d >> /var/tmp/user.txt


addusers()
{
/usr/local/bin/expect<<EOF
        set timeout 300
        spawn -noecho /ericsson/opendj/bin/add_user.sh -d vts.com -f /var/tmp/user.txt
        expect {LDAP Directory Manager password:}
        send "ldappass\r"
        puts "*************"
        expect {
        eof {exit}
        default {exit 1}
        }
EOF
ret=$?
if [[ $ret != 0 ]]
then
        G_PASS_FLAG=1
        log "ERROR :: failed to add users"
        rm -rf /var/tmp/user.txt
        exit 1
fi
}

verifyusers()
{
ldapsearch -D "cn=directory manager" -w ldappass -b "uid=Nitin1,ou=people,dc=vts,dc=com" objectclass=*
ret=$?
if [[ $ret != 0 ]]
then
        G_PASS_FLAG=1
        log "ERROR :: failed to add users"
        rm -rf /var/tmp/user.txt
        exit 1
else
        log "INFO :: user Nitin1[OSS_ONLY] added successfully."
fi
}

listusers()
{
/usr/local/bin/expect<<EOF
        set timeout 60
        spawn -noecho /ericsson/opendj/bin/list_users -n Nitin1
        expect {LDAP Directory Manager password:}
        send "ldappass\r"
        puts "*************"
        expect {[y]}
        send "y\r"
        expect {
        eof {exit}
        default {exit 1}
        }
EOF
ret=$?
if [[ $ret != 0 ]]
then
        G_PASS_FLAG=1
        log "ERROR :: failed to list OSS_ONLY user"
else
        log "INFO :: Nitin1 listed successfully."
fi
}

deleteusers()
{
/usr/local/bin/expect<<EOF
        set timeout 60
        spawn -noecho /ericsson/opendj/bin/del_user.sh -n Nitin1
        expect {LDAP Directory Manager password:}
        send "ldappass\r"
        puts "*************"
        expect {[y]}
        send "y\r"
        expect {
        eof {exit}
        default {exit 1}
        }
EOF
ret=$?
if [[ $ret != 0 ]]
then
        G_PASS_FLAG=1
        log "ERROR :: failed to remove Nitin1 user."
else
        log "INFO :: Nitin1 deleted successfully."
fi

}


###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO: Adding users........ "
       addusers
elif [ $l_action == "2" ]; then
        log "INFO: Verifying added users....... "
       verifyusers
elif [ $l_action == "3" ]; then
        log "INFO: Listing users......"
       listusers
elif [ $l_action == "4" ]; then
        log "INFO: Deleting users"
        deleteusers
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

rm -rf /var/tmp/user.txt

#Final assertion of TC, this should be the final step of tc
evaluateTC

