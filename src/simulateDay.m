function [dailyStats,state] = simulateDay(params,state)
%% variable initialization
isStochastic=1;
stateAlreadyUpdated=1;

dailyStats.dynamicObjective=[];
dailyStats.deviationCost=[];
dailyStats.deviationTime=[];
dailyStats.dynamicEscalateLevelVec=[];
dailyStats.contingenciesHappened=[];
dailyStats.dynamicWindSpilled=[];
dailyStats.dynamicLoadLost=[];

%% First part - generate day-ahead UC forecast
windScenario = generateWind(1:params.horizon,params,state,~isStochastic); %% in the future - change wind profile according to date
params.windScenario = windScenario;
dynamicUCParams=[];
if(~params.myopicUCForecast)
    [originalPg,originalObjective,originalOnoff,~,~,~,originalEscalateLevel,~,originalWindSpilled,originalLoadLost] = ...
        escalateUC(params,state,dynamicUCParams,stateAlreadyUpdated);
else
     [originalPg,originalObjective,originalOnoff,~,~,~,originalEscalateLevel,~,originalWindSpilled,originalLoadLost] = ...
        myopicEscalateUC(params,state,dynamicUCParams,stateAlreadyUpdated);
end

%% Second part - dynamic myopic UC - take multiple samples
for i_sample = 1:params.dynamicSamplesPerDay
     timeStr=datestr(datetime('now'));
    display([timeStr,': day sample ',num2str(i_sample),' out of ',num2str(params.dynamicSamplesPerDay), ' params.dynamicSamplesPerDay']);
    try
        [stochasticWindScenario , Pr] = generateWind(1:params.horizon,params,state,isStochastic);
        params.windScenario = stochasticWindScenario;
        [objective,~,deviationCost,deviationTime,stateCopy,escalateLevelVec,contingenciesHappened,dynamicWindSpilled,dynamicLoadLost] = ...
            dynamicMyopicUC(originalPg,originalOnoff,params,state);
        if(i_sample==params.dynamicSamplesPerDay) %store the last sample's state for the next day
            state = stateCopy;
        end
        
        %% save all statistics - dynamic UC plan
        dailyStats.dynamicObjective=[dailyStats.dynamicObjective,objective];
        dailyStats.deviationCost=[dailyStats.deviationCost,deviationCost];
        dailyStats.deviationTime=[dailyStats.deviationTime,deviationTime];
        dailyStats.dynamicEscalateLevelVec=[dailyStats.dynamicEscalateLevelVec,escalateLevelVec];
        dailyStats.contingenciesHappened=[dailyStats.contingenciesHappened,contingenciesHappened];
        dailyStats.dynamicWindSpilled=[dailyStats.dynamicWindSpilled,dynamicWindSpilled];
        dailyStats.dynamicLoadLost=[dailyStats.dynamicLoadLost,dynamicLoadLost];
    catch ME
        warning(['Problem using simulateDay for i_sample = ' num2str(i_sample)]);
        msgString = getReport(ME);
        display(msgString);
    end
end

%% save all statistics - original UC plan
dailyStats.originalObjective=originalObjective;
dailyStats.originalEscalateLevel=originalEscalateLevel;
dailyStats.originalWindSpilled=originalWindSpilled;
dailyStats.originalLoadLost=originalLoadLost*params.horizon; %in the original plan - load shedding is done for the whole day



