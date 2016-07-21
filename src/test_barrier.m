P=20;
x=-10:10;
lambda = ones(size(x));
figure(1);
xyHandles=zeros(P,1);

for p=1:P
    xyHandles(p)=subplot(4,5,p);
%     plot(x,phi_p(x,p,lambda)); 
    [v,idx] = sort(succes_rate_barrier(success_rate_values,barrier_struct,params.alpha,p));
    plot(success_rate_values(idx),v);
end
linkaxes(xyHandles,'xy');
