tic
caseName='case24';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
RATE_A=6;
params.verbose=1;
% params.mpcase.branch(:,RATE_A)=300; %interesting: 300,200,190 - for case 24
% params.mpcase.branch(4,:)=[];
% params.mpcase.branch=[params.mpcase.branch;params.mpcase.branch];
state=getInitialState(params);
isStochastic=1;

%% First part - generate day-ahead UC forecast
windScenario = generateWind(1:params.horizon,params,~isStochastic); %% in the future - change wind profile according to date
params.windScenario = windScenario;
dynamicUCParams=[];

[originalPg,originalObjective,originalOnoff,~,~,~,escalateLevel] = escalateUC(params,state,dynamicUCParams,1)

%% Second part - dynamic myopic UC
[stochasticWindScenario , Pr] = generateWind(1:params.horizon,params,isStochastic);
params.windScenario = stochasticWindScenario;

[objective,onoff,deviationCost,deviationTime,state] = dynamicMyopicUC(originalPg,originalOnoff,params,state);

% Res=[   sum(totcost(params.mpcase.gencost,Pg_ed)),o_ed;...
%         sum(totcost(params.mpcase.gencost,Pg_opf)),o_opf;...
%         sum(totcost(params.mpcase.gencost,Pg_n1)),o_n1]
% Res=[   o_ed,oo_ed';...
%         o_opf,oo_opf';...
%         o_n1,oo_n1']

%TODO: add to objective a penalty on stepping away from original Pg
toc