% runs from distant node. Therefore - generates params itself, and reads
% arguemnts from local file
function [monthlyStats]=simulateMonth(i_month,maintenancePlan,nn_db,params)
%% generate the initial state struct
state=getInitialState(params);
%% read maintenance plan and update the state according to it
state = updateMonthlyState(maintenancePlan,i_month,state,params);
%% simulate the month and gather statistics
params.nn_db = nn_db;
[monthlyStats,~] = simulateSequenceOfDays(state,params);
%% save statistics to file
% save([mPlanDir , '/monthlyStats' , '_m_' , num2str(i_month)],'monthlyStats');
%save monthly stats to file with i_month name, and full plan path