function mPlanBatch = applyConstraints(unconstrainedMPlanBatch)

mPlanBatch=unconstrainedMPlanBatch;
%% limit maintenance to two assets per month
maxMaintenancesPerMonth=1;
mPlanBatchSize=size(unconstrainedMPlanBatch);
for i_plan=1:mPlanBatchSize(3)
	currPlan=unconstrainedMPlanBatch(:,:,i_plan);

	for i_month=1:mPlanBatchSize(2)
		if(sum(currPlan(:,i_month))>maxMaintenancesPerMonth)
			idx=find(currPlan(:,i_month));
			subIdx=randsample(idx,maxMaintenancesPerMonth);
			newVec=zeros(mPlanBatchSize(1),1);
			newVec(subIdx)=1;
			mPlanBatch(:,i_month,i_plan)=newVec;
		end
	end	
end
	
%% limit single specific maintenance to once per year
maxSpecificMaintenancesPerYear=1;
mPlanBatchSize=size(unconstrainedMPlanBatch);
for i_plan=1:mPlanBatchSize(3)
	currPlan=mPlanBatch(:,:,i_plan);

	for i_line=1:mPlanBatchSize(1)
		if(sum(currPlan(i_line,:))>maxSpecificMaintenancesPerYear)
			idx=find(currPlan(i_line,:));
			subIdx=randsample(idx,maxSpecificMaintenancesPerYear);
			newVec=zeros(1,mPlanBatchSize(2));
			newVec(subIdx)=1;
			mPlanBatch(i_line,:,i_plan)=newVec;
		end
	end	
end