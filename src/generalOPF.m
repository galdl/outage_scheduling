%calls either a regular SCOPF or N-1 SCOPF
function [Pg,objective,onoff] = generalOPF(str,params)
%% Data
mpc=params.mpcase;
%% data dimensions
nb   = size(mpc.bus, 1);    %% number of buses
nl   = size(mpc.branch, 1); %% number of branches
ng   = size(mpc.gen, 1);    %% number of dispatchable injections
%% Choose OPF type
if(strcmp(str,'n1'))
    N_contingencies=nl;
else N_contingencies=0;
end
%% define optimization vars
onoff_var = binvar(ng,1,'full');
Va_var     = sdpvar(nb,N_contingencies+1,'full'); %for no contingency, and N possible ones
Pg_var     = sdpvar(ng,1,'full');
Constraints=[];
%% contrained model
%% define named indices into data matrices
% [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
%     VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
% [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
%     MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
%     QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
% [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
%     TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
%     ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
% [PW_LINEAR, POLYNOMIAL, MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;
define_constants;
%% ignore reactive costs for DC
mpc.gencost = pqcost(mpc.gencost, ng);
%% convert single-block piecewise-linear costs into linear polynomial cost
pwl1 = find(mpc.gencost(:, MODEL) == PW_LINEAR & mpc.gencost(:, NCOST) == 2);
% p1 = [];
if ~isempty(pwl1)
    x0 = mpc.gencost(pwl1, COST);
    y0 = mpc.gencost(pwl1, COST+1);
    x1 = mpc.gencost(pwl1, COST+2);
    y1 = mpc.gencost(pwl1, COST+3);
    m = (y1 - y0) ./ (x1 - x0);
    b = y0 - m .* x0;
    mpc.gencost(pwl1, MODEL) = POLYNOMIAL;
    mpc.gencost(pwl1, NCOST) = 2;
    mpc.gencost(pwl1, COST:COST+1) = [m b];
end
%% create (read-only) copies of individual fields for convenience
[baseMVA, bus, gen, branch, gencost, Au, lbu, ubu, mpopt, ...
    N, fparm, H, Cw, z0, zl, zu, userfcn] = opf_args(mpc);
%% warn if there is more than one reference bus
refs = find(bus(:, BUS_TYPE) == REF);
if length(refs) > 1 && mpopt.verbose > 0
    errstr = ['\nopf_setup: Warning: Multiple reference buses.\n', ...
        '           For a system with islands, a reference bus in each island\n', ...
        '           may help convergence, but in a fully connected system such\n', ...
        '           a situation is probably not reasonable.\n\n' ];
    fprintf(errstr);
end
%% set up initial variables and bounds
Pmin = gen(:, PMIN) / baseMVA;
Pmax = gen(:, PMAX) / baseMVA;
%% more problem dimensions
nv    = 0;            %% number of voltage magnitude vars
nq    = 0;            %% number of Qg vars
q1    = [];           %% index of 1st Qg column in Ay

%% basin constraints for piece-wise linear gen cost variables
ipwl = find(gencost(:, MODEL) == PW_LINEAR);  %% piece-wise linear costs
ny = size(ipwl, 1);   %% number of piece-wise linear cost vars
[Ay, by] = makeAy(baseMVA, ng, gencost, 1, q1, 1+ng+nq);
numSegments=length(by)/ng;
if(ny>0)
    coeff=kron(onoff_var,ones(numSegments,1));
    y=sdpvar(ny,1,'full'); %in case of pwl costs, form epigraph variables y
    Constraints=[Constraints,Ay*[Pg_var;y]<=by.*coeff]; %y basin constraints
else y=0;
end

for i_branch = 1:N_contingencies+1
    %% N-1 criterion - N(=nl) possible single line outage
    newMpcase=mpc;
    if(i_branch>1)
    %for i_branc==1, no contingencies.
    %for i_branc==2, 1st contingency, etc..
        newMpcase.branch(i_branch-1,BR_STATUS)=0;
    end
    %     newMpcase.branch = mpc.branch(idx,:);
    newMpcaseInternal=ext2int(newMpcase); %transform to internal format,
    %to remove components  that can be disconnected as a result of line outage
    [baseMVA, bus, gen, branch, gencost, Au, lbu, ubu, mpopt, ...
        N, fparm, H, Cw, z0, zl, zu, userfcn] = opf_args(newMpcaseInternal);
    %% power mismatch constraints - updated as load and branch changes - equation 6.16 in manual
    [Amis,bmis,Bf,Pfinj] = mismatchConstraints(baseMVA,bus,branch,gen,ng,nb);
    %% branch flow constraints - equation 6.17,6.18 in manual
    [upf,upt,il] = powerFlowConstraints(baseMVA,branch,Pfinj);
    %% branch voltage angle difference limits - updated as load changes
    [Aang, lang, uang, iang]  = makeAang(baseMVA, branch, nb, mpopt);
    %% add constraints
    Constraints = [Constraints, onoff_var.*Pmin <= Pg_var <= onoff_var.*Pmax];
    Constraints = [Constraints,Va_var(refs,i_branch)== bus(refs,VA)*(pi/180)]; %constrain ref angle to be the specified (usually 0)
    Constraints = [Constraints,Amis*[Va_var(:,i_branch);Pg_var] == bmis]; %overall power equality
    if(size(lang,1)+size(lang,2)>0) %only add this constraint when relevant, otherwise causes size mismatch issues in yalmip
        Constraints=[Constraints,lang<=Aang*Va_var(:,i_branch)<=uang]; %angle differences between lines limits (as appears in ANGMAX,ANGMIN in the branch matrix). if 0 - unconstrained.
    end
    if(size(upt,1)+size(upt,2)>0) %only add this constraint when relevant, otherwise causes size mismatch issues in yalmip
        Constraints=[Constraints,-upt<=Bf(il,:)*Va_var(:,i_branch)<=upf]; %line rating limits
    end
    
end
%% objective
ipol = find(gencost(:, MODEL) == POLYNOMIAL);
%% quadratic costs - mutually exclusive with pwl! so don't try to work with them together
if( (ipol>0) + (ny>0) > 1 )
    display('case includes both polynomail and pwl costs!');
    quit;
end
polynomialCost=calculatePolynomialCost(mpc,ipol,Va_var,Pg_var,onoff_var);
pwlCost=sum(sum(y));
Objective = pwlCost+polynomialCost;
% Objective=0;
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