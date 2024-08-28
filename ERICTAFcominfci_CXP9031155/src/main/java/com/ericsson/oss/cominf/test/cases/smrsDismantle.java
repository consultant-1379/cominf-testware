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

public class smrsDismantle extends TorTestCaseHelper implements TestCase {
	
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
	    	 host = DataHandler.getHostByType(HostType.OMSRVM);  //HostGroup.getOmsrvm(); 
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

     @TestId(id = "OSS40742_FUNC_01", title = "Dismantle SMRS setup")
     @Context(context = {Context.CLI})
     @Test(groups={ "KGB" })
     @DataDriven(name = "OSS40742FUNC01")
     // TestCase TAFTM link :http://taftm.lmera.ericsson.se/#tm/viewTC/1352
     public void OSS40742FUNC01(
            @Input("executeFile")String executeFileCmd,
            @Input("file")String file,
            @Input("changeDir") String changeDirCmd,
            @Input("fileLocation") String fileLocation,
            @Input("lib")String lib,    
            @Input("timeout") int timeout,
            @Input("exitShell") String exitShellCmd,
            @Output("expectedExit") int expectedExitCode) throws TimeoutException, FileNotFoundException, InterruptedException{
             GenericOperator cliOperator = operatorRegistry.provide(GenericOperator.class);
             try {
             cliOperator.initializeShell(ossmaster,user);
             cliOperator.sendFileRemotely(ossmaster, file, fileLocation);
             cliOperator.sendFileRemotely(ossmaster, lib, fileLocation);
             cliOperator.writeln(changeDirCmd, fileLocation);
             cliOperator.writeln("convertLineEndings", lib);
             cliOperator.writeln("convertLineEndings", file);
             cliOperator.writeln(executeFileCmd, file);
             Thread.sleep(4000000);
             cliOperator.getStdOut();
             cliOperator.writeln(exitShellCmd);
             cliOperator.expectClose(timeout);

         boolean isClose = cliOperator.isClosed();
         int exitValue = cliOperator.getExitValue();
         cliOperator.deleteRemoteFile(ossmaster, file, fileLocation);
         cliOperator.disconnect();
         assertTrue(isClose);
         assertEquals(expectedExitCode,exitValue);
             }catch (TimeoutException e){}
}

//##CI_AUTOMATION_END##
}
