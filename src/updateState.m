%bring fixed lines back online, draw failures of new lines (contingencies)
%, and save it into 'state'
function [state,contingenciesHappened] = updateState(params,state)
get_global_constants
[lineStatus,fixed] = getFixedLineStatus(1,1,params,state);
%% draw contingencies in lines
lineAge=state.currTime-state.topology.lastChange;
linesUp = (state.topology.lineStatus == 1);
branchFailure = simulateContingency(lineAge,1,params);
failed = linesUp.*branchFailure; %those who failed had to be up before failing

changed = fixed | failed ;
lineStatus(logical(failed))=0;
% contingenciesHappened=sum(failed);
contingenciesHappened = failed;
state.topology.lineStatus=lineStatus;
state.topology.lastChange(changed)=state.currTime;
