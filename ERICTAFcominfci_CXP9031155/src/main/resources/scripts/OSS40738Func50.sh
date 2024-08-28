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

OIFS=${IFS}
IFS=$'\n'
domain=($(ldapsearch -D "cn=directory manager" -w ldappass -b "" -s base objectclass=* namingcontexts| cut -d':' -f 2 |sed '1,2d'))
IFS=${OIFS}
dLen=${#domain[@]}

set_property()
{
/usr/local/bin/expect<<EOF
spawn -noecho /ericsson/opendj/bin/manage_CaasAdmin.sh -o set
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
        log "ERROR ::Failed to set the search limit properties to OSS-RC recommended values!"
fi
}

status_check()
{
        log "\n"
        for (( i=0; i<${dLen}; i++ ));
        do
                ldapsearch -M -D "cn=directory manager" -w ldappass -b "cn=CaasAdmin,${domain[${i}]}" objectclass=* >/dev/null 2> /dev/null
                output=$?

                if [[ "$output" -ne "32" ]]
                then
                        size_lt=`ldapsearch -M -D "cn=directory manager" -w ldappass -b "cn=CaasAdmin,${domain[${i}]}" objectclass=* ds-rlim-size-limit | sed '3!d' | cut -d':' -f 2 | sed -e 's/^[ \t]*//'`

                        lookup_lt=`ldapsearch -M -D "cn=directory manager" -w ldappass -b "cn=CaasAdmin,${domain[${i}]}" objectclass=* ds-rlim-lookthrough-limit | sed '3!d' | cut -d':' -f 2 | sed -e 's/^[ \t]*//'`

                        if [[ $size_lt -ne 60000 && $lookup_lt -ne 60000 ]]; then
                                G_PASS_FLAG=1
                                log "ERROR ::cn=CaasAdmin,${domain[${i}]} exists but search limits are not set to OSS-RC recommended values.\n"
                        else
                                log "INFO ::cn=CaasAdmin,${domain[${i}]} exists and search limits are set to OSS-RC recommended values.\n"
                        fi
                else
                        log "INFO ::cn=CaasAdmin,${domain[${i}]} doesn't exist!!!\n"
                fi
        done
}
#set_property
#status_check

###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
        log "INFO: Setting the search limit properties to OSS-RC recommended values."
        set_property
elif [ $l_action == "2" ]; then
        log "INFO: Verifying if the search limit properties are set with OSS-RC recommended values or not."
        status_check
fi
}

#########
##MAIN ##
#########

log "Start of TC"

executeAction 1
executeAction 2

#Final assertion of TC, this should be the final step of tc
evaluateTC

