function [tempPythonLocalFilePath,logDir,matlabInnerCode,MATLAB_PATH,tempPyhonRemotePath]=prepareScriptArguments(funcName,funcArgs,jobArgs)
%% function arguments - struct
remoteIterDir=funcArgs.remoteIterDir;
argContentFilename=funcArgs.argContentFilename;
localIterDir=funcArgs.localIterDir;
jobName=jobArgs.jobName;

funcArgsStr=[ '''' , remoteIterDir , '''' , ',' , '''' , argContentFilename , '''' ];

%% matlab call string
MATLAB_PATH = '/usr/local/bin/matlab';
WORK_PATH = '/u/gald/PSCC16_continuation/current_version';
logDir = [remoteIterDir , '/..'];
tempJobsFileLocalPath= [localIterDir , '/../tempJobFiles/'];
tempPyhonRemotePath= [remoteIterDir , '/../tempJobFiles/'];

matlabInnerCode=[ ' "cd(''' , WORK_PATH , ''');,warning off,' , funcName , '(' , funcArgsStr , ');"' ];
tempPythonFilename    = [ jobName , '.py'];
tempPythonLocalFilePath = [ tempJobsFileLocalPath , tempPythonFilename ];
tempPyhonRemotePath = [ tempPyhonRemotePath , tempPythonFilename ];
