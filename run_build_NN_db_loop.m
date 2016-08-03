%% load UC_NN optimize parameters file
load '~/mount/PSCC16_continuation/current_version/output/UC_NN/saved_runs/Optimize/optimize_run_2016-07-24-12-27-30--1--case24/optimize_saved_run';

%% send the loop jobs - use the last job arguments, but change the job name (they all do the same thing)
N_loop_jobs = 3;
for i_job = 1:N_loop_jobs
    jobArgs.jobName = [jobArgs.jobNamePrefix,'_loop_',num2str(i_job)];
    sendJob('build_NN_db_loop_job',funcArgs,jobArgs,config);
end

% killRemainingJobs(jobArgs);
