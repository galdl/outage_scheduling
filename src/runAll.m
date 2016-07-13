caseName='case24';%case5,case9,case14,case24
numOfDays = 3;
params=am_getProblemParamsForCase(caseName);
RATE_A=6;
params.verbose=0;
% params.mpcase.branch(:,RATE_A)=300; %interesting: 300,200,190 - for case 24
% params.mpcase.branch(4,:)=[];
% params.mpcase.branch=[params.mpcase.branch;params.mpcase.branch];
% muStdRatioVec=[0.01,0.05,0.1,0.15,0.2,0.3,0.4,0.5,0.7,0.9];
muStdRatioVec=[0.01,0.1,0.5,0.9];
params.dynamicSamplesPerDay=4;
statsForDifferentRatios = cell(1,length(muStdRatioVec));
exceptionIndices = [];
timeStr=datetime('now');

for i_r = 1:length(muStdRatioVec)
    params.muStdRatio = muStdRatioVec(i_r);
    display(['Outer wind std ration iteration ',num2str(i_r),' out of ',num2str(length(muStdRatioVec))]);
    try
        [sequenceStats,state] = simulateSequenceOfDays(numOfDays,params);
    catch ME
        warning(['Problem using simulateSequenceOfDays for i_r = ' num2str(i_r)]);
        msgString = getReport(ME);
        display(msgString);
        exceptionIndices=[exceptionIndices,i_r];
    end
    statsForDifferentRatios{i_r} = sequenceStats;
    save(['./saved_runs/statsForDifferentRatios_',timeStr,'.mat'],'statsForDifferentRatios')
end
statsForDifferentRatios(exceptionIndices) = []; 
muStdRatioVec(exceptionIndices)=[];
plotStats(statsForDifferentRatios,muStdRatioVec);
