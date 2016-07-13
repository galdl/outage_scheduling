function loadRescaleFactor=getLoadRescaleFactor(genToLoadRatio,modifiedMpcase,caseParams)
define_constants;
minWindGeneration = sum(min(caseParams.windHourlyForcast/caseParams.windScaleRatio));
maxGeneration = sum(modifiedMpcase.gen(:,PMAX)) + minWindGeneration;
overallLoad = sum(modifiedMpcase.bus(:,PD));
loadRescaleFactor = maxGeneration/overallLoad*genToLoadRatio;