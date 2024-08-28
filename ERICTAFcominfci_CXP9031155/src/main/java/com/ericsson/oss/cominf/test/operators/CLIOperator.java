package com.ericsson.oss.cominf.test.operators;

import java.io.FileNotFoundException;
import java.util.List;

import org.apache.log4j.Logger;

import com.ericsson.cifwk.taf.annotations.Context;
import com.ericsson.cifwk.taf.annotations.Operator;
import com.ericsson.cifwk.taf.data.DataHandler;
import com.ericsson.cifwk.taf.data.Host;
import com.ericsson.cifwk.taf.data.User;
import com.ericsson.cifwk.taf.data.UserType;

//SOL11
//import com.ericsson.cifwk.taf.handlers.RemoteFileHandler;
import com.ericsson.cifwk.taf.tools.cli.handlers.impl.RemoteObjectHandler;
import com.ericsson.cifwk.taf.data.Host;
import com.ericsson.cifwk.taf.data.HostType;

//SOL11

import com.ericsson.cifwk.taf.tools.cli.CLI;
import com.ericsson.cifwk.taf.tools.cli.CLICommandHelper;
import com.ericsson.cifwk.taf.tools.cli.Shell;
import com.ericsson.cifwk.taf.tools.cli.TimeoutException;
import com.ericsson.cifwk.taf.utils.FileFinder;
import com.ericsson.oss.taf.hostconfigurator.HostGroup;
import com.google.inject.Singleton;

@Operator(context = Context.CLI)
@Singleton
public class CLIOperator implements GenericOperator {

    private CLI cli;
    private Shell shell;
    private static String myString;

    Logger logger = Logger.getLogger(CLIOperator.class);
    //private static User user = new User("root", "shroot12", UserType.ADMIN);
    Host host = DataHandler.getHostByType(HostType.OMSRVM);
    private String uname=host.getUser(UserType.ADMIN);
    private String passwd=host.getPass(UserType.ADMIN);
     private User user = new User(uname,passwd , UserType.ADMIN);


    @Override
    public String getCommand(String command) {
        return DataHandler.getAttribute(cliCommandPropertyPrefix + command)
                .toString();
    }

    public static boolean initialise() {

        Host host = HostGroup.getOssmaster();//DataHandler.getHostByName("sc2");
        String source = DataHandler.getAttribute("CLISOURCE").toString();
        String target = DataHandler.getAttribute("TESTFILES").toString();
        
        //SOL11
        //RemoteFileHandler remoteFileHandler = new RemoteFileHandler(host,user);
        RemoteObjectHandler remoteFileHandler = new RemoteObjectHandler(host, host.getUser("root"));
        //SOL11
        if (!remoteFileHandler.remoteFileExists(target)) {
            return remoteFileHandler.copyLocalFileToRemote(source, target);
        } else
            return true;            
    }

    @Override
    public void initializeShell(Host host,User user) {
        cli = new CLI(host,user);
        if (shell == null) {
            shell = cli.openShell();
            logger.debug("Creating new shell instance");
        }
    }

    @Override
    public void writeln(String command, String args) {
        String cmd = getCommand(command);
        logger.trace("Writing " + cmd + " " + args + " to standard input");
        logger.info("Executing commmand " + cmd + " with args " + args);
        shell.writeln(cmd + " " + args);
    }

    @Override
    public void writeln(String command) {
        String cmd = getCommand(command);
        logger.trace("Writing " + cmd + " to standard input");
        logger.info("Executing commmand " + cmd);
        shell.writeln(cmd);
    }

    @Override
    public int getExitValue() {
        int exitValue = shell.getExitValue();
        logger.debug("Getting exit value from shell, exit value is :"
                + exitValue);
        return exitValue;
    }

    @Override
    public String expect(String expectedText) throws TimeoutException {
        logger.debug("Expected return is " + expectedText);
        String found = shell.expect(expectedText);
        return found;
    }

    @Override
    public void expectClose(int timeout) throws TimeoutException {
        try{
                logger.info("Expected Timeout is " + timeout);
		shell.expectClose(timeout);
		}catch(TimeoutException e) {
                   } 
    }
    @Override
    public boolean isClosed() throws TimeoutException {
        return shell.isClosed();
    }

    @Override
    public String checkForNullError(String error) {
        if (error == null) {
            error = "";
            return error;
        }
        return error;
    }

    @Override
    public String getStdOut() {
        String result = shell.read();
        logger.debug("Standard out: " + result);
        return result;
    }

    @Override
    public void disconnect() {
        logger.info("Disconnecting from shell");
        shell.disconnect();
        shell = null;
    }

    @Override
    public void sendFileRemotely(Host host, String fileName,
            String fileServerLocation) throws FileNotFoundException {

        //SOL11
    	//RemoteFileHandler remote = new RemoteFileHandler(host,user);
	//Vishwa
	User user = host.getUser("root");
	logger.trace("Vishwa : Username : " + user.getUsername());
	logger.trace("Vishwa : Password : " + user.getPassword());
	logger.info("Vishwa : Username : " + user.getUsername());
	logger.info("Vishwa : Password : " + user.getPassword());
	//Vishwa
    	RemoteObjectHandler remote = new RemoteObjectHandler(host,host.getUser("root"));
    	//SOL11
        List<String> fileLocation = FileFinder.findFile(fileName);
        String remoteFileLocation = fileServerLocation; // unix address
        remote.copyLocalFileToRemote(fileLocation.get(0), remoteFileLocation);
        logger.debug("Copying " + fileName + " to " + remoteFileLocation
                + " on remote host");

    }

    @Override
    public void deleteRemoteFile(Host host,String fileName,
            String fileServerLocation) throws FileNotFoundException {
    	CLICommandHelper cli=  new CLICommandHelper(host,user);
    	System.out.println(cli.simpleExec("id"));
    	
    	//SOL11
        //RemoteFileHandler remoteFileHandler = new RemoteFileHandler(host,user);
    	RemoteObjectHandler remoteFileHandler = new RemoteObjectHandler(host,host.getUser("root"));
    	//SOL11
        String remoteFileLocation = fileServerLocation;
        boolean result = remoteFileHandler.remoteFileExists(remoteFileLocation + fileName);
        remoteFileHandler.deleteRemoteFile(remoteFileLocation + fileName);
        logger.debug("deleting " + fileName + " at location "
                + remoteFileLocation + " on remote host");
    }

    @Override
    public void scriptInput(String message) {
        logger.info("Writing " + message + " to standard in");
        shell.writeln(message);
    }

    @Override
    public Shell executeCommand(String... commands) {
        logger.info("Executing command(s) " + commands);
        return cli.executeCommand(commands);

    }
	public void writelnAndexit(String command, String args) {
		String cmd = getCommand(command)+" " + args+";exit;";
        logger.trace("Writing " + cmd + " to standard input");
        logger.info("Executing commmand " + cmd);
        shell.writeln(cmd);
		}
	
}
