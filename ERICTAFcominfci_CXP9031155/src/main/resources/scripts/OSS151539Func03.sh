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
##TC VARIABLE##
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

G_LDAP_DOMAIN_DIR=/ericsson/sdee/ldap_domain_settings

G_Backup_dir="/var/tmp/`hostname`"


###################################
#This fucntion takes the backup of
#cominf configuration files
#################################

function backup_NTP() {
	mkdir -p $G_Backup_dir/NTP || {
    		log "could not $G_Backup_dir/NTP"
		G_PASS_FLAG=1
	}

        if [ -f /etc/inet/ntp.conf ]
        then
                cp /etc/inet/ntp.conf $G_Backup_dir/NTP/ntp.conf.premig_infra
                if [[ $? -ne 0 ]] ; then
			log "ERROR:$FUNCNAME::Error in copying ntp.conf"
			G_PASS_FLAG=1
		fi
	else
		log "NTP: service not detected"
		G_PASS_FLAG=1
	fi
}

function log_error () {

        failed_file=$1
        log "ERROR:$FUNCNAME::Error in copying $failed_file"
	G_PASS_FLAG=1
}

function backup_DNS() {

	mkdir -p $G_Backup_dir/pre-named || {
    		log "could not $G_Backup_dir/pre-named"
		G_PASS_FLAG=1
	}

        [ -d /var/named ]        && cp -rpP /var/named $G_Backup_dir/pre-named/named.premig_infra || log_error "/var/named"
#       [ -s /etc/rndc.conf ]    && cp -p  /etc/rndc.conf $G_Backup_dir/pre-named/rndc.conf.premig_infra || log_error "/etc/rndc.conf"
        [ -s /etc/resolv.conf ]  && cp -p  /etc/resolv.conf $G_Backup_dir/pre-named/resolv.conf.premig_infra || log_error "/etc/resolv.conf"
        [ -s /etc/named.conf ]   && cp -p /etc/named.conf $G_Backup_dir/pre-named/named.conf.premig_infra || log_error "/etc/named.conf"
}

function backup_config_files() {
	mkdir -p $G_Backup_dir/CONFIG || {
        	log "could not $G_Backup_dir/CONFIG"
		G_PASS_FLAG=1
	}

        [ -f /etc/inet/hosts ] && cp -p /etc/inet/hosts $G_Backup_dir/CONFIG/hosts.premig_infra || log_error "/etc/inet/hosts"
        [ -d $G_LDAP_DOMAIN_DIR ] && cp -rp $G_LDAP_DOMAIN_DIR $G_Backup_dir/CONFIG/ldap_domain_settings.premig_infra || log_error $G_LDAP_DOMAIN_DIR

        [ -f /etc/passwd ] && cp -p /etc/passwd $G_Backup_dir/CONFIG/passwd.premig_infra || log_error "/etc/passwd"
        [ -f /etc/shadow ] && cp -p /etc/shadow $G_Backup_dir/CONFIG/shadow.premig_infra || log_error "/etc/shadow"
        [ -f /etc/group ] && cp -p /etc/group $G_Backup_dir/CONFIG/group.premig_infra || log_error "/etc/group"
        [ -f /etc/netmasks ] && cp -p /etc/netmasks $G_Backup_dir/CONFIG/netmasks.premig_infra || log_error "/etc/netmasks"
        #[ -d /ericsson/config ] && cp -rp /ericsson/config $G_Backup_dir/CONFIG/config.premig_infra || G_PASS_FLAG=1
}

function backup_DHCP() {
		mkdir -p $G_Backup_dir/DHCP || {
    	log "could not $G_Backup_dir/DHCP"
		G_PASS_FLAG=1
		}
		[ -d /usr/local/etc ] && cp /usr/local/etc/dhcpd{6,}.conf_* $G_Backup_dir/DHCP || log_error "/usr/local/etc"
		
}

function backup_SMRS() {
	mkdir -p $G_Backup_dir/SMRS/ || {
    		log "could not $G_Backup_dir/SMRS"
		G_PASS_FLAG=1
	}

        [ -f /ericsson/smrs/etc/smrs_config ] && cp -p /ericsson/smrs/etc/smrs_config $G_Backup_dir/SMRS/smrs_config.premig_infra || log_error "/ericsson/smrs/etc/smrs_config"
	[ -f /etc/vfstab ] && cp -p /etc/vfstab $G_Backup_dir/SMRS/vfstab.premig_infra || log_error "/etc/vfstab"
	[ -f /etc/auto_vfstab ] && cp -p /etc/auto_vfstab $G_Backup_dir/SMRS/auto_vfstab.premig_infra || log_error "/etc/auto_vfstab"
	[ -f /etc/dfs/dfstab ] && cp -p /etc/dfs/dfstab $G_Backup_dir/SMRS/dfstab.premig_infra || log_error "/etc/dfs/dfstab"
	#[ -f /etc/dfs/sharetab ] && cp -p /etc/dfs/sharetab $G_Backup_dir/SMRS/sharetab.premig_infra || log_error "/etc/dfs/sharetab"
	#[ -f /etc/mnttab ] && cp -p /etc/mnttab $G_Backup_dir/SMRS/mnttab.premig_infra || log_error "/etc/mnttab"
	#[ -f /etc/default/nfs ] && cp -p /etc/default/nfs $G_Backup_dir/SMRS/nfs.premig_infra || log_error "/etc/default/nfs"
	[ -f /etc/security/prof_attr ] && cp -p /etc/security/prof_attr $G_Backup_dir/SMRS/prof_attr.premig_infra || log_error "/etc/security/prof_attr"
	[ -f /etc/user_attr ] && cp -p /etc/user_attr $G_Backup_dir/SMRS/user_attr.premig_infra || log_error "/etc/user_attr"
}

function get_infra_type() {
        SERVER_CONFIG_TYPE_FILE=/ericsson/config/ericsson_use_config

        # Check server config type file exists
        if [ ! -f "$SERVER_CONFIG_TYPE_FILE" ]; then
		log "ERROR: Failed to locate $SERVER_CONFIG_TYPE_FILE\n"
                G_PASS_FLAG=1
        fi

        G_SERV_TYPE=`grep "config" $SERVER_CONFIG_TYPE_FILE | awk -F= '{print $2}'` 2>/dev/null

        if [[ -z $G_SERV_TYPE ]] ;then
          G_PASS_FLAG=1
        fi
} 

function cleanup_exit () {
  [ -d "$G_Backup_dir" ] && rm -rf $G_Backup_dir || {
          log "ERROR: Failed to cleanup"
          G_PASS_FLAG=1
        }
}


# creating a tar file
function create_tar() {

	tar -cvf /var/tmp/${G_SERV_TYPE}.tar $G_Backup_dir >> $LOG 2>/dev/null || {
          log "ERROR: Failed to create tar file"
          G_PASS_FLAG=1
        }
}

function prepareExpects ()
{
  EXPCMD="scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /var/tmp/${G_SERV_TYPE}.tar root@10.42.33.76:/var/tmp/"
  EXITCODE=5
  INPUTEXP=/tmp/${SCRIPTNAME}.in
  OUTPUTEXP=/tmp/${SCRIPTNAME}.exp
  echo 'Password
shroot99' > $INPUTEXP
}

function copy_tar () {

  prepareExpects
  createExpect  $INPUTEXP $OUTPUTEXP "$EXPCMD"
  executeExpect $OUTPUTEXP >/dev/null
  if [[ $? -ne 0 ]]; then
	log "ERROR: Failed to copy tar file"
        G_PASS_FLAG=1	
  fi
}

function delete_tar ()
{
	[ -f "/var/tmp/${G_SERV_TYPE}.tar" ] && rm -rf /var/tmp/${G_SERV_TYPE}.tar ||  {
           log "ERROR: Failed to remove tar file"
           G_PASS_FLAG=1
        }
}
	
###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
  l_action=$1
  get_infra_type

  if [ $l_action == 1 ]; then 
	mkdir -p $G_Backup_dir || {
    	log "could not create backup dir $G_Backup_dir"
		G_PASS_FLAG=1
	}
	if [[ $G_SERV_TYPE == "om_serv_master" ]]; then
		backup_NTP
		backup_DNS
		backup_config_files
		backup_DHCP
		backup_SMRS
		create_tar
                cleanup_exit
	elif [[ $G_SERV_TYPE == "om_serv_slave" ]]; then
		backup_NTP
		backup_DNS
		backup_config_files
		backup_DHCP
		create_tar
                cleanup_exit
	elif [[ $G_SERV_TYPE == "smrs_slave" ]]; then
		backup_SMRS
		create_tar
                cleanup_exit
	elif [[ $G_SERV_TYPE == "infra_omsas" ]]; then
		backup_config_files
		create_tar
                cleanup_exit
	fi

  elif [[ $l_action == 2 ]];then
    copy_tar
    delete_tar

  fi
}
#########
##MAIN ##
#########
#Check File databackup.
executeAction 1

#Copy tar to MWS
executeAction 2

#Final assertion of TC, this should be the final step of tc
evaluateTC


