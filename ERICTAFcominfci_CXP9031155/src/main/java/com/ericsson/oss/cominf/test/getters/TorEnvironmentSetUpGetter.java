package com.ericsson.oss.cominf.test.getters;

import com.ericsson.cifwk.taf.data.DataHandler;
import com.ericsson.cifwk.taf.tools.cli.CLI;
import com.ericsson.cifwk.taf.tools.cli.Shell;

public class TorEnvironmentSetUpGetter {

    private static String configFiles;
    private static String runCommands;
    private static String extraCommand;
    private static String hostName;

    private static String getConfigFiles() {
        if (configFiles == null)
            configFiles = DataHandler.getAttribute("CONFIG_FILES").toString();
        return configFiles;
    }
    private static String getRunCommand() {
        if (runCommands == null)
             runCommands = DataHandler.getAttribute("TORFIRSTPARAMETERS").toString();
        return runCommands;
    }
    private static String getExtraCommands() {
        if (extraCommand == null)
            extraCommand = DataHandler.getAttribute("TORSECONDPARAMETERS").toString();
        return extraCommand;
    }

    private static String getHostName() {
        if (hostName == null){
        	CLI cli = new CLI(DataHandler.getHostByName("gateway"));
        	Shell sh = cli.executeCommand("hostname");
        	hostName = sh.read();
        	sh.disconnect();
        	//            hostName = DataHandler.getHostByName("gateway").getIp();
        
        }return hostName;
    }

	public static String getConfigureTorMSCommand() {
		return "/export/scripts/CLOUD/bin/master.sh -c " + getConfigFiles() + " -g `hostname` -f tor_ms_configuration -o yes";
	}

	public static String getConfigureTorPeerNodesCommand() {
		return "/export/scripts/CLOUD/bin/master.sh -c " + getConfigFiles() + " -g `hostname` -f tor_peer_node_configuration -o yes";
	}

	public static String getPhysicalInstallationCommand() {
        return "/proj/lciadm100/cifwk/latest/bin/cicmd torinst_deployment " + getRunCommand() + " " + getExtraCommands();
	}

	public static String getautoDeploymentInstallationCommand() {
        return "/proj/lciadm100/cifwk/latest/bin/cicmd deployment " + getRunCommand() + " " + getExtraCommands();
	}
}
