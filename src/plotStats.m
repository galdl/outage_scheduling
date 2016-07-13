function [] = plotStats(statsForDifferentRatios,muStdRatioVec)
%% initialize all statistics vectors
dynamicObjectiveVec=zeros(1,length(statsForDifferentRatios));
dynamicObjectiveStdVec=zeros(1,length(statsForDifferentRatios));
deviationCostVec=zeros(1,length(statsForDifferentRatios));
deviationTimeVec=zeros(1,length(statsForDifferentRatios));
%for the scatter plot
dynamicEscalateLevelVecVec=zeros(length(statsForDifferentRatios),4);

contingenciesHappenedVec=zeros(1,length(statsForDifferentRatios));
dynamicWindSpilledVec=zeros(1,length(statsForDifferentRatios));
dynamicLoadLostVec=zeros(1,length(statsForDifferentRatios));

originalObjectiveVec=zeros(1,length(statsForDifferentRatios));
originalEscalateLevelVec=zeros(1,length(statsForDifferentRatios));
originalWindSpilledVec=zeros(1,length(statsForDifferentRatios));
originalLoadLostVec=zeros(1,length(statsForDifferentRatios));

%% gather all statistics from the different ratios and all samples
for i_r = 1:length(statsForDifferentRatios)
    sequenceStats = statsForDifferentRatios{i_r};
    dynamicObjective=[];
    deviationCost=[];
    deviationTime=[];
    dynamicEscalateLevelVec=[];
    contingenciesHappened=[];
    dynamicWindSpilled=[];
    dynamicLoadLost=[];
    
    originalObjective=[];
    originalEscalateLevel=[];
    originalWindSpilled=[];
    originalLoadLost=[];
    
    for day = 1:length(sequenceStats)
        dynamicObjective=[dynamicObjective,sequenceStats{day}.dynamicObjective];
        deviationCost=[deviationCost,sequenceStats{day}.deviationCost];
        deviationTime=[deviationTime,sequenceStats{day}.deviationTime];
        dynamicEscalateLevelVec=[dynamicEscalateLevelVec,sequenceStats{day}.dynamicEscalateLevelVec];
        contingenciesHappened=[contingenciesHappened,sequenceStats{day}.contingenciesHappened];
        dynamicWindSpilled=[dynamicWindSpilled,sequenceStats{day}.dynamicWindSpilled];
        dynamicLoadLost=[dynamicLoadLost,sequenceStats{day}.dynamicLoadLost];
        
        originalObjective=[originalObjective;sequenceStats{day}.originalObjective];
        originalEscalateLevel=[originalEscalateLevel;sequenceStats{day}.originalEscalateLevel];
        originalWindSpilled=[originalWindSpilled;sequenceStats{day}.originalWindSpilled];
        originalLoadLost=[originalLoadLost;sequenceStats{day}.originalLoadLost];
    end
    
    dynamicObjectiveVec(i_r)=mean(dynamicObjective);
    dynamicObjectiveStdVec(i_r)=std(dynamicObjective);
    deviationCostVec(i_r)=mean(deviationCost);
    deviationTimeVec(i_r)=mean(deviationTime);
    
    dynamicEscalateLevelVecVec(i_r,1)=sum(sum(dynamicEscalateLevelVec==0));
    dynamicEscalateLevelVecVec(i_r,2)=sum(sum(dynamicEscalateLevelVec==1));
    dynamicEscalateLevelVecVec(i_r,3)=sum(sum(dynamicEscalateLevelVec==2));
    dynamicEscalateLevelVecVec(i_r,4)=sum(sum(dynamicEscalateLevelVec==3));
    
    
    
    contingenciesHappenedVec(i_r)=mean(contingenciesHappened);
    dynamicWindSpilledVec(i_r)=mean(dynamicWindSpilled);
    dynamicLoadLostVec(i_r)=mean(dynamicLoadLost);
    
    originalObjectiveVec(i_r)=mean(originalObjective);
    originalEscalateLevelVec(i_r)=mean(originalEscalateLevel);
    originalWindSpilledVec(i_r)=mean(originalWindSpilled);
    originalLoadLostVec(i_r)=mean(originalLoadLost);
end

%% plot all


figure();
subplot(331);
plot(muStdRatioVec,dynamicObjectiveVec);
xlabel('std as a fraction of mean');
hold on;
plot(muStdRatioVec,originalObjectiveVec);
legend('dynamicObjective','originalObjective');
hold off;
title(['Wind variance effect on 24-hour operation costs - averaged over ',num2str(length(dynamicObjective)),' trails']);





subplot(332);
plot(muStdRatioVec,deviationCostVec);
legend('deviationCost');

subplot(333);
plot(muStdRatioVec,deviationTimeVec);
legend('deviationTime');

subplot(334);
[stdX,locY]=meshgrid(muStdRatioVec,1:4);
dynamicEscalateLevelVecVec=dynamicEscalateLevelVecVec';
scatterSize=30*dynamicEscalateLevelVecVec/max(max(dynamicEscalateLevelVecVec))+0.01;
scatter(stdX(:),locY(:),scatterSize(:));
% plot(muStdRatioVec,dynamicEscalateLevelVecVec);
% hold on;
% plot(muStdRatioVec,originalEscalateLevelVec);
% legend('dynamicEscalateLevelVec','originalEscalateLevelVec');
% hold off;

subplot(335);
plot(muStdRatioVec,contingenciesHappenedVec);
legend('contingenciesHappened');

subplot(336);
plot(muStdRatioVec,dynamicWindSpilledVec);
hold on;
plot(muStdRatioVec,originalWindSpilledVec);
legend('dynamicWindSpilled','originalWindSpilled');
hold off;

subplot(337);
plot(muStdRatioVec,dynamicLoadLostVec);
hold on;
plot(muStdRatioVec,originalLoadLostVec);
legend('dynamicLoadLost','originalLoadLost');
hold off;

subplot(338);
plot(muStdRatioVec,dynamicObjectiveStdVec);
legend('dynamicObjectiveStd');
