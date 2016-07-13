function price = pgDeviationCost(originalPg,originalOnoff,y,gencost)

%notice that totcost returns 
% price=sum(abs((originalPg>0).*totcost(gencost,originalPg)-y));
price=sum(abs((originalOnoff).*totcost(gencost,originalPg)-y));