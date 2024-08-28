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

policy_check()
{
        count=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "ou=people,dc=vts,dc=com" "objectclass=ericssonUserAuthorization" cn=* |  sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | wc -l`

        rand_no=$(($RANDOM%$count+1))

        user=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "ou=people,dc=vts,dc=com" "objectclass=ericssonUserAuthorization" cn=* |sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | sed -n "$rand_no"p | cut -d ',' -f 1 | cut -d '=' -f 2`

        policy=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=$user,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | sed '3!d' | cut -d '=' -f 2 | cut -d ',' -f 1`

        if [ "$policy" == "ComSecurityPolicy" ];
        then
                sleep 3s
                echo " ---------------------------------------------------------------------------------------"
                log "INFO: ComSecurityPolicy has been assigned for COM Users"
                ldapsearch -D "cn=directory manager" -w ldappass -b "dc=vts,dc=com" objectclass=ldapsubentry cn=* | grep cn=ComSecurityPolicy
                echo "---------------------------------------------------------------------------------------"
        else
                log "INFO: ComSecurityPolicy policy is not assigned for COM Users"
        fi


        count=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "ou=people,dc=vts,dc=com" "objectclass=inetOrgPerson" cn=* | sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | wc -l`

        if [ $count -ne 0 ];
        then
        rand_no=$(($RANDOM%$count+1))

        user=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "ou=people,dc=vts,dc=com" "objectclass=inetOrgPerson" cn=* |sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | sed -n "$rand_no"p | cut -d ',' -f 1 | cut -d '=' -f 2`

        policy=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=$user,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | sed '3!d' | cut -d '=' -f 2 | cut -d ',' -f 1`

        if [ "$policy" == "SecurityPolicy" ];
        then
                sleep 3s
                log "INFO: Security Policy has been assigned for OSS-RC Users"
                ldapsearch -D "cn=directory manager" -w ldappass -b "dc=vts,dc=com" objectclass=ldapsubentry cn=* | grep cn=SecurityPolicy
                echo " ---------------------------------------------------------------------------------------"
        else
                log "INFO: Security policy is not assigned for OSS-RC Users"
        fi
        else
                log "INFO: No OSS-RC users are present!"
        fi

        count=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "cn=proxyagent,ou=profile,dc=vts,dc=com" objectclass=* cn=* | grep -v "version" | wc -l`
        rand_no=$(($RANDOM%$count+1))
        user=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "cn=proxyagent,ou=profile,dc=vts,dc=com" objectclass=* cn=* |sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | sed -n "$rand_no"p | cut -d ',' -f 1 | cut -d '=' -f 2`

        policy=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "cn=$user,ou=profile,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | sed '3!d' | cut -d '=' -f 2 | cut -d ',' -f 1`

        if [ "$policy" == "ProxyAgentPWDPolicy" ]
        then
                sleep 3s
                log "INFO: ProxyAgentPWDPolicy has been assigned for Proxy User"
                ldapsearch -D "cn=directory manager" -w ldappass -b "dc=vts,dc=com" objectclass=ldapsubentry cn=* | grep cn=ProxyAgentPWDPolicy
                echo " ---------------------------------------------------------------------------------------"
        else
                log "INFO: Security policy is not assigned for Proxy User"
        fi

        count=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "ou=people,dc=vts,dc=com" "objectclass=SolarisUserAttr" cn=* | sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | wc -l`
        rand_no=$(($RANDOM%$count+1))
        user=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "ou=people,dc=vts,dc=com" "objectclass=SolarisUserAttr" cn=* |sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | sed -n "$rand_no"p | cut -d ',' -f 1 | cut -d '=' -f 2`

        policy=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=$user,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | sed '3!d' | cut -d '=' -f 2 | cut -d ',' -f 1`

        if [ "$policy" == "nmsSecurityPolicy" ]
        then
                sleep 3s
                log "INFO: nmsSecurityPolicy has been assigned for NMS Users"
                ldapsearch -D "cn=directory manager" -w ldappass -b "dc=vts,dc=com" objectclass=ldapsubentry cn=* | grep cn=nmsSecurityPolicy
                echo "---------------------------------------------------------------------------------------"
                echo  "***************************************************************************************"
                echo " ---------------------------------------------------------------------------------------"
        else
                log "INFO: Security policy is not assigned for NMS Users"
        fi

        property=`/opt/opendj/bin/dsconfig get-global-configuration-prop -h localhost -D "cn=directory manager" -w ldappass --port 4444 --trustall --property default-password-policy | sed '3!d' | cut -d ":" -f 2`

        if [ "$property" == " Default Password Policy" ]
        then
                log "INFO: default-password-policy : Default Password Policy"
        else
                log "INFO: default-password-policy : $property"
        fi

        #------------------------------------------Password Policy Attributes List-----------------------------------------

        echo "---------------------------------------------------------------------------------------"
        echo "***************************************************************************************"
        echo "---------------------------------------------------------------------------------------"

        attribute=`ldapsearch -D "cn=directory manager" -w ldappass -b "cn=comSecurityPolicy,dc=vts,dc=com" objectclass=ldapsubentry | grep pwd* | grep -v "objectClass" | wc -l`

        if [ "$attribute" -eq 12 ];
        then
                sleep 3s
                log "INFO: All policy attributes are present"
                ldapsearch -D "cn=directory manager" -w ldappass -b "cn=comSecurityPolicy,dc=vts,dc=com" objectclass=ldapsubentry | grep pwd* | grep -v "objectClass"
        else
                G_PASS_FLAG=1
                log "ERROR: Policy attributes are missing"
                log "INFO: ----------------------------------------------------------------"
                ldapsearch -D "cn=directory manager" -w ldappass -b "cn=comSecurityPolicy,dc=vts,dc=com" objectclass=ldapsubentry | grep pwd* | grep -v "objectClass"
        fi
}


check_newpolicy()
{
                count=0
                OIFS=${IFS}
                IFS=$'\n'

                policy=($(ldapsearch -D "cn=directory manager" -w ldappass -b "dc=vts,dc=com"  objectclass=ldapsubentry cn=* | sed '/^\s*#/d;/^\s*$/d' | grep -v "version" | cut -d '=' -f 2 | cut -d ',' -f 1))
                IFS=${OIFS}

                policy_list=("ComSecurityPolicy" "SecurityPolicy" "ProxyAgentPWDPolicy" "nmsSecurityPolicy")

                for (( i=0;i<${#policy_list[@]};i++ )); do
                for (( j=0;j<${#policy[@]};j++ )); do
                        if [[ "${policy_list[${i}]}" == "${policy[${j}]}" ]]; then
                                                                ((count=count+1))
                                                fi
                                done
                done

                if [[ $count -eq 4 ]]
                then
                                log "INFO: All 4 Password Policies are present!"
                                ldapsearch -D "cn=directory manager" -w ldappass -b "dc=vts,dc=com"  objectclass=ldapsubentry cn=* | grep -v "version"

                else
                                G_PASS_FLAG=1
                                log "ERROR: Password Policies are not present!"
                fi
}


check_validators()
{
                count=0
                OIFS=${IFS}
                IFS=$'\n'

                validators=($(/opt/opendj/bin/dsconfig list-password-validators --hostname localhost --port 4444 --trustAll --bindDN "cn=directory manager" -w ldappass --no-prompt --script-friendly))
                IFS=${OIFS}

                validators_list=("Attribute Value" "Character Set" "Default Attribute Value" "Default Character Set" "Default Dictionary" "Default Length-Based Password Validator" "Default Repeated Characters" "Default Similarity-Based Password Validator" "Default Unique Characters" "Dictionary" "Length-Based Password Validator" "Repeated Characters" "Similarity-Based Password Validator" "Unique Characters")

                for (( i=0;i<${#validators_list[@]};i++ )); do
                for (( j=0;j<${#validators[@]};j++ )); do
                        if [[ "${validators_list[${i}]}" == "${validators[${j}]}" ]]; then
                                                                ((count=count+1))
                                                fi
                                done
                done

                if [[ $count -eq 14 ]]
                then
                                log "INFO: 14 Password Validators are present!"
                                /opt/opendj/bin/dsconfig list-password-validators --hostname localhost --port 4444 --trustAll --bindDN "cn=directory manager" -w ldappass --no-prompt --script-friendly
                else
                                G_PASS_FLAG=1
                                log "ERROR: Password Validators are not present!"
                fi
}

check_policy()
{
                count=0
                OIFS=${IFS}
                IFS=$'\n'

                policy=($(/opt/opendj/bin/dsconfig list-password-policies --hostname localhost --port 4444 --trustAll --bindDN "cn=directory manager" -w ldappass --no-prompt --script-friendly))
                IFS=${OIFS}

                policy_list=("Default Password Policy" "Root Password Policy")

                for (( i=0;i<${#policy_list[@]};i++ )); do
                       for (( j=0;j<${#policy[@]};j++ )); do
                                if [[ "${policy_list[${i}]}" == "${policy[${j}]}" ]]; then
                                           ((count=count+1))
                                fi
                       done
                done

                 if [[ $count -eq 2 ]]
                 then
                        log "INFO: 2 Password Policies under cn=config are present!"
                        /opt/opendj/bin/dsconfig list-password-policies --hostname localhost --port 4444 --trustAll --bindDN "cn=directory manager" -w ldappass --no-prompt --script-friendly
                 else
                                G_PASS_FLAG=1
                              log "ERROR: Password Policies are not present!"
                 fi
}


check_policy_status()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
        spawn /ericsson/opendj/bin/manage_pwd_policy.bsh -l -d vts.com
        expect {Password:}
        send "$pass\r"
        expect {test}
EOF
}

add_comapp_user()
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

add_comonly_user()
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
add_ossrc_user()
{
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

remove_users()
{
pass="ldappass"
/usr/local/bin/expect<<EOF
              spawn /ericsson/opendj/bin/del_user.sh -n comapp
              expect {Password:}
              send "$pass\r"
              expect {user name:*}
              send "\r"
              expect {uidNumber*}
              send "\r"
              expect {[y]}
              send "y\r"
              expect {test}
EOF

log "INFO: User: comapp has been deleted Successfully!"

/usr/local/bin/expect<<EOF
              spawn /ericsson/opendj/bin/del_user.sh -n comonly
              expect {Password:}
              send "$pass\r"
              expect {user name:*}
              send "\r"
              expect {uidNumber*}
              send "\r"
              expect {[y]}
              send "y\r"
              expect {test}
EOF

log "INFO: User: comonly has been deleted Successfully!"

/usr/local/bin/expect<<EOF
              spawn /ericsson/opendj/bin/del_user.sh -n ossrc
              expect {Password:}
              send "$pass\r"
              expect {user name:*}
              send "\r"
              expect {uidNumber*}
              send "\r"
              expect {[y]}
              send "y\r"
              expect {test}
EOF

log "INFO: User: ossrc has been deleted Successfully!"
}
check_new_user()
{
        app=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=comapp,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | sed '3!d' | cut -d '=' -f 2 | cut -d ',' -f 1`

        if [ "$app" == "ComSecurityPolicy" ];
        then
                log "INFO: User: comapp has been set with ComSecurityPolicy for COM_APP Users"
                ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=comapp,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | grep -v "version"
        else
                G_PASS_FLAG=1
                log "ERROR: ComSecurityPolicy policy is not assigned properly for COM Users"
        fi

        only=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=comonly,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | sed '3!d' | cut -d '=' -f 2 | cut -d ',' -f 1`

        if [ "$only" == "SecurityPolicy" ];
        then
                log "INFO: User: comonly has been set with SecurityPolicy for COM_ONLY Users"
                ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=comonly,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | grep -v "version"
        else
                G_PASS_FLAG=1
                log "ERROR: SecurityPolicy is not assigned properly for COM_ONLY Users"
        fi

        ossrc=`ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=ossrc,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | sed '3!d' | cut -d '=' -f 2 | cut -d ',' -f 1`

        if [ "$ossrc" == "SecurityPolicy" ];
        then
                log "INFO: User: ossrc is set with Security Policy for OSS-RC Users"
                ldapsearch -T -D "cn=directory manager" -w ldappass -b "uid=ossrc,ou=people,dc=vts,dc=com" "objectclass=*" pwdPolicySubentry | grep -v "version"
        else
                G_PASS_FLAG=1
                log "ERROR: Security policy is not assigned properly for OSS-RC Users"
        fi
}

###############################
#Execute the action to be performed
#####################################
executeAction ()
{
l_action=$1

if [ $l_action == "1" ]; then
    log "INFO: verifying if all users are tagged to respective password policies"
       policy_check
elif [ $l_action == "2" ]; then
    log "INFO: verifying if all 4 password policies are created."
      check_newpolicy
elif [ $l_action == "3" ]; then
    log "INFO: Verifying if all 14 validators are present or not."
       check_validators
elif [ $l_action == "4" ]; then
    log "INFO: Verifying if root and default policy are present or not."
       check_policy
elif [ $l_action == "5" ]; then
    log "INFO: Verifying password policy status."
       check_policy_status
elif [ $l_action == "6" ]; then
    log "INFO: Adding COM_APP user"
       add_comapp_user
elif [ $l_action == "7" ]; then
    log "INFO: Adding COM_ONLY user"
       add_comonly_user
elif [ $l_action == "8" ]; then
    log "INFO: Adding OSS_RC user"
        add_ossrc_user
elif [ $l_action == "10" ]; then
    log "INFO: Removing added users."
       remove_users
elif [ $l_action == "9" ]; then
    log "INFO: Verifying policies for new users."
       check_new_user
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
executeAction 7
executeAction 8
executeAction 9
executeAction 10
#Final assertion of TC, this should be the final step of tc
evaluateTC

