function barrier_struct = calibrate_barrier(planValues)
%calibrate the barrier function parameters according to the order of
%magnitude of the objective costs
%explanation of the method: we require our barrier function to hold
%f_{p=1}(x0)=M, and find x0, where M is a large value in the order of magnitude of the 
% costs (the rest of the objective). Then, we scale s.t. 1-alpha
% corresponds to x0, where alpha is from the chance-constraint: P['bad
% event']<alpha.


%some of the planValues may be negative. That's ok though.
M = mean(abs(planValues(~isnan(planValues)))); %consider taking max or high percentile

%function can be found in phi.m
syms t
eqn = 0.5*t.^2+t == M;
res = solve(eqn,t);
res_val = double(res);
x0 = res_val(res_val>0);
barrier_struct.M = M;
barrier_struct.x0 = x0;
