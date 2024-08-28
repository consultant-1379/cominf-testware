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

public class ericSdee extends TorTestCaseHelper implements TestCase {
	
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
	    	 /*user = new User("root", "shroot", UserType.ADMIN);
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


     @TestId(id = "OSS_40738_Func01", title = "SSH keys generatin and Passwordless login")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func01")

     public void OSS40738Func01(
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
             Thread.sleep(200000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func02", title = "Reset of users password")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func02")

     public void OSS40738Func02(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func03", title = "Add user usage")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func03")

     public void OSS40738Func03(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func05", title = "verifying existing server certificates and root certificates using /ericsson/sdee/bin/prepSSL.sh and ldapsearch commands")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func05")

     public void OSS40738Func05(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func06", title = "Add ##COMINF_TC_TITLE## remove privileges (targets/role/aliases) to the multiple users of different types using /ericsson/sdee/bin/manage_COM_privs.bsh")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func06")

     public void OSS40738Func06(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func07", title = "verifying the ERROR messages while Adding ##COMINF_TC_TITLE## removing privileges to users with invalid privileges(targets/roles/aliases) Invalid ACTIONS and Invalid Users in the batchfile using /ericsson/sdee/bin/manage_COM_privs.bsh")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func07")

     public void OSS40738Func07(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func09", title = "Adding Bulk users")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func09")

     public void OSS40738Func09(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func08", title = "verifying the validation of domain by /ericsson/sdee/bin/manage_COM_privs.bsh script")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func08")

     public void OSS40738Func08(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func04", title = "Reseting users' password")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func04")

     public void OSS40738Func04(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func10", title = "verifying the addition of alias with target qualified roles using /ericsson/sdee/bin/manage_COM.bsh")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func10")

     public void OSS40738Func10(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func11", title = "verifying the addition of target qualified roles to the alias with invalid target names using /ericsson/sdee/bin/manage_COM.bsh")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func11")

     public void OSS40738Func11(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func14", title = "Adding bulk users with valid and invalid users")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func14")

     public void OSS40738Func14(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func13", title = "verify the modification of alias by inserting and removing the target qualified roles into alias using /ericsson/sdee/bin/manage_COM.bsh")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func13")

     public void OSS40738Func13(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func12", title = "Adding non existing target specified role")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func12")

     public void OSS40738Func12(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func15", title = "Verify the addition of freestanding target to ldapuser")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func15")

     public void OSS40738Func15(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func16", title = "Adding ##COMINF_TC_TITLE##Removing priveleges to users using /ericsson/sdee/bin/manage_COM_privs.bsh script with -f <batch_file> option where target is *")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func16")

     public void OSS40738Func16(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func17", title = "Verifying addition of roles in the domain")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func17")

     public void OSS40738Func17(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func19", title = "HT22877 : script manage_COM_privs.bsh delete second target role when user delete first target role")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func19")

     public void OSS40738Func19(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func20", title = "HT23821 /ericsson/sdee/bin/manage_COM_privs.bsh script is taking invalid targets as input")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func20")

     public void OSS40738Func20(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func21", title = "HR48618 14A /ericsson/sdee/bin has full permissions 777 on infra servers")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func21")

     public void OSS40738Func21(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func22", title = "Verifying the location of root certificate")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func22")

     public void OSS40738Func22(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func25", title = "HT47384 importing roles using file")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func25")

     public void OSS40738Func25(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}



     @TestId(id = "OSS_40738_Func26", title = "bsimuser UID verification")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func26")

     public void OSS40738Func26(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func27", title = "Poodle_cipher_verification")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func27")

     public void OSS40738Func27(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func28", title = "HT96627_Removing a role removes roles and aliases assigned to user")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func28")

     public void OSS40738Func28(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40738_Func29", title = "HU10414 15B while adding target as star to users in bulk users creation ERROR isthrown")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func29")

     public void OSS40738Func29(
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
             Thread.sleep(150000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS40738Func41", title = "verifying the validations for bulk user promote")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func41")

     public void OSS40738Func41(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS40738Func47", title = "Listing single user")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func47")

     public void OSS40738Func47(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}

     @TestId(id = "OSS40738Func48", title = "Checking DNS Service in Infra master, slave and Omsas")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func48")

     public void OSS40738Func48(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS40738Func49", title = "Verify new password policy")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func49")

     public void OSS40738Func49(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS40738Func50", title = "Verify Caasadmin changes")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func50")

     public void OSS40738Func50(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS40738Func51", title = "Verify Cipher changes")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func51")

     public void OSS40738Func51(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func52", title = "Apply patch password policy")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func52")

     public void OSS40738Func52(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func53", title = "Verify PwdMustChange attribute is ture")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func53")

     public void OSS40738Func53(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func54", title = "If pwdMustChange attribute is true then add users")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func54")

     public void OSS40738Func54(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func55", title = "Check pwdReset attribute values for OSS-ONLY and COM-OSS users")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func55")

     public void OSS40738Func55(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func56", title = "Login users via UAS  as OSS-ONLY and COM-OSS and change password")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func56")

     public void OSS40738Func56(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func57", title = "Verify PwdMustChange attribute is false")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func57")

     public void OSS40738Func57(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func58", title = "Create proxy user and check pwdReset value")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func58")

     public void OSS40738Func58(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


  @TestId(id = "OSS40738Func59", title = "Batch file execution of manage COM privs")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func59")

     public void OSS40738Func59(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}

@TestId(id = "OSS40738Func60", title = "Removing DHE cipher")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40738Func60")

     public void OSS40738Func60(
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

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsrvm, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}

//##CI_AUTOMATION_END##
}
