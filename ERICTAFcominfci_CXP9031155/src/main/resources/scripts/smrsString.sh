CI_SMRS_EXP=smrs.exp
CI_SMRS_DATA=smrs.data
CI_SMRS_STRING="Please set password for the New local accounts created during upgrade,named as FTPServices:"
CI_EXPECT=/usr/local/bin/expect

prepareSMRSexp ()
{
echo '#!/usr/local/bin/expect
        set timeout 120
        spawn /opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh upgrade
        expect "Please set password "
        send "\003\r"
        interact' > $CI_SMRS_EXP
}

searchSMRSstring ()
{
l_cmd=`grep -w "$CI_SMRS_STRING" $CI_SMRS_DATA`
if [ $? != 0 ];then
echo "SMRS UPGRADE procedure doesnt have proper user Message"
exit 5
fi
}


# MAIN
prepareSMRSexp;
$CI_EXPECT $CI_SMRS_EXP > $CI_SMRS_DATA
searchSMRSstring
exit 0
