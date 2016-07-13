caseName='case5';%case5,case9,case14,case24
params=am_getProblemParamsForCase(caseName);
RATE_A=6;
params.verbose=1;
% params.mpcase.branch(:,RATE_A)=300; %interesting: 300,200,190 - for case 24
% params.mpcase.branch(4,:)=[];
% params.mpcase.branch=[params.mpcase.branch;params.mpcase.branch];
[Pg_ed,o_ed,oo_ed]=ED(params);
[Pg_opf,o_opf,oo_opf]=SCOPF(params);
[Pg_n1,o_n1,oo_n1]=N1OPF(params);

% Res=[   sum(totcost(params.mpcase.gencost,Pg_ed)),o_ed;...
%         sum(totcost(params.mpcase.gencost,Pg_opf)),o_opf;...
%         sum(totcost(params.mpcase.gencost,Pg_n1)),o_n1]
Res=[   o_ed,oo_ed';...
        o_opf,oo_opf';...
        o_n1,oo_n1']