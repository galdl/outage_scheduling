function hourlyDemand=getHourlyDemand(hour,params)

hourlyDemand=getHourlyDemandFactor(hour)*getMaxDemand(params);