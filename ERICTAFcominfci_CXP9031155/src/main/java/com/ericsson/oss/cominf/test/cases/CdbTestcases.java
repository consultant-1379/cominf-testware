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
import com.ericsson.cifwk.taf.data.Ports;
import com.ericsson.cifwk.taf.data.User;
import com.ericsson.cifwk.taf.data.UserType;
import com.ericsson.cifwk.taf.guice.OperatorRegistry;
import com.ericsson.cifwk.taf.tools.cli.TimeoutException;
//import com.google.inject.Inject;
import com.ericsson.oss.cominf.test.operators.CdbTestcasesOperator;
import com.ericsson.oss.cominf.test.operators.GenericOperator;
import com.ericsson.oss.taf.hostconfigurator.HostGroup;

public class CdbTestcases extends TorTestCaseHelper implements TestCase {
 
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
	    	 //user = new User("root", "shroot", UserType.ADMIN);
	    	 	    	     	 	    	 
	    	 //host = HostGroup.getOmsrvm(); //DataHandler.getHostByName("omsrvmroot");
	    	 //uas =  HostGroup.getUas(); //DataHandler.getHostByName("uas1root");
	    	 //ossmaster = HostGroup.getOssmaster();//DataHandler.getHostByName("masterroot");
	    	 //omsrvm = HostGroup.getOmsrvm();//DataHandler.getHostByName("omsrvmroot");
	    	 //omsrvs = HostGroup.getOmsrvs();//DataHandler.getHostByName("omsrvsroot");
	    	 //omsas = HostGroup.getOmsas();//DataHandler.getHostByName("omsasroot");
	    	 //nedss = HostGroup.getNedss();//DataHandler.getHostByName("nedss");
	    	 
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
	    	 //SOL11
	     }
	     
    @Inject
    OperatorRegistry<CdbTestcasesOperator> operatorRegistry1;
    @Context(context = { Context.CLI })
    @TestId(id = "UAS1", title = "Add NAT IP on UAS")
    @Test(groups={"Acceptance"})
    public void verifyEnvironmentInstallation() {
    	CdbTestcasesOperator cdb = operatorRegistry1.provide(CdbTestcasesOperator.class);
    	int expected = 1;
    	assertEquals(expected,cdb.additionofNatIp());        
    }

    
  /**
   * @DESCRIPTION Add a LDAP user and check if user is added successfully
   * @PRE Connection to SUT
   * @PRIORITY HIGH
   * @VUsers 1
   * @throws TimeoutException
   * @throws FileNotFoundException
   * @throws InterruptedException 
   */

  @TestId(id = "LDAP_1", title = "Add user and check if user is added successfully Check for Sudo")
  @Context(context = {Context.CLI})
  @Test(groups={"Acceptance"})
  @DataDriven(name = "executeLdapData")
  public void checkLdapDetails(
         @Input("executeFile")String executeFileCmd,
         @Input("file")String file,
         @Input("prompt1response") String firstPromptResponse,
         @Input("changeDir") String changeDirCmd,
         @Input("fileLocation") String fileLocation,
         @Input("timeout") int timeout,
         @Input("exitShell") String exitShellCmd,
         @Output("prompt1") String firstPrompt,
         @Output("prompt2response") String secondPromptResponse,
         @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{

      GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
      cliOperator.initializeShell(host,user);
      cliOperator.sendFileRemotely(host, file, fileLocation);
      cliOperator.writeln(changeDirCmd, fileLocation);
      cliOperator.writeln("convertLineEndings", file);
      cliOperator.writeln(executeFileCmd, file);
      Thread.sleep(10000);
      cliOperator.expect(firstPrompt);
      cliOperator.scriptInput(firstPromptResponse);
      Thread.sleep(150000);
      cliOperator.writeln(exitShellCmd);
      cliOperator.expectClose(timeout);
      boolean isClose = cliOperator.isClosed();
      int exitValue = cliOperator.getExitValue();

      cliOperator.deleteRemoteFile(host, file, fileLocation);
      cliOperator.disconnect();
      assertTrue(isClose);
      assertEquals(expectedExitCode,exitValue);


  }

  /**
   * @DESCRIPTION Check whether /ericsson/ocs/bin/clear_unused_shmids.sh is added or not in UAS 
   * @PRE Connection to SUT
   * @PRIORITY HIGH
   * @VUsers 1
   * @throws TimeoutException
   * @throws FileNotFoundException
   * @throws InterruptedException 
   */
/* // SOL11 Exclusion

  @TestId(id = "UAS_2", title = "Check whether /ericsson/ocs/bin/clear_unused_shmids.sh is added or not in UAS ")
  @Context(context = {Context.CLI})
  @Test(groups={"Acceptance"})
  @DataDriven(name = "UasData")
  public void UasShm(
         @Input("executeFile")String executeFileCmd,
         @Input("file")String file,
          @Input("changeDir") String changeDirCmd,
        @Input("fileLocation") String fileLocation,
        @Input("timeout") int timeout,
        @Input("exitShell") String exitShellCmd,
         @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{

      GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
      cliOperator.initializeShell(uas,user);
      cliOperator.sendFileRemotely(uas, file, fileLocation);
      cliOperator.writeln(changeDirCmd, fileLocation);
      cliOperator.writeln("convertLineEndings", file);
      cliOperator.writeln(executeFileCmd, file);
      //        Thread.sleep(100000);
      cliOperator.writeln(exitShellCmd);
      cliOperator.expectClose(timeout);

      boolean isClose = cliOperator.isClosed();
      int exitValue = cliOperator.getExitValue();
      cliOperator.deleteRemoteFile(uas, file, fileLocation);
      cliOperator.disconnect();
      assertTrue(isClose);
      assertEquals(expectedExitCode,exitValue);


  }
*/  //SOL11 Exclusion
  /**
   * @DESCRIPTION Check whether Java Policies for Global policies should be set-up for PXM for MME 
   * @PRE Connection to SUT
   * @PRIORITY HIGH
   * @VUsers 1
   * @throws TimeoutException
   * @throws FileNotFoundException
   * @throws InterruptedException 
*/

/* //SOL11 Exclusion
  @TestId(id = "UAS_3", title = "Check whether Java Policies for Global policies should be set-up for PXM for MME ")
  @Context(context = {Context.CLI})
  @Test(groups={"Acceptance"})
  @DataDriven(name = "UasGB")
  public void UasPolicy(
         @Input("executeFile")String executeFileCmd,
         @Input("file")String file,
         @Input("changeDir") String changeDirCmd,
        @Input("fileLocation") String fileLocation,
        @Input("timeout") int timeout,
        @Input("exitShell") String exitShellCmd,
         @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{

      GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
      cliOperator.initializeShell(uas,user);
      cliOperator.sendFileRemotely(uas, file, fileLocation);
      cliOperator.writeln(changeDirCmd, fileLocation);
      cliOperator.writeln("convertLineEndings", file);
      cliOperator.writeln(executeFileCmd, file);
      //        Thread.sleep(100000);
      cliOperator.writeln(exitShellCmd);
      cliOperator.expectClose(timeout);
     boolean isClose = cliOperator.isClosed();
     int exitValue = cliOperator.getExitValue();
      //
      cliOperator.deleteRemoteFile(uas, file, fileLocation);
      cliOperator.disconnect();
      assertTrue(isClose);
      assertEquals(expectedExitCode,exitValue);

  }
*/ //SOL11 Exclusion

    /**
   * @DESCRIPTION Verify configure_smrs.sh upgrade script message
   * @PRE Connection to SUT
   * @PRIORITY HIGH
   * @VUsers 1
   * @throws TimeoutException
   * @throws FileNotFoundException
   * @throws InterruptedException 
   */
/**
  @TestId(id = "SMRS_1", title = "Verify configure_smrs.sh upgrade script message")
  @Context(context = {Context.CLI})
  @Test(groups={"Acceptance"})
  @DataDriven(name = "smrsData")
  public void smrsString(
         @Input("executeFile")String executeFileCmd,
         @Input("file")String file,
         @Input("changeDir") String changeDirCmd,
        @Input("fileLocation") String fileLocation,
        @Input("timeout") int timeout,
        @Input("exitShell") String exitShellCmd,
         @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{

      GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
      cliOperator.initializeShell(ossmaster);
      cliOperator.sendFileRemotely(ossmaster, file, fileLocation);
      cliOperator.writeln(changeDirCmd, fileLocation);
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
 */ 
/* //SOL11 Exclusion till  OpenDJBR
     @TestId(id = "OSS_40744_Func02", title = "Backup of LDAP Database")
     @Context(context = {Context.CLI})
     @Test(groups={ "CDB" })
     @DataDriven(name = "OSS40744Func02")

     public void OSS40744Func02(
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
*/

/*  //SOL11 Exclusion till IPV6 Exists

     @TestId(id = "OSS_40744_Func01", title = "IPv6 Solaris OS Configuration Check")
     @Context(context = {Context.CLI})
     @Test(groups={ "CDB" })
     @DataDriven(name = "OSS40744Func01")

     public void OSS40744Func01(
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
*/  // SOL11 Exclusion till IPV6 Exists

     @TestId(id = "OSS_40744_Func03", title = "Adding ths user to sys_adm group")
     @Context(context = {Context.CLI})
     @Test(groups={ "CDB" })
     @DataDriven(name = "OSS40744Func03")

     public void OSS40744Func03(
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

