function normalizedP1Vec=calcNormalizedP1Vec(p,epsilon,includeNull)
pVec=p(:);
planProbVec=max(pVec,epsilon);
nullPlanProbVec=max((1-pVec),epsilon);
logNullPlanProb=sum(log(nullPlanProbVec));
p1LogVec=logNullPlanProb-log(nullPlanProbVec)+log(planProbVec);
if(includeNull)
    p1LogVec=[p1LogVec;logNullPlanProb]; %last entry is the null action (no assets mainained in this month)
end
p1Vec=exp(p1LogVec);
normalizedP1Vec=p1Vec/sum(p1Vec);
