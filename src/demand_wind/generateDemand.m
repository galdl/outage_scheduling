function  demand = generateDemand(time_vector,params,state,isStochastic)
run('get_global_constants.m');
peak_demand = params.mpcase.bus(:,PD);
demand_factor_mat = repmat(getHourlyDemandFactor(time_vector)',[params.nb,1]);
if(isStochastic)
    peak_demand(peak_demand>0) = peak_demand(peak_demand>0) + ...
        randn(size(peak_demand(peak_demand>0))).*peak_demand(peak_demand>0)*params.demandStd;
end
demand = repmat(peak_demand,[1,params.horizon]).*demand_factor_mat;
