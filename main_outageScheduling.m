%% Outage_scheduling progarm
warning off
set_global_constants()
run('get_global_constants.m')
program_name =  'outage_scheduling'; %'outage_scheduling','uc_nn'
run_mode = 'compare'; %'optimize','compare' (also referred to as 'train' and 'evaluate' in the code)
prefix_num = 1;
caseName = 'case96'; %case5,case9,case14,case24
program_path = strsplit(mfilename('fullpath'),'/');
program_matlab_name = program_path{end};
%% Initialize program
[jobArgs,params,dirs,config] = ...
    initialize_program(relativePath,prefix_num,caseName,program_name,run_mode);
%% Load UC_NN database path
%% case 5
if(strcmp(caseName,'case5'))
    db_file_path = ['~/PSCC16_continuation/current_version/output/UC_NN/saved_runs/Optimize/optimize_run_2016-07-19-19-00-27--1--case5',...
        '/optimize_saved_run'];
end
%% case 24
if(strcmp(caseName,'case24'))
    if(strcmp(params.n1_str,'n1'))
        db_file_path = ['~/PSCC16_continuation/current_version/output/UC_NN/saved_runs/Optimize/optimize_run_2016-08-24-12-33-44--4--case24',...
            '/optimize_saved_run'];
    else
        db_file_path = ['~/PSCC16_continuation/current_version/output/UC_NN/saved_runs/Optimize/optimize_run_2016-10-25-14-45-05--4--case24',...
            '/optimize_saved_run'];
    end
end
%% case 96
if(strcmp(caseName,'case96'))
    db_file_path = ['~/PSCC16_continuation/current_version/output/UC_NN/saved_runs/Optimize/optimize_run_2016-08-11-15-14-03--1--case96',...
        '/optimize_saved_run'];
end
%% common initialization to optimize and compare
epsilon=0.005;
planSize=[params.nl,params.numOfMonths];
n = planSize(1)*planSize(2);
p = 0.5*ones(n,1);
pauseDuration=60; %seconds
killRemainingJobs(jobArgs);
pause(3);
if(strcmp(run_mode,'optimize'))
    
    %% meta-optimizer initialized
    timeOutLimit=60*pauseDuration*1;
    rho = 0.2;
    N_plans=params.N_plans;
    maxConcurrentJobs=17*12;
    jobsPerIteration=N_plans*params.numOfMonths;
    maxConcurrentPlans=ceil(maxConcurrentJobs/params.numOfMonths);
    N_CE_inner=ceil(jobsPerIteration/maxConcurrentJobs);
    
    solutionStats=zeros(params.N_CE,4);
    bestPlanVec = cell(params.N_CE,1);
    bestPlanVecTemp = cell(9,N_plans,params.N_CE);
    i_CE=1;
    
    %% generate DA scenarios that are shared across all iterations and plans
    params_with_DA_scenarios = cell(params.numOfMonths,1);
    for i_month=1:params.numOfMonths
        params_with_DA_scenarios{i_month} = generate_shared_DA_scenarios(params,i_month);
    end    
    %% optimization iterations - each w/ multiple solutions (m.plans)
    while(i_CE<=params.N_CE && ~convergenceObtained(p,epsilon))
        try
            %% build iteration dir
            relativeIterDir=['/iteration_',num2str(i_CE)];
            localIterDir=[dirs.full_localRun_dir,relativeIterDir];
            remoteIterDir=[dirs.full_remoteRun_dir,relativeIterDir];
            mkdir(localIterDir);
            
            %% generate current solutions
            X = generatePlans(reshape(p,planSize),N_plans,epsilon,params);
            mPlanBatch=reshape(X,planSize(1),planSize(2),N_plans);
            %% prepere jobs and send all of them to cluster
            previousIterationsJobs=0;
            for i_CE_inner=1:N_CE_inner
                innerPlanRange=(i_CE_inner-1)*maxConcurrentPlans+1:min(i_CE_inner*maxConcurrentPlans,N_plans);
                for i_plan=innerPlanRange
                    [localPlanDir,remotePlanDir]=...
                        perparePlanDir(localIterDir,remoteIterDir,i_plan,config.PLAN_DIRNAME_PREFIX);
                    for i_month=1:params.numOfMonths
                        [argContentFilename] = write_job_contents(localPlanDir,remotePlanDir,i_month,mPlanBatch(:,:,i_plan),db_file_path,params_with_DA_scenarios{i_month},config);
                        [funcArgs,jobArgs]=prepere_for_sendJob(i_plan,i_month,i_CE,remotePlanDir,jobArgs,argContentFilename);
                        sendJob('simulateMonth_job',funcArgs,jobArgs,config);
                    end
                end
                mostFinished=0;
                c=1;
                jobsWaitingToFinish=length(innerPlanRange)*params.numOfMonths;
                display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),' - ','Iteration ',num2str(i_CE),' (inner iteration ',num2str(i_CE_inner),')',...
                    ':waiting for at least ',num2str(ceil(config.fraction_of_finished_jobs*jobsWaitingToFinish)),' of ',num2str(jobsWaitingToFinish),' jobs...']);
                timeOutCounter=0;
                
                while(~mostFinished && timeOutCounter<=timeOutLimit)
                    pause(pauseDuration);
                    %             display([num2str(numFinishedFiles),' finished after ',num2str(pauseDuration*c),' seconds.']);
                    %             display(['Wating for at least ',num2str(ceil(fractionOfFinishedJobs*jobsPerIteration)),' of ',...
                    %num2str(jobsPerIteration),' jobs...']);
                    [mostFinished,numFinishedFiles]=checkIfMostFinished(config.fraction_of_finished_jobs,jobsWaitingToFinish,...
                        previousIterationsJobs,localIterDir,dirs.job_output_filename);
                    c=c+1;
                    timeOutCounter=timeOutCounter+pauseDuration;
                end
                previousIterationsJobs=numFinishedFiles;
                display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
                killRemainingJobs(jobArgs);
            end
            deleteUnnecessaryTempFiles(config.local_tempFiles_dir);
            [planValues,success_rate_values,monthlyCost,contingenciesFrequency,planValuesVec,lostLoad,relative_nn_std_values] = ...
                extractObjectiveValue(localIterDir,N_plans,params,config);
            %         S=planValues(~isnan(planValues));
            %% calibrate the barrier function according to planValues
            if(i_CE==1)
                barrier_struct = calibrate_barrier(planValues);
            end
            %% calculate objective values
            K=2;
            lostLoad_values = 1- lostLoad/max(lostLoad);
            success_rate_barrier_values = K*success_rate_barrier(success_rate_values,barrier_struct,params.alpha,i_CE);
            lostLoad_barrier_values = K*success_rate_barrier(lostLoad_values,barrier_struct,params.alpha,i_CE);

            objective_values = planValues + success_rate_barrier_values + lostLoad_barrier_values;
            [S_sorted_includingNan,I] = sort(objective_values);
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
                bestPlanVecTemp{2,j_plan,i_CE}  = monthlyCost(I(j_plan),:,1);
                bestPlanVecTemp{3,j_plan,i_CE}  = contingenciesFrequency(:,:,I(j_plan));
                bestPlanVecTemp{4,j_plan,i_CE}  = planValues(I(j_plan));
                bestPlanVecTemp{5,j_plan,i_CE}  = planValuesVec(I(j_plan),:,:);
                bestPlanVecTemp{6,j_plan,i_CE}  = lostLoad(I(j_plan));
                bestPlanVecTemp{7,j_plan,i_CE}  = success_rate_barrier_values(I(j_plan));
                bestPlanVecTemp{8,j_plan,i_CE}  = success_rate_values(I(j_plan));
                bestPlanVecTemp{9,j_plan,i_CE}  = relative_nn_std_values{I(j_plan)};
            end
            bestPlanVec{i_CE}=bestPlanVecTemp(:,1:length(S_sorted),i_CE);
            p'
            entropy = wentropy(p,'shannon')
            
            %         p=p*pertubation; %so it wont converge too fast
            %analyze results and save
            % timeStr=datestr(datetime('now'));
            % save(['./saved_runs/Hermes/yearlyStats_case24_',timeStr,'.mat'],'yearlyStats')
            
        catch ME
            warning(['Problem using',program_matlab_name,'for iteration = ' num2str(i_CE)]);
            msgString = getReport(ME);
            display(msgString);
            if(isempty(mPlanBatch) | (sum(isnan(mPlanBatch))>0))
                mPlanBatch=round(rand(planSize(1),planSize(2),N_plans));
            end
        end
        i_CE=i_CE+1;
        save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME,'_partial']);
    end
    %% plot barrier values
    plot_barrier_values
    %% plot objective statistics
    bestPlanVec(i_CE:end)=[];
    solutionStats=solutionStats(1:i_CE-1,:);
    titles={'min','mean','median','mean of percentile'};
    figure;
    for i_plot=1:4
        subplot(2,2,i_plot);
        plot(solutionStats(:,i_plot));
        title(titles{i_plot});
    end
    save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME]);
else %compare
    %% generate solutions for assesment
    generate_new_plans = 1;
    if(generate_new_plans)
        N_plans=10;
        X = generatePlans(reshape(p,planSize),N_plans,epsilon,params);
        mPlanBatch=reshape(X,planSize(1),planSize(2),N_plans);
        mPlanBatch(:,:,1) = zeros(size(mPlanBatch(:,:,1)));
% %DEBUG: (remove afterwards)
%         for k=1:N_plans
%             mPlanBatch(:,:,k) = zeros(size(mPlanBatch(:,:,1)));
%         end
        save('mPlanBatch96','mPlanBatch','N_plans'); %assuming root dir is an agreed upon, regular dir
    else
        %% load mPlanBatch
        %     load('/Users/galdalal/mount/PSCC16_continuation/current_version/output/Outage_scheduling/saved_runs/Compare/compare_run_2016-08-12-18-59-54--1--case24/compare_saved_run','mPlanBatch');
        %     new_plans = [2,3,4,6,7,9:19];
        %     mPlanBatch(:,:,new_plans) = mPlanBatch_new(:,:,new_plans);
        load('mPlanBatch96');
    end
    %% send assessment jobs
    params_with_DA_scenarios = cell(params.numOfMonths,1);
    for i_plan=1:N_plans
        [localPlanDir,remotePlanDir] = perparePlanDir(dirs.full_localRun_dir,dirs.full_remoteRun_dir,i_plan,config.PLAN_DIRNAME_PREFIX);
        for i_month=1:params.numOfMonths
            if(i_plan == 1) % generate only once, for the scenarios to be shared across plans
                params_with_DA_scenarios{i_month} = generate_shared_DA_scenarios(params,i_month);
            end
            [argContentFilename] = write_job_contents(localPlanDir,remotePlanDir,i_month,mPlanBatch(:,:,i_plan),db_file_path,params_with_DA_scenarios{i_month},config);
            [funcArgs,jobArgs]=prepere_for_sendJob(i_plan,i_month,1,remotePlanDir,jobArgs,argContentFilename);
            sendJob('simulateMonth_job',funcArgs,jobArgs,config);
        end
    end
    %% wait for them to finish
    mostFinished=0; timeOutCounter=0;
    jobsWaitingToFinish=size(mPlanBatch,3)*params.numOfMonths;
    display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),'  - waiting for  ',num2str(jobsWaitingToFinish),' jobs...'])
    save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME]);
    while(~mostFinished)
        pause(pauseDuration);
        [mostFinished,numFinishedFiles]=checkIfMostFinished(1,jobsWaitingToFinish,0,dirs.full_localRun_dir,dirs.job_output_filename);
        timeOutCounter = timeOutCounter + pauseDuration;
    end
    display([num2str(timeOutCounter),' seconds passed. ','Num of finished files: ',num2str(numFinishedFiles)]);
    deleteUnnecessaryTempFiles(config.local_tempFiles_dir);
    %% extract their values
    [planValues,success_rate_values,monthlyCost,contingenciesFrequency,planValuesVec,lostLoad,relative_nn_std_values,monthly_success_rate_values,monthly_lost_load,monthlyCost_DA,monthly_lost_load_DA] = ...
        extractObjectiveValue(dirs.full_localRun_dir,N_plans,params,config);
    save([dirs.full_localRun_dir,'/',config.SAVE_FILENAME,'_post_extraction']);
    plot_outage_compare
end
