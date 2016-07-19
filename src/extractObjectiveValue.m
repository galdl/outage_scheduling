function [planValues,monthlyCost,contingenciesFrequency,planValuesVec,lostLoad] = extractObjectiveValue(iterationDir,N_plans,params,config)
planValues = zeros(N_plans,1);
planValuesVec=nan(N_plans,params.numOfMonths,params.dynamicSamplesPerDay);
contingenciesFrequency = nan(params.nl,params.numOfMonths,N_plans); %frequencies of cont. per month, per plan
monthlyCost = nan(N_plans,params.numOfMonths); %average cost per month, per plan
lostLoad=zeros(N_plans,1);
numOfMonthsPerPlan =  zeros(N_plans,1);
for i_plan=1:N_plans
    %     lsPath=[iterationDir,'/',PLAN_DIRNAME_PREFIX,num2str(i_plan),'/*.mat'];
    lsPath=[iterationDir,'/',config.PLAN_DIRNAME_PREFIX,num2str(i_plan)];
    monthsFolder=what(lsPath);
    out_idx = cellfun('length', regexp(monthsFolder.mat, config.JOB_OUTPUT_FILENAME)) > 0;
    numOfExistingMonths = sum(out_idx);
    %      [~,numLinesStr]=   unix(['ls ',(lsPath),' | wc -l']);
    numOfMonthsPerPlan(i_plan)=numOfExistingMonths;
    if(numOfMonthsPerPlan(i_plan)<params.numOfMonths) %if not all months finished, dont use that data
        planValues(i_plan)=nan;
        lostLoad(i_plan)=nan;
    else
        monthFileList=monthsFolder.mat(out_idx);
        for i_matFile=1:length(monthFileList)
            dynamicObjective=[];
            originalObjective = [];
            dynamicLoadLost=[];
            contingenciesHappened=[];
            monthFilename = monthFileList{i_matFile};
            monthlyStatsStruct=load([monthsFolder.path,'/',monthFilename]);
            parsedMonthNum = str2num(monthFilename(end-length('.mat'))); 
    
            monthlyStats=monthlyStatsStruct.monthlyStats; %dont ask...
            for day = 1:length(monthlyStats)
                %each monthlyStats{day}.dynamicObjective is a vector of 24
                %scalars 'dynamicObjective' values, which are the 
                %post-realization actual costs of the day
                dynamicObjective=[dynamicObjective,monthlyStats{day}.dynamicObjective];
                %each monthlyStats{day}.originalObjective is a scalar, the value of the 
                %pre-realization estimated cost of the day, based on the UC
                originalObjective=[originalObjective,monthlyStats{day}.originalObjective];
                dynamicLoadLost=[dynamicLoadLost,monthlyStats{day}.dynamicLoadLost];
                contingenciesHappened=[contingenciesHappened,monthlyStats{day}.contingenciesHappened];
                if(day==1) %save all first day objective values for std analysis
                    planValuesVec(i_plan,parsedMonthNum,:)=monthlyStats{day}.dynamicObjective;
                end
            end
            contingenciesFrequency(:,parsedMonthNum,i_plan) = mean(contingenciesHappened,2);
            %at the end, we care about the deviations and extra costs, not
            %the base costs (which the system operator doesn't pay anyhow).
            %We expect this number to be positive, obviously (redispatch
            %always causes more expanses. curtailment can be smaller though, but it small)
            planValues(i_plan) = planValues(i_plan) + mean(dynamicObjective) - mean(originalObjective);
                        lostLoad(i_plan) = lostLoad(i_plan) + mean(dynamicLoadLost);
            monthlyCost(i_plan,parsedMonthNum) = mean(dynamicObjective) - mean(originalObjective); 
        end
        %normalize if partial year (not all month jobs returend)
        planValues(i_plan)=planValues(i_plan)*(params.numOfMonths/length(monthFileList));
    end
end
