function currMonth = getCurrentMonth(currentTime)
currMonth=mod(ceil(currentTime/(24*30))-1,12)+1;