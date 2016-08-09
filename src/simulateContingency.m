function [branchFailure] = simulateContingency(age_noScaling,dt,params)
age=age_noScaling*(12/params.numOfMonths)/10; % for case24, division by 10 and eta = 0.005 gives 10-18 (month 1-month 8) contingencies a day  
eta = 0.0000005; alpha = 0.1; gamma=0.012; s=0.05; %eta = 0.005
H =  @(t, sigmat,eta,alpha,gamma, s) (1-exp(-eta*(alpha*exp(gamma*sigmat)*t).^s));
% based on the "Monte Carlo Simulation of the time dependent failure of
% bundles of parallel fibers.pdf"
pH =  H(dt, age ,eta,alpha,gamma, s);
r = rand(size(pH));
% r = ones(size(pH)); no contingencies
branchFailure = r<pH;