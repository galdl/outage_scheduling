function maintenancePlan = readMaintenancePlan(mPlanDir,mPlanFilename,params)
%% read current maintenance plan from file
fid = fopen([mPlanDir,'/',mPlanFilename], 'r');
columnPlan=fscanf(fid,'%d ');
fclose(fid);

maintenancePlan=reshape(columnPlan,params.nl,params.numOfMonths);