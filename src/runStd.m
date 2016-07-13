% addHermesPaths;
caseName='case5';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
state=getInitialState(params);

muStdRatioVec=[0.01,0.05,0.1,0.15,0.2,0.3,0.4,0.5,0.7,0.9];
% muStdRatioVec=[0.01,0.1,0.5,0.9];
params.dynamicSamplesPerDay=1;
statsForDifferentRatios = cell(1,length(muStdRatioVec));
exceptionIndices = [];
% timeStr=datestr(datetime('now'));
% i_r=getenv('STD_ITERATION');
i_r=1;
%% this part runs independently on each node
    params.muStdRatio = muStdRatioVec(i_r);
    display(['Outer wind std ration iteration ',num2str(i_r),' out of ',num2str(length(muStdRatioVec))]);
    try
        [sequenceStats,state] = simulateSequenceOfDays(state,params);
    catch ME
        warning(['Problem using simulateSequenceOfDays for i_r = ' num2str(i_r)]);
        msgString = getReport(ME);
        display(msgString);
%         exceptionIndices=[exceptionIndices,i_r];
    end
%     statsForDifferentRatios{i_r} = sequenceStats;
    save(['./saved_runs/Hermes/statsForDifferentRatios_ir=',num2str(i_r),'.mat'],'statsForDifferentRatios')
% statsForDifferentRatios(exceptionIndices) = []; 
% muStdRatioVec(exceptionIndices)=[];
% plotStats(statsForDifferentRatios,muStdRatioVec);
