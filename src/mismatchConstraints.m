function [Amis,bmis,Bf,Pfinj] = mismatchConstraints(baseMVA,bus,branch,gen,ng,nb,windAdditionToDemand,loadhShedding_reductionFromDemand)
% power mismatch constraints - updated as load and branch changes - equation 6.16 in manual

define_constants;
[B, Bf, Pbusinj, Pfinj] = makeBdc(baseMVA, bus, branch);
neg_Cg = sparse(gen(:, GEN_BUS), 1:ng, -1, nb, ng);   %% Pbus w.r.t. Pg
Amis = [B neg_Cg];
bmis = -(bus(:, PD) + windAdditionToDemand - loadhShedding_reductionFromDemand + bus(:, GS)) / baseMVA - Pbusinj;