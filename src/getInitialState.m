function state=getInitialState(params)
%% Contingency data structure
state.topology.lineStatus=ones(params.nl,1); %saves the status of each branch
state.topology.lastChange=zeros(params.nl,1); %last time stamp where the asset had been fixed (reset)
state.topology.lastChange(1)=-700;
state.topology.lastChange(2)=-150;
state.topology.lastChange(6)=-2500;
if(strcmp(params.caseName,'case5'))
%     state.topology.lastChange=[-700;-150;-200;-50;-350;-2500];
    state.topology.lastChange(1:6)=[-700;-150;-10000;-50;-350;-10000];
end

state.topology.fixDuration=params.fixDuration*ones(params.nl,1); %duration of time it takes to fix each asset
%% current time. Note that it is overrided by the monthlyStateUpdate func
state.currTime=params.fixDuration+1; %first hour of the second day. If we use (fixDuration) or less, matintenance will take the assets down
%% initial generator state
state.initialGeneratorState=params.initialGeneratorState;
