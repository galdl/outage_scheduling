caseName='case5';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
RATE_A=6;
params.verbose=0;
% params.mpcase.branch(:,RATE_A)=300; %interesting: 300,200,190 - for case 24
% params.mpcase.branch(4,:)=[];
% params.mpcase.branch=[params.mpcase.branch;params.mpcase.branch];
state=getState(params);
isStochastic=1;
windScenario = generateWind(1:params.horizon,params,~isStochastic);
params.windScenario = windScenario;
[originalPg,originalObjective,originalOnoff] = generalSCUC('not-n1',params,state)
[stochasticWindScenario , Pr] = generateWind(1:params.horizon,params,isStochastic);
% [stochasticWindScenario] = generateWind(1:params.horizon,params,~isStochastic);

params.windScenario = stochasticWindScenario;
[objective,onoff,deviationCost,deviationTime] = dynamicMyopicUC('not-n1',originalPg,originalOnoff,params,state)

% Res=[   sum(totcost(params.mpcase.gencost,Pg_ed)),o_ed;...
%         sum(totcost(params.mpcase.gencost,Pg_opf)),o_opf;...
%         sum(totcost(params.mpcase.gencost,Pg_n1)),o_n1]
% Res=[   o_ed,oo_ed';...
%         o_opf,oo_opf';...
%         o_n1,oo_n1']

%TODO: add to objective a penalty on stepping away from original Pg