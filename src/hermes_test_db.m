%% LOAD DB FILE FIRST!
% mat_file_path =  '~/mount/PSCC16_continuation/current_version/saved_runs/BDB_build_run_2016-06-02-18-04-49--case24';
% load([mat_file_path,'/hermes_build_db.mat'],'fullRemoteParentDir');
db_file_path = [fullRemoteParentDir,'/hermes_build_db.mat'];
fractionOfFinishedJobs=0.95;
%% initialize program
sets_global_constants()
run('get_global_constants.m')
%% set case params
caseName = 'case5'; %case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
%% build directory structure
prefix_num=2;
[fullLocalParentDir,fullRemoteParentDir,tempFilesDir,...
    GENERAL_JOB_FILENAME,job_output_filename,JOB_DIRNAME_PREFIX] = build_dirs(prefix_num,'test',caseName);
%% hermes job configuration
jobArgs = set_job_args(prefix_num);
%% outer-program parameters
N_jobs=240;
pauseDuration=60; %seconds
timeOutLimit=60*pauseDuration*20;
%% start by killing all current jobs
killRemainingJobs(jobArgs); 
pause(3);
for i_job=1:N_jobs
    %% build iteration dir
    relativeIterDir=['/',JOB_DIRNAME_PREFIX,num2str(i_job)];
    localIterDir=[fullLocalParentDir,relativeIterDir];
    remoteIterDir=[fullRemoteParentDir,relativeIterDir];
    mkdir(localIterDir);
    %% prepere job and send it to cluster
    display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),' - Sending job num ',num2str(i_job), '...']);
    [argContentFilename] = perpareJobDir(localIterDir,i_job,GENERAL_JOB_FILENAME,params);
    [funcArgs,jobArgs]= perpareJobArgs(i_job,localIterDir,argContentFilename,remoteIterDir,jobArgs);
    %this is a hack - we refer all jobs to the same file.
    %fullLocalParentDir is loaded from previous run
    funcArgs.argContentFilename = db_file_path; % this will be the 2nd argument to test_UC_NN_error_job
    sendJob('test_UC_NN_error_job',funcArgs,jobArgs);
end
save([fullLocalParentDir,'/hermes_test_db.mat']);
mostFinished=0;
jobsWaitingToFinish=N_jobs;
display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),' - ','Waiting for at least ', ...
    num2str(ceil(fractionOfFinishedJobs*jobsWaitingToFinish)),' of ',num2str(jobsWaitingToFinish),' jobs...']);
timeOutCounter=0;
numFinishedFiles=0;
%% wait for enough jobs to finish
while((~mostFinished && timeOutCounter<=timeOutLimit))
    pause(pauseDuration);
    [mostFinished,numFinishedFiles]= ...
        checkIfMostFinished(fractionOfFinishedJobs,jobsWaitingToFinish,fullLocalParentDir,job_output_filename);
    timeOutCounter=timeOutCounter+pauseDuration;
end
%% after enough jobs finished - destroy remaining
display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
killRemainingJobs(jobArgs);
deleteUnnecessaryTempFiles(tempFilesDir);
%% extract and build database

% mat_test_file_path =  '~/mount/PSCC16_continuation/current_version/saved_runs/BDB_test_run_2016-04-14-15-19-37--case24/hermes_test_db.mat';
% load(mat_test_file_path,'fullLocalParentDir','N_jobs','JOB_DIRNAME_PREFIX','job_output_filename','params');
% params.N_samples_test = 15;
KNN=params.KNN;
%%
tic
[final_db_test,finished_idx,uc_samples] = extract_data_test(fullLocalParentDir,N_jobs,JOB_DIRNAME_PREFIX,job_output_filename,params);
toc
save([fullLocalParentDir,'/hermes_test_db.mat']);
%%
plot_stats