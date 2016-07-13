function polynomialCost=calculatePolynomialCost(mpc,ipol,Va,Pg,onoff)
define_constants;
[baseMVA, bus, gen, branch, gencost, Au, lbu, ubu, mpopt, ...
    N, fparm, H, Cw, z0, zl, zu, userfcn] = opf_args(mpc);
polynomialCost=0;
%%
nw =0;        %% number of general cost vars, w
nxyz = length([Va(:,1);Pg]);     %% total number of control vars of all types

%% set up objective function of the form: f = 1/2 * X'*HH*X + CC'*X
%% where X = [x;y;z]. First set up as quadratic function of w,
%% f = 1/2 * w'*HHw*w + CCw'*w, where w = diag(M) * (N*X - Rhat). We
%% will be building on the (optionally present) user supplied parameters.

%% piece-wise linear costs
% if (ny == 0)
Npwl = sparse(0, nxyz);
Hpwl = [];
Cpwl = [];
fparm_pwl = [];
% end
if(ipol>0)
    any_pwl=0;
    npol = length(ipol);
    if any(find(gencost(ipol, NCOST) > 3))
        error('DC opf cannot handle polynomial costs with higher than quadratic order.');
    end
    iqdr = find(gencost(ipol, NCOST) == 3);
    ilin = find(gencost(ipol, NCOST) == 2);
    polycf = zeros(npol, 3);                            %% quadratic coeffs for Pg
    if ~isempty(iqdr)
        polycf(iqdr, :)   = gencost(ipol(iqdr), COST:COST+2);
    end
    polycf(ilin, 2:3) = gencost(ipol(ilin), COST:COST+1);
    polycf = polycf * diag([ baseMVA^2 baseMVA 1]);     %% convert to p.u.
    Npol = sparse(1:npol, length(Va(:,1))+ipol, 1, npol, nxyz);         %% Pg vars
    Hpol = sparse(1:npol, 1:npol, 2*polycf(:, 1), npol, npol);
    Cpol = polycf(:, 2);
    fparm_pol = ones(npol,1) * [ 1 0 0 1 ];
    
    %% combine with user costs
    NN = [ Npwl; Npol; N ];
    HHw = [ Hpwl, sparse(any_pwl, npol+nw);
        sparse(npol, any_pwl), Hpol, sparse(npol, nw);
        sparse(nw, any_pwl+npol), H   ];
    CCw = [Cpwl; Cpol; Cw];
    ffparm = [ fparm_pwl; fparm_pol; fparm ];
    
    %% transform quadratic coefficients for w into coefficients for X
    nnw = any_pwl+npol+nw;
    M   = sparse(1:nnw, 1:nnw, ffparm(:, 4), nnw, nnw);
    MR  = M * ffparm(:, 2);
    HMR = HHw * MR;
    MN  = M * NN;
    HH = MN' * HHw * MN;
    CC = full(MN' * (CCw - HMR));
    C0 = 1/2 * MR' * (HMR.*onoff) + sum(polycf(:, 3).*onoff);   %% constant term of cost
    X=[Va(:,1);Pg];
    polynomialCost= polynomialCost + 1/2 * X'*HH*X + CC'*X + C0;
end