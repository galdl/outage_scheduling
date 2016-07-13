function maintainThresholdPlan=generateThresholdPlan(params)
state=getInitialState(params);
lastChange=state.topology.lastChange;
maintainThresholdPlan=zeros(params.nl,params.numOfMonths);

tresh=3*40*24*params.numOfMonths/12; % 4 EFFECTIVE months
for i_m=1:params.numOfMonths
    currentTimestep=(i_m-1)*30*24;
    effectiveAge=repmat(currentTimestep,params.nl,1)-lastChange;
    toMaintain=(effectiveAge*params.numOfMonths/12>tresh);
    maintainThresholdPlan(toMaintain,i_m)=1;
    lastChange(toMaintain)=currentTimestep;
end