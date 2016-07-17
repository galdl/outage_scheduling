function    [funcArgs,jobArgs]=prepere_for_sendJob(i_plan,i_month,i_CE,remotePlanDir,jobArgs,argContentFilename)
funcArgs.i_month=i_month;
funcArgs.remote_job_run_dir=remotePlanDir;
jobArgs.jobName=buildJobName(i_CE,i_plan,i_month,jobArgs.jobNamePrefix);
funcArgs.argContentFilename=argContentFilename;
