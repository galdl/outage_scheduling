%Currently this is run outside after decided not to follow original commitment
%(dynamicUCParams.enforceOnoff=0), but doesn't have to be that way in the future
function [Pg,objective,onoff,y,demandVector,state,escalateLevel,contingenciesHappened,windSpilled,loadLost] ...
    = escalateUC(params,state,dynamicUCParams,stateAlreadyUpdated)
contingenciesHappened=zeros(params.nl,1);
loadLost=0;
%% stage one - try n-1
[Pg,objective,onoff,y,demandVector,success,windSpilled] = generalSCUC('n1',params,state,dynamicUCParams);
escalateLevel=0;
%if state wasn't already updated for this current time step (happens always
%except for the deviation time step) - update it to include fixed lines and
%new failures.
if(~stateAlreadyUpdated)
    [state,contingenciesHappened] = updateState(params,state);
end
%% if failed - stage two - try not n-1
%Notice that in principle it will be more correct to retry to solve with n-1 first, but its negligible.
if(~success || (sum(contingenciesHappened)>0)) %%TODO: return escalation integer here - to later know what happened
%     display(['escalateUC: solutionObtained: ',num2str(success),'contingenciesHappened: ',num2str(contingenciesHappened),...
%         ' - escalated to without n-1, not following commitment']);
    [Pg,objective,onoff,y,demandVector,success,windSpilled] = generalSCUC('not-n1',params,state,dynamicUCParams);
    escalateLevel=1;
end
%% if failed - stage three - try load shedding
if(~success)
    display('escalated to LS in escalateUC');
    [Pg,objective,onoff,y,demandVector,success,windSpilled,loadLost] = loadSheddingSCUC(params,state,dynamicUCParams);
    escalateLevel=2;
end
%% if failed - stage four - pay high fine and move on
if(~success)
    display('escalated to FINE PAYMENT escalateUC');
%     objective=1e6;
    objective = params.finePayment*params.horizon;
    escalateLevel=3;
end