%% set case params
caseName='case24';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
params.dynamicSamplesPerDay=4;
params.numOfDaysPerMonth=3;

%% set maintenance plan
maintenancePlan=zeros(params.nl,12);

%% simulate yearly trajectory
yearlyStats=simulateYear(maintenancePlan,params);

%% plot yearly statistics
plotYearlyStats(yearlyStats);
