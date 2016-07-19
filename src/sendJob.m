function []=sendJob(funcName,funcArgs,jobArgs,config)
%% prepare arguments for the python script file
[tempPythonLocalFilePath,logDir,matlabInnerCode,tempPyhonRemotePath]=prepareScriptArguments(funcName,funcArgs,jobArgs,config);

%% build the python script file
createTempPythonFile(tempPythonLocalFilePath,logDir,matlabInnerCode,config.REMOTE_SERVER_MATLAB_PROGRAM_PATH,jobArgs)

%% send job
sendSSHCommand(['chmod u+x ',tempPyhonRemotePath]);
sendSSHCommand(tempPyhonRemotePath);
