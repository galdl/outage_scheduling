function [totalObjective,finalOnoff,deviationCost,deviationTime,state,escalateLevelVec,allContingenciesHappened,totalWindSpilled,...
    totalLoadLost,success_rate,lostLoad_percentage,relative_lostLoad_vector] = dynamicMyopicUC(originalPg,originalOnoff,params,state)
%% initialization
deviate=0;
k=1;
paramsCopy=params;
paramsCopy.horizon=1;
deviationCost=0;
totalObjective=0;
finalOnoff=zeros(params.ng,params.horizon);
finalPg=zeros(params.ng,params.horizon);
finalWindSpilled = zeros(params.nb,params.horizon);
finalLoadLost = zeros(params.nb,params.horizon);
deviationTime=0;
dynamicUCParams.enforceOnoff=1;
escalateLevelVec=zeros(params.horizon,1);
totalWindSpilled=0;
totalLoadLost=0;
relative_lostLoad_vector = 0;
loadLost=0;
lostLoad_percentage = zeros(params.horizon,1);
success_rate = 0;
allContingenciesHappened=zeros(params.nl,1);
db1 = [];%TODO: remove
db2 = [];
%% while UC haven't deveiated from the original plan, follow original plan.
%% if it has deviated, remove originalOnoff constraint
for k=1:params.horizon
    dynamicUCParams.externalStartTime=k;
    dynamicUCParams.originalPg=originalPg(:,k);
    dynamicUCParams.originalOnoff=originalOnoff(:,k);
    %% first try to follow commitment plan
    if(~deviate)
        [state,contingenciesHappened] = updateState(params,state); %possible take stress levels as input
%         state.topology.lineStatus = ones(size(state.topology.lineStatus));
        [Pg,objective,onoff,y,~,success,windSpilled,loadLost] = generalSCUC('not-n1',paramsCopy,state,dynamicUCParams);
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
            [Pg,objective,onoff,y,demandVector,success,windSpilled,loadLost] = generalSCUC('not-n1',paramsCopy,state,dynamicUCParams);
        end
    else
            [Pg,objective,onoff,y,demandVector,success,windSpilled,loadLost] = generalSCUC('not-n1',paramsCopy,state,dynamicUCParams);
            [state,contingenciesHappened] = updateState(paramsCopy,state);

    end
    %if it is not overriden after the for loop - success rate will be simply the rate of success
    success_rate = success_rate + success/params.horizon;
    allContingenciesHappened=allContingenciesHappened+contingenciesHappened;
    state.currTime = state.currTime+1;
    %escalateLevelVec(k)=escalateLevel; obsolete
    totalWindSpilled=totalWindSpilled+sum(sum(windSpilled));
    totalLoadLost=totalLoadLost+sum(sum(loadLost));
    relative_lostLoad_vector = relative_lostLoad_vector + loadLost./max(1e-5,(params.demandScenario(:,k) - (params.windScenario(:,k) - windSpilled)));
    finalOnoff(:,k)=onoff;
    finalPg(:,k) = Pg;
    finalWindSpilled(:,k) = windSpilled;
    finalLoadLost(:,k) = loadLost;
    lostLoad_percentage(k) =  sum(loadLost)/sum((params.demandScenario(:,k) - (params.windScenario(:,k) - windSpilled)));
    totalObjective=totalObjective+objective;
    db1=[db1,objective]; %TODO: remove
    db2=[db2,pgDeviationCost(originalPg(:,k),originalOnoff(:,k),Pg,[],params)];
    deviationCost = deviationCost + pgDeviationCost(originalPg(:,k),originalOnoff(:,k),Pg,[],params); 
    state.initialGeneratorState = getInitialGeneratorState_oneStep(onoff,state.initialGeneratorState,params);
end
relative_lostLoad_vector = relative_lostLoad_vector/params.horizon;
if(params.n1_success_rate) %success rate will be computed as the portion of N-1 list that is recoverable, averaged over the 24-hours
    uc_sample.onoff = finalOnoff;
    uc_sample.Pg = finalPg;
    uc_sample.windSpilled = finalWindSpilled;
    uc_sample.loadLost = finalLoadLost;
    uc_sample.demandScenario = params.demandScenario;
    uc_sample.windScenario = params.windScenario;
    %notice that state.topology.lineStatus can change every hour, but we'll fix the line status for evaluation to the last hour
    uc_sample.line_status = state.topology.lineStatus; 
    uc_sample.voltage_setpoints = [];
    success_rate = evaluate_UC_reliability(uc_sample,params);
end