%% Outage_scheduling progarm
%% initialize program
program_path = strsplit(mfilename('fullpath'),'/');
program_name = program_path(end);
addpath([relativePath,'/src/outage_scheduling']); %some functions are shared
%between NN and outageSechduling, so remove the path of the opposite program
rmpath([relativePath,'/src/uc_nn']); %some functions are shared
%between NN and outageSechduling, so just remove the path of the opposite program
warning off
configuration
set_global_constants()
run('get_global_constants.m')
prefix_num = 2;
%% Load UC_NN database path
db_file_path = '';
%% cluster job configuration
jobArgs = set_job_args(prefix_num,config);
%% set test case params
caseName = 'case5'; %case5,case9,case14,case24
params=get_testCase_params(caseName,config);
%% build directory structure
[job_dirname_prefix,full_localRun_dir,job_data_filename,job_output_filename...
    ,full_remoteRun_dir,config] = build_dirs(prefix_num,config,caseName);
%% meta-optimizer initialized
pauseDuration=60; %seconds
timeOutLimit=60*pauseDuration*20;
epsilon=0.005;
rho = 0.2;
planSize=[params.nl,params.numOfMonths];
n = planSize(1)*planSize(2);
% p = (2/planSize(1))*ones(n,1);
p = 0.5*ones(n,1);
N_plans=params.N_plans;
maxConcurrentJobs=50;
jobsPerIteration=N_plans*params.numOfMonths;
maxConcurrentPlans=ceil(maxConcurrentJobs/params.numOfMonths);
N_CE_inner=ceil(jobsPerIteration/maxConcurrentJobs);

solutionStats=zeros(params.N_CE,4);
bestPlanVec = cell(params.N_CE,1);
bestPlanVecTemp = cell(6,N_plans,params.N_CE);
i_CE=1;

killRemainingJobs(jobArgs);
pause(3);
%% optimization iterations - each w/ multiple solutions (m.plans)
while(i_CE<=params.N_CE && ~convergenceObtained(p,epsilon))
    try
        %% build iteration dir
        relativeIterDir=['/iteration_',num2str(i_CE)];
        localIterDir=[full_localRun_dir,relativeIterDir];
        remoteIterDir=[full_remoteRun_dir,relativeIterDir];
        mkdir(localIterDir);
        
        %% build directory structure
        X = generatePlans(reshape(p,planSize),N_plans,epsilon);
        %% choose current solutions
        mPlanBatch=reshape(X,planSize(1),planSize(2),N_plans);
        %% prepere jobs and send all of them to cluster
        previousIterationsJobs=0;
        for i_CE_inner=1:N_CE_inner
            innerPlanRange=(i_CE_inner-1)*maxConcurrentPlans+1:min(i_CE_inner*maxConcurrentPlans,N_plans);
            for i_plan=innerPlanRange
                [localPlanDir,remotePlanDir]=...
                    perparePlanDir(localIterDir,remoteIterDir,i_plan,job_data_filename,config.PLAN_DIRNAME_PREFIX);
                for i_month=1:params.numOfMonths
                    [argContentFilename] = write_job_contents(localPlanDir,i_month,mPlanBatch(:,:,i_plan),db_file_path,params,config);
                    [funcArgs,jobArgs]=prepere_for_sendJob(i_plan,i_month,i_CE,remotePlanDir,jobArgs,argContentFilename);
                    sendJob('simulateMonth_job',funcArgs,jobArgs,config);
                end
            end
            mostFinished=0;
            c=1;
            jobsWaitingToFinish=length(innerPlanRange)*params.numOfMonths;
            display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),' - ','Iteration ',num2str(i_CE),' (inner iteration ',num2str(i_CE_inner),')',...
                ':waiting for at least ',num2str(ceil(fractionOfFinishedJobs*jobsWaitingToFinish)),' of ',num2str(jobsWaitingToFinish),' jobs...']);
            timeOutCounter=0;
            
            while(~mostFinished && timeOutCounter<=timeOutLimit)
                pause(pauseDuration);
                %             display([num2str(numFinishedFiles),' finished after ',num2str(pauseDuration*c),' seconds.']);
                %             display(['Wating for at least ',num2str(ceil(fractionOfFinishedJobs*jobsPerIteration)),' of ',...
                %num2str(jobsPerIteration),' jobs...']);
                [mostFinished,numFinishedFiles]=checkIfMostFinished(fractionOfFinishedJobs,jobsWaitingToFinish,previousIterationsJobs,localIterDir);
                c=c+1;
                timeOutCounter=timeOutCounter+pauseDuration;
            end
            previousIterationsJobs=numFinishedFiles;
            display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
            killRemainingJobs(jobArgs);
        end
        deleteUnnecessaryTempFiles(tempFilesDir);
        [planValues,monthlyCost,contingenciesFrequency,planValuesVec,lostLoad] = ...
            extractObjectiveValue(localIterDir,N_plans,config.PLAN_DIRNAME_PREFIX,params);
        %         S=planValues(~isnan(planValues));
        [S_sorted_includingNan,I] = sort(planValues);
        S_sorted=S_sorted_includingNan(~isnan(S_sorted_includingNan));
        %% save min,mean,median,max, and best plans along iterations
        solutionStats(i_CE,1) = S_sorted(1);
        mean(S_sorted)
        solutionStats(i_CE,2) = mean(S_sorted);
        solutionStats(i_CE,3) = S_sorted(floor(length(S_sorted)/2));
        
        %         topI = I(floor(length(S_sorted)*(1-rho)):end);
        topI = I(1:ceil(length(I)*rho));
        p = sum(X(:,topI),2)/length(topI);
        solutionStats(i_CE,4)=mean(planValues(topI));
        for j_plan = 1:length(S_sorted)
            bestPlanVecTemp{1,j_plan,i_CE}  = mPlanBatch(:,:,I(j_plan));
            bestPlanVecTemp{2,j_plan,i_CE}  = monthlyCost(I(j_plan),:);
            bestPlanVecTemp{3,j_plan,i_CE}  = contingenciesFrequency(:,:,I(j_plan));
            bestPlanVecTemp{4,j_plan,i_CE}  = planValues(I(j_plan));
            bestPlanVecTemp{5,j_plan,i_CE}  = planValuesVec(I(j_plan),:,:);
            bestPlanVecTemp{6,j_plan,i_CE}  = lostLoad(I(j_plan));
            
        end
        bestPlanVec{i_CE}=bestPlanVecTemp(:,1:length(S_sorted),i_CE);
        p'
        entropy = wentropy(p,'shannon')
        
        %         p=p*pertubation; %so it wont converge too fast
        %analyze results and save
        % timeStr=datestr(datetime('now'));
        % save(['./saved_runs/Hermes/yearlyStats_case24_',timeStr,'.mat'],'yearlyStats')
        
    catch ME
        warning(['Problem using',program_name,'for iteration = ' num2str(i_CE)]);
        msgString = getReport(ME);
        display(msgString);
        if(isempty(mPlanBatch) | (sum(isnan(mPlanBatch))>0))
            mPlanBatch=round(rand(planSize(1),planSize(2),N_plans));
        end
    end
    i_CE=i_CE+1;
    save([full_localRun_dir,'/bestPlanVecFile_partial.mat']);
end
bestPlanVec(i_CE:end)=[];
solutionStats=solutionStats(1:i_CE-1,:);
titles={'min','mean','median','mean of percentile'};
figure;
for i_plot=1:4
    subplot(2,2,i_plot);
    plot(solutionStats(:,i_plot));
    title(titles{i_plot});
end
save([full_localRun_dir,'/bestPlanVecFile.mat']);
