%% Parameters configuration file for the test-cases, algorithm, distributions and simulation
%% UC_NN simulation parameters
params.N_jobs_NN=25; %240
%% number of samples for building db in each job
params.N_samples_bdb = 10; %400
%% num samples for testing in each job
params.N_samples_test = ceil(params.N_samples_bdb/8);%1

%% Outage_scheduling simulation parameters
params.N_CE=15; %15
%in case5, 4 months, 75 plans , 2x10 - finished in 40 mins
%in case9, 4 months, 75 plans , 2x25 - finished in 4 hours
%in case9, 8 months, 75 plans , 3x25 - in 7 hours t.o, 280 out of 600
%reached
% in case24, 4 months, 75 plans, params.numOfDaysPerMonth=2;
% params.dynamicSamplesPerDay=15; - in 7 hours timeout, 100 of 300 plans
% finished
params.numOfDaysPerMonth=1; %3. currently 1 since there is no difference between them in any case
if(strcmp(config.program_name,'optimize'))
    %reduced to three since currently we draw very little contingencies, and reduced the rand_walk_w_std,rand_walk_d_std values
    params.dynamicSamplesPerDay=3; %3
else
    params.dynamicSamplesPerDay=3; %5
end
params.N_plans=150; %75
params.numOfMonths=12; %when changing this, make sure generate_shared_DA_scenarios(params,i_month) is fixed to not rely on 8 months (hardcoded).
params.myopicUCForecast=0;
params.dropUpDownConstraints=0; %1
params.SU_cost = 1;
params.use_NN_UC = true; %true
%if false - success rate will be simply the rate of success
%if true - success rate will be computed as the portion of N-1 list that is
%recoverable, averaged over the 24-hours (increases complexity by a factor
%of params.nl, per each day of simulation)
params.n1_success_rate = true;
if(strcmp('case96',params.caseName))
    params.reliability_percentageTolerance = 200;
end
if(strcmp('case24',params.caseName))
    params.reliability_percentageTolerance = 50;
end
%% seperate the edited cases (which include dynamic parameters for UC,
%% s.a min up/down times, initial state, etc.) and the non-edited, classic matpower cases
if(sum(strcmp(caseName,{'case5','case9','case14','case24','case24_ieee_rts','case96'}))>0)
    params.caseName=caseName;
    caseParams=getSpecificCaseParams(caseName,'matpower_cases/ieee_RTS96_UW');
    generatorTypeVector=caseParams.generatorTypeVector;
    generatorBusVector=caseParams.generatorBusVector;
    params.initialGeneratorState=caseParams.initialGeneratorState;
    loads=caseParams.loads;
    params.windScaleRatio=caseParams.windScaleRatio; %%wind generation mean will be devided by this factor
    
    
    generatorData=getGeneratorData();
    [mpcase,redispatch_price]=setCaseParams(caseName,generatorData,generatorTypeVector,generatorBusVector,loads,caseParams);
    params.redispatch_price = redispatch_price;
    
    if(strcmp('case96',params.caseName))
        params.numerical_branch = modify_to_numerical_branch(mpcase.branch);
    end
    
    unitsInfo=[];
    for g=generatorTypeVector
        unitsInfo=[unitsInfo;generatorData{g}.PMIN,generatorData{g}.PMAX,generatorData{g}.MD,generatorData{g}.MU];
    end
    params.PMIN=1;
    params.PMAX=2;
    params.MD=3; %column enum, not value!
    params.MU=4;
    params.unitsInfo=unitsInfo;
    
    params.generatorTypeVector=generatorTypeVector;
    params.generatorBusVector=generatorBusVector;
    params.generatorData=generatorData;
else
    funcHandle=str2func(caseName);
    mpcase=funcHandle();
end
params.mpcase=mpcase;

% small corrections needed for RTS96 network
% if(strcmp('case96',params.caseName))
%     case24_copy = case24_ieee_rts;
%     case24_pmin = case24_copy.gen(:,PMIN);
%     params.mpcase.gen(:,PMIN) = repmat(case24_pmin,[3,1]);
% end

params.verbose=0;
params.horizon=24;
%% data dimensions
params.nb   = size(mpcase.bus, 1);    %% number of buses
params.nl   = size(mpcase.branch, 1); %% number of branches
params.ng   = size(mpcase.gen, 1);    %% number of dispatchable injections
%% set up requested outages
ro = zeros(params.nl,1);

if(strcmp(caseName,'case96'))
    ro = zeros(40,1); %number of lines in each area
    ro(1)=2; ro(3:5)=1; ro(10)=2;  ro(15)=1; ro(20)=2; ro(14)=1; ro(17)=1; ro(28)=1; ro(30)=1; ro(35)=2; %ro(11)=1;
    if(strcmp(config.program_name,'compare')) %add some
        ro(11)=2; ro(16) =2; ro(25)=2;
    end
    ro=[ro;ro;ro];
end

if(strcmp(caseName,'case24'))
    ro(1)=2; ro(3:5)=1; ro(10)=2;  ro(15)=1; ro(20)=2; ro(14)=1; ro(17)=1; ro(28)=1; ro(30)=1; ro(35)=2; %ro(11)=1;
    if(strcmp(config.program_name,'compare')) %add some
        ro(11)=2; ro(16) =2; ro(25)=2;
    end
end
if(strcmp(caseName,'case5'))
    ro(1)=2; ro(3)=1; ro(6)=1;
end
params.requested_outages = ro;
params.shrinkage_factor = 0.75; %shrink the schedule probability matrix entries
%that were chosen from one month to the next by this amount
%% wind params
params.windBuses = caseParams.windBuses;
params.windHourlyForcast = caseParams.windHourlyForcast;
params.windCurtailmentPrice=100; %[$/MW]
%% optimization parameters
params.alpha = 0.05; % success_rate chance-constraint parameter : P['bad event']<alpha
%% demand and wind STDs
params.demandStd = 0.05; %0.05
params.muStdRatio = 0.15;
params.rand_walk_w_std = 0.015; %0.03
params.rand_walk_d_std = 0.005; %0.01
%% VOLL
params.VOLL = 1000;
%% fine payment escalation cost
params.finePayment = sum(mpcase.bus(:,3))*params.VOLL; %multiple of the full LS cost - this is per hour
params.fixDuration=24*params.numOfDaysPerMonth+1;
%% optimization settings
params.verbose = 0;
% params.optimizationSettings =  sdpsettings('solver','mosek','mosek.MSK_DPAR_MIO_MAX_TIME',200,'verbose',params.verbose); %gurobi,sdpa,mosek
% params.optimizationSettings =  sdpsettings('solver','mosek','verbose',params.verbose);
% params.optimizationSettings = sdpsettings('solver','gurobi','gurobi.MIPGap','1e-2','verbose',params.verbose); %gurobi,sdpa,mosek

% params.optimizationSettings = sdpsettings('solver','cplex','cplex.timelimit',5,'verbose',params.verbose); %gurobi,sdpa,mosek

% params.optimizationSettings = sdpsettings('solver','cplex','verbose',params.verbose); %good for hermes
params.optimizationSettings = sdpsettings('solver','cplex','verbose',params.verbose,'cplex.output.clonelog',-1);

% ops = sdpsettings('solver','cplex');
%% db random NN mode
params.db_rand_mode = true;
%% choose whether to run in n-1 mode
params.n1_str = 'not-n1'; %'n1'
%% contingency prob per line
if(strcmp('case96',params.caseName))
    params.failure_probability = 0.08;
else
    params.failure_probability = 0.15;
end
%% NN weighted norm
params.line_status_norm_weight = 100;
params.KNN = 10;