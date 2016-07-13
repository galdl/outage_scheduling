function [originalPg,originalObjective,originalOnoff,y,demandVector,state,originalEscalateLevel,contingenciesHappened,originalWindSpilled,originalLoadLost] ...
    = myopicEscalateUC(params,state,dynamicUCParams,stateAlreadyUpdated)

paramsCopy=params;
originalPg=zeros(params.ng,params.horizon);
originalObjective=0;
originalOnoff=zeros(params.ng,params.horizon);
originalEscalateLevel=zeros(params.horizon,1);
originalWindSpilled=0;
originalLoadLost=0;

paramsCopy.horizon=1;
dynamicUCParams.enforceOnoff=0;

for k=1:params.horizon
    dynamicUCParams.externalStartTime=k;

    %% run escalate UC in dynamic mode. this will not run a bad UC 
    %% (hopefully) since we do not run updateState (that draws contingencies)
    [hourlyOriginalPg,hourlyOriginalObjective,hourlyOriginalOnoff,y,demandVector,state,hourlyOriginalEscalateLevel,contingenciesHappened,hourlyOriginalWindSpilled,hourlyOriginalLoadLost] = ...
        escalateUC(paramsCopy,state,dynamicUCParams,stateAlreadyUpdated);
    
    originalPg(:,k)=hourlyOriginalPg;
    originalObjective=originalObjective+hourlyOriginalObjective;
    originalOnoff(:,k)=hourlyOriginalOnoff;
    originalEscalateLevel(k)=hourlyOriginalEscalateLevel;
    originalWindSpilled=originalWindSpilled+hourlyOriginalWindSpilled;
    originalLoadLost=originalLoadLost+hourlyOriginalLoadLost;
    
    state.initialGeneratorState = getInitialGeneratorState_oneStep(hourlyOriginalOnoff,state.initialGeneratorState,params);

    %TODO: include external time and fix the conflict with needing to update
    %the dynamic mode structure that uses that - I think its ok now
end

