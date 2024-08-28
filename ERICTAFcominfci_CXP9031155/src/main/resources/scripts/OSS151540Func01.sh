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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/#tm/viewTC/1352
##TC VARIABLE##

G_COMLIB=commonFunctions.lib
#source the commonFunctions.
source $G_COMLIB
G_PASS_FLAG=0
SCRIPTNAME="`basename $0`"
LOG_DIR=/var/tmp/CILogs/
TC_DIR="/var/tmp/TC"
GTAR="/usr/sfw/bin/gtar"
G_Backup_dir="/var/tmp/`hostname`"

if [ ! -d $LOG_DIR ]; then
		mkdir $LOG_DIR
fi
LOG=${LOG_DIR}/${SCRIPTNAME}_${DATE}.log

function log_error ()
{
  failed_file=$1
  log "ERROR:$FUNCNAME::Differences in file $failed_file"
  log "ERROR:$FUNCNAME::Restore didn't happen properly for file - $failed_file"
  G_PASS_FLAG=1
}
			  
function prepareExpects ()
{
  EXPCMD="scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@10.42.33.76:/var/tmp/${G_SERV_TYPE}.tar /var/tmp/"
  EXITCODE=5
  INPUTEXP=/tmp/${SCRIPTNAME}.in
  OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
  echo 'Password
shroot99' > $INPUTEXP
}

function checkPrenamed ()
{
  #diff $G_Backup_dir/pre-named/resolv.conf.premig_infra /etc/resolv.conf >/dev/null 2>&1 || log_error "/etc/resolv.conf"
  diff $G_Backup_dir/pre-named/named.conf.premig_infra /etc/named.conf >/dev/null 2>&1 || log_error "/etc/named.conf"
  #diff $G_Backup_dir/pre-named/rndc.conf.premig_infra /etc/rndc.conf >/dev/null 2>&1 || log_error "/etc/rndc.conf"
  diff -r $G_Backup_dir/pre-named/named.premig_infra /var/named >/dev/null 2>&1 || log_error "/var/named"
  log "$FUNCNAME done successfully"
}

function checkNTP ()
{ 
  diff $G_Backup_dir/NTP/ntp.conf.premig_infra /etc/inet/ntp.conf >/dev/null 2>&1 || log_error "/etc/inet/ntp.conf"
  log "$FUNCNAME done successfully" 
}

function checkDHCP ()
{
  if [[ ! -f /ericsson/config/config.ini ]];then
    log "ERROR:$FUNCNAME::Unable to find - /ericsson/config/config.ini"
    G_PASS_FLAG=1
  fi

  dhcp_conf=$(grep "DHCP_CONF" /ericsson/config/config.ini | awk -F= '{print $2}')
  if [[ $dhcp_conf != "N/A" ]];then
    for dhcp_files in `ls -1 $G_Backup_dir/DHCP`
    do
      dhcp_file=$(echo $dhcp_files | awk -F".premig_infra" '{print $1}')
  	diff $G_Backup_dir/DHCP/${dhcp_files} /etc/inet/${dhcp_file} >/dev/null 2>&1 || log_error "/etc/inet/${dhcp_file}"
    done
  fi
  log "$FUNCNAME done successfully"
}

function checkCONFIG ()
{

G_BLACK_LIST_USER="root|daemon|bin|sys|adm|lp|uucp|nuucp|smmsp|listen|nobody|noaccess|nobody4|ctxlsadm|caudb|sls|caas|racrs|gdm|webservd|postgres|svctag|unknown|ddcuser|hyperic|dladm|netadm|netcfg"
G_BLACK_LIST_GROUP="root|other|bin|sys|adm|uucp|mail|tty|lp|nuucp|staff|daemon|sysadmin|smmsp|nobody|noaccess|nogroup|ftp|anoftp|sls|caas|racrs|caudb|lmadmin|gdm|webservd|postgres|svctag|unknown|ddc|hyperic"
G_BLACK_LIST_USER_ATTR="root|adm|lp|postgres|hyperic|nerole|neuser"

  unset user1
  unset user2
  unset user3
  unset user4
  
  SIFS=$IFS
  IFS=$'\n'
  
  for user1 in `awk -F: '{print $1}' $G_Backup_dir/CONFIG/passwd.premig_infra | egrep -v "$G_BLACK_LIST_USER"`
  do
    if [[ `grep "^$user1:" /etc/passwd 2>/dev/null | wc -l` -eq 0 ]];then
	  log "ERROR:$FUNCNAME::Differences in file /etc/passwd"
	  G_PASS_FLAG=1
	fi
  done

  for user2 in `awk -F: '{print $1}' $G_Backup_dir/CONFIG/shadow.premig_infra | egrep -v "$G_BLACK_LIST_USER"`
  do
    if [[ `grep "^$user2:" /etc/shadow 2>/dev/null | wc -l` -eq 0 ]];then
	  log "ERROR:$FUNCNAME::Differences in file /etc/shadow"
	  G_PASS_FLAG=1
	fi
  done
  
  for user3 in `awk -F: '{print $1}' $G_Backup_dir/CONFIG/group.premig_infra | egrep -v "$G_BLACK_LIST_GROUP"`
  do
    if [[ `grep "^$user3:" /etc/group 2>/dev/null | wc -l` -eq 0 ]];then
	  log "ERROR:$FUNCNAME::Differences in file /etc/group"
	  G_PASS_FLAG=1
	fi
  done
  
  for user4 in `awk -F: '{print $1}' $G_Backup_dir/SMRS/user_attr.premig_infra | egrep -v "$G_BLACK_LIST_USER_ATTR"`
  do
    [[ "$user4" = \#* ]] && continue
    if [[ `grep "^$user4:" /etc/user_attr 2>/dev/null | wc -l` -eq 0 ]];then
	  log "ERROR:$FUNCNAME::Differences in file /etc/user_attr"
	  G_PASS_FLAG=1
	fi
  done
  
  IFS=$SIFS
  log "$FUNCNAME done successfully"
  
}

function checkSMRS ()
{
  diff $G_Backup_dir/SMRS/smrs_config.premig_infra /ericsson/smrs/etc/smrs_config >/dev/null 2>&1 || log_error "/ericsson/smrs/etc/smrs_config"
# diff $G_Backup_dir/SMRS/vfstab.premig_infra /etc/vfstab >/dev/null 2>&1 || log_error "/etc/vfstab"
  diff $G_Backup_dir/SMRS/auto_vfstab.premig_infra /etc/auto_vfstab >/dev/null 2>&1 || log_error "/etc/auto_vfstab"
  diff $G_Backup_dir/SMRS/dfstab.premig_infra /etc/dfs/dfstab >/dev/null 2>&1 || log_error "/etc/dfs/dfstab"
  diff $G_Backup_dir/SMRS/prof_attr.premig_infra /etc/security/prof_attr >/dev/null 2>&1 || log_error "/etc/security/prof_attr"
  
  SIFS=$IFS
  IFS=$'\n'
  
  for nfs_entry in `grep nfs $G_Backup_dir/SMRS/vfstab.premig_infra`
  do
    if [[ `grep $nfs_entry /etc/vfstab | wc -l` -eq 0 ]];then
      log "ERROR:$FUNCNAME::Differences in file /etc/vfstab"
	  G_PASS_FLAG=1
    fi
  done
  
  IFS=$SIFS
  log "$FUNCNAME done successfully"
}

function checkAIFusers ()
{
  AIF_test_list=("test_WRAN_nedssv4" \
                 "test_WRAN_nedssv6" \
                 "test_LRAN_nedssv4" \
                 "test_LRAN_nedssv6" \
                 "test_GRAN_nedssv4" \
                 "test_GRAN_nedssv6" \
                 "test_CORE_nedssv4" \
                 "test_CORE_nedssv6" \
				 )
  for aif_user in "${AIF_test_list[@]}"
  do  
    if [[ `grep $aif_user /etc/passwd | wc -l` -eq 0 ]];then
	  log "ERROR:$FUNCNAME::Unable to find aif user - $aif_user in /etc/passwd"
	  G_PASS_FLAG=1
	fi
  done
  log "$FUNCNAME done successfully"
}

function checkLDAPusers ()
{
  LDAP_users_list=("oss_on1" "oss_on2" "oss_on3" "com_ap1" "com_ap4" "com_ap5" \
		   "com_ap6" "com_ap7" "com_ap8" "com_ap9" "com_ap10" "com_ap13" \
		   "com_ap14" "com_on1" "com_on2" "com_os1" "com_os2" "comoss3" \
		   "com_os4" "com_os5" "com_os6" "com_os7" "com_os8" \
		   )
  
  for user in ${LDAP_users_list[@]}
  do
    ldapsearch -h "$server" -D "cn=directory manager" -w ldappass -T -b "uid=${user},ou=people,dc=vts,dc=com" "objectclass=*" >/dev?null 2>&1
	if [[ $? -ne 0 ]];then
	  log "ERROR:$FUNCNAME::Unable to find ldap user - $user"
	  G_PASS_FLAG=1
	fi
  done
  log "$FUNCNAME done successfully"  
}

function checkRoleAndAlias ()
{
  LDAP_roles_list=("role1" "role2" "role3")
  LDAP_aliases_list=("alias1" "alias2")
  
  ldapsearch -p 389 -M -T -D "cn=directory manager" -w ldappass -b "ou=role,ou=com,dc=vts,dc=com" "objectclass=*" cn | grep "cn:" | awk '{print $2}' > /tmp/roles
  ldapsearch -p 389 -M -T -D "cn=directory manager" -w ldappass -b "ou=rolealias,ou=com,dc=vts,dc=com" "objectclass=*" role | grep "role:" | awk '{print $2}' > /tmp/aliases
  
  for ldap_role in ${LDAP_roles_list[@]}
  do
    if [[ `grep -w $ldap_role /tmp/roles | wc -l` -eq 0 ]];then
	  log "ERROR:$FUNCNAME::Unable to find ldap role - $ldap_role"
	  G_PASS_FLAG=1
	fi
  done
  
  for ldap_alias in ${LDAP_aliases_list[@]}
  do
    if [[ `grep -w $ldap_alias /tmp/aliases | wc -l` -eq 0 ]];then
	  log "ERROR:$FUNCNAME::Unable to find ldap alias - $ldap_alias"
	  G_PASS_FLAG=1
	fi
  done
  
  rm -rf /tmp/roles /tmp/aliases 2>/dev/null || {
    log "ERROR:$FUNCNAME::Unable to remove temporary files - /tmp/roles and /tmp/aliases"
	G_PASS_FLAG=1
  }
  log "$FUNCNAME done successfully"
}

function get_infra_type ()
{
  SERVER_CONFIG_TYPE_FILE=/ericsson/config/ericsson_use_config
  
  # Check server config type file exists
  if [ ! -f "$SERVER_CONFIG_TYPE_FILE" ];then
    log "ERROR: Failed to locate $SERVER_CONFIG_TYPE_FILE\n"
    G_PASS_FLAG=1
  fi
  
  G_SERV_TYPE=`grep "config" $SERVER_CONFIG_TYPE_FILE | awk -F= '{print $2}'` 2>/dev/null
  
  if [[ -z $G_SERV_TYPE ]];then
    G_PASS_FLAG=1
  fi
}

function checkDirectories ()
{
  SERVER_TYPE=$1
  
  if [[ $SERVER_TYPE == "om_serv_master" ]];then  
    DIR_LIST=("$G_Backup_dir" "$G_Backup_dir/NTP" "$G_Backup_dir/pre-named" "$G_Backup_dir/DHCP" "$G_Backup_dir/CONFIG" "$G_Backup_dir/SMRS")
    for dir_list in ${DIR_LIST[@]}
    do
      if [[ ! -d $dir_list ]];then
        log "ERROR:$FUNCNAME::Unable to find directory - $dir_list"
        G_PASS_FLAG=1
      fi
    done
  
  elif [[ $SERVER_TYPE == "om_serv_slave" ]];then
    DIR_LIST=("$G_Backup_dir" "$G_Backup_dir/pre-named" "$G_Backup_dir/DHCP" "$G_Backup_dir/CONFIG")
    for dir_list in ${DIR_LIST[@]}
    do
      if [[ ! -d $dir_list ]];then
        log "ERROR:$FUNCNAME::Unable to find directory - $dir_list"
        G_PASS_FLAG=1
      fi
    done
	
  elif [[ $SERVER_TYPE == "smrs_slave" ]];then
    DIR_LIST=("$G_Backup_dir" "$G_Backup_dir/SMRS")
    for dir_list in ${DIR_LIST[@]}
    do
      if [[ ! -d $dir_list ]];then
        log "ERROR:$FUNCNAME::Unable to find directory - $dir_list"
        G_PASS_FLAG=1
      fi
    done
	
  elif [[ $SERVER_TYPE == "infra_omsas" ]];then
    DIR_LIST=("$G_Backup_dir" "$G_Backup_dir/CONFIG")
    for dir_list in ${DIR_LIST[@]}
    do
      if [[ ! -d $dir_list ]];then
        log "ERROR:$FUNCNAME::Unable to find directory - $dir_list"
        G_PASS_FLAG=1
      fi
    done
	
  fi
}

function unpack_tarfile ()
{
  # Copy the tarfile from MWS
  prepareExpects 
  createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
  executeExpect $OUTPUTEXP
  
  # Check the tarfile in TC_DIR
  if [[ ! -f /var/tmp/${G_SERV_TYPE}.tar ]];then
    log "ERROR:$FUNCNAME::Unable to find tar file in /var/tmp/${G_SERV_TYPE}.tar"
	G_PASS_FLAG=1
	evaluateTC
  fi
	
  # Unpack the tar file
  #cd $G_Backup_dir
  cd /
  tar -xvf /var/tmp/${G_SERV_TYPE}.tar >/dev/null 2>&1 || {
    log "ERROR:$FUNCNAME::Failed to unpack tarfile."
    G_PASS_FLAG=1
    evaluateTC
  } 
}

function cleanup_exit () {
	[ -d "$G_Backup_dir" ] && rm -rf $G_Backup_dir || G_PASS_FLAG=1
	[ -f "/var/tmp/${G_SERV_TYPE}.tar" ] && rm -rf /var/tmp/${G_SERV_TYPE}.tar || G_PASS_FLAG=1
	log "$FUNCNAME: cleanup and exit"
}

#####################################
# Execute the action to be performed
#####################################
function executeAction ()
{
  l_action=$1
  get_infra_type
  
  if [[ $l_action == 1 ]];then
  
    mkdir -p $G_Backup_dir || {
      log "could not create restore dir $G_Backup_dir"
      G_PASS_FLAG=1
    }
		
    unpack_tarfile
	
	if [[ $G_SERV_TYPE == "om_serv_master" ]]; then
	  server=omsrvm
      checkDirectories om_serv_master
      checkNTP
      checkPrenamed
      checkDHCP
      checkCONFIG
      checkSMRS
      checkAIFusers
      checkLDAPusers
      checkRoleAndAlias
      cleanup_exit
	  
	elif [[ $G_SERV_TYPE == "om_serv_slave" ]]; then
	  server=omsrvs
	  checkDirectories om_serv_slave
	  checkNTP
      checkPrenamed
      checkDHCP
      checkCONFIG
	  checkLDAPusers
      checkRoleAndAlias
      cleanup_exit
	  
	elif [[ $G_SERV_TYPE == "smrs_slave" ]]; then
	  checkDirectories smrs_slave
      checkSMRS
      checkAIFusers
	cleanup_exit
	  
	elif [[ $G_SERV_TYPE == "infra_omsas" ]]; then
	  server=omsas
	  checkDirectories infra_omsas
      checkCONFIG
      checkLDAPusers
      checkRoleAndAlias
      cleanup_exit
	  
	fi
  fi
}

#########
##MAIN ##
#########


# Check for error in smrs_upgrade_tasks log.
executeAction 1

#Final assertion of TC, this should be the final step of tc
evaluateTC
