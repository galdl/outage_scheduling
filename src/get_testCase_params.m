function [ params ] = get_testCase_params( caseName , config )
run('get_global_constants.m')
%need matpower for that
if(strcmp(caseName,'case24'))
    internal_caseName = 'case24_ieee_rts';
else 
    internal_caseName = caseName;
end
funcHandle=str2func(internal_caseName);
mpcase=funcHandle();
params.caseName=caseName;
parameters
end
%% paratmeres that worked:
% for 3 days with 7 outer iterations, step size 0.2 and gamma 1, we get
% good convergence when doing only s0 regression (GD)