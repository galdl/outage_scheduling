function [tempPythonLocalFilePath,logDir,matlabInnerCode,MATLAB_PATH,tempPyhonRemotePath]=prepareScriptArguments_obsolete(funcName,funcArgs,jobArgs,config)
%% function arguments - struct
i_monthStr=num2str(funcArgs.i_month);
remotePlanDir=funcArgs.remotePlanDir;
localPlanDir=funcArgs.localPlanDir;

mPlanFilename=funcArgs.mPlanFilename;
caseName=funcArgs.caseName;
jobName=jobArgs.jobName;

funcArgsStr=[i_monthStr , ',' , '''' , remotePlanDir , '''' , ',' , '''' , mPlanFilename , '''' , ',' , '''' , caseName, ''''];
% for i_arg=1:length(funcArgs)
%     if(i_arg==1)
%             funcArgsStr=funcArgs{i_arg};
%     else
%     funcArgsStr=[funcArgsStr,',',num2str(funcArgs{i_arg})];
%     end
% end
%% matlab call string
MATLAB_PATH = '/usr/local/bin/matlab';
WORK_PATH = config.REMOTE_SERVER_MATLAB_WORKPATH;
logDir = [remotePlanDir , '/../..'];
tempJobsFileLocalPath= [localPlanDir , '/../../tempJobFiles/'];
tempPyhonRemotePath= [remotePlanDir , '/../../tempJobFiles/'];

matlabInnerCode=[ ' "cd(''' , WORK_PATH , ''');,warning off,' , funcName , '(' , funcArgsStr , ');"' ];
tempPythonFilename    = [ jobName , '.py'];
tempPythonLocalFilePath = [ tempJobsFileLocalPath , tempPythonFilename ];
tempPyhonRemotePath = [ tempPyhonRemotePath , tempPythonFilename ];
