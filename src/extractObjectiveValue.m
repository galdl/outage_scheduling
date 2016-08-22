function [planValues,success_rate_values,monthlyCost,contingenciesFrequency,planValuesVec,lostLoad,relative_nn_std_values,monthly_success_rate_values,monthly_lost_load,monthlyCost_DA,monthly_lost_load_DA]...
    = extractObjectiveValue(iterationDir,N_plans,params,config)
planValues = zeros(N_plans,1);
success_rate_values = zeros(N_plans,1);
monthly_success_rate_values = zeros(N_plans,params.numOfMonths,2);
monthly_lost_load = zeros(N_plans,params.numOfMonths,2);

monthly_lost_load_DA = zeros(N_plans,params.numOfMonths,2);
monthlyCost_DA = nan(N_plans,params.numOfMonths,2); %average cost per month, per plan. third dimension: mean and std
relative_nn_std_values = cell(N_plans,1);

planValuesVec=nan(N_plans,params.numOfMonths,params.dynamicSamplesPerDay);
contingenciesFrequency = nan(params.nl,params.numOfMonths,N_plans); %frequencies of cont. per month, per plan
monthlyCost = nan(N_plans,params.numOfMonths,2); %average cost per month, per plan. third dimension: mean and std
lostLoad=zeros(N_plans,1);
numOfMonthsPerPlan =  zeros(N_plans,1);
for i_plan=1:N_plans
    try
        %     lsPath=[iterationDir,'/',PLAN_DIRNAME_PREFIX,num2str(i_plan),'/*.mat'];
        lsPath=[iterationDir,'/',config.PLAN_DIRNAME_PREFIX,num2str(i_plan)];
        monthsFolder=what(lsPath);
        out_idx = cellfun('length', regexp(monthsFolder.mat, config.JOB_OUTPUT_FILENAME)) > 0;
        numOfExistingMonths = sum(out_idx);
        %      [~,numLinesStr]=   unix(['ls ',(lsPath),' | wc -l']);
        numOfMonthsPerPlan(i_plan)=numOfExistingMonths;
        if(numOfMonthsPerPlan(i_plan)<round(0.75*params.numOfMonths)) %if not almost all months finished, dont use that data
            planValues(i_plan)=nan;
            lostLoad(i_plan)=nan;
        else
            monthFileList=monthsFolder.mat(out_idx);
            relative_nn_std_per_plan=[];
            
            for i_matFile=1:length(monthFileList)
                dynamicObjective=[];
                success_rate = [];
                originalObjective = [];
                originalLoadLost=[];
                dynamicLoadLost=[];
                
                contingenciesHappened=[];
                monthFilename = monthFileList{i_matFile};
                monthlyStatsStruct=load([monthsFolder.path,'/',monthFilename]);
                parsedMonthNum = str2num(monthFilename(end-length('.mat')-1:end-length('.mat')));  %for double-digit months
                if(isempty(parsedMonthNum))
                    parsedMonthNum = str2num(monthFilename(end-length('.mat'))); %for single-digit months
                end
                
                monthlyStats=monthlyStatsStruct.monthlyStats; %dont ask...
                for day = 1:length(monthlyStats)
                    %each monthlyStats{day}.dynamicObjective is a vector of 24
                    %scalars 'dynamicObjective' values, which are the
                    %post-realization actual costs of the day
                    dynamicObjective=[dynamicObjective,monthlyStats{day}.dynamicObjective];
                    success_rate = [success_rate,monthlyStats{day}.success_rate];
                    %each monthlyStats{day}.originalObjective is a scalar, the value of the
                    %pre-realization estimated cost of the day, based on the UC
                    originalObjective=[originalObjective,monthlyStats{day}.originalObjective];
                    dynamicLoadLost=[dynamicLoadLost,monthlyStats{day}.dynamicLoadLost];
                    originalLoadLost=[originalLoadLost,monthlyStats{day}.originalLoadLost];

                    relative_nn_std_per_plan=[relative_nn_std_per_plan,monthlyStats{day}.relative_nn_std];
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
                planValues(i_plan) = planValues(i_plan) + mean(dynamicObjective); %each summation is a mean daily cost
                lostLoad(i_plan) = lostLoad(i_plan) + mean(dynamicLoadLost);
                monthlyCost(i_plan,parsedMonthNum,1) = mean(dynamicObjective - dynamicLoadLost*params.VOLL);
                monthlyCost(i_plan,parsedMonthNum,2) = std(dynamicObjective - dynamicLoadLost*params.VOLL);
                
                monthlyCost_DA(i_plan,parsedMonthNum,1) = mean(originalObjective - originalLoadLost*params.VOLL);
                monthlyCost_DA(i_plan,parsedMonthNum,2) = std(originalObjective - originalLoadLost*params.VOLL);

                                
                monthly_success_rate_values(i_plan,parsedMonthNum,1) = mean(success_rate);
                monthly_success_rate_values(i_plan,parsedMonthNum,2) = std(success_rate);
                
                monthly_lost_load(i_plan,parsedMonthNum,1) = mean(dynamicLoadLost);
                monthly_lost_load(i_plan,parsedMonthNum,2) = std(dynamicLoadLost);
                
                monthly_lost_load_DA(i_plan,parsedMonthNum,1) = mean(originalLoadLost);
                monthly_lost_load_DA(i_plan,parsedMonthNum,2) = std(originalLoadLost);                
                
                success_rate_values(i_plan) = success_rate_values(i_plan) + mean(success_rate);
                %             inspect_success_rate
                relative_nn_std_values{i_plan} = [relative_nn_std_values{i_plan},relative_nn_std_per_plan];
                
            end
            %normalize if partial year (not all month jobs returend)
            planValues(i_plan)=planValues(i_plan)/length(monthFileList);
            lostLoad(i_plan) = lostLoad(i_plan)/length(monthFileList);
            success_rate_values(i_plan) = success_rate_values(i_plan)/length(monthFileList);
            %success_rate is a number in [0,1], so no need to normalize it by the number of months.
        end
    catch ME
        display(['Problem using extractObjectiveValue for i_plan = ' num2str(i_plan)]);
        msgString = getReport(ME);
        display(msgString);
    end
end
