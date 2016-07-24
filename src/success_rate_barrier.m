function success_rate_barrier_values = success_rate_barrier(success_rate_values,barrier_struct,alpha,p)

lambda = ones(size(success_rate_values));
penalty = 1-success_rate_values;
x = (penalty - alpha)./(1 - alpha) * barrier_struct.x0;
success_rate_barrier_values =  phi_p(x,p,lambda);