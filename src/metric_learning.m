% run investigate_sample_matrix first to clean up the data

[x,y] = generate_sample_set_from_db(final_db,sample_matrix);

%generate J^2 pairs
sigmas = linspace(0.011,0.016,7);
sigmas = 0.0127; %cross validation is done by choosing the most variant solution
Q=[];

J = 100;
[x_pairs_raw,y_pairs_raw] = generate_pairs(x,y,J);
x_pairs = (x_pairs_raw - repmat(mean(x_pairs_raw,2),[1,size(x_pairs_raw,2)]))./repmat(std(x_pairs_raw,[],2),[1,size(x_pairs_raw,2)]);
y_pairs = (y_pairs_raw - repmat(mean(y_pairs_raw,2),[1,length(y_pairs_raw)]))./repmat(std(y_pairs_raw,[],2),[1,length(y_pairs_raw)]);
% x_pairs = x_pairs(1:38,:,:);
m = size(x_pairs,1);
N = length(y_pairs);
% sigma = max(abs(y_pairs(1,:)-y_pairs(2,:)));
for k=1:length(sigmas)

    sigma = sigmas(k);
    coeff = exp(-(y_pairs(1,:)-y_pairs(2,:)).^2/(sigma^2));
    c_full = (x_pairs(:,:,1)-x_pairs(:,:,2)).^2*coeff';
    idx_nonz = (~isnan(c_full));
    c = c_full(idx_nonz);
    % obj = @(q) (sum(coeff.*sum(repmat(q.^2,[1,N]).*(x_pairs(:,:,1)-x_pairs(:,:,2)).^2,1)));
    ub =[];
    lb = zeros(size(c));
    q_learned = linprog(c,[],[],[],[],lb,ub);

    % options = optimoptions('fmincon','Algorithm','interior-point');
    % %trust-region-reflective %interior-point, sqp

%     q0 = rand(size(x_pairs,1),1);
%     options = optimoptions('fmincon','Display','iter','Algorithm','trust-region-reflective');
%     % q_learned = fmincon(obj,q,[],[],[],[],[],[],[],options);
%     q_learned = fmincon(obj,q0,[],[],[],[],[],[],[],options);
    Q=[Q,q_learned];
end


q_learned_b = q_learned;
%% test if makes sense

norm(x_pairs(idx_nonz,1,1)-x_pairs(idx_nonz,2,1))
sqrt(ones(1,sum(idx_nonz))*(x_pairs(idx_nonz,1,1)-x_pairs(idx_nonz,2,1)).^2)
sqrt(q_learned'*(x_pairs(idx_nonz,1,1)-x_pairs(idx_nonz,2,1)).^2)
