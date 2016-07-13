caseName='case5';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
maintenancePlan=zeros(params.nl,12);
maintenancePlan(1,1)=1;
maintenancePlan(1,2)=1;
maintenancePlan(2,2)=1;
maintenancePlan(3,3)=1;
maintenancePlan(4,4)=1;


yearlyStats=simulateYear(maintenancePlan,params);

plotYearlyStats(yearlyStats);
