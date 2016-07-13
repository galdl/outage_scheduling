function lastChange = getLastChangeVector(maintenancePlan,month,params)
%% get last month of maintenance for each line
maintenancePlan=maintenancePlan(:,1:month);
positiveMaintenanceLoc=(sum(maintenancePlan,2)>0);
positiveMaintenancePlan=maintenancePlan(positiveMaintenanceLoc,:);
lastPositiveMaintenanceMonth=arrayfun(@(x)find(positiveMaintenancePlan(x,:),1,'last'),1:size(positiveMaintenancePlan,1));
%% set last touch date for touched assets
st=getInitialState(params);
lastChange=st.topology.lastChange;
lastChange(positiveMaintenanceLoc) = (lastPositiveMaintenanceMonth-1)*24*30;
