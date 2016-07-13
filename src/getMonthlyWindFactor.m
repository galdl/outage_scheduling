function monthlyWindFactor = getMonthlyWindFactor(state)

monthlyWindFactorVec = getMonthlyWindFactorVec();
currMonth = getCurrentMonth(state.currTime);
monthlyWindFactor=monthlyWindFactorVec(currMonth);