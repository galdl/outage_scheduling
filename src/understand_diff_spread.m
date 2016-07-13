N=1e6;
drawn_reliability = rand(N,params.horizon);
diff_reliability = drawn_reliability(1:end-1,:) - drawn_reliability(2:end,:);
all_norms = sqrt( sum( diff_reliability.^2, 2 ) );
hist(all_norms,100);
mean(all_norms)
std(all_norms)
