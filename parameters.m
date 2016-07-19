%% Parameters configuration file for the test-cases, algorithm, distributions and simulation
%% UC_NN simulation parameters
params.N_jobs_NN=20; %500
%% number of samples for building db in each job
params.N_samples_bdb = 2; %400
%% num samples for testing in each job
params.N_samples_test = ceil(params.N_samples_bdb/8);

%% Outage_scheduling simulation parameters
params.N_CE=2;
%in case5, 4 months, 75 plans , 2x10 - finished in 40 mins
%in case9, 4 months, 75 plans , 2x25 - finished in 4 hours
%in case9, 8 months, 75 plans , 3x25 - in 7 hours t.o, 280 out of 600
%reached
% in case24, 4 months, 75 plans, params.numOfDaysPerMonth=2;
% params.dynamicSamplesPerDay=15; - in 7 hours timeout, 100 of 300 plans
% finished
params.numOfDaysPerMonth=2; %3
params.dynamicSamplesPerDay=2; %5
params.N_plans=10; %75
params.numOfMonths=8;
params.myopicUCForecast=1;
params.dropUpDownConstraints=1;

%% seperate the edited cases (which include dynamic parameters for UC,
%% s.a min up/down times, initial state, etc.) and the non-edited, classic matpower cases
if(sum(strcmp(caseName,{'case5','case9','case14','case24','case24_ieee_rts','case96'}))>0)
    params.caseName=caseName;
    caseParams=getSpecificCaseParams(caseName);
    generatorTypeVector=caseParams.generatorTypeVector;
    generatorBusVector=caseParams.generatorBusVector;
    params.initialGeneratorState=caseParams.initialGeneratorState;
    loads=caseParams.loads;
    params.windScaleRatio=caseParams.windScaleRatio; %%wind generation mean will be devided by this factor
    
    generatorData=getGeneratorData();
    mpcase=setCaseParams(caseName,generatorData,generatorTypeVector,generatorBusVector,loads,caseParams);
    %     if(strcmp(caseName,'case5'))
    %         mpcase.branch=[mpcase.branch;mpcase.branch(5,:)];
    %         mpcase.branch(7,1)=3;  %add line between bus 3 and 5 with no rating limits
    %         mpcase.branch(7,2)=5;
    %     end
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
params.verbose=0;
params.horizon=24;
%% data dimensions
params.nb   = size(mpcase.bus, 1);    %% number of buses
params.nl   = size(mpcase.branch, 1); %% number of branches
params.ng   = size(mpcase.gen, 1);    %% number of dispatchable injections
%% wind params
params.windBuses = caseParams.windBuses;
params.windHourlyForcast = caseParams.windHourlyForcast;
params.windCurtailmentPrice=100; %[$/MW]
%% demand and wind STDs
params.demandStd = 0.05; %0.05
params.muStdRatio = 0.15;
%% VOLL
params.VOLL = 1000;
%% fine payment escalation cost
params.finePayment = sum(mpcase.bus(:,3))*params.VOLL; %multiple of the full LS cost - this is per hour
params.fixDuration=24;
%% optimization settings
% params.optimizationSettings =  sdpsettings('solver','mosek','mosek.MSK_DPAR_MIO_MAX_TIME',200,'verbose',params.verbose); %gurobi,sdpa,mosek
% params.optimizationSettings =  sdpsettings('solver','mosek','verbose',params.verbose);
% params.optimizationSettings = sdpsettings('solver','gurobi','gurobi.MIPGap','1e-2','verbose',params.verbose); %gurobi,sdpa,mosek

% params.optimizationSettings = sdpsettings('solver','cplex','cplex.timelimit',5,'verbose',params.verbose); %gurobi,sdpa,mosek

params.optimizationSettings = sdpsettings('solver','cplex','verbose',params.verbose); %good for hermes
% params.optimizationSettings = sdpsettings('solver','cplex','verbose',params.verbose,'cplex.output.clonelog',-1); 

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