function [branchFailure] = simulateContingency(age_noScaling,dt,params)
age=age_noScaling*(12/params.numOfMonths)/2; %TODO: suitable for 2 months. more months should be verified...
eta = 0.005; alpha = 0.1; gamma=0.012; s=0.05;
H =  @(t, sigmat,eta,alpha,gamma, s) (1-exp(-eta*(alpha*exp(gamma*sigmat)*t).^s));
% based on the "Monte Carlo Simulation of the time dependent failure of
% bundles of parallel fibers.pdf"
pH =  H(dt, age ,eta,alpha,gamma, s);
r = rand(size(pH));
branchFailure = r<pH;