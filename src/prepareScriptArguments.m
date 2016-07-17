function [tempPythonLocalFilePath,logDir,matlabInnerCode,MATLAB_PATH,tempPyhonRemotePath]=prepareScriptArguments(funcName,funcArgs,jobArgs,config)
%% function arguments - struct
remote_job_run_dir=funcArgs.remote_job_run_dir;

argContentFilename=funcArgs.argContentFilename;
jobName=jobArgs.jobName;

funcArgsStr=[ '''' , remote_job_run_dir , '''' , ',' , '''' , argContentFilename , '''' ];

%% matlab call string
MATLAB_PATH = '/usr/local/bin/matlab';
WORK_PATH = config.REMOTE_SERVER_MATLAB_WORKPATH;
logDir = config.full_remoteRun_dir;

matlabInnerCode=[ ' "cd(''' , WORK_PATH , ''');,warning off,' , funcName , '(' , funcArgsStr , ');"' ];
tempPythonFilename    = [ jobName , '.py'];

tempPythonLocalFilePath = [ config.local_tempFiles_dir , tempPythonFilename ];
tempPyhonRemotePath = [ config.remote_tempFiles_dir , tempPythonFilename ];
