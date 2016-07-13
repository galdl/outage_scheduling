function [tempPythonLocalFilePath,logDir,matlabInnerCode,MATLAB_PATH,tempPyhonRemotePath]=prepareScriptArguments(funcName,funcArgs,jobArgs)
%% function arguments - struct
i_monthStr=num2str(funcArgs.i_month);
remotePlanDir=funcArgs.remotePlanDir;
mPlanFilename=funcArgs.mPlanFilename;
caseName=funcArgs.caseName;
localPlanDir=funcArgs.localPlanDir;
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
WORK_PATH = '/u/gald/Asset_Management/matlab/Matlab/current_workspace';
logDir = [remotePlanDir , '/../..'];
tempJobsFileLocalPath= [localPlanDir , '/../../tempJobFiles/'];
tempPyhonRemotePath= [remotePlanDir , '/../../tempJobFiles/'];

matlabInnerCode=[ ' "cd(''' , WORK_PATH , ''');,warning off,' , funcName , '(' , funcArgsStr , ');"' ];
tempPythonFilename    = [ jobName , '.py'];
tempPythonLocalFilePath = [ tempJobsFileLocalPath , tempPythonFilename ];
tempPyhonRemotePath = [ tempPyhonRemotePath , tempPythonFilename ];
