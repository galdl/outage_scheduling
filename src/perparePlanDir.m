function  [localPlanDir,remotePlanDir]=perparePlanDir(localIterDir,remoteIterDir,i_plan,PLAN_DIRNAME_PREFIX)
%% create plan dir - applied for the first month of each plan
relativePlanPath=['/',PLAN_DIRNAME_PREFIX,num2str(i_plan)];
localPlanDir  = [localIterDir,relativePlanPath];
remotePlanDir = [remoteIterDir,relativePlanPath];
if(isempty(dir(localPlanDir)))
    mkdir(localPlanDir);
end
