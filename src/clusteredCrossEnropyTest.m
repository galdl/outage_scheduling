% addHermesPaths

fractionOfFinishedJobs=0.7;
%% set case params
caseName='case5';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);

%% create initial dir
LOCAL_DIR_ROOT  = '~/mount/';
REMOTE_DIR_ROOT = '/u/gald/Asset_Management/matlab/';
RELATIVE_DIR    = 'Matlab/current_workspace/saved_runs/CE/';
PLAN_DIRNAME_PREFIX = 'plan_';
parentDir=['CE_run_',datestr(clock,'yyyy-mm-dd-HH-MM-SS')];
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
jobArgs.jobNamePrefix='sim_m';
jobArgs.userName='gald';
N_CE=20;

rho = 0.3;
planSize=[params.nl,params.numOfMonths];
n = planSize(1)*planSize(2);
p = (2/planSize(1))*ones(n,1);
N_plans=300;
pauseDuration=60;
% mPlanBatch=round(rand(planSize(1),planSize(2),N_plans));
jobsPerIteration=N_plans*params.numOfMonths;
% pertubation=0.95;
solutionStats=zeros(N_CE,4);
bestPlanVec=zeros([planSize,N_CE]);
optimalPlan = round(rand(planSize));
%% optimization iterations - each w/ multiple solutions (m.plans)
for i_CE=1:N_CE
    try
        X = (rand(n,N_plans)<repmat(p,1,N_plans)); %ralizations of bernoulli w.p p
        %% choose current solutions
        unconstrainedMPlanBatch=reshape(X,planSize(1),planSize(2),N_plans);
        mPlanBatch = unconstrainedMPlanBatch;
%                 mPlanBatch = applyConstraints(unconstrainedMPlanBatch);
        X=reshape(mPlanBatch,n,N_plans);
        %% build iteration dir
        relativeIterDir=['/iteration_',num2str(i_CE)];
        localIterDir=[fullLocalParentDir,relativeIterDir];
        remoteIterDir=[fullRemoteParentDir,relativeIterDir];
        mkdir(localIterDir);
        
        %% build directory structure
        %% prepere jobs and send all of them to cluster
        for i_plan=1:N_plans
%             [localPlanDir,mPlanFilename,remotePlanDir]=...
%                 perparePlanDir(localIterDir,remoteIterDir,i_plan,mPlanBatch,GENERAL_PLAN_FILENAME,PLAN_DIRNAME_PREFIX);
%             
%             for i_month=1:params.numOfMonths
%                 [funcArgs,jobArgs]=...
%                     perpareJobArgs(i_plan,i_month,i_CE,localPlanDir,mPlanFilename,remotePlanDir,jobArgs,caseName);
%                 sendJob('simulateMonth',funcArgs,jobArgs);
%             end
%             
%         end
%         mostFinished=0;
%         c=1;
%         numFinishedFiles=0;
%         display(['Iteraion ',num2str(i_CE),':wating for at least ',num2str(ceil(fractionOfFinishedJobs*jobsPerIteration)),' of ',num2str(jobsPerIteration),' jobs...']);
% 
%         while(~mostFinished)
%             pause(pauseDuration);
% %             display([num2str(numFinishedFiles),' finished after ',num2str(pauseDuration*c),' seconds.']);
% %             display(['Wating for at least ',num2str(ceil(fractionOfFinishedJobs*jobsPerIteration)),' of ',num2str(jobsPerIteration),' jobs...']);
%             [mostFinished,numFinishedFiles]=checkIfMostFinished(fractionOfFinishedJobs,N_plans,localIterDir,params);
%             c=c+1;
%         end
% 
%         killRemainingJobs(jobArgs);
%         deleteUnnecessaryTempFiles(tempFilesDir);
%         [planValues] = extractObjectiveValue(localIterDir,N_plans,PLAN_DIRNAME_PREFIX,params);

%         S=planValues(~isnan(planValues));
        S=zeros(length(N_plans),1);
        for i_plan=1:N_plans
            S(i_plan)=sum(abs(mPlanBatch(:,:,i_plan)-optimalPlan));
        end
        [S_sorted,I] = sort(S);
        
        %% save min,mean,median,max, and best plans along iterations
        solutionStats(i_CE,1) = S_sorted(1);
        S_sorted(1)
        solutionStats(i_CE,2) = mean(S_sorted); 
        solutionStats(i_CE,3) = S_sorted(floor(length(S_sorted)/2)); 
        solutionStats(i_CE,4) = S_sorted(end); 
        bestPlanVec(:,:,i_CE) = mPlanBatch(:,:,I(1));
%         topI = I(floor(length(S_sorted)*(1-rho)):end);
        topI = I(1:floor(length(S_sorted)*rho));
        p = sum(X(:,topI),2)/length(topI);
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
end
titles={'min','mean','median','max'};
figure;
for i_plot=1:4
    subplot(2,2,i_plot);
    plot(solutionStats(:,i_plot));
    title(titles{i_plot});
end