%% generate sample DB
run('sets_global_constants.m');
caseName = 'case24';
params = am_getProblemParamsForCase(caseName);
N_samples = 100;
sample_db = cell(N_samples,1);
isStochastic = true;
state = getInitialState(params);
for i_sample = 1:N_samples
    uc_sample.windScenario = generateWind(1:params.horizon,params,state,isStochastic);
    uc_sample.demandScenario = generateDemand(1:params.horizon,params,state,isStochastic);
    params.windScenario = uc_sample.windScenario;
    params.demandScenario = uc_sample.demandScenario;
    [Pg,objective,onoff,y,demandVector,success,windSpilled] = generalSCUC('not-n1',params,state,[]);
    uc_sample.success = success;
    uc_sample.onoff = onoff;
    uc_sample.objective = objective;

    sample_db{i_sample}=uc_sample;
end