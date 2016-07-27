function relative_std = calc_relative_std(NN_uc_sample_vec)
% calculate the ratio of std/mean of the nearest neighbours


obj_values = zeros(length(NN_uc_sample_vec),1);
for i_ucSample = 1:length(NN_uc_sample_vec)
    obj_values(i_ucSample) = NN_uc_sample_vec{i_ucSample}.objective;
end
positive_values = obj_values(obj_values>0);
relative_std = std(positive_values)/mean(positive_values);