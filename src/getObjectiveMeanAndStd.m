function [objectiveMean,objectiveStd]=getObjectiveMeanAndStd(fileToLoad)
load(fileToLoad);
bestPlanVec(i_CE:end)=[];
N_iter=length(bestPlanVec);
allCosts=cell(N_iter,1);
objectiveStd=zeros(N_iter,1);
objectiveMean=zeros(N_iter,1);
for i_iter=1:N_iter
    %         currentHandle=subplot(3,3,i_iter);
     allCosts{i_iter}=cell2mat(bestPlanVec{i_iter}(4,:));
    objectiveStd(i_iter)=std(allCosts{i_iter});
    objectiveMean(i_iter)=mean(allCosts{i_iter});
end
