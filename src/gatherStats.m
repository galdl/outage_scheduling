N_iter=i_CE-1;
close all;
N_plans_max=jobsPerIteration/params.numOfMonths;
N_plans=zeros(length(N_iter),1);
for i_iter=1:N_iter
    N_plans(i_iter)=length(bestPlanVec{i_iter});
end
%% gather frequency of repair matrix
mat=zeros([planSize,N_iter]);
for i_iter=1:N_iter
    for i_plan=1:N_plans(i_iter)
        if(~isempty(bestPlanVec{i_iter}{1,i_plan}))
            mat(:,:,i_iter)=mat(:,:,i_iter)+bestPlanVec{i_iter}{1,i_plan};
        end
    end
%     mat(:,:,i_iter)=mat(:,:,i_iter)./repmat(sum(mat(:,:,i_iter),1),planSize(1),1);
end
mat

%% plot histogram of solution costs along iterations, their mean and their std 
%% - originally for identical plans at each iteration for senity check run
figure;
objectiveStd=zeros(N_iter,1);
objectiveMean=zeros(N_iter,1);
xHandles=zeros(N_iter,1);
yHandles=cell(N_iter,1);
maxXHandle=0;
maxYHandle=0;
allCosts=cell(N_iter,1);
for i_iter=1:N_iter
    xHandles(i_iter)=subplot(ceil(sqrt(N_iter)),ceil(sqrt(N_iter)),i_iter);
    %         currentHandle=subplot(3,3,i_iter);
    title(['Iteration ',num2str(i_iter)]);
    allCostsTmp=cell2mat(bestPlanVec{i_iter}(4,:));
    allCosts{i_iter}=allCostsTmp(~isnan(allCostsTmp));
    hist(allCosts{i_iter});
    objectiveStd(i_iter)=std(allCosts{i_iter});
    objectiveMean(i_iter)=mean(allCosts{i_iter});
end
[objectiveMean,objectiveStd]
figure;
errorbar(objectiveMean,objectiveStd,'rx');
title(['Mean and std of different solutions. Each iteration (x axis) has the same plan, sampled ',num2str(N_plans_max),' times']);

linkaxes(xHandles,'xy');

% figure;
% plot(objectiveStd);
% title('std of solution costs along iterations');
% figure;
% plot(objectiveMean);
% title('mean of solution costs along iterations');

%% plot mean and std's of the same N_plan plans, along the different samples
%% - originally for identical plans at each iteration for senity check run
planCostMean=cell(N_iter,1);
planCostStd=cell(N_iter,1);
handles=zeros(N_iter,1);

figure;
for i_iter=1:N_iter
    planCostMean{i_iter}=zeros(N_plans(i_iter),1);
    planCostStd{i_iter}=zeros(N_plans(i_iter),1);
    handles(i_iter)=subplot(ceil(sqrt(N_iter)),ceil(sqrt(N_iter)),i_iter);
    
    for i_plan=1:N_plans(i_iter)
        planCostMean{i_iter}(i_plan)=mean(bestPlanVec{i_iter}{5,i_plan});
        planCostStd{i_iter}(i_plan)=std(bestPlanVec{i_iter}{5,i_plan});
    end
    errorbar(planCostMean{i_iter},planCostStd{i_iter},'rx');
    title(['Mean and std of different solutions. Each iteration (x axis) has the same plan, sampled ',num2str(params.dynamicSamplesPerDay),' times']);
    
end

linkaxes(handles,'xy');



%% filter out plans that weren't fully assessed at all months - obselete now since done in the code itself
%% CONCLUSION: no mean doesnt change, std is 3 times larger when not filtering
% monthlyCosts=nan(N_plans_max,params.numOfMonths,N_iter);
% objectiveCostFilteredMean=zeros(N_iter,1);
% objectiveCostFilteredStd=zeros(N_iter,1);
% monthlyCostsFilteredCell=cell(N_iter,1);
% for i_iter=1:N_iter
%     idxToRemove=[];
%     for i_plan=1:N_plans(i_iter)
%         if(~isempty(bestPlanVec{i_iter}{2,i_plan}) && (sum(~isnan(bestPlanVec{i_iter}{2,i_plan}))>0))
%             monthlyCosts(i_plan,:,i_iter)=bestPlanVec{i_iter}{2,i_plan};
%             monthlyCosts(i_plan,:,i_iter)
%             if((sum(isnan(monthlyCosts(i_plan,:,i_iter)))>0))
%                 idxToRemove=[idxToRemove,i_plan];
%             end
%         else
%             idxToRemove=[idxToRemove,i_plan];
%             idxToRemove
%         end
%     end
%     monthlyCostsFiltered=monthlyCosts(:,:,i_iter);
%     monthlyCostsFiltered(idxToRemove,:)=[];
%     monthlyCostsFilteredCell{i_iter}=monthlyCostsFiltered;
%     objectiveCostFiltered=sum(monthlyCostsFiltered,2);
%     objectiveCostFilteredMean(i_iter)=mean(objectiveCostFiltered);
%     objectiveCostFilteredStd(i_iter)=std(objectiveCostFiltered);
% end
% [objectiveMean,objectiveStd]
% [objectiveCostFilteredMean,objectiveCostFilteredStd]
% figure;
% errorbar(objectiveCostFilteredMean,objectiveCostFilteredStd,'rx');
% title(['Mean and std of different solutions. Each iteration (x axis) has the same plan, sampled ',num2str(N_plans_max),' times']);

%% a small experiment
% au=zeros(5,1);
% as=zeros(5,1);
% for j=1:5
%     a=j*rand(200,1); % play with the number of samples here
%     au(j)=mean(a);
%     as(j)=std(a);
% end
% figure;
% errorbar(au,as,'rx');

%% reduce the number of plans
%% - originally for identical plans at each iteration for senity check run
bestPlanVecReduced=cell(N_iter,1);
newNumofPlans=1;
for i_iter=1:N_iter
    sparseIndices=randsample(N_plans(i_iter),newNumofPlans);
    bestPlanVecReduced{i_iter}=bestPlanVec{i_iter}(4,sparseIndices);
end
figure;
objectiveStdReduced=zeros(N_iter,1);
objectiveMeanReduced=zeros(N_iter,1);
for i_iter=1:N_iter
    allCosts{i_iter}=cell2mat(bestPlanVecReduced{i_iter});
    objectiveStd(i_iter)=std(allCosts{i_iter});
    objectiveMean(i_iter)=mean(allCosts{i_iter});
end
[objectiveMean,objectiveStd]
figure;
errorbar(objectiveMean,objectiveStd,'rx');
title(['Mean and std of different solutions. Each iteration (x axis) has the same plan, sampled ',num2str(N_plans_max),' times']);

linkaxes(xHandles,'xy');
%squeeze(cell2mat(bestPlanVec{1}(5,1)))