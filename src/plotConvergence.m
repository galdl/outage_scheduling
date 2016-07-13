relativePath='./saved_runs/stuffToWorkWith/';
case5Path=[relativePath,'bestPlanVecFilePartial_8m_case5_3x10/bestPlanVecFilePartial_8m_case5_3x10.mat'];
case9Path=[relativePath,'bestPlanVecFile_8m_case9_3x10/bestPlanVecFile.mat'];
[objectiveMean5,objectiveStd5]=getObjectiveMeanAndStd(case5Path);
[objectiveMean9,objectiveStd9]=getObjectiveMeanAndStd(case9Path);

normalizedObjectiveMean5=objectiveMean5/(objectiveMean5(1));
normalizedObjectiveStd5=objectiveStd5/objectiveMean5(1);

normalizedObjectiveMean9=objectiveMean9/(objectiveMean9(1));
normalizedObjectiveStd9=objectiveStd9/objectiveMean9(1);

figure;
errorbar(normalizedObjectiveMean5,normalizedObjectiveStd5);
hold on
errorbar(normalizedObjectiveMean9,normalizedObjectiveStd9);
legend({'case5','case9'});
title(['Mean and std of different solutions. Each iteration (x axis) has the same plan, sampled ',num2str(N_plans_max),' times']);
