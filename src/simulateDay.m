function [dailyStats,state] = simulateDay(params,state,day_number)
%% variable initialization
isStochastic=1;

dailyStats.dynamicObjective=[];
dailyStats.deviationCost=[];
dailyStats.deviationTime=[];
dailyStats.dynamicEscalateLevelVec=[];
dailyStats.contingenciesHappened=[];
dailyStats.dynamicWindSpilled=[];
dailyStats.dynamicLoadLost=[];
dailyStats.success_rate=[];
dailyStats.relative_nn_std=[];
dailyStats.lostLoad_percentage=[];
dailyStats.relative_lostLoad_vector=[];

relative_nn_std=[];

%% First part - generate day-ahead UC forecast
% in the future - change wind profile according to date
% [demandScenario_DA,windScenario_DA] =
% generateDemandWind_with_category(1:params.horizon,params,state,isStochastic);
% moved it to the main server side - for shared scenarios, to reduce
% variance
demandScenario_DA = params.demandScenario_DA{day_number};
windScenario_DA = params.windScenario_DA{day_number};


uc_sample_in.windScenario = windScenario_DA;
uc_sample_in.demandScenario = demandScenario_DA;
beginning_of_day_hour=1; dynamicUC=0;
uc_sample_in.line_status = getFixedLineStatus(beginning_of_day_hour,dynamicUC,params,state);
if(params.use_NN_UC)
    %% find K nearest neighbours
    [NN_uc_sample_vec,~]= get_uc_NN(params.nn_db.final_db,params.nn_db.sample_matrix,uc_sample_in,params);
    relative_nn_std = calc_relative_std(NN_uc_sample_vec);
    uc_sample_out = NN_uc_sample_vec{1};
else
    %% compute optimal UC plan for the drawn case
    uc_sample_out = run_UC(params.n1_str , state , uc_sample_in.demandScenario , uc_sample_in.windScenario , uc_sample_in.line_status, params);
end


windScenario_RT_cell = cell(params.dynamicSamplesPerDay,1);
demandScenario_RT_cell = cell(params.dynamicSamplesPerDay,1);
%% Second part - real-time OPF solutions - take multiple samples
for i_sample = 1:params.dynamicSamplesPerDay
    timeStr=datestr(datetime('now'));
    display([timeStr,': day sample ',num2str(i_sample),' out of ',num2str(params.dynamicSamplesPerDay), ' params.dynamicSamplesPerDay']);
    try
        
        %% draw RT wind and demand and run step-by-step DCOPFs for costs and reliability assesment
        %         if(i_sample==1) %TODO: remove
        [windScenario_RT,demandScenario_RT] = generate_RT_wind_demand(windScenario_DA,demandScenario_DA,params);
        %         end
        windScenario_RT_cell{i_sample} = windScenario_RT;
        demandScenario_RT_cell{i_sample} = demandScenario_RT;
        params.windScenario = windScenario_RT;
        params.demandScenario = demandScenario_RT;
        originalPg = uc_sample_out.Pg;
        originalOnoff = uc_sample_out.onoff;
        [objective,~,deviationCost,deviationTime,stateCopy,escalateLevelVec,contingenciesHappened,dynamicWindSpilled,dynamicLoadLost,success_rate,lostLoad_percentage,relative_lostLoad_vector] = ...
            dynamicMyopicUC(originalPg,originalOnoff,params,state);
        if(i_sample==params.dynamicSamplesPerDay) %store the last sample's state for the next day
            state = stateCopy;
        end
        
        %% save all statistics - dynamic UC plan
        dailyStats.dynamicObjective=[dailyStats.dynamicObjective,objective];
        dailyStats.deviationCost=[dailyStats.deviationCost,deviationCost];
        dailyStats.deviationTime=[dailyStats.deviationTime,deviationTime];
        %         dailyStats.dynamicEscalateLevelVec=[dailyStats.dynamicEscalateLevelVec,escalateLevelVec];         obsolete
        dailyStats.contingenciesHappened=[dailyStats.contingenciesHappened,contingenciesHappened];
        dailyStats.dynamicWindSpilled=[dailyStats.dynamicWindSpilled,dynamicWindSpilled];
        dailyStats.dynamicLoadLost=[dailyStats.dynamicLoadLost,dynamicLoadLost];
        dailyStats.success_rate=[dailyStats.success_rate,success_rate];
        dailyStats.relative_nn_std=[dailyStats.relative_nn_std,relative_nn_std];
        dailyStats.lostLoad_percentage=[dailyStats.lostLoad_percentage,lostLoad_percentage];
        dailyStats.relative_lostLoad_vector= [dailyStats.relative_lostLoad_vector,relative_lostLoad_vector];

        
        
    catch ME
        warning(['Problem using simulateDay for i_sample = ' num2str(i_sample)]);
        msgString = getReport(ME);
        display(msgString);
    end
end

%% save DA and RT scenarios for later analysis
dailyStats.demandScenario_DA = demandScenario_DA;
dailyStats.windScenario_DA = windScenario_DA;
dailyStats.windScenario_RT_cell = windScenario_RT_cell;
dailyStats.demandScenario_RT_cell = demandScenario_RT_cell;
%% save all statistics - original UC plan
dailyStats.originalObjective=uc_sample_out.objective;
% dailyStats.originalEscalateLevel=originalEscalateLevel; obsolete
dailyStats.originalWindSpilled=uc_sample_out.windSpilled;
dailyStats.originalLoadLost=sum(sum(uc_sample_out.loadLost)); %in the original plan - load shedding is done for the whole day
%         to be used in the future




