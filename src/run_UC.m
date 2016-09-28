function uc_sample = run_UC(str , state , demandScenario , windScenario, line_status, params)
get_global_constants
uc_sample.windScenario = windScenario;
uc_sample.demandScenario = demandScenario;
uc_sample.line_status = line_status;
params.windScenario = windScenario;
params.demandScenario = demandScenario;
params.line_status = line_status;
state.topology.lineStatus = line_status;
% state.topology.lastChange(logical(1-line_status))=state.currTime;
state.topology.lastChange(logical(1-line_status))=0;

[Pg,objective,onoff,y,demandVector,success,windSpilled,loadLost,warm_start,solution_time] = generalSCUC(str,params,state,[]);
uc_sample.success = success;
uc_sample.onoff = onoff;
uc_sample.objective = objective;
uc_sample.Pg = Pg;
uc_sample.windSpilled = windSpilled;
uc_sample.loadLost = loadLost;
uc_sample.voltage_setpoints = [];
uc_sample.solution_time = solution_time;
uc_sample.warm_start = warm_start;
