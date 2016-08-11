%%
N=size(uc_samples,1);
overallDemand = nan(1,N);
success = nan(1,N);
for j=1:N
    curr = uc_samples{j,1};
    if(~isempty(curr))
        overallDemand(j) = sum(sum(curr.demandScenario - curr.windScenario));
        success(j) = curr.success;
    end
end
%%
figure(20);
[v,idx] = sort(overallDemand);
scatter(1:length(v),v,[],success(idx)); %seperate to UC success and no success
title(['Effective demand of UC sample. Color seperation to success and no success']);
%%
figure(21);
overallDemand_success = overallDemand((success==1));
[v,idx] = sort(overallDemand_success);
scatter(1:length(v),v,[],bad_idx); %seperate to correlation and no correlation
title(['Effective demand of UC sample. Color seperation to correlation and no correlation']);
% plot(sort(overallDemand));
%% costs

figure(23);
[v,idx] = sort(cost_orig);
scatter(1:length(v),v,[],success(idx)); %seperate to UC success and no success
%% costs and demand

figure(24);
[v,idx] = sort(cost_orig);
scatter(cost_orig,overallDemand_success); %seperate to UC success and no success
