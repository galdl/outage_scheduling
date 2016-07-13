function [w, Pr] =  generateWind(timesOfDay, params, state, isStochastic)
windMonthlyFactor = getMonthlyWindFactor(state);
N = length(timesOfDay);
buses = params.windBuses;
mu = zeros(params.nb,N);
mu(buses,:) = windMonthlyFactor*params.windHourlyForcast(timesOfDay, : )';
if(isfield(params,'windScaleRatio') && ~isempty(params.windScaleRatio))
    mu = mu/params.windScaleRatio;
end
w = zeros(params.nb,N);

if(exist('isStochastic','var') && isStochastic)
    if(isfield(params,'muStdRatio') && ~isempty(params.muStdRatio))
        muStdRatio=params.muStdRatio;
    else
        muStdRatio = 0.15;
    end
    [w, Pr] = drawSample(mu, params, muStdRatio);
else w = mu;
end

