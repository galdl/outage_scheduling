function [c, lambdas, Pc] = getLineContingencies(lambdas, params, pg, dt)

LINERATING = 6;
STATUS = 11;

lineRating = params.mpcase.branch(:,LINERATING);
status = params.mpcase.branch(:,STATUS);
lambdas = lambdas + pg*dt/lineRating

