%only return line status - the actual state update will be done in the
%dynamic mode
function [lineStatus,fixed] = getFixedLineStatus(currHour,dynamicUC,params,state)
currTimeStamp=state.currTime;
if(~dynamicUC)  %state.currTime is not updated in each iteration of staticUC so it we need to add currHour here. -1 since first hour is currTime
    currTimeStamp=currTimeStamp+currHour-1;
end

lineStatus = state.topology.lineStatus;
%% restore lines that had been down and had been repaired
linesDown=(state.topology.lineStatus==0);
fixed=linesDown.*(repmat(currTimeStamp,params.nl,1) - state.topology.lastChange > state.topology.fixDuration);
lineStatus = lineStatus+fixed; 