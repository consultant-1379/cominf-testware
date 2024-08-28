package com.ericsson.oss.cominf.test.cases;


import java.io.FileNotFoundException;

import javax.inject.Inject;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import com.ericsson.cifwk.taf.TestCase;
import com.ericsson.cifwk.taf.TorTestCaseHelper;
import com.ericsson.cifwk.taf.annotations.Context;
import com.ericsson.cifwk.taf.annotations.DataDriven;
import com.ericsson.cifwk.taf.annotations.Input;
import com.ericsson.cifwk.taf.annotations.Output;
import com.ericsson.cifwk.taf.annotations.TestId;
import com.ericsson.cifwk.taf.data.DataHandler;
import com.ericsson.cifwk.taf.data.Host;
import com.ericsson.cifwk.taf.data.HostType;
import com.ericsson.cifwk.taf.data.User;
import com.ericsson.cifwk.taf.data.UserType;
import com.ericsson.cifwk.taf.guice.OperatorRegistry;
import com.ericsson.cifwk.taf.tools.cli.TimeoutException;
import com.ericsson.oss.cominf.test.operators.GenericOperator;
import com.ericsson.oss.taf.hostconfigurator.HostGroup;

public class postMig extends TorTestCaseHelper implements TestCase {
	
	  @Inject
	    OperatorRegistry<GenericOperator> operatorRegistry;
	    Host host;
	    Host uas;
	    Host ossmaster;
	    Host omsrvm;
	    Host omsrvs;
	    Host omsas;
	    Host nedss;
	    User user;
	    
	     @BeforeSuite
	     public void initialise()
	     {
	    	 //SOL11
	    	 /*
	    	 user = new User("root", "shroot", UserType.ADMIN);
	    	 host = HostGroup.getOmsrvm(); //DataHandler.getHostByName("omsrvmroot");
	         uas =  HostGroup.getUas(); //DataHandler.getHostByName("uas1root");
	         ossmaster = HostGroup.getOssmaster();//DataHandler.getHostByName("masterroot");
	         omsrvm = HostGroup.getOmsrvm();//DataHandler.getHostByName("omsrvmroot");
	         omsrvs = HostGroup.getOmsrvs();//DataHandler.getHostByName("omsrvsroot");
	         omsas = HostGroup.getOmsas();//DataHandler.getHostByName("omsasroot");
	         nedss = HostGroup.getNedss();//DataHandler.getHostByName("nedss");
	         */
	    	 
	    	 //SOL11
	         host = DataHandler.getHostByType(HostType.OMSRVM); //HostGroup.getOmsrvm(); 
	    	 omsrvm = DataHandler.getHostByType(HostType.OMSRVM);
	    	 uas =  DataHandler.getHostByType(HostType.UAS);
	    	 ossmaster = DataHandler.getHostByType(HostType.RC);
	    	 omsrvs = DataHandler.getHostByType(HostType.OMSRVS);
	    	 omsas = DataHandler.getHostByType(HostType.OMSAS);
	    	 nedss = DataHandler.getHostByType(HostType.NEDSS);
	    	 
	    	 //user = new User("root", "shroot12", UserType.ADMIN);
		  user = new User(host.getUser(UserType.ADMIN),host.getPass(UserType.ADMIN) , UserType.ADMIN);
	    	//SOL11
	     }	



     @TestId(id = "OSS_151540_Func01", title = "VALIDATE_PREMIG_BACKUP")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS151540Func01")

     public void OSS151540Func01(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             cliOperator.initializeShell(omsrvm,user);
             cliOperator.sendFileRemotely(omsrvm, file, fileLocation);
             cliOperator.sendFileRemotely(omsrvm, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
//omsrvs

	 cliOperator.initializeShell(omsrvs,user);
             cliOperator.sendFileRemotely(omsrvs, file, fileLocation);
             cliOperator.sendFileRemotely(omsrvs, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);
			 
         cliOperator.deleteRemoteFile(omsrvs, file, fileLocation);
         cliOperator.disconnect();
//omsas
	 cliOperator.initializeShell(omsas,user);
             cliOperator.sendFileRemotely(omsas, file, fileLocation);
             cliOperator.sendFileRemotely(omsas, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);
			 
         cliOperator.deleteRemoteFile(omsas, file, fileLocation);
         cliOperator.disconnect();
//nedss
	 cliOperator.initializeShell(nedss,user);
             cliOperator.sendFileRemotely(nedss, file, fileLocation);
             cliOperator.sendFileRemotely(nedss, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

	 boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();			 
         cliOperator.deleteRemoteFile(nedss, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_151540_Func02", title = "CHECK_COMINF_SERVICES")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS151540Func02")

     public void OSS151540Func02(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             cliOperator.initializeShell(omsrvm,user);
             cliOperator.sendFileRemotely(omsrvm, file, fileLocation);
             cliOperator.sendFileRemotely(omsrvm, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
//omsrvs
	cliOperator.initializeShell(omsrvs,user);
             cliOperator.sendFileRemotely(omsrvs, file, fileLocation);
             cliOperator.sendFileRemotely(omsrvs, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         cliOperator.deleteRemoteFile(omsrvs, file, fileLocation);
         cliOperator.disconnect();
//omsas
	cliOperator.initializeShell(omsas,user);
             cliOperator.sendFileRemotely(omsas, file, fileLocation);
             cliOperator.sendFileRemotely(omsas, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);
			 
         cliOperator.deleteRemoteFile(omsas, file, fileLocation);
         cliOperator.disconnect();
//nedss
	cliOperator.initializeShell(nedss,user);
             cliOperator.sendFileRemotely(nedss, file, fileLocation);
             cliOperator.sendFileRemotely(nedss, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);
	 		 
	 boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();			 
         cliOperator.deleteRemoteFile(nedss, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS151540Func03", title = "SMRS_SFTP_LOGIN")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS151540Func03")

     public void OSS151540Func03(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             cliOperator.initializeShell(ossmaster,user);
             cliOperator.sendFileRemotely(ossmaster, file, fileLocation);
             cliOperator.sendFileRemotely(ossmaster, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(ossmaster, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_151540_Func04", title = "CHECK_SMRS_MOUNTS")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS151540Func04")

     public void OSS151540Func04(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             cliOperator.initializeShell(omsrvm,user);
             cliOperator.sendFileRemotely(omsrvm, file, fileLocation);
             cliOperator.sendFileRemotely(omsrvm, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
//nedss
	cliOperator.initializeShell(nedss,user);
             cliOperator.sendFileRemotely(nedss, file, fileLocation);
             cliOperator.sendFileRemotely(nedss, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

	 boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(nedss, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}

//##CI_AUTOMATION_END##
}
