function [sequenceStats,state] = simulateSequenceOfDays(state,params)
numOfDays=params.numOfDaysPerMonth;
sequenceStats=cell(numOfDays,1);

rng('shuffle');
for day = 1:numOfDays
    try
        timeStr=datestr(datetime('now'));
        display([timeStr,': Day iteration ',num2str(day),' out of ',num2str(numOfDays)]);
        [dailyStats,state] = simulateDay(params,state,day);
        sequenceStats{day}=dailyStats;
    catch ME
        warning(['Problem using simulateDay for day = ' num2str(day)]);
        msgString = getReport(ME);
        display(msgString);
    end
end

