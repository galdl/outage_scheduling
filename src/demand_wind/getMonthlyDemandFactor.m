function  monthlyDemandFactor = getMonthlyDemandFactor(state)

monthlyDemandVec = getMonthlyDemandFactorVec();
currMonth = getCurrentMonth(state.currTime);
monthlyDemandFactor=monthlyDemandVec(currMonth);
