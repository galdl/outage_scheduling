function current_running_jobs = get_current_running_jobs(jobArgs)
%% get num of current running jobs
jobNamePrefix = jobArgs.jobNamePrefix;
userName      = jobArgs.userName;

cmd =['qstat -u ',userName,' | grep ', jobNamePrefix ,'|wc -l'];

[~,running_jobs_str]=sendSSHCommand(cmd);
if(length(running_jobs_str)>10)
    if(isnan(str2double(running_jobs_str(end-3))))
        running_jobs_str = running_jobs_str(end-2:end);
    else
        running_jobs_str = running_jobs_str(end-3:end);
    end
end
current_running_jobs=str2double(running_jobs_str);
