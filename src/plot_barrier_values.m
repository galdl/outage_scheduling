values = zeros(4,i_CE-1);
o1=[];o2=[];o3=[];
for j=1:i_CE-1
    for i = 1:length(S_sorted)
        if(~isempty(bestPlanVecTemp{K,i,j}))
            c=c+1;
            o1=[o1, bestPlanVecTemp{4,i,j}];
            o2=[o2,bestPlanVecTemp{7,i,j}];
            %             o3=[o3,bestPlanVecTemp{8,i,j}];
        end
        o3 = zeros(size(o2));
    end
    values(:,j) = mean([o1;o2;o3;o1+o2],2);
end
figure(10);
titles={'planValues','success rate barrier values','success rate values','overall objective values'};
figure;
for i_plot=1:4
    subplot(2,2,i_plot);
    plot(values(i_plot,:));
    title(titles{i_plot});
end

%% reconstruct o3 - for the experiment done when it wasn't available
o3_values = zeros(1,i_CE-1);

for j=1:i_CE-1
    o3=[];
    for i = 1:length(S_sorted)
        if(~isempty(bestPlanVecTemp{7,i,j}))
            o2_curr_val = bestPlanVecTemp{7,i,j};
            syms t
            eqn = (1/j)*(0.5*(j*(t-params.alpha)*barrier_struct.x0/(1-params.alpha))^2 + (j*(t-params.alpha)*barrier_struct.x0/(1-params.alpha))) == o2_curr_val;
            res = solve(eqn,t);
            res_val = double(res);
            o3_curr_val = res_val(res_val>0);
            o3 = [o3,o3_curr_val];
            j
            i
        end
    end
    o3_values(j) = mean(o3);
end

values(3,:) = o3_values;
% and now run the subplot again to include o3

