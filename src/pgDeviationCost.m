function price = pgDeviationCost(originalPg,originalOnoff,Pg,gencost,params)

%notice that totcost returns (positive even if zeros?)
% y are epigraph values, so this line doesn't really work.
% price=sum(abs((originalOnoff).*totcost(gencost,originalPg)-y));
%this is because y is chosen to be higher and equal to the totcost and we
%get a difference of 0, which is not correct.

%since piecewise-linear objective results in non-linear objective, we
%modify the redispatch cost slightly, by weighting the difference by the
%average slopes of each generator.
price=sum(params.redispatch_price.*abs(originalPg-Pg));