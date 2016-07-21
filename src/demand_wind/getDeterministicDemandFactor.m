function deterministicDemandFactor=getDeterministicDemandFactor(timeOfDay)
%taken from UW data of load in week1,day1
hourlyDemandFactor=getHourlyDemandFactor();
deterministicDemandFactor=hourlyDemandFactor(timeOfDay);