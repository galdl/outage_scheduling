savedFileName='./saved_runs/CE/CE_run_2015-10-07-02-32-33/bestPlanVecFile_partial.mat';
load(savedFileName);
caseName='case5';
tempP=am_getProblemParamsForCase(caseName);
dynamicSamplesPerDay=4;


%% routine
strEvalType='rout';
plansToEvaluate=cell(1,1);
plansToEvaluate{1}=generateRoutinePlan(params)
evaluatePlans(plansToEvaluate,strEvalType,caseName,savedFileName,dynamicSamplesPerDay);
% %% oldest-first
% oldestNumPlans=1;
% strEvalType='oldest';
% plansToEvaluate=cell(oldestNumPlans,1);
% plansToEvaluate{1}=generateMaintainOldestPlan(params);
% evaluatePlans(plansToEvaluate,strEvalType,caseName,savedFileName);
% % 
% %% null-plan
% nullNumPlans=1;
% strEvalType='null';
% plansToEvaluate=cell(nullNumPlans,1);
% plansToEvaluate{1}=zeros(params.nl,params.numOfMonths);
% evaluatePlans(plansToEvaluate,strEvalType,caseName,savedFileName);

% %% thresold
% thresholdNumPlans=1;
% strEvalType='thresh';
% plansToEvaluate=cell(thresholdNumPlans,1);
% plansToEvaluate{1}=generateThresholdPlan(params);
% evaluatePlans(plansToEvaluate,strEvalType,caseName,savedFileName);
%% best plan
% generate numOfPlansPerIter vec
% N_iter=i_CE-1;
% N_plans_max=jobsPerIteration/params.numOfMonths;
% N_plans=zeros(length(N_iter),1);
% iterIdx=[];
% allIterationPlanValues=[];
% innerPlanIdx=[];
% for i_iter=1:N_iter
%     N_plans(i_iter)=length(bestPlanVec{i_iter});
%     iterIdx=[iterIdx,i_iter*ones(1,N_plans(i_iter))]; %a vector of indices of iterations of plans, 
%     %so we can know which plan belongs to which iteration
%     allIterationPlanValues=[allIterationPlanValues,cell2mat(bestPlanVec{i_iter}(4,:))];
%     innerPlanIdx=[innerPlanIdx,1:N_plans(i_iter)];
% end
% % get best N_best plans
% N_best=1;
% [bestVals,bestIdx]=sort(allIterationPlanValues);
% bestPlanValues=bestVals(1:N_best);
% iterOfBest=iterIdx(bestIdx(1:N_best));
% innerIdxOfBest=innerPlanIdx(bestIdx(1:N_best)); %makes sense these are the 
% %first indices since each iteration is already sorted
% bestPlans=cell(N_best,1);
% for i_best=1:N_best
%     bestPlans{i_best}=bestPlanVec{iterOfBest(i_best)}{1,innerIdxOfBest(i_best)};
% end

strEvalType='bestl';
plansToEvaluate=cell(1,1);
plansToEvaluate{1}=bestPlanVec{N_iter}{1,1};
% evaluatePlans(plansToEvaluate,strEvalType,caseName,savedFileName);