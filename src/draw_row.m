function [drawn_row,shrinkage_vec] = draw_row(p_row,num_of_maintenances,shrinkage_vec,epsilon,params)

p_row = p_row.*shrinkage_vec;
subsets = nchoosek(1:length(p_row),num_of_maintenances);
log_one_minus_p = log(max(1-p_row,epsilon));
log_p = log(max(p_row,epsilon));
if(num_of_maintenances<2)
    log_p_vec = sum(log_one_minus_p) - log_one_minus_p' + log_p';
else
    log_p_vec = sum(log_one_minus_p) - sum(log_one_minus_p(subsets),2) + sum(log_p(subsets),2);
end
p_vec = exp(log_p_vec);
p_vec_normalized = p_vec/sum(p_vec);
drawn_subset = mnrnd(1,p_vec_normalized,1);
drawn_row = zeros(size(p_row));
drawn_row(subsets(find(drawn_subset),:)) = 1;
shrinkage_vec(find(drawn_row)) = shrinkage_vec(find(drawn_row))*params.shrinkage_factor;
