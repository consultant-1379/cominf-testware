package com.ericsson.oss.cominf.test.operators;

import org.apache.log4j.Logger;

import com.ericsson.cifwk.taf.annotations.Context;
import com.ericsson.cifwk.taf.annotations.Operator;
import com.ericsson.cifwk.taf.data.User;
import com.ericsson.cifwk.taf.data.UserType;
import com.ericsson.cifwk.taf.tools.cli.CLICommandHelper;
import com.ericsson.oss.taf.hostconfigurator.HostGroup;


//SOL11
import com.ericsson.cifwk.taf.data.DataHandler;
import com.ericsson.cifwk.taf.data.Host;
import com.ericsson.cifwk.taf.data.HostType;
//SOL11

@Operator(context = { Context.CLI })
public class CdbTestcasesOperatorCli implements CdbTestcasesOperator {

	Logger logger = Logger.getLogger(CdbTestcasesOperator.class);

        Host host = DataHandler.getHostByType(HostType.OMSRVM);
        private String uname=host.getUser(UserType.ADMIN);
        private String passwd=host.getPass(UserType.ADMIN);
	User user = new User(host.getUser(UserType.ADMIN),host.getPass(UserType.ADMIN), UserType.ADMIN);

	//User user = new User("root", "shroot12", UserType.ADMIN);
	@Override
	public int additionofNatIp() {
		
		logger.info("START ------------------ Addition of NatIp ------------------ START");
		CLICommandHelper cmdHelper = new CLICommandHelper(HostGroup.getUas(),user);
		String str = cmdHelper.simpleExec("/opt/CTXSmf/sbin/ctxnfusesrv -bind 192.168.0.6 255.255.255.192","/opt/CTXSmf/sbin/ctxalt -a 192.168.0.6 172.18.117.131","/opt/CTXSmf/sbin/ctxsrv stop msd","/opt/CTXSmf/sbin/ctxsrv start msd");
		
		System.out.println(str);
		String str1= cmdHelper.simpleExec("/opt/CTXSmf/sbin/ctxalt -l|grep -c 192.168.0.6");
		System.out.println(str1);
		
		
		return 1;
			
	}
		 

}
