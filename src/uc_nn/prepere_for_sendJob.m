function [funcArgs,jobArgs] = prepere_for_sendJob(i_job,argContentFilename,remoteIterDir,jobArgs)
% info for the usage of sendJob - function arguments
jobArgs.jobName=buildJobName(i_job,jobArgs.jobNamePrefix);
funcArgs.argContentFilename=argContentFilename;
% funcArgs.localIterDir=localIterDir;
funcArgs.remote_job_run_dir=remoteIterDir;
