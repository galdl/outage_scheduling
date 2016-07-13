function [yearlyStats]=simulateYear(maintenancePlan,params)
exceptionIndices = [];
timeStr=datestr(datetime('now'));
yearlyStats=cell(1,params.numOfMonths);
parfor month = 1:params.numOfMonths
    display([timeStr,': Outer parallel month iteration ',num2str(month),' out of ',num2str(params.numOfMonths)]);
    try
        state=getInitialState(params);
        state = updateMonthlyState(maintenancePlan,month,state,params);
        [monthlyStats,~] = simulateSequenceOfDays(state,params);
    catch ME
        warning(['Problem using simulateYear for month = ' num2str(month)]);
        msgString = getReport(ME);
        display(msgString);
        exceptionIndices=[exceptionIndices,month];
    end
    yearlyStats{month} = monthlyStats;
end
yearlyStats(exceptionIndices) = []; 
