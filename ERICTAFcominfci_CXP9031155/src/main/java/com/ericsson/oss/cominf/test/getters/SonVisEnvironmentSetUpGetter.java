package com.ericsson.oss.cominf.test.getters;

import com.ericsson.cifwk.taf.data.DataHandler;
import com.ericsson.cifwk.taf.tools.cli.CLI;
import com.ericsson.cifwk.taf.tools.cli.Shell;

public class SonVisEnvironmentSetUpGetter {

    private static String configFiles;
    private static String hostName;

    private static String getConfigFiles() {
        if (configFiles == null)
            configFiles = DataHandler.getAttribute("CONFIG_FILES").toString();
        return configFiles;

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

    public static String getSonVisInitialInstallCommand() {
        return "/export/scripts/CLOUD/bin/master.sh -c " + getConfigFiles() + " -g `hostname` -o yes -l /export/scripts/CLOUD/logs/web/CI_EXEC_SON_VIS/ -f rollout_config";
    }

}
