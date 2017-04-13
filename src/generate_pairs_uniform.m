function [x_pairs,y_pairs] = generate_pairs_uniform(x,y,J)
y = y(:); y = y'; %make y a row. x is suppose to have the samples in columns
num_samples = length(y);
N = J * num_samples;
pair_idx = round((num_samples-1)*rand(2,N))+1;


x_pairs = zeros(size(x,1),N,2);
y_pairs = [y(pair_idx(1,:));y(pair_idx(2,:))];

x_pairs(:,:,1) = x(:,pair_idx(1,:));
x_pairs(:,:,2) = x(:,pair_idx(2,:));

