function params_with_DA_scenarios = generate_shared_DA_scenarios(params)

state = getInitialState(params);
isStochastic = 1;
num_of_days=params.numOfDaysPerMonth;
params_with_DA_scenarios = params;

demandScenario_DA = cell(num_of_days,1);
windScenario_DA = cell(num_of_days,1);

for day = 1:num_of_days
    [demandScenario_DA_daily,windScenario_DA_daily] = generateDemandWind_with_category(1:params.horizon,params,state,isStochastic,day);
    demandScenario_DA{day} = demandScenario_DA_daily;
    windScenario_DA{day} = windScenario_DA_daily;
end

params_with_DA_scenarios.demandScenario_DA = demandScenario_DA;
params_with_DA_scenarios.windScenario_DA = windScenario_DA;