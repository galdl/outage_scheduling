% N=500;
reliability_orig = final_db_test(:,3);
idx=find(reliability_orig==0);
% idx=idx(1:N);
% idx=1:length(idx);
reliability_res = zeros(size(idx));
distances = zeros(size(idx));

for j=1:500
    curr_uc_sample = uc_samples{j};
%     reliability_res(j) = evaluate_UC_reliability(curr_uc_sample,params);
    [NN_uc_sample,NN_uc_sample_rand,NN_distance] = get_uc_NN(final_db,sample_matrix,curr_uc_sample,params);
    distances(j) = NN_distance;
end
% reliability_res
mean(distances.^2)
