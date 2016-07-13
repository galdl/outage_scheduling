% runs from distant node. Therefore - generates params itself, and reads
% arguemnts from local file
function [monthlyStats]=simulateMonth(i_month,mPlanDir,mPlanFilename,caseName)
% exceptionIndices = [];
addHermesPaths;
% fid = fopen([mPlanDir,'/b'], 'w');
% fclose(fid);
%% get params and update state
params=am_getProblemParamsForCase(caseName);
state=getInitialState(params);
%% read maintenance plan and update the state according to it
maintenancePlan=readMaintenancePlan(mPlanDir,mPlanFilename,params);
state = updateMonthlyState(maintenancePlan,i_month,state,params);
%% simulate the month and gather statistics
[monthlyStats,~] = simulateSequenceOfDays(state,params);
%     catch ME
%         warning(['Problem using simulateYear for month = ' num2str(month)]);
%         msgString = getReport(ME);
%         display(msgString);
%         exceptionIndices=[exceptionIndices,month];
%     end
%     yearlyStats{month} = monthlyStats;
% end
% yearlyStats(exceptionIndices) = [];

%% save statistics to file
% rng('shuffle')
% monthlyStats.db1=rand;
% monthlyStats.db2=i_month;
save([mPlanDir , '/monthlyStats' , '_m_' , num2str(i_month)],'monthlyStats');
%save monthly stats to file with i_month name, and full plan path