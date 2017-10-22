function jobArgs = set_job_args(prefix_num,config)
% Sets arguemnts for jobs that on the server cluster. Used when running
% locally as well, since the machanism is the same for both.
jobArgs.ncpus=1;
jobArgs.memory=config.memory_used; %in GB
jobArgs.queue='new_q'; %all_q,new_q
%currently switched off usage of prefix_num, due to too-long job names
% jobArgs.jobNamePrefix=[config.JOB_NAME_PREFIX,num2str(prefix_num)];
jobArgs.jobNamePrefix=config.JOB_NAME_PREFIX;
jobArgs.userName='gald';