function [totalObjective,finalOnoff,deviationCost,deviationTime,state,escalateLevelVec,allContingenciesHappened,totalWindSpilled,totalLoadLost,success_rate] = ...
    dynamicMyopicUC(originalPg,originalOnoff,params,state)
%% initialization
deviate=0;
k=1;
paramsCopy=params;
paramsCopy.horizon=1;
deviationCost=0;
totalObjective=0;
finalOnoff=zeros(params.ng,params.horizon);
deviationTime=0;
dynamicUCParams.enforceOnoff=1;
escalateLevelVec=zeros(params.horizon,1);
totalWindSpilled=0;
totalLoadLost=0;
loadLost=0;
success_rate = 0;
allContingenciesHappened=zeros(params.nl,1);
%% while UC haven't deveiated from the original plan, follow original plan.
%% if it has deviated, remove originalOnoff constraint
for k=1:params.horizon
    dynamicUCParams.externalStartTime=k;
    dynamicUCParams.originalPg=originalPg(:,k);
    dynamicUCParams.originalOnoff=originalOnoff(:,k);
    %% first try to follow commitment plan
    if(~deviate)
        [state,contingenciesHappened] = updateState(params,state); %possible take stress levels as input
        [~,objective,onoff,y,~,success,windSpilled] = generalSCUC('not-n1',paramsCopy,state,dynamicUCParams);
        %% if couldn't follow original commitment - remove this constraint for all remaining hours
        if (~success) % indication of infeasibility - this block runs at most once. don't advance time here since it was already done
            display(['DEVIATION (re-commitment) at time ',num2str(k)]);
            deviate=1;
            deviationTime=k;
            dynamicUCParams.enforceOnoff=0;
            %q: if this is run, use stateCopy since the updated state is irelevant
            %a: no, use state, since we tried the original plan and its stresss led
            %to contingecies (or haven't, but age did), so thats our
            %current topology. state.currTime still hasn't advanced.
            [Pg,objective,onoff,y,demandVector,success,windSpilled] = generalSCUC('not-n1',paramsCopy,state,dynamicUCParams);
        end
    else
            [Pg,objective,onoff,y,demandVector,success,windSpilled] = generalSCUC('not-n1',paramsCopy,state,dynamicUCParams);
            [state,contingenciesHappened] = updateState(paramsCopy,state);

    end
    success_rate = success_rate + success/params.horizon;
    allContingenciesHappened=allContingenciesHappened+contingenciesHappened;
    state.currTime = state.currTime+1;
    %escalateLevelVec(k)=escalateLevel; obsolete
    totalWindSpilled=totalWindSpilled+sum(sum(windSpilled));
    %totalLoadLost=totalLoadLost+loadLost; will be used in the future
    finalOnoff(:,k)=onoff;
    totalObjective=totalObjective+objective;
    deviationCost = deviationCost + pgDeviationCost(originalPg(:,k),originalOnoff(:,k),value(y),params.mpcase.gencost);
    state.initialGeneratorState = getInitialGeneratorState_oneStep(onoff,state.initialGeneratorState,params);
end