function sample_db = build_NN_db(params)
% generates sample DB
run('set_global_constants.m');
N_samples = params.N_samples_bdb;
sample_db = cell(N_samples,1);
isStochastic = true;
state = getInitialState(params);
state.currTime = 700;
for i_sample = 1:N_samples
%   to check out this phenomena, set state.currTime=700 and in runUC,
%   lastChange line =0, run and see if cost difference are very
%   significant. They have to be, otherwise - how can it be that when this
%   was the case, in outageScheduling compare, plan1 was very cheap, while
%   the other plans showed very high prices. In other words, when currTime
%   was high (and maybe also low), and runUC had the bug of lastChange=0 (instead of =currTime),
%   the results were good! while alegedly, the UCNN results showed no
%   difference between the plans, while they were the correct ones!
%   conclusion: generalSCUC is not doing exactly what I thought it would
    [demandScenario,windScenario,category] = generateDemandWind_with_category(1:params.horizon,params,state,isStochastic,params.job_category);
    line_status = draw_contingencies(params);
    tic
    uc_sample = run_UC(params.n1_str , state , demandScenario , windScenario ,line_status, params);
    uc_sample.category = category;
    sample_db{i_sample}=uc_sample;
    display(['Sample ',num2str(i_sample),' out of ',num2str(N_samples),'. Success: ',num2str(uc_sample.success)]);
    toc
end