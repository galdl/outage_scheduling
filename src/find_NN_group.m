function nn_index = find_NN_group(sample_matrix,vec_sample)

diff_mat = sample_matrix-repmat(vec_sample,[1,size(sample_matrix,2)]);
% all_norms = norms(diff_mat);
all_norms = sqrt( sum( diff_mat.^2, 1 ) );
[~,nn_index] = sort(all_norms);