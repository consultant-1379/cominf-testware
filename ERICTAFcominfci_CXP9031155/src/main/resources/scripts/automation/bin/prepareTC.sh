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
clear
# History
# 07/07/2014    xnavema         First version
########################################
# ----------------------------------
# Variables 
# ----------------------------------
EDITOR=vim
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'
G_SCRIPTDIR=$(cd $(/usr/bin/dirname $0); pwd)
G_SCRIPTNAME=$(basename $0)
G_MAIN_SCRIPT=$( /usr/bin/dirname $( /usr/bin/dirname $G_SCRIPTDIR ))
G_JAVA_DIR=$G_MAIN_SCRIPT/../../java/com/ericsson/oss/cominf/test/cases/
G_CSV_STORE=$G_MAIN_SCRIPT/../data/
G_LIB_DIR=$G_MAIN_SCRIPT/automation/lib/
G_TEMPLATE_FILE=$G_LIB_DIR/testCase.template
G_NODETC_FILE=$G_LIB_DIR/nodeTestCase.template
G_TEMPLATE_CSV=$G_LIB_DIR/csv.template
G_NODE_CSV_TMP=$G_LIB_DIR/node.csv.template
G_cdb_file=$G_JAVA_DIR/CdbTestcases.java 
G_OCS_file=$G_JAVA_DIR/ericOCS.java
G_Sdee_file=$G_JAVA_DIR/ericSdee.java
G_PU_file=$G_JAVA_DIR/ocsPostUpgrade.java
G_PrM_file=$G_JAVA_DIR/preMig.java
G_PoM_file=$G_JAVA_DIR/postMig.java
G_smrsaif_file=$G_JAVA_DIR/smrsAif.java
G_smrsconf_file=$G_JAVA_DIR/smrsConfig.java 
G_smrsdisman_file=$G_JAVA_DIR/smrsDismantle.java
G_cominfOther_file=$G_JAVA_DIR/cominfOthers.java
G_AUTOMATION_STRING="CI_AUTOMATION_END"
G_CDBT_CASE="cdbt"
#G_OCS_CASE="ocs"
NODEFLAG=0
G_SDEE_CASE="sdee"
G_postu_CASE="poup"
G_smaif_CASE="saif"
G_sconf_CASE="sconf"
G_dism_CASE="sdis"
G_prM_CASE="premig"
G_poM_CASE="postmig"
#G_comoth_CASE="comoth"
rn=`echo $((RANDOM % 9999))`
G_TAF_Prop=$G_MAIN_SCRIPT/../taf_properties/
G_Data_Properties=$G_TAF_Prop/datadriven.properties
G_Data_Templ=$G_LIB_DIR/datadriven.template
G_tcShell_templ=$G_LIB_DIR/testShell.template
G_UC_DIR=$G_MAIN_SCRIPT/automation/unitCases/
if [ ! -d $G_UC_DIR ]; then
mkdir $G_UC_DIR
fi
G_UC_Template=$G_LIB_DIR/unitTc.java.template
#updated the values for below variables when jira is created
#G_CDBT_CASE="cominf123"
G_OCS_CASE="occ1234"
#G_SDEE_CASE="cominf122"
#G_postu_CASE="cominf124"
#G_smaif_CASE="cominf126"
#G_sconf_CASE="cominf125"
#G_dism_CASE="cominf120"
G_comoth_CASE="occ1231"

# ----------------------------------
# Functions
# ----------------------------------
checkRandom () {

l_cmd=`ls $G_MAIN_SCRIPT | grep -w $rn`
if [ $? == "0" ]; then
	rn=`echo $((RANDOM % 9999))`
	l_cmd=`ls $G_MAIN_SCRIPT | grep -w $rn`
               if [ $? == "0" ]; then
		rn=`echo $((RANDOM % 9999))`
		l_cmd=`ls $G_MAIN_SCRIPT | grep -w $rn`
		if [ $? == "0" ]; then	
			echo "ID are exausted or please re run the script"
		exit 0	
		fi  
	fi	
fi
}

showStats ()
{
		tcCount=`ls $G_CSV_STORE | wc -l`
		tcCbd=`ls $G_CSV_STORE | grep $G_CDBT_CASE | wc -l`
		tcocs=`ls $G_CSV_STORE | grep  -i $G_OCS_CASE | wc -l`
		tcSdee=`ls $G_CSV_STORE | grep  $G_SDEE_CASE  | wc -l`
		tcpost=`ls $G_CSV_STORE | grep  $G_postu_CASE | wc -l`
		tcsaif=`ls $G_CSV_STORE | grep  $G_smaif_CASE | wc -l`
		tcsconf=`ls $G_CSV_STORE | grep  $G_sconf_CASE | wc -l`
		tccomoth=`ls $G_CSV_STORE | grep  $G_comoth_CASE | wc -l`
		tcdism=`ls $G_CSV_STORE | grep  $G_dism_CASE | wc -l`
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TESTCASE STATS ~~~~~~~~~~~~~~~~~~~~~"
		echo " TOTAL TESTCASES:		$tcCount "
		echo " 			TESTCASES PER FA  	 "
		echo " CdbTestcases	- $tcCbd    "
		echo " ericOCS	- $tcocs"
		echo " ericSdee	- $tcSdee "
		echo " ocsPostUpgrade	- $tcpost"
		echo " smrsAif	- $tcsaif"
		echo " smrsConfig	- $tcsconf"
		echo " smrsDismantle	- $tcdism"
		echo " cominfOthers	- $tccomoth"
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TESTCASE STATS ~~~~~~~~~~~~~~~~~~~~~"
}
pause(){
		read -p "Press [Enter] key to continue..." fackEnterKey
}

readAns () {
[  -z  "$1"  ]  &&  {
echo " empty value "
return 2
}
retun 0

}

checkNode ()
{
echo "Is this Node realted TC:[n]"
read node_ans1

if [ $node_ans1 == y ];then
NODEFLAG=1
G_TEMPLATE_CSV=$G_NODE_CSV_TMP
deletexml=`echo $G_TCID`_delete.xml
createxml=`echo $G_TCID`_create.xml
modifyxml=`echo $G_TCID`_modify.xml
modifyxml1=$G_MAIN_SCRIPT/$modifyxml
deletexml1=$G_MAIN_SCRIPT/$deletexml
createxml1=$G_MAIN_SCRIPT/$createxml
touch $modifyxml1 
touch $deletexml1
touch $createxml1

else
return 0
fi



}

preInirator ()
{

		G_Quest_1="Enter the Test Case Id:"
		G_Quest_2="Enter the Test Case Title:"
		G_Quest_3="Enter the Server name from where test needs to be executed [uas omsrvm omsrvs ossmaster omsas nedss ]:"
		G_Quest_4="Enter the Group[KGB ,CDB]:"
		G_Quest_5="Enter the time required to complete the execution of test case in seconds :" 
		echo $G_Quest_1
		read ans_1
		G_TCID=`echo $ans_1 |sed "s/_//g"`	
		
		echo $G_Quest_2
		read ans_2

		echo $G_Quest_3
		read ans_3

		echo $G_Quest_4
		read ans_4	

		echo $G_Quest_5
		read ans_5
}


displayDetails () {
		clear
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TESTCASE GENERATED ~~~~~~~~~~~~~~~~~~~~~"
		echo "TESTCASE ID : $ans_1"
		echo "TESTCASE FA FILE NAME: $FA"
		echo "TESTCASE FUCNTION NAME:public void $l_fun ()"
		echo "TESTCASE SHELL  NAME: $l_shell"
		echo "TESTCASE CSV  NAME: $l_csv "
		echo "TESTCASE SHELL PATH: $G_MAIN_SCRIPT/$l_shell "
		echo "TESTCASE CSV PATH: $G_CSV_STORE/$l_csv "
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TESTCASE GENERATED ~~~~~~~~~~~~~~~~~~~~~"
		rm -rf  $tmp_file
		rm -rf  $tmp_file2 
		rm -rf	/tmp/$rn.java 
		rm -rf /tmp/csv.tmp.$$
		exit
}

prepareTestCase () {
	tmp_file=/tmp/tmpfile.$$
	tmp_file2=/tmp/tmpfile.$$$
	touch $tmp_file $tmp_file2
        if [ $NODEFLAG == 1 ]; then
           G_TEMPLATE_FILE=$G_NODETC_FILE	
	fi
	dos2unix $G_TEMPLATE_FILE $G_TEMPLATE_FILE
      
	cp $G_TEMPLATE_FILE  $tmp_file
	#l_csv=$1$rn.csv
	l_csv=$G_TCID.csv
	#l_shell=$1_$rn.sh
	l_shell=$G_TCID.sh
	l_csvname=`echo $l_csv | awk -F'.' '{ print $1 }'`
	touch $G_CSV_STORE/$l_csv
	touch $G_MAIN_SCRIPT/$l_shell
	l_cmd=`cat $G_tcShell_templ > $G_MAIN_SCRIPT/$l_shell`
	chmod 777  $G_MAIN_SCRIPT/$l_shell 
	touch /tmp/csv.tmp.$$

	sed "s,##CSVNAME##,$l_csvname,g" $G_Data_Templ > /tmp/csv.tmp.$$
	l_cmd=`cat /tmp/csv.tmp.$$ >> $G_Data_Properties`
	#sed "s,##COMINF_DESCRIPTION##,$ans_2,g" $G_TEMPLATE_FILE >$tmp_file
	`sed "s,##COMINF_TC_ID##,$ans_1,g" $G_TEMPLATE_FILE>$tmp_file2`
	`sed "s,##COMINF_TC_TITLE##,$ans_2,g" $tmp_file2>$tmp_file`
	`sed "s,##COMINF_SRV_NAME##,$ans_3,g" $tmp_file>$tmp_file2`
	`sed "s,##COMINF_CSV_NAME##,$l_csvname,g" $tmp_file2>$tmp_file`
        `sed "s,##COMINF_ACCEPTANCE##,$ans_4,g" $tmp_file>$tmp_file2`
	`sed "s,##TC_SHELL##,$l_shell,g;s,##TC_EXECUTION##,$ans_5,g" $G_TEMPLATE_CSV>$G_CSV_STORE/$l_csv`
	if [ $NODEFLAG == 1 ]; then
	`sed "s,##TC_NODE_CREATE##,$createxml,g" $G_CSV_STORE/$l_csv>tmp1.csv`	
	`sed "s,##TC_NODE_DELETE##,$deletexml,g" tmp1.csv>$G_CSV_STORE/$l_csv`	
	`sed "s,##TC_NODE_MODIFY##,$modifyxml,g" $G_CSV_STORE/$l_csv>tmp1.csv`
       d=`mv tmp1.csv $G_CSV_STORE/$l_csv`  		
	fi
         cp $tmp_file2 $tmp_file

}


updateJava ()
{
	#l_fun=$2_$rn
	l_fun=$G_TCID
	`sed "s,##COMINF_FUNCTION_NAME##,$l_fun,g" $tmp_file>$tmp_file2`

	#creating Unit Tetcases
	#cp $tmp_file2 $G_UC_DIR/unitCase_$l_fun.java
	#cp $G_UC_Template $G_UC_DIR/tmp.java
	#ld_uc=`cat $G_UC_DIR/unitCase_$l_fun.java >>$G_UC_DIR/tmp.java`
        #echo "}">>$G_UC_DIR/tmp.java
        #ld_cs=`mv $G_UC_DIR/tmp.java $G_UC_DIR/unitCase_$l_fun.java`
        # Unit TestCase Created.	

	l_StringNu=`grep -n $G_AUTOMATION_STRING $1 | awk -F':' ' {print $1}'`
	l_StringNu=`echo $((--l_StringNu))`
	l_cmd=`sed -n "1,$l_StringNu p" $1 > /tmp/$rn.java`
	l_cmd=`cat $tmp_file2 >> /tmp/$rn.java`
	echo "//##CI_AUTOMATION_END##"  >> /tmp/$rn.java
	echo "}" >> /tmp/$rn.java
	cp /tmp/$rn.java $1

}

verifyUniq () {
	funName=$1
	fileSearch=$2
	l_cmd=`grep -w "$funName" $fileSearch `
	if [ $? == 0 ];then
	echo " THE TEST CASE IS ALREADY PRESENT, Please refer again, Exiting now..."
	exit 8
	fi 


}
preCdbT ()
{
	FA=$G_cdb_file
	preInirator
	verifyUniq $G_TCID $G_cdb_file
	prepareTestCase $G_CDBT_CASE
	updateJava $G_cdb_file $G_CDBT_CASE 
	 
}

preEricOCS ()
{
	FA=$G_OCS_file 
	preInirator
	verifyUniq $G_TCID $G_OCS_file 
	prepareTestCase $G_OCS_CASE
	updateJava $G_OCS_file $G_OCS_CASE
}



preEricSdee()
{
	FA=$G_Sdee_file
	preInirator
	verifyUniq $G_TCID $G_Sdee_file 
	prepareTestCase $G_SDEE_CASE
	updateJava $G_Sdee_file $G_SDEE_CASE
}


preOcsPU ()
{
	FA=$G_PU_file
	preInirator
	verifyUniq $G_TCID $G_PU_file
	prepareTestCase $G_postu_CASE 
	updateJava $G_PU_file $G_postu_CASE
}


preSmrsAif()
{
	FA=$G_smrsaif_file
	preInirator
	verifyUniq $G_TCID $G_smrsaif_file
	prepareTestCase $G_smaif_CASE
	updateJava $G_smrsaif_file $G_smaif_CASE
}


preSmrsConfig ()
{
	FA=$G_smrsconf_file
	preInirator
	checkNode
	verifyUniq $G_TCID $G_smrsconf_file 
	prepareTestCase $G_sconf_CASE  
	updateJava $G_smrsconf_file $G_sconf_CASE
}


preSmrsDismantle ()
{
	FA=$G_smrsdisman_file
	preInirator
	verifyUniq $G_TCID $G_smrsdisman_file
	prepareTestCase $G_dism_CASE
	updateJava $G_smrsdisman_file $G_dism_CASE
} 

preCominfOthers ()
{
        FA=$G_cominfOther_file
        preInirator
	verifyUniq $G_TCID $G_cominfOther_file
        prepareTestCase $G_comoth_CASE
        updateJava $G_cominfOther_file $G_comoth_CASE
}

preMig ()
{
        FA=$G_PrM_file
        preInirator
        verifyUniq $G_TCID $G_PrM_file
        prepareTestCase $G_PrM_CASE 
        updateJava $G_PrM_file $G_prM_CASE
}

postMig ()
{
        FA=$G_PoM_file
        preInirator
        verifyUniq $G_TCID $G_PoM_file
        prepareTestCase $G_poM_CASE 
        updateJava $G_PoM_file $G_poM_CASE 
}

showUnitCases ()
{
      echo "~~~~~~~~~~~~~~~~~~~~~"
      echo " Select the unit Cases"
      echo "~~~~~~~~~~~~~~~~~~~~~"
	ucList=( `ls $G_UC_DIR` )
	ucCount=${#ucList[*]}
        l_count=0
		   while [ $l_count -lt $ucCount ]; do
                               l_men=`echo ${ucList[$l_count]} | awk -F'.' '{ print $1}'`                   
                               echo "$l_men"
                          let l_count+=1
                        done
}
unitTestCases ()
{
showUnitCases
if [  -z $ucList ];then
echo "There are No Unit TC yet"
exit 
fi 
echo "Enter the Unit Testcase :"
read G_ucCase
l_cmd=`ls $G_UC_DIR | grep -w "$G_ucCase.java"`
if [ $? != 0 ]; then
clear
echo "Selected UC is not avaliable,Please reselect"
unitTestCases
fi
l_cmd=`cp $G_UC_DIR\$G_ucCase.java $G_JAVA_DIR\UnitCase.java`
echo "Unit Case $G_ucCase is copied to /Java/cases directory!! refresh your Eclipse and execute UnitCase Suite"
exit
}


showTCList ()
{
clear
      echo "~~~~~~~~~~~~~~~~~~~~~"
      echo " Select the Function Area"
      echo "~~~~~~~~~~~~~~~~~~~~~"
        ucList=( `ls $G_JAVA_DIR` )
        ucCount=${#ucList[*]}
        l_count=0
                   while [ $l_count -lt $ucCount ]; do
                               l_men=`echo ${ucList[$l_count]} | awk -F'.' '{ print $1}'`
                               echo "$l_men"
                          let l_count+=1
                        done
}

showTCFA ()
{
clear
T_FA=$1
val=`grep -w 'title' $G_JAVA_DIR/$1.java `
 if [ $? != 0 ];then
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " There are no Testcases written in $1"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"	
else 
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " The following Test Cases are present in FA : $1"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
grep title $G_JAVA_DIR/$1.java | cut -d "(" -f2 |cut -d ")" -f1 
echo ""
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
fi
}

listTCs () {
showTCList
echo "Please provide the Functional Area:"
read userFA
showTCFA $userFA
exit
}

read_options(){
	local choice
	read -p "Enter choice [ 1 - 12 ] " choice
	case $choice in
		1)preCdbT ;;
		2)preEricOCS ;;
		3)preEricSdee ;;
		4)preOcsPU ;;
		5)preSmrsAif ;;
		6)preSmrsConfig ;;
		7)preSmrsDismantle ;;
		8)preCominfOthers ;;
		9)unitTestCases ;;
		10)listTCs ;;
		11)preMig ;;
		12)postMig ;;
		x) exit 0 ;;
		*) echo -e "${RED}Please selct a proper value${STD}" && sleep 2	
	esac
}

prepareMenu () {
		l_count=0
			echo "~~~~~~~~~~~~~~~~~~~~~"
				echo " Select the FA for testcase"
				echo "~~~~~~~~~~~~~~~~~~~~~"
		 #	 while [ $l_count -lt $menuLen ]; do
		#		l_men=`echo ${menuItems[$l_count]} | awk -F'.' '{ print $1}'`			
		#		echo "$l_count. $l_men  "
		#          let l_count+=1
		#        done
		echo "1.CdbTestcases "
		echo "2.ericOCS "
		echo "3.ericSdee "  
		echo "4.ocsPostUpgrade "  
		echo "5.smrsAif "  
		echo "6.smrsConfig "  
		echo "7.smrsDismantle "
		echo "8.cominfOthers "
		echo "9.Unit Testcases "
		echo "10.List TestCases "
		echo "11.preMigration "
		echo "12.postMigration "
		echo "x. EXIT"
}
 
# ----------------------------------------------
# Handle Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
	#trap '' SIGINT SIGQUIT SIGTSTP
	if [ "$1" != "d" ]; then 
# -----------------------------------
# Main
# ------------------------------------
	while true
	do
		checkRandom	
		prepareMenu	 
	#	show_menus
		read_options
		displayDetails	
	done
	else 
	showStats
	fi
