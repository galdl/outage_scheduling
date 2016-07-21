function [windScenario_RT,demandScenario_RT] = generate_RT_wind_demand(windScenario,demandScenario,params)

mean_wind = mean(windScenario,2);
mean_demand = mean(demandScenario,2);

wind_rand_walk = cumsum([zeros(size(mean_wind)),params.rand_walk_w_std*mean_wind*randn(1,params.horizon-1)],2);
demand_rand_walk = cumsum([zeros(size(mean_demand)),params.rand_walk_d_std*mean_demand*randn(1,params.horizon-1)],2);

windScenario_RT = windScenario + wind_rand_walk;
demandScenario_RT = demandScenario + demand_rand_walk;