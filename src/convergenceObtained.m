function [convergence] = convergenceObtained(p,epsilon)
withinRange = (epsilon < p & p< 1-epsilon);
convergence = (sum(withinRange)==0);
