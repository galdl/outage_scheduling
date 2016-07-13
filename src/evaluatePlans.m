%% load according to file name and run tests on pre-found maintenance plans
function []=evaluatePlans(plansToEvaluate,strEvalType,caseName,savedFileName,dynamicSamplesPerDay)
load(savedFileName);
params.myopicUCForecast=0; %use full forecast for evaluation
fractionOfFinishedJobs=0.95;
params.dynamicSamplesPerDay=dynamicSamplesPerDay;
%% set case params
% caseName='case5';%case5,case9,case14,case24
% params=am_getProblemParamsForCase(caseName);

%% create initial dir
LOCAL_DIR_ROOT  = '~/mount/';
REMOTE_DIR_ROOT = '/u/gald/Asset_Management/matlab/';
RELATIVE_DIR    = 'Matlab/current_workspace/saved_runs/CE/';
PLAN_DIRNAME_PREFIX = 'plan_';
parentDir=['EVALUATION_',strEvalType,'_',datestr(clock,'yyyy-mm-dd-HH-MM-SS')];
% parentDir=['CE_run_',datestr(clock,'yyyy-mm-dd-H,datestr(clock,'yyyy-mm-dd-HH-MM-SS')];H-MM-SS')];
fullLocalParentDir  = [LOCAL_DIR_ROOT,RELATIVE_DIR,parentDir];
fullRemoteParentDir = [REMOTE_DIR_ROOT,RELATIVE_DIR,parentDir];
tempFilesDir=[fullLocalParentDir,'/','tempJobFiles'];
if(isempty(dir(fullLocalParentDir)))
    mkdir(fullLocalParentDir);
    mkdir(fullLocalParentDir,'output');
    mkdir(fullLocalParentDir,'error');
    mkdir(tempFilesDir);
end
GENERAL_PLAN_FILENAME='plan_content';
%% perform one-step authentication
% ssh-copy-id can be obtained for mac by running:
% curl -L https://raw.githubusercontent.com/beautifulcode/ssh-copy-id-for-OSX/master/install.sh | sh

% unix('ssh-keygen');
% unix('/usr/local/bin/ssh-copy-id -i ~/.ssh/id_rsa.pub gald@hermes.technion.ac.il');

%% meta-optimizer initialized

jobArgs.ncpus=1;
jobArgs.memory=2; %in GB
jobArgs.queue='all_q';
jobArgs.jobNamePrefix=['j',strEvalType];
jobArgs.userName='gald';
% N_best=length(planToEvaluate);
epsilon=0.005;
rho = 0.12;
planSize=[params.nl,params.numOfMonths];
n = planSize(1)*planSize(2);
% p = (2/planSize(1))*ones(n,1);
% p = 0.5*ones(n,1);
N_CE=length(plansToEvaluate);
N_plans=75;
pauseDuration=60;
timeOutLimit=pauseDuration*60*1;
% mPlanBatch=round(rand(planSize(1),planSize(2),N_plans));
jobsPerIteration=N_plans*params.numOfMonths;
% pertubation=0.95;
solutionStats=zeros(N_CE,4);
bestPlanVec = cell(N_CE,1);
bestPlanVecTemp = cell(6,N_plans,N_CE);
killRemainingJobs(jobArgs);
pause(5);
i_CE=1;
%% optimization iterations - each w/ multiple solutions (m.plans)
while(i_CE<=N_CE)
    try
        %         X = (rand(n,N_plans)<repmat(p,1,N_plans)); %ralizations of bernoulli w.p p
%         X = generatePlans(reshape(p,planSize),N_plans,epsilon);
        currPlan=plansToEvaluate{i_CE};
        X=repmat(currPlan(:),1,N_plans);
%         mPlanBatch=reshape(X,planSize);

        %% choose current solutions
        mPlanBatch=reshape(X,planSize(1),planSize(2),N_plans);
        
        %         mPlanBatch = unconstrainedMPlanBatch;
        %                 mPlanBatch = applyConstraints(unconstrainedMPlanBatch);
        %         X2=reshape(mPlanBatch,n,N_plans);
        %% build iteration dir
        relativeIterDir=['/iteration_',num2str(i_CE)];
        localIterDir=[fullLocalParentDir,relativeIterDir];
        remoteIterDir=[fullRemoteParentDir,relativeIterDir];
        mkdir(localIterDir);
        
        %% build directory structure
        %% prepere jobs and send all of them to cluster
        for i_plan=1:N_plans
            [localPlanDir,mPlanFilename,remotePlanDir]=...
                perparePlanDir(localIterDir,remoteIterDir,i_plan,mPlanBatch,GENERAL_PLAN_FILENAME,PLAN_DIRNAME_PREFIX);
            
            for i_month=1:params.numOfMonths
                [funcArgs,jobArgs]=...
                    perpareJobArgs(i_plan,i_month,i_CE,localPlanDir,mPlanFilename,remotePlanDir,jobArgs,caseName);
                sendJob('simulateMonth',funcArgs,jobArgs);
            end
            
        end
        mostFinished=0;
        c=1;
        numFinishedFiles=0;
        display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),' - ','Iteraion ',num2str(i_CE),...
            ':wating for at least ',num2str(ceil(fractionOfFinishedJobs*jobsPerIteration)),' of ',num2str(jobsPerIteration),' jobs...']);
        timeOutCounter=0;
        while(~mostFinished && timeOutCounter<=timeOutLimit)
            pause(pauseDuration);
            %             display([num2str(numFinishedFiles),' finished after ',num2str(pauseDuration*c),' seconds.']);
            %             display(['Wating for at least ',num2str(ceil(fractionOfFinishedJobs*jobsPerIteration)),' of ',...
            %num2str(jobsPerIteration),' jobs...']);
            [mostFinished,numFinishedFiles]=checkIfMostFinished(fractionOfFinishedJobs,N_plans,localIterDir,params);
            c=c+1;
            timeOutCounter=timeOutCounter+pauseDuration;
        end
        display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
        killRemainingJobs(jobArgs);
        deleteUnnecessaryTempFiles(tempFilesDir);
      [planValues,monthlyCost,contingenciesFrequency,planValuesVec] = ...
        extractObjectiveValue(localIterDir,N_plans,PLAN_DIRNAME_PREFIX,params);
%         S=planValues(~isnan(planValues));
        [S_sorted_includingNan,I] = sort(planValues);
        S_sorted=S_sorted_includingNan(~isnan(S_sorted_includingNan));
        %% save min,mean,median,max, and best plans along iterations
        solutionStats(i_CE,1) = S_sorted(1);
        mean(S_sorted)
        solutionStats(i_CE,2) = mean(S_sorted);
        solutionStats(i_CE,3) = S_sorted(floor(length(S_sorted)/2));
        
%                 topI = I(floor(length(S_sorted)*(1-rho)):end);
%         topI = I(1:ceil(length(I)*rho));
%         p = sum(X(:,topI),2)/length(topI);
%         solutionStats(i_best,4)=mean(planValues(topI));
        for j_plan = 1:length(S_sorted)
            bestPlanVecTemp{1,j_plan,i_CE}  = mPlanBatch(:,:,I(j_plan));
            bestPlanVecTemp{2,j_plan,i_CE}  = monthlyCost(I(j_plan),:);
            bestPlanVecTemp{3,j_plan,i_CE}  = contingenciesFrequency(:,:,I(j_plan));
            bestPlanVecTemp{4,j_plan,i_CE}  = planValues(I(j_plan));
            bestPlanVecTemp{5,j_plan,i_CE}  = planValuesVec(I(j_plan),:,:);
            bestPlanVecTemp{6,j_plan,i_CE}  = lostLoad(I(j_plan));

        end
        bestPlanVec{i_CE}=bestPlanVecTemp(:,1:length(S_sorted),i_CE);
    
%         p
%         entropy = wentropy(p,'shannon')
        
        %         p=p*pertubation; %so it wont converge too fast
        %analyze results and save
        % timeStr=datestr(datetime('now'));
        % save(['./saved_runs/Hermes/yearlyStats_case24_',timeStr,'.mat'],'yearlyStats')
        
    catch ME
        warning(['Problem using clusteredCrossEntropy for iteration = ' num2str(i_CE)]);
        msgString = getReport(ME);
        display(msgString);
        if(isempty(mPlanBatch) | (sum(isnan(mPlanBatch))>0))
            mPlanBatch=round(rand(planSize(1),planSize(2),N_plans));
        end
    end
    i_CE=i_CE+1;
    save([fullLocalParentDir,'/bestPlanVecFile_partial.mat']);
end
bestPlanVec(i_CE:end)=[];
solutionStats=solutionStats(1:i_CE-1,:);
% titles={'min','mean','median','mean of percentile'};
% figure;
% for i_plot=1:4
%     subplot(2,2,i_plot);
%     plot(solutionStats(:,i_plot));
%     title(titles{i_plot});
% end

figure;
hold on;
for i_plot=1:4
    plot(solutionStats(:,i_plot));
end
legend({'min','mean','median','mean of percentile'});
hold off;

save([fullLocalParentDir,'/bestPlanVecFile.mat']);
