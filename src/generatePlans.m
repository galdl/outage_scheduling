function X = generatePlans(p,N_plans,epsilon,params)
X=zeros(length(p(:)),N_plans);
planSize=size(p);
mPlanBatch=zeros([planSize,N_plans]);
numOfMonthsPerYearlyPlan=12;
numOfYearlyPlans=ceil(planSize(2)/numOfMonthsPerYearlyPlan);

for i_plan=1:N_plans
    fullPlan=[];
    for i_plan_yearly=1:numOfYearlyPlans
        relevantMonths=(i_plan_yearly-1)*numOfMonthsPerYearlyPlan+1:min(i_plan_yearly*numOfMonthsPerYearlyPlan,planSize(2));
        tempP=p(:,relevantMonths);
        yearlyPlan = generateYearlyPlan(tempP,epsilon,params);
        fullPlan=[fullPlan,yearlyPlan];
    end
    
    mPlanBatch(:,:,i_plan) = fullPlan;
    X(:,i_plan)=fullPlan(:);
end

%% generate plans only out of the feasible set, according to their joint probability
% n=planSize(1);
% k=planSize(2);
% if(n>k) %if there are more assets than months
%     numOfPossiblePlans=factorial(n)/factorial(n-k);
% else
%     numOfPossiblePlans=nchoosek(k,n)*factorial(n);
% end
% planProbabilities=cell(