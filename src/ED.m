%solves ED
function [Pg,objective,onoff] = ED(params)
%% Data
mpc=params.mpcase;
mpc=ext2int(mpc);
define_constants;
%% data dimensions
nb   = size(mpc.bus, 1);    %% number of buses
nl   = size(mpc.branch, 1); %% number of branches
ng   = size(mpc.gen, 1);    %% number of dispatchable injections
%% create (read-only) copies of individual fields for convenience
[baseMVA, bus, gen, branch, gencost, Au, lbu, ubu, mpopt, ...
    N, fparm, H, Cw, z0, zl, zu, userfcn] = opf_args(mpc);
%% define optimization vars
onoff_var = binvar(ng,1,'full');
Pg_var     = sdpvar(ng,1,'full');

Pmin = gen(:, PMIN) / baseMVA;
Pmax = gen(:, PMAX) / baseMVA;
Constraints=[];
Constraints = [Constraints, onoff_var.*Pmin <= Pg_var <= onoff_var.*Pmax];
Constraints = [Constraints,sum(Pg_var) == sum(mpc.bus(:,PD))/baseMVA]; %overall power equality
%% basin constraints for piece-wise linear gen cost variables
ipwl = find(gencost(:, MODEL) == PW_LINEAR);  %% piece-wise linear costs
ny = size(ipwl, 1);   %% number of piece-wise linear cost vars
[Ay, by] = makeAy(baseMVA, ng, gencost, 1, [], 1+ng);
numSegments=length(by)/ng;

if(ny>0)
    coeff=kron(onoff_var,ones(numSegments,1));
    y=sdpvar(ny,1,'full'); %in case of pwl costs, form epigraph variables y
    Constraints=[Constraints,Ay*[Pg_var;y]<=by.*coeff]; %y basin constraints
else y=0;
end

%% pwl cost
%% objective
ipol = find(gencost(:, MODEL) == POLYNOMIAL);
%% quadratic costs - mutually exclusive with pwl! so don't try to work with them together
if( (ipol>0) + (ny>0) > 1 )
    display('case includes both polynomail and pwl costs!');
    quit;
end
Va_var=zeros(nb,1); %In ED, we don't have Va_var. It is only needed for corrrect size, for calculatePolynomialCost
polynomialCost=calculatePolynomialCost(mpc,ipol,Va_var,Pg_var,onoff_var);
pwlCost=sum(sum(y));
Objective = pwlCost+polynomialCost;
%% solve
gurobiParams.MIPGap=1e-2; %(default is 1e-4)
% ops = sdpsettings('solver','gurobi','gurobi.MIPGap','1e-2'); %gurobi,sdpa,mosek
% ops = sdpsettings('solver','mosek','mosek.MSK_DPAR_MIO_MAX_TIME',20); %gurobi,sdpa,mosek
ops = sdpsettings('solver','gurobi','verbose',params.verbose); %gurobi,sdpa,mosek
% ops = sdpsettings('solver','Cplex','cplex.epgap','1e-2'); %gurobi,sdpa,mosek



result=optimize(Constraints,Objective,ops);
% result=optimize(Constraints,Objective);
Pg=value(Pg_var)*baseMVA;
objective=value(Objective);
onoff=value(onoff_var);