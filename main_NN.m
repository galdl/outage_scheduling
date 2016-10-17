%% UC_NN progarm
warning off
set_global_constants()
run('get_global_constants.m')
program_name =  'uc_nn'; %'outage_scheduling','uc_nn'
run_mode = 'compare'; %'optimize','compare' (also referred to as 'train' and 'evaluate' in the code)
prefix_num = 4;
caseName = 'case96'; %case5,case9,case14,case24,case96
program_path = strsplit(mfilename('fullpath'),'/');
program_matlab_name = program_path{end};
%% Load UC_NN database path
db_file_path = '';
if(~strcmp(run_mode,'optimize'))
    %% When evaluating - load DB file first!
    % mat_file_path =  '~/mount/PSCC16_continuation/current_version/saved_runs/BDB_build_run_2016-06-02-18-04-49--case24';
    % load([mat_file_path,'/hermes_build_db.mat'],'fullRemoteParentDir');
    %db_file_path = [dirs.full_localRun_dir,'/',config.SAVE_FILENAME];
    db_file_path = [dirs.full_remoteRun_dir,'/optimize_saved_run'];
end
%% Initialize program
[jobArgs,params,dirs,config] = ...
    initialize_program(relativePath,prefix_num,caseName,program_name,run_mode);
%% meta-optimizer iterations
pauseDuration=30; %seconds
timeOutLimit=60*60*48;
%% start by killing all current jobs
killRemainingJobs(jobArgs);
pause(3);
N_jobs_NN = params.N_jobs_NN;
max_concurrent_jobs = params.N_jobs_NN;
i_job = 1;
save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME]);
%%
max_iterations = 5e3;
while(i_job<max_iterations)
    if(get_current_running_jobs(jobArgs) < N_jobs_NN)
        params.job_category = params.categories(1+mod(i_job-1,length(params.categories)));
        prepare_and_send_job(i_job,dirs,program_matlab_name,db_file_path,jobArgs,params,config);
        i_job = i_job+1;
        display(['current running jobs: ',num2str(get_current_running_jobs(jobArgs))]);
        pause(3);
    else
        pause(pauseDuration);
    end
end
% mostFinished=0;
% jobsWaitingToFinish=N_jobs_NN;
% display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),'-',program_matlab_name,' - ','Waiting for at least ', ...
%     num2str(ceil(config.fraction_of_finished_jobs*jobsWaitingToFinish)),' of ',num2str(jobsWaitingToFinish),' jobs...']);
% timeOutCounter=0;
% numFinishedFiles=0;
%% wait for enough jobs to finish
% while((~mostFinished && timeOutCounter<=timeOutLimit))
%     pause(pauseDuration);
%     [mostFinished,numFinishedFiles]= ...
%         checkIfMostFinished(config.fraction_of_finished_jobs,jobsWaitingToFinish,dirs.full_localRun_dir,dirs.job_output_filename);
%     timeOutCounter=timeOutCounter+pauseDuration;
% end
% save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME]);
%% after enough jobs finished - destroy remaining
% display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
killRemainingJobs(jobArgs);
deleteUnnecessaryTempFiles(config.local_tempFiles_dir);
if(strcmp(config.run_mode,'optimize'))
    %% extract and build database
    tic
    [final_db,sample_matrix,finished_idx] = extract_data(dirs.full_localRun_dir,dirs.job_dirname_prefix,dirs.job_output_filename,params);
    toc
    [split_data_loc,num_data_chunks] = split_and_save_data(final_db,sample_matrix,dirs.full_localRun_dir,config.SPLIT_DIR);
    % saves all but the variables in the regex
    save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME],'-regexp','^(?!(final_db|sample_matrix)$).');
else
    %% extract and build database
    % mat_test_file_path =  '~/mount/PSCC16_continuation/current_version/saved_runs/BDB_test_run_2016-04-14-15-19-37--case24/hermes_test_db.mat';
    % load(mat_test_file_path,'fullLocalParentDir','N_jobs','JOB_DIRNAME_PREFIX','dirs.job_output_filename','params');
    % params.N_samples_test = 15;
    KNN=params.KNN;
    %%
    tic
    [final_db_test,finished_idx,uc_samples] = extract_data_test(dirs.full_localRun_dir,config.JOB_DIRNAME_PREFIX,dirs.job_output_filename,params);
    toc
    [split_data_loc,num_data_chunks] = split_and_save_data_compare(final_db_test,uc_samples,dirs.full_localRun_dir,config.SPLIT_DIR);
    % saves all but the variables in the regex
    save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME],'-regexp','^(?!(final_db_test|uc_samples)$).');
%     save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME,'_post_extraction'], '-v7.3');
    %%
    plot_stats
end
%% test how feasible NN solutions are
% N_test = 1000;
% feasbility_test = zeros(N_test,1);
% mod_interval=50;
% state = getInitialState(params);
% isStochastic=1;
% for j=1:N_test
%     if(mod(j,mod_interval)==1)
%         display(['Test iteration ',num2str(j),' out of ',num2str(N_test)]);
%         tic
%     end
%     uc_sample.windScenario = generateWind(1:params.horizon,params,state,isStochastic);
%     uc_sample.demandScenario = generateDemand(1:params.horizon,params,state,isStochastic);
%     params.windScenario = uc_sample.windScenario;
%     params.demandScenario = uc_sample.demandScenario;
%     NN_uc_sample = get_uc_NN(final_db,sample_matrix,uc_sample);
%     feasbility_test(j) = check_uc_feasibility(NN_uc_sample.onoff,params);
%     if(mod(j,mod_interval)==0)
%         toc
%     end
% end
% mean(feasbility_test)