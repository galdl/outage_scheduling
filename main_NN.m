%% UC_NN progarm
warning off
set_global_constants()
run('get_global_constants.m')
program_name =  'uc_nn'; %'outage_scheduling','uc_nn' 
% run_mode = 'compare'; %'optimize','compare' (also referred to as 'train' and 'evaluate' in the code)
prefix_num = 2;
caseName = 'case24'; %case5,case9,case14,case24
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
pauseDuration=60; %seconds
timeOutLimit=60*60*48;
%% start by killing all current jobs
killRemainingJobs(jobArgs);
pause(3);
for i_job=1:params.N_jobs_NN
    %% build iteration dir
    relativeIterDir=['/',dirs.job_dirname_prefix,num2str(i_job)];
    localIterDir=[dirs.full_localRun_dir,relativeIterDir];
    remoteIterDir=[dirs.full_remoteRun_dir,relativeIterDir];
    mkdir(localIterDir);
    %% prepere job and send it to cluster
    display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),' - ',program_matlab_name,' - Sending job num ',num2str(i_job), '...']);
    [argContentFilename] = write_job_contents(localIterDir,i_job,db_file_path,params,config);
    [funcArgs,jobArgs]= prepere_for_sendJob(i_job,argContentFilename,remoteIterDir,jobArgs);
    if(strcmp(config.run_mode,'optimize'))
        sendJob('build_NN_db_job',funcArgs,jobArgs,config);
    else 
        sendJob('test_UC_NN_error_job',funcArgs,jobArgs,config);
    end
end
mostFinished=0;
jobsWaitingToFinish=params.N_jobs_NN;
display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),'-',program_matlab_name,' - ','Waiting for at least ', ...
    num2str(ceil(config.fraction_of_finished_jobs*jobsWaitingToFinish)),' of ',num2str(jobsWaitingToFinish),' jobs...']);
timeOutCounter=0;
numFinishedFiles=0;
save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME]);
%% wait for enough jobs to finish
while((~mostFinished && timeOutCounter<=timeOutLimit))
    pause(pauseDuration);
    [mostFinished,numFinishedFiles]= ...
        checkIfMostFinished(config.fraction_of_finished_jobs,jobsWaitingToFinish,dirs.full_localRun_dir,dirs.job_output_filename);
    timeOutCounter=timeOutCounter+pauseDuration;
end
save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME]);
%% after enough jobs finished - destroy remaining
display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
killRemainingJobs(jobArgs);
deleteUnnecessaryTempFiles(config.local_tempFiles_dir);
if(strcmp(config.run_mode,'optimize'))
    %% extract and build database
    tic
    [final_db,sample_matrix,finished_idx] = extract_data(dirs.full_localRun_dir,params.N_jobs_NN,dirs.job_dirname_prefix,dirs.job_output_filename,params);
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
    [final_db_test,finished_idx,uc_samples] = extract_data_test(dirs.full_localRun_dir,params.N_jobs_NN,config.JOB_DIRNAME_PREFIX,dirs.job_output_filename,params);
    toc
    save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME]);
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