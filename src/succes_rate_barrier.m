function success_rate_barrier_values = succes_rate_barrier(success_rate_values,barrier_struct,alpha,p)

lambda = ones(size(success_rate_values));

x = (success_rate_values - alpha)./(1 - alpha) * barrier_struct.x0;
success_rate_barrier_values =  phi_p(x,p,lambda);