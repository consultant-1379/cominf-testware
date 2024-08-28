package com.ericsson.oss.cominf.test.operators;

import com.ericsson.cifwk.taf.annotations.Context;
import com.ericsson.cifwk.taf.annotations.Operator;
import com.ericsson.cifwk.taf.data.Host;
import com.ericsson.cifwk.taf.tools.cli.CLICommandHelper;
import com.google.inject.Singleton;

@Operator(context = Context.CLI)
@Singleton
public class CLICommandHelperOperator {

    private CLICommandHelper cliCommandHelper;

    public void initializeShell(Host host) {
        cliCommandHelper = new CLICommandHelper(host);
        cliCommandHelper.openShell();
        cliCommandHelper.simpleExec();
    }

    public String simpleExec(String... commands){
        return cliCommandHelper.simpleExec(commands);
    }
}
