function sample_db = build_NN_db(params)
% generates sample DB
run('sets_global_constants.m');
N_samples = params.N_samples_bdb;
sample_db = cell(N_samples,1);
isStochastic = true;
state = getInitialState(params);
for i_sample = 1:N_samples
%     windScenario = generateWind(1:params.horizon,params,state,isStochastic);
%     demandScenario = generateDemand(1:params.horizon,params,state,isStochastic);
    [demandScenario,windScenario] = generateDemandWind_with_category(1:params.horizon,params,state,isStochastic);
    line_status = draw_contingencies(params);
    tic
    uc_sample = run_UC(params.n1_str , state , demandScenario , windScenario ,line_status, params);
    sample_db{i_sample}=uc_sample;
    display(['Sample ',num2str(i_sample),' out of ',num2str(N_samples),'. Success: ',num2str(uc_sample.success)]);
    toc
end