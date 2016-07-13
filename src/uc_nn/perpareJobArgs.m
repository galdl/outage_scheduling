function [funcArgs,jobArgs] = perpareJobArgs(i_job,localIterDir,argContentFilename,remoteIterDir,jobArgs)
funcArgs.remoteIterDir=remoteIterDir;
funcArgs.argContentFilename=argContentFilename;
funcArgs.localIterDir=localIterDir;
jobArgs.jobName=buildJobName(i_job,jobArgs.jobNamePrefix);
