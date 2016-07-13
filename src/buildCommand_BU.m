function finalCommand = buildCommand_BU(funcName,funcArgs,jobArgs)
%% job arguments - struct
ncpusStr=num2str(jobArgs.ncpus);
memStr=[num2str(jobArgs.memory),'gb'];
queue=jobArgs.queue;
jobName=jobArgs.jobName;

%% function arguments - struct
i_monthStr=num2str(funcArgs.i_month);
remotePlanDir=funcArgs.remotePlanDir;
mPlanFilename=funcArgs.mPlanFilename;
caseName=funcArgs.caseName;

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
outputPath=[logDir , '/output/', jobName , '.out'];
errorPath= [logDir , '/error/' , jobName , '.err'];

% funcCall=[ '"cd(''' , WORK_PATH , ''');,warning off,' , funcName , '(' , funcArgsStr , ');"' ];

funcCall=[ '"cd(''' , WORK_PATH , ''');,warning off,' , funcName , '(' , funcArgsStr , ');"' ];
MATLAB_COMMAND = [MATLAB_PATH,' -nodisplay -r ',funcCall];

% PBS_OPTS = ['-S /bin/bash -l select=1:ncpus=',ncpusStr,':mem=',memStr,' -j oe -q ',queue,' -mn -N ',jobName ,...
PBS_OPTS = ['-S /bin/bash -l select=1:ncpus=',ncpusStr,':mem=',memStr,' -q ',queue,' -N ',jobName ,...
    ' -o ' , outputPath , ' -e ' , errorPath];
finalCommand = ['qsub ',PBS_OPTS,' -- ',MATLAB_COMMAND];
