function [x_pairs,y_pairs] = generate_pairs(x,y,J)
y = y(:); y = y'; %make y a row. x is suppose to have the samples in columns
num_samples = length(y);
N = J * num_samples;
permuted = randperm(num_samples);
set_idx = permuted(1:J);
set_y = y(set_idx);
set_x = x(:,set_idx);

y_pairs = zeros(2,N);
x_pairs = zeros(size(x,1),N,2);

y_pairs(1,:) = repmat(y,[1,J]);
y_pairs(2,:) = repmat(set_y,[1,num_samples]);

x_pairs(:,:,1) = repmat(x,[1,J]);
x_pairs(:,:,2) = repmat(set_x,[1,num_samples]);

