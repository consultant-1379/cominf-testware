package com.ericsson.oss.cominf.test.getters;

import com.ericsson.cifwk.taf.data.DataHandler;
import com.ericsson.cifwk.taf.tools.cli.CLI;
import com.ericsson.cifwk.taf.tools.cli.Shell;

public class EnvironmentSetUpGetter {

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

    public static String getInitialInstallCommand() {
        return "/export/scripts/CLOUD/bin/master.sh -c " + getConfigFiles() + " -g `hostname` -o yes -l /export/scripts/CLOUD/logs/web/CI_EXEC_OSSRC/ -f rollout_config";
    }

    public static String getArneImportCommand() {
        return "/export/scripts/CLOUD/bin/master.sh -c " + getConfigFiles() + "  -g `hostname`  -o yes -l /export/scripts/CLOUD/logs/web/CI_EXEC_OSSRC/ -f netsim_post_steps";
    }

    public static String getAddUserCommand() {
        return "/export/scripts/CLOUD/bin/master.sh -c " + getConfigFiles() + " -g `hostname` -o yes -l /export/scripts/CLOUD/logs/web/CI_EXEC_OSSRC/ -f create_users_config";

    }
}
