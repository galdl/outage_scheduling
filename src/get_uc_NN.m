function [NN_uc_sample_vec,NN_uc_sample_rand,NN_distance] = get_uc_NN(final_db,sample_matrix,uc_sample,params)
KNN = params.KNN;
%% reduce training set size if required (for experiments)
final_db = final_db(1:round(length(final_db)*params.training_set_effective_size));
sample_matrix = sample_matrix(:,1:round(size(sample_matrix,2)*params.training_set_effective_size));
%%
% meanS = mean(sample_matrix,2);
% stdS = std(sample_matrix,[],2);
% nonz = (stdS~=0);
% stdS = stdS(nonz);
% meanS = meanS(nonz);
% sample_matrix = sample_matrix(nonz,:);
% sample_matrix = (sample_matrix-repmat(meanS,[1,size(sample_matrix,2)]))./repmat(stdS,[1,size(sample_matrix,2)]);
% vec_sample = vec_sample(nonz);
% vec_sample = (vec_sample-meanS)./stdS;

% finds the NN in the database
vec_sample = [uc_sample.line_status(:);uc_sample.windScenario(:);uc_sample.demandScenario(:)];

diff_mat = sample_matrix-repmat(vec_sample,[1,size(sample_matrix,2)]);
% all_norms = norms(diff_mat);
if(isfield(params,'q_learned') && isfield(params,'idx_nonz'))
    weighted_l2 = zeros(length(vec_sample),1); weighted_l2(params.idx_nonz) = params.q_learned;
else
    weighted_l2 = ones(length(vec_sample),1); weighted_l2(1:params.nl) = params.line_status_norm_weight^2;
end
% weighted_l2 = params.q_learned;
% all_norms = sqrt( sum( diff_mat.^2, 1 ) );
all_norms = sqrt(weighted_l2'*(diff_mat.^2));
[sorted_distances,nn_index] = sort(all_norms);

NN_uc_sample_vec = cell(1,KNN);
i_nn=1;

for j=1:KNN
    NN_uc_sample = final_db{nn_index(i_nn)}; %if problem here - need to take care of case where NN is empty
    %% choose the first NN that has had UC success
    while(i_nn<length(nn_index) && ~NN_uc_sample.success)
        i_nn = i_nn + 1;
        NN_uc_sample = final_db{nn_index(i_nn)};
    end
    NN_distance = inf;
    if(i_nn==length(nn_index))
        display('No successes in the DB!')
        return;
    end
    NN_uc_sample_vec{j}=NN_uc_sample;
    i_nn = i_nn + 1;
end
NN_distance = sorted_distances(i_nn-1);
%% for debugging - also draw a random neighbour
NN_uc_sample_rand=[];
if(params.db_rand_mode)
    while(isempty(NN_uc_sample_rand) || (~isempty(NN_uc_sample_rand) && ~NN_uc_sample_rand.success) )
        NN_uc_sample_rand = final_db{randsample(length(all_norms),1)};
    end
end
