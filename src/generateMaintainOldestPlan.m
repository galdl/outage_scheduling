function maintainOldestPlan=generateMaintainOldestPlan(params)
state=getInitialState(params);
[~,ind]=sort(state.topology.lastChange);
maintainOldestPlan=zeros(params.nl,params.numOfMonths);
for i_m=1:min(size(maintainOldestPlan))
    maintainOldestPlan(ind(i_m),i_m)=1;
end