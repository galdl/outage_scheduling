function  [localPlanDir,planFileName,remotePlanDir]=perparePlanDir(localIterDir,remoteIterDir,i_plan,mPlanBatch,GENERAL_PLAN_FILENAME,PLAN_DIRNAME_PREFIX)
%% create plan dir
relativePlanPath=['/',PLAN_DIRNAME_PREFIX,num2str(i_plan)];
localPlanDir  = [localIterDir,relativePlanPath];
remotePlanDir = [remoteIterDir,relativePlanPath];
mkdir(localPlanDir);

%% write plan content file
plan=mPlanBatch(:,:,i_plan);
planFileName=[GENERAL_PLAN_FILENAME,'_p_',num2str(i_plan)];
columnPlan=plan(:);
fid = fopen([localPlanDir,'/',planFileName], 'w');
fprintf(fid,'%d ',columnPlan);
fclose(fid);

