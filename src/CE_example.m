rho = 0.05;

% y = rand(6*12,1)<0.15;
n = length(y(:));
p = 0.5*ones(size(y(:)));
N=100;

for i=1:10
X = rand(length(y(:)),N)<repmat(p,1,N); %ralizations of bernoulli w.p p
S = n-sum(abs(repmat(y(:),1,N)-X));
[S_sorted,I] = sort(S);

topI = I(ceil(N*(1-rho)):end);

p = sum(X(:,topI),2)/length(topI);
reshape(p,[6,12])
end

reshape(y,[6,12])