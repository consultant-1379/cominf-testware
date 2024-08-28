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

## TC TAFTM Link :http://taftm.lmera.ericsson.se/
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


function dhcpActivationOnSlave () {

ACTIVATE_ISC_DHCP=/ericsson/ocs/bin/activate_isc_dhcp.sh
LOG_DIR=/ericsson/ocs/log

#SOL11
if [ `uname -r` = "5.10" ]; then
	COPY_KEYS=`scp omsrvs:/.ssh/id_dsa.pub /.ssh/id_dsa.pub_omsrvm`
	l_cmd=`cat /.ssh/id_dsa.pub_omsrvm >> /.ssh/authorized_keys`

else
	#COPY_KEYS=`scp omsrvs:/root/.ssh/id_dsa.pub /root/.ssh/id_dsa.pub_omsrvm`
	COPY_KEYS=`scp omsrvs:/root/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub_omsrvm`
	#l_cmd=`cat /root/.ssh/id_dsa.pub_omsrvm >> /root/.ssh/authorized_keys`
	l_cmd=`cat /root/.ssh/id_rsa.pub_omsrvm >> /root/.ssh/authorized_keys`

fi
#SOL11

DATE1=`date +%Y-%m-%d_%H:%M:%S`
l_cmd2=`ssh 192.168.0.7 -o StrictHostKeyChecking=no $ACTIVATE_ISC_DHCP om_serv_slave`
log "INFO::$FUNCNAME: command $ACTIVATE_ISC_DHCP executed on non-active DHCP Slave server"

set sleep 50

COPY_FILES=`scp omsrvs:/ericsson/ocs/log/sys_activate_isc_dhcp.$DATE1.log /var/tmp/dhcp_activate.log`
l_cmd3=`grep "INFO Copying the /var/lib/dhcp/dhcpd.leases from om_serv_master" /var/tmp/dhcp_activate.log`
ret=$?
	if [ $ret == 0 ] ; then
		l_cmd4=`grep "ERROR Problem copying the /var/lib/dhcp/dhcpd.leases" /var/tmp/dhcp_activate.log`
			ret=$?
			if [ $ret == 0 ] ; then
				G_PASS_FLAG=1
				log "ERROR:: File /var/lib/dhcp/dhcpd.leases not copied from om_serv master to slave"
			else
				log "SUCESS:: File /var/lib/dhcp/dhcpd.leases copied from om_serv master to slave"
			fi
	fi
	
#SOL11	
	#l_cmd5=`grep "INFO Copying the /usr/local/etc/dhcpd.conf_static from om_serv_master" /var/tmp/dhcp_activate.log`
	l_cmd5=`grep "INFO Copying the /etc/inet/dhcpd.conf_static from om_serv_master" /var/tmp/dhcp_activate.log`
	
	ret=$?
	if [ $ret == 0 ] ; then
		l_cmd6=`grep "ERROR Problem copying the /etc/inet/dhcpd.conf_static" /var/tmp/dhcp_activate.log`
			ret=$?
			if [ $ret == 0 ] ; then
				G_PASS_FLAG=1
				log "ERROR:: File /etc/inet/dhcpd.conf_static not copied from om_serv master to slave"
			else
				log "SUCESS:: File /etc/inet/dhcpd.conf_static copied from om_serv master to slave"
			fi
	fi
#SOL11
	
#SOL11	
	#l_cmd7=`grep "INFO Copying the /usr/local/etc/dhcpd.conf_subnet from om_serv_master" /var/tmp/dhcp_activate.log`
	l_cmd7=`grep "INFO Copying the /etc/inet/dhcpd.conf_subnet from om_serv_master" /var/tmp/dhcp_activate.log`
	
	ret=$?
	if [ $ret == 0 ] ; then
		l_cmd8=`grep "ERROR Problem copying the /etc/inet/dhcpd.conf_subnet" /var/tmp/dhcp_activate.log`
			ret=$?
			if [ $ret == 0 ] ; then
				G_PASS_FLAG=1
				log "ERROR:: File /etc/inet/dhcpd.conf_subnet not copied from om_serv master to slave"
			else
				log "SUCESS:: File /etc/inet/dhcpd.conf_subnet copied from om_serv master to slave"
			fi
	fi
#SOL11
	
#SOL11	
	#l_cmd9=`grep "INFO Copying the /usr/local/etc/dhcpd.conf from om_serv_master" /var/tmp/dhcp_activate.log`
	l_cmd9=`grep "INFO Copying the /etc/inet/dhcpd.conf from om_serv_master" /var/tmp/dhcp_activate.log`
	
	ret=$?
	if [ $ret == 0 ] ; then
		l_cmd10=`grep "ERROR Problem copying the /etc/inet/dhcpd.conf" /var/tmp/dhcp_activate.log`
			ret=$?
			if [ $ret == 0 ] ; then
				G_PASS_FLAG=1
				log "ERROR:: File /etc/inet/dhcpd.conf not copied from om_serv master to slave"
			else
				log "SUCESS:: File /etc/inet/dhcpd.conf copied from om_serv master to slave"
			fi
	fi
#SOL11

	l_cmd11=`grep "INFO Stopping the DHCP Server on the om_serv_master" /var/tmp/dhcp_activate.log`
	ret=$?
	if [ $ret == 0 ] ; then
		l_cmd12=`grep "ERROR Problem stopping the DHCPD Server on om_serv_master host" /var/tmp/dhcp_activate.log`
			ret=$?
			if [ $ret == 0 ] ; then
				G_PASS_FLAG=1
				log "ERROR:: DHCP Server is not stopped on om_serv_master"
			else
				log "SUCESS:: DHCP Server stopped on om_serv_master"
			fi
	fi



#SOL11
sleep 50
#dhcp_process_omsrvs=`ssh omsrvs ps -ef | grep -i dhcp > /var/tmp/dhcp.txt`
dhcp_process_omsrvs=`ssh omsrvs svcs -a | grep -i dhcp > /var/tmp/dhcp.txt`

#l_cmd13=`grep "/usr/local/sbin/dhcpd -q -lf /var/lib/dhcp/dhcpd.leases -cf /usr/local/etc/dhcp" /var/tmp/dhcp.txt`
l_cmd13=`grep "online"  /var/tmp/dhcp.txt`

ret=$?
	if [ $ret == 0 ] ; then
		log "SUCESS::$FUNCNAME: DHCP is running on DHCP Slave server"
	else
		G_PASS_FLAG=1
		log "ERROR::$FUNCNAME: DHCP is not running on DHCP Slave server"
	fi
#SOL11

#SOL11
#dhcp_process_omsrvm=`ps -ef | grep -i dhcp > /var/tmp/dhcp1.txt`
dhcp_process_omsrvm=`svcs -a | grep -i dhcp > /var/tmp/dhcp1.txt`

#l_cmd14=`grep "/usr/local/sbin/dhcpd -q -lf /var/lib/dhcp/dhcpd.leases -cf /usr/local/etc/dhcp" /var/tmp/dhcp1.txt`
l_cmd14=`grep "online" /var/tmp/dhcp1.txt`

ret=$?
	if [ $ret == 0 ] ; then
		G_PASS_FLAG=1
		log "ERROR::$FUNCNAME: DHCP is running on DHCP Master server"
	else
		log "SUCESS::$FUNCNAME: DHCP is not running on DHCP Master server"
	fi
#SOL11

#l_cmd15=`ssh omsrvs ls -lrt /etc/rc2.d/S96dhcpd`

#ret=$?
#	if [ $ret == 0 ] ; then
#		log "SUCESS:: File /etc/rc2.d/S96dhcpd present on DHCP Slave server"
#	else
#		G_PASS_FLAG=1
#		log "ERROR:: File /etc/rc2.d/S96dhcpd is not present on DHCP Slave server"
#	fi

}


###############################
#Execute the action to be performed
#####################################
function executeAction () 
{
	l_action=$1
 
	if [ $l_action == 16 ]; then
		log "INFO:$FUNCNAME::Activating DHCP service on om_serv Slave"
		dhcpActivationOnSlave
	fi
}

#########
##MAIN ##
#########

log "Starting Configuring "
#if preconditions execute pre conditions

#main Logic should be in executeActions subroutine with numbers in order.

#To activate DHCP on slave server
log "ACTION 16 Started"
executeAction 16
log "ACTION 16 Completed"


#Final assertion of TC, this should be the final step of tc
evaluateTC

