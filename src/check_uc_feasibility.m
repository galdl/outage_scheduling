function feasibility_value = check_uc_feasibility(onoff,params)
% Feasibility is a score in [0.1], where '1' is full feasibility
Pmin = sum(onoff.*repmat(params.unitsInfo(:,params.PMIN),[1,params.horizon]),1);
Pmax = sum(onoff.*repmat(params.unitsInfo(:,params.PMAX),[1,params.horizon]),1);
feasibility_vec=(sum(params.demandScenario,1)>Pmin).*(sum(params.demandScenario,1)<Pmax+sum(params.windScenario,1));
feasibility_value = mean(feasibility_vec);
