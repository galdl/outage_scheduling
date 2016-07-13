caseName='case5';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
params.verbose=1;
params.horizon=1;

[Pg_n1,o_n1,oo_n1]=generalOPF('n1',params);
[Pg_uc_n1,o_uc_n1,oo_uc_n1]=generalSCUC('n1',params);