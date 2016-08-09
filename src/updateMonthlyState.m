function state = updateMonthlyState(maintenancePlan,month,state,params)
%% advance time to current month - assume maintenance is done in the first 
%% day of the month, and the evaluation starts from the second
state.currTime = state.currTime + 24*30*(month-1);

%% reset effective age for maintained assets
state.topology.lastChange = getLastChangeVector(maintenancePlan,month,params);

%% assume all assets are on-line in the beginning of the month
state.topology.lineStatus = ones(params.nl,1);

%% maintenance currently takes the asset offline for the whole duration of this month's simulation, since params.fixDuration=24*params.numOfDaysPerMonth
state.topology.lineStatus = 1 - maintenancePlan(:,month);

%% set initial generator state to the original one
state.initialGeneratorState=params.initialGeneratorState;

%% the following lines were used before, in the non-parallel version
% hoursToAdvance=24*(30-params.numOfDaysPerMonth);
% state.topology.lastChange(monthlyMaintenance)=state.currentTime;