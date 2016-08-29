function jobArgs = set_job_args(prefix_num,config)
% Sets arguemnts for jobs that on the server cluster. Used when running
% locally as well, since the machanism is the same for both.
jobArgs.ncpus=1;
jobArgs.memory=config.memory_used; %in GB
jobArgs.queue='all_q'; %all_q,new_q
jobArgs.jobNamePrefix=[config.JOB_NAME_PREFIX,num2str(prefix_num)];
jobArgs.userName='gald';