caseName='case5';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
maintenancePlan=ones(params.nl,12);


yearlyStats=simulateYear(maintenancePlan,params);

for j=1:12 
    j
    yearlyStats{j}{1} 
end;


