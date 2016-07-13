fractionOfFinishedJobs=0.95;
%% initialize program
sets_global_constants()
run('get_global_constants.m')
%% set case params
caseName = 'case5'; %case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
%% build directory structure
prefix_num=1;
[fullLocalParentDir,fullRemoteParentDir,tempFilesDir,...
    GENERAL_JOB_FILENAME,job_output_filename,JOB_DIRNAME_PREFIX] = build_dirs(prefix_num,'build',caseName);
%% hermes job configuration
jobArgs = set_job_args(prefix_num);
%% outer-program parameters
N_jobs=500;
pauseDuration=60; %seconds
timeOutLimit=60*pauseDuration*48;
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
    sendJob('build_NN_db_job',funcArgs,jobArgs);
end
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
save([fullLocalParentDir,'/hermes_build_db.mat']);
%% after enough jobs finished - destroy remaining
display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
killRemainingJobs(jobArgs);
deleteUnnecessaryTempFiles(tempFilesDir);
%% extract and build database
tic
[final_db,sample_matrix,finished_idx] = extract_data(fullLocalParentDir,N_jobs,JOB_DIRNAME_PREFIX,job_output_filename,params);
toc
split_dir = '/split_data';
[split_data_loc,num_data_chunks] = splitAndSaveData(final_db,sample_matrix,fullLocalParentDir,split_dir);
save([fullLocalParentDir,'/hermes_build_db.mat'],'-regexp','^(?!(final_db|sample_matrix)$).');
% save([fullLocalParentDir,'/hermes_build_db.mat'],'-v7.3');
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