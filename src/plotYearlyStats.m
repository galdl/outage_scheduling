function [] = plotYearlyStats(yearlyStats)
%% initialize all statistics vectors
dynamicObjectiveVec=zeros(1,length(yearlyStats));
dynamicObjectiveStdVec=zeros(1,length(yearlyStats));
deviationCostVec=zeros(1,length(yearlyStats));
deviationTimeVec=zeros(1,length(yearlyStats));
%for the scatter plot
dynamicEscalateLevelVecVec=zeros(length(yearlyStats),4);

contingenciesHappenedVec=zeros(1,length(yearlyStats));
dynamicWindSpilledVec=zeros(1,length(yearlyStats));
dynamicLoadLostVec=zeros(1,length(yearlyStats));

originalObjectiveVec=zeros(1,length(yearlyStats));
originalEscalateLevelVec=zeros(1,length(yearlyStats));
originalWindSpilledVec=zeros(1,length(yearlyStats));
originalLoadLostVec=zeros(1,length(yearlyStats));

%% gather all statistics from the different ratios and all samples
for month = 1:length(yearlyStats)
    monthlyStats = yearlyStats{month};
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
    
    for day = 1:length(monthlyStats)
        dynamicObjective=[dynamicObjective,monthlyStats{day}.dynamicObjective];
        deviationCost=[deviationCost,monthlyStats{day}.deviationCost];
        deviationTime=[deviationTime,monthlyStats{day}.deviationTime];
        dynamicEscalateLevelVec=[dynamicEscalateLevelVec,monthlyStats{day}.dynamicEscalateLevelVec];
        contingenciesHappened=[contingenciesHappened,monthlyStats{day}.contingenciesHappened];
        dynamicWindSpilled=[dynamicWindSpilled,monthlyStats{day}.dynamicWindSpilled];
        dynamicLoadLost=[dynamicLoadLost,monthlyStats{day}.dynamicLoadLost];
        
        originalObjective=[originalObjective;monthlyStats{day}.originalObjective];
        originalEscalateLevel=[originalEscalateLevel;monthlyStats{day}.originalEscalateLevel];
        originalWindSpilled=[originalWindSpilled;monthlyStats{day}.originalWindSpilled];
        originalLoadLost=[originalLoadLost;monthlyStats{day}.originalLoadLost];
    end
    
    dynamicObjectiveVec(month)=mean(dynamicObjective);
    dynamicObjectiveStdVec(month)=std(dynamicObjective);
    deviationCostVec(month)=mean(deviationCost);
    deviationTimeVec(month)=mean(deviationTime);
    
    dynamicEscalateLevelVecVec(month,1)=sum(sum(dynamicEscalateLevelVec==0));
    dynamicEscalateLevelVecVec(month,2)=sum(sum(dynamicEscalateLevelVec==1));
    dynamicEscalateLevelVecVec(month,3)=sum(sum(dynamicEscalateLevelVec==2));
    dynamicEscalateLevelVecVec(month,4)=sum(sum(dynamicEscalateLevelVec==3));
    
    
    
    contingenciesHappenedVec(month)=mean(contingenciesHappened);
    dynamicWindSpilledVec(month)=mean(dynamicWindSpilled);
    dynamicLoadLostVec(month)=mean(dynamicLoadLost);
    
    originalObjectiveVec(month)=mean(originalObjective);
    originalEscalateLevelVec(month)=mean(originalEscalateLevel);
    originalWindSpilledVec(month)=mean(originalWindSpilled);
    originalLoadLostVec(month)=mean(originalLoadLost);
end

%% plot all
monthVector=1:12;

figure();
subplot(331);
plot(monthVector,dynamicObjectiveVec);
xlabel('std as a fraction of mean');
hold on;
plot(monthVector,originalObjectiveVec);
legend('dynamicObjective','originalObjective');
hold off;
title(['Wind variance effect on 24-hour operation costs - averaged over ',num2str(length(dynamicObjective)),' trails']);





subplot(332);
plot(monthVector,deviationCostVec);
legend('deviationCost');

subplot(333);
plot(monthVector,deviationTimeVec);
legend('deviationTime');

subplot(334);
[stdX,locY]=meshgrid(monthVector,1:4);
dynamicEscalateLevelVecVec=dynamicEscalateLevelVecVec';
scatterSize=30*dynamicEscalateLevelVecVec/max(max(dynamicEscalateLevelVecVec))+0.01;
scatter(stdX(:),locY(:),scatterSize(:));
% plot(monthVector,dynamicEscalateLevelVecVec);
% hold on;
% plot(monthVector,originalEscalateLevelVec);
% legend('dynamicEscalateLevelVec','originalEscalateLevelVec');
% hold off;

subplot(335);
plot(monthVector,contingenciesHappenedVec);
legend('contingenciesHappened');

subplot(336);
plot(monthVector,dynamicWindSpilledVec);
hold on;
plot(monthVector,originalWindSpilledVec);
legend('dynamicWindSpilled','originalWindSpilled');
hold off;

subplot(337);
plot(monthVector,dynamicLoadLostVec);
hold on;
plot(monthVector,originalLoadLostVec);
legend('dynamicLoadLost','originalLoadLost');
hold off;

subplot(338);
plot(monthVector,dynamicObjectiveStdVec);
legend('dynamicObjectiveStd');
