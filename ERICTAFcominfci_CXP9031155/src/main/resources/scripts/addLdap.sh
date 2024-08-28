#Test Variables
CI_USER=ci-us10
CI_UID=1325
CI_RESULTSFILE=$CI_USER.file
CI_UASSTRING="Connection to uas1 closed"
CI_UASEXP_SCRIPT="uas.exp"
CI_UASOUTPUT=uasdata
CI_EXPECT=/usr/local/bin/expect
CI_LISTUSER_SCRIPT="/tmp/listusers.exp"
CI_LISTUSER_OUTPUT="/tmp/listuserdata"
CI_LDAPSTRING="OSS-RC user"
CI_DEL_SCRIPT="/tmp/del.exp"
CI_DEL_DATA=deldata
CI_DEL_OK="Account deleted:"

## Added a check for LDAP script.
if pgrep ns-slapd > /dev/null; then
        CI_LDAP_DIR=/ericsson/sdee
else
        CI_LDAP_DIR=/ericsson/opendj
fi

verifyLdap ()
{
ldapsearch -D "cn=directory manager" -w ldappass -b "uid=$CI_USER,ou=people,dc=vts,dc=com" "objectclass=*">$CI_RESULTSFILE

l_use=`grep uid: $CI_RESULTSFILE | awk '{print $2}'`
l_id=`grep uidNumber: $CI_RESULTSFILE | awk '{print $2}'`


if [ $l_use != $CI_USER ]; then
	echo "USER NAME MISSMATCH"
	exit 4
fi

if [ $l_id != $CI_UID ]; then
	echo "USER ID MISSMATCH"
	exit 5
fi

}


prepareExpect ()
{
	
	    echo '#!/usr/local/bin/expect
        set timeout 120
        spawn ssh "ci-us10@uas1"
        expect "Password:"
        send "password\r"
        expect ">"
        send "exit\r"
        interact' > $CI_UASEXP_SCRIPT
}

prepareExpectLdap ()
{
cat <<EOF > $CI_LISTUSER_SCRIPT
#!/usr/local/bin/expect
set timeout 120
spawn ${CI_LDAP_DIR}/bin/list_users
expect "LDAP Directory Manager password:"
send "ldappass\r"
interact 
EOF
chmod 777 $CI_LISTUSER_SCRIPT

}
		
verifyUASConnection ()
{

 prepareExpect
 $CI_EXPECT $CI_UASEXP_SCRIPT > $CI_UASOUTPUT
 grep -w "$CI_UASSTRING" "$CI_UASOUTPUT"
 if [ $? != 0 ]; then
		echo "UAS CONNECTION REFUSED"
		exit 6
 fi
}

verifyLdapUser ()
{
	prepareExpectLdap
	$CI_EXPECT $CI_LISTUSER_SCRIPT > $CI_LISTUSER_OUTPUT
	grep -w "$CI_LDAPSTRING" "$CI_LISTUSER_OUTPUT" | grep "$CI_USER"
	if [ $? != 0 ]; then
		echo "LIST USER DID'N PRINT $CI_USER"
	exit 7
	fi
}

prepareDeleteExp ()
{
cat <<EOF > $CI_DEL_SCRIPT
#!/usr/local/bin/expect
set timeout 120
spawn  ${CI_LDAP_DIR}/bin/del_user.sh -n ci-us10
expect "LDAP Directory Manager password:"
send "ldappass\r"
expect "Continue to delete"
send "y\r"
interact 
EOF
chmod 777 $CI_DEL_SCRIPT
}

delteLdapUser ()
{
prepareDeleteExp;
$CI_EXPECT $CI_DEL_SCRIPT > $CI_DEL_DATA
grep -w "$CI_DEL_OK" "$CI_DEL_DATA" 
  	if [ $? != 0 ]; then
	echo "USER NOT Deleted"
	exit 5
	fi

}

mainLogic ()
{
	${CI_LDAP_DIR}/bin/add_user.sh -d vts.com -i $CI_UID -n $CI_USER -c "ass_ope" -C "OSS-RC user" -p password  -y 
	if [ $? != 0 ]; then
	echo "ADD USER SCRIPT NOT EXECUTED"
	exit 2
	else
		verifyLdap;
#		verifyUASConnection;
		verifyLdapUser;
	fi

}


verifyPLUser ()
{
	prepareExpectLdap
	$CI_EXPECT $CI_LISTUSER_SCRIPT > $CI_LISTUSER_OUTPUT
	grep -w "$CI_LDAPSTRING" "$CI_LISTUSER_OUTPUT" | grep "$CI_USER"
	if [ $? != 0 ]; then
	echo "USER NOT FOUND"
 		return 0
	else
	delteLdapUser;
	fi
}


#MAIN

verifyPLUser;
mainLogic;
delteLdapUser
exit 0


