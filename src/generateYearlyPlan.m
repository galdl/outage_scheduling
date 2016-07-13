function yearlyPlan = generateYearlyPlan(tempP,epsilon)

yearlyPlan=zeros(size(tempP));
indexMat=reshape(1:length(tempP(:)),size(tempP));
numOfMaintenances=min(size(tempP));
for i_maintenance=1:numOfMaintenances
    normalizedP1Vec=calcNormalizedP1Vec(tempP,epsilon,1);
    drawnIndices = mnrnd(1,normalizedP1Vec,1);
    %         indices = arrayfun(@(j) find(drawnIndices(j,:)) , 1:size(drawnIndices,1));
    index=find(drawnIndices);
    if(index~=length(normalizedP1Vec))
        [r,c]=ind2sub(size(tempP),index);
        [innerIndex_r,innerIndex_c]=ind2sub(size(yearlyPlan),indexMat(index));
        yearlyPlan(innerIndex_r,innerIndex_c)=1;
        
        tempP(r,:)=[];
        tempP(:,c)=[];
        indexMat(r,:)=[];
        indexMat(:,c)=[];
    end
end