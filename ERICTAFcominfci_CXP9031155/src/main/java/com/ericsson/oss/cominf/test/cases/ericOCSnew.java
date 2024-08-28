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

public class ericOCSnew extends TorTestCaseHelper implements TestCase {
	
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
	         host = DataHandler.getHostByType(HostType.OMSRVM);
	    	 omsrvm = DataHandler.getHostByType(HostType.OMSRVM);
	    	 uas =  DataHandler.getHostByType(HostType.UAS);
	    	 ossmaster = DataHandler.getHostByType(HostType.RC);
	    	 omsrvs = DataHandler.getHostByType(HostType.OMSRVS);
	    	 omsas = DataHandler.getHostByType(HostType.OMSAS);
	    	 nedss = DataHandler.getHostByType(HostType.NEDSS);
	    	 
	    	 //user = new User("root", "shroot12", UserType.ADMIN);
		  user = new User(host.getUser(UserType.ADMIN),host.getPass(UserType.ADMIN) , UserType.ADMIN);
	         
	     } 

     @TestId(id = "OSS_40739_Func05", title = "Updating Published Applications list")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func05")

     public void OSS40739Func05(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             cliOperator.initializeShell(uas,user);
             cliOperator.sendFileRemotely(uas, file, fileLocation);
             cliOperator.sendFileRemotely(uas, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(300000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(uas, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}

/* // SOL11 Exclusion

     @TestId(id = "OSS_40739_Func06", title = "Verify ntpv4 is in enabled state in all servers in initial and uprgade scenarios")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func06")

     public void OSS40739Func06(
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

*/ // SOL11 Exclusion


     @TestId(id = "OSS_40739_Func07", title = "Verify NTP service is in disabled state in all server")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func07")

     public void OSS40739Func07(
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


     @TestId(id = "OSS_40739_Func08", title = "Verify NTP ip in /etc/inet/ntp.conf file")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func08")

     public void OSS40739Func08(
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


     @TestId(id = "OSS_40739_Func09", title = "Verify time sync in all the servers")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func09")

     public void OSS40739Func09(
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




     @TestId(id = "OSS_40739_Func18", title = "Setup ISC-DHCP fails if NTP Server not specified in config file-HQ32401")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func18")

     public void OSS40739Func18(
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


     @TestId(id = "OSS_40739_Func11", title = "verify dhcpd config files are world writable or not")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func11")

     public void OSS40739Func11(
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
  


     @TestId(id = "OSS_40739_Func14", title = "Checking the dhcp script outputs are redirected to /dev/null properly in crontab-HS65493")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func14")

     public void OSS40739Func14(
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


     @TestId(id = "OSS_40739_Func12", title = "Checking the dhcp script outputs are redirected to /dev/null in crontab-HS39928")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func12")

     public void OSS40739Func12(
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


     @TestId(id = "OSS_40739_Func13", title = "OCS back up and restore tescase on OMSAS")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func13")

     public void OSS40739Func13(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             cliOperator.initializeShell(omsas,user);
             cliOperator.sendFileRemotely(omsas, file, fileLocation);
             cliOperator.sendFileRemotely(omsas, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(150000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(omsas, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40739_Func19", title = "Adding Multiple NTP/PEER servers to /etc/inet/ntp.conf file using /ericsson/ocs/bin/update_ntp_conf.sh")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func19")

     public void OSS40739Func19(
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


     @TestId(id = "OSS_40739_Func20", title = "HT82353-setup_isc_dhcp.sh-functionality_check")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func20")

     public void OSS40739Func20(
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


     @TestId(id = "OSS_40739_Func22", title = "Sudo does not work in UAS")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func22")

     public void OSS40739Func22(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             cliOperator.initializeShell(uas,user);
             cliOperator.sendFileRemotely(uas, file, fileLocation);
             cliOperator.sendFileRemotely(uas, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(100000);
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(uas, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
}


     @TestId(id = "OSS_40739_Func23", title = "[2~Check for exit code of cominf_small_upgrade.sh script.")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40739Func23")

     public void OSS40739Func23(
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
