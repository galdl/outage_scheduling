function [upf,upt,il] = powerFlowConstraints(baseMVA,branch,Pfinj)

% branch flow constraints - equation 6.17,6.18 in manual
define_constants;
il = find(branch(:, RATE_A) ~= 0 & branch(:, RATE_A) < 1e10);
nl2 = length(il);         %% number of constrained lines
if nl2
    upf = branch(il, RATE_A) / baseMVA - Pfinj(il); %branch(il, RATE_A) / baseMVA is Fmax, Pfinj(il) is Pf,shift
    upt = branch(il, RATE_A) / baseMVA + Pfinj(il);
else
    upf = [];
    upt = [];
end