function    [funcArgs,jobArgs]=perpareJobArgs(i_plan,i_month,i_CE,localPlanDir,mPlanFilename,remotePlanDir,jobArgs,caseName)
funcArgs.i_month=i_month;
funcArgs.remotePlanDir=remotePlanDir;
funcArgs.mPlanFilename=mPlanFilename;
funcArgs.caseName=caseName;
funcArgs.localPlanDir=localPlanDir;
jobArgs.jobName=buildJobName(i_CE,i_plan,i_month,jobArgs.jobNamePrefix);
