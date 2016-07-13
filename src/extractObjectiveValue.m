function [planValues,monthlyCost,contingenciesFrequency,planValuesVec,lostLoad] = extractObjectiveValue(iterationDir,N_plans,PLAN_DIRNAME_PREFIX,params)
planValues = zeros(N_plans,1);
planValuesVec=nan(N_plans,params.numOfMonths,params.dynamicSamplesPerDay);
contingenciesFrequency = nan(params.nl,params.numOfMonths,N_plans); %frequencies of cont. per month, per plan
monthlyCost = nan(N_plans,params.numOfMonths); %average cost per month, per plan
lostLoad=zeros(N_plans,1);
numOfMonthsPerPlan =  zeros(N_plans,1);
for i_plan=1:N_plans
    %     lsPath=[iterationDir,'/',PLAN_DIRNAME_PREFIX,num2str(i_plan),'/*.mat'];
    lsPath=[iterationDir,'/',PLAN_DIRNAME_PREFIX,num2str(i_plan)];
    monthsFolder=what(lsPath);
    numOfExistingMonths=length(monthsFolder.mat);
    %      [~,numLinesStr]=   unix(['ls ',(lsPath),' | wc -l']);
    numOfMonthsPerPlan(i_plan)=numOfExistingMonths;
    if(numOfMonthsPerPlan(i_plan)<params.numOfMonths) %if not all months finished, dont use that data
        planValues(i_plan)=nan;
        lostLoad(i_plan)=nan;
    else
        fullFileList=what([iterationDir,'/',PLAN_DIRNAME_PREFIX,num2str(i_plan)]);
        monthFileList=fullFileList.mat;
        for i_matFile=1:length(monthFileList)
            dynamicObjective=[];
            dynamicLoadLost=[];
            contingenciesHappened=[];
            monthFilename = monthFileList{i_matFile};
            monthlyStatsStruct=load([fullFileList.path,'/',monthFilename]);
            parsedMonthNum = str2num(monthFilename(length('monthlyStats_m_')+1)); %TODO: fix magic sometime
    
            monthlyStats=monthlyStatsStruct.monthlyStats; %dont ask...
            for day = 1:length(monthlyStats)
                dynamicObjective=[dynamicObjective,monthlyStats{day}.dynamicObjective];
                dynamicLoadLost=[dynamicLoadLost,monthlyStats{day}.dynamicLoadLost];
                contingenciesHappened=[contingenciesHappened,monthlyStats{day}.contingenciesHappened];
                if(day==1) %save all first day objective values for std analysis
                    planValuesVec(i_plan,parsedMonthNum,:)=monthlyStats{day}.dynamicObjective;
                end
            end
            contingenciesFrequency(:,parsedMonthNum,i_plan) = mean(contingenciesHappened,2);
            planValues(i_plan) = planValues(i_plan) + mean(dynamicObjective);
                        lostLoad(i_plan) = lostLoad(i_plan) + mean(dynamicLoadLost);
            monthlyCost(i_plan,parsedMonthNum) = mean(dynamicObjective); 
        end
        %normalize if partial year (not all month jobs returend)
        planValues(i_plan)=planValues(i_plan)*(params.numOfMonths/length(monthFileList));
    end
end

%
% lsCmd=[iterationDir,'/',PLAN_DIRNAME_PREFIX,'*'];
% ls(lsCmd);
% %% initialize all statistics vectors
% dynamicObjectiveVec=zeros(1,length(yearlyStats));
% dynamicObjectiveStdVec=zeros(1,length(yearlyStats));
% deviationCostVec=zeros(1,length(yearlyStats));
% deviationTimeVec=zeros(1,length(yearlyStats));
% %for the scatter plot
% dynamicEscalateLevelVecVec=zeros(length(yearlyStats),4);
%
% contingenciesHappenedVec=zeros(1,length(yearlyStats));
% dynamicWindSpilledVec=zeros(1,length(yearlyStats));
% dynamicLoadLostVec=zeros(1,length(yearlyStats));
%
% originalObjectiveVec=zeros(1,length(yearlyStats));
% originalEscalateLevelVec=zeros(1,length(yearlyStats));
% originalWindSpilledVec=zeros(1,length(yearlyStats));
% originalLoadLostVec=zeros(1,length(yearlyStats));
%
% %% gather all statistics from the different ratios and all samples
% for month = 1:length(yearlyStats)
%     monthlyStats = yearlyStats{month};
%     dynamicObjective=[];
%     deviationCost=[];
%     deviationTime=[];
%     dynamicEscalateLevelVec=[];
%     contingenciesHappened=[];
%     dynamicWindSpilled=[];
%     dynamicLoadLost=[];
%
%     originalObjective=[];
%     originalEscalateLevel=[];
%     originalWindSpilled=[];
%     originalLoadLost=[];
%
%     for day = 1:length(monthlyStats)
%         dynamicObjective=[dynamicObjective,monthlyStats{day}.dynamicObjective];
%         deviationCost=[deviationCost,monthlyStats{day}.deviationCost];
%         deviationTime=[deviationTime,monthlyStats{day}.deviationTime];
%         dynamicEscalateLevelVec=[dynamicEscalateLevelVec,monthlyStats{day}.dynamicEscalateLevelVec];
%         contingenciesHappened=[contingenciesHappened,monthlyStats{day}.contingenciesHappened];
%         dynamicWindSpilled=[dynamicWindSpilled,monthlyStats{day}.dynamicWindSpilled];
%         dynamicLoadLost=[dynamicLoadLost,monthlyStats{day}.dynamicLoadLost];
%
%         originalObjective=[originalObjective;monthlyStats{day}.originalObjective];
%         originalEscalateLevel=[originalEscalateLevel;monthlyStats{day}.originalEscalateLevel];
%         originalWindSpilled=[originalWindSpilled;monthlyStats{day}.originalWindSpilled];
%         originalLoadLost=[originalLoadLost;monthlyStats{day}.originalLoadLost];
%     end
%
%     dynamicObjectiveVec(month)=mean(dynamicObjective);
%     dynamicObjectiveStdVec(month)=std(dynamicObjective);
%     deviationCostVec(month)=mean(deviationCost);
%     deviationTimeVec(month)=mean(deviationTime);
%
%     dynamicEscalateLevelVecVec(month,1)=sum(sum(dynamicEscalateLevelVec==0));
%     dynamicEscalateLevelVecVec(month,2)=sum(sum(dynamicEscalateLevelVec==1));
%     dynamicEscalateLevelVecVec(month,3)=sum(sum(dynamicEscalateLevelVec==2));
%     dynamicEscalateLevelVecVec(month,4)=sum(sum(dynamicEscalateLevelVec==3));
%
%
%
%     contingenciesHappenedVec(month)=mean(contingenciesHappened);
%     dynamicWindSpilledVec(month)=mean(dynamicWindSpilled);
%     dynamicLoadLostVec(month)=mean(dynamicLoadLost);
%
%     originalObjectiveVec(month)=mean(originalObjective);
%     originalEscalateLevelVec(month)=mean(originalEscalateLevel);
%     originalWindSpilledVec(month)=mean(originalWindSpilled);
%     originalLoadLostVec(month)=mean(originalLoadLost);
% end
%
% %% plot all
% monthVector=1:12;
%
% figure();
% subplot(331);
% plot(monthVector,dynamicObjectiveVec);
% xlabel('std as a fraction of mean');
% hold on;
% plot(monthVector,originalObjectiveVec);
% legend('dynamicObjective','originalObjective');
% hold off;
% title(['Wind variance effect on 24-hour operation costs - averaged over ',num2str(length(dynamicObjective)),' trails']);
%
%
%
%
%
% subplot(332);
% plot(monthVector,deviationCostVec);
% legend('deviationCost');
%
% subplot(333);
% plot(monthVector,deviationTimeVec);
% legend('deviationTime');
%
% subplot(334);
% [stdX,locY]=meshgrid(monthVector,1:4);
% dynamicEscalateLevelVecVec=dynamicEscalateLevelVecVec';
% scatterSize=30*dynamicEscalateLevelVecVec/max(max(dynamicEscalateLevelVecVec))+0.01;
% scatter(stdX(:),locY(:),scatterSize(:));
% % plot(monthVector,dynamicEscalateLevelVecVec);
% % hold on;
% % plot(monthVector,originalEscalateLevelVec);
% % legend('dynamicEscalateLevelVec','originalEscalateLevelVec');
% % hold off;
%
% subplot(335);
% plot(monthVector,contingenciesHappenedVec);
% legend('contingenciesHappened');
%
% subplot(336);
% plot(monthVector,dynamicWindSpilledVec);
% hold on;
% plot(monthVector,originalWindSpilledVec);
% legend('dynamicWindSpilled','originalWindSpilled');
% hold off;
%
% subplot(337);
% plot(monthVector,dynamicLoadLostVec);
% hold on;
% plot(monthVector,originalLoadLostVec);
% legend('dynamicLoadLost','originalLoadLost');
% hold off;
%
% subplot(338);
% plot(monthVector,dynamicObjectiveStdVec);
% legend('dynamicObjectiveStd');
