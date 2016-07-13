%% generate fig 1 - convergence plot
figure;
hold on;
for i_plot=1:4
    plot(solutionStats(:,i_plot));
end
legend({'min','mean','median','mean of percentile'});
hold off;
%% generate numOfPlansPerIter vec
N_iter=i_CE-1;
N_plans_max=jobsPerIteration/params.numOfMonths;
N_plans=zeros(length(N_iter),1);
iterIdx=[];
allIterationPlanValues=[];
innerPlanIdx=[];
for i_iter=1:N_iter
    N_plans(i_iter)=length(bestPlanVec{i_iter});
    iterIdx=[iterIdx,i_iter*ones(1,N_plans(i_iter))]; %a vector of indices of iterations of plans, 
    %so we can know which plan belongs to which iteration
    allIterationPlanValues=[allIterationPlanValues,cell2mat(bestPlanVec{i_iter}(4,:))];
    innerPlanIdx=[innerPlanIdx,1:N_plans(i_iter)];
end
%% get best N_best plans
N_best=5;
[bestVals,bestIdx]=sort(allIterationPlanValues);
bestPlanValues=bestVals(1:N_best);
iterOfBest=iterIdx(bestIdx(1:N_best));
innerIdxOfBest=innerPlanIdx(bestIdx(1:N_best)); %makes sense these are the 
%first indices since each iteration is already sorted
bestPlans=cell(N_best,1);
for i_best=1:N_best
    bestPlans{i_best}=bestPlanVec{iterOfBest(i_best)}{1,innerIdxOfBest(i_best)};
end
%% save params and bestPlans and run evaluation
savedFileName=['./saved_runs/bestPlansFile_',datestr(clock,'yyyy-mm-dd-HH-MM-SS'),'.mat'];
save(savedFileName,'bestPlans','params');
evaluatePlans(N_best,caseName,savedFileName);