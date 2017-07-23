%% load all data
already_loaded = 0;
max_lost_load = sum(params.mpcase.bus(:,PD));
if(~already_loaded)
    multiple_plans_file = '/Users/galdalal/Dropbox (MLGroup)/TeamViewer transfers/compare_100_rand_schedules';
    load(multiple_plans_file);
    rand_vals = [planValues - lostLoad*params.VOLL,100*success_rate_values,100*lostLoad/max_lost_load,lostLoad./success_rate_values];
    optimal_plan_file = '/Users/galdalal/Dropbox (MLGroup)/TeamViewer transfers/case_96_alpha_0.05.mat';
    load(optimal_plan_file);
    num_opt = 10;
    optimal_vals = [planValues(I(1:num_opt)) - lostLoad(I(1:num_opt))*params.VOLL,...
        100*success_rate_values(I(1:num_opt)),100*lostLoad(I(1:num_opt))/max_lost_load,lostLoad(I(1:num_opt))./success_rate_values(I(1:num_opt))];
    optimal_val = [planValues(I(1)) - lostLoad(I(1))*params.VOLL,100*success_rate_values(I(1))/max_lost_load,100*lostLoad(I(1))/max_lost_load];
    all_vals = [rand_vals;optimal_vals];
end

%% plot histograms - 100 random schedules vs. 10 instances of the best schedule
titles = {'Operational Cost [$]','Reliability [%]','Lost Load [%]','Ratio'};
fontSize=20;
% n_bins = length(all_vals);

% figure;
% for i_plot=1:3
%     subplot(3,1,i_plot);
%     [n1,x1] = hist(all_vals(:,i_plot),n_bins);
%     h = bar(x1,diag(n1/sum(n1)),1.5,'stacked'); 
%     for i_b=1:length(rand_vals)
%         set(h(i_b),'facecolor','b') 
%     end
%      for i_b=length(rand_vals)+1:length(all_vals)
%         set(h(i_b),'facecolor','r') 
%     end
%     title(titles{i_plot});
% end
n_bins = 50;
figure;
for i_plot=1:3
    subplot(3,1,i_plot);
    [n1,x1] = hist(rand_vals(:,i_plot),n_bins);
    bar(x1,n1/length(all_vals),0.7,'b'); 
    hold on;
    width = 4;
    if(i_plot == 3)
        n_bins = 3;
        width = 12;
    end
    [n1,x1] = hist(optimal_vals(:,i_plot),2);
    bar(x1,n1/length(all_vals),width,'r'); 
    set(gca,'fontsize',fontSize );
    hold off;
    title(titles{i_plot},'FontSize',fontSize);
    if(i_plot==1)
        legend({'Random schedules','Optimization Solution'},'FontSize', fontSize);
    end
end

xlim(100*[-15,2000]/max_lost_load);

%% plot scatter - 100 random schedules vs. 10 instances of the best schedule
figure;
scatter(rand_vals(:,2),rand_vals(:,3));
hold on;
scatter(optimal_vals(:,2),optimal_vals(:,3),'r');
legend({'Random schedules','Optimization Solution'},'FontSize', fontSize);
xlabel('Reliability [%]', 'FontSize', fontSize)
ylabel('Load Shedding [%]', 'FontSize', fontSize)
set(gca,'fontsize',fontSize );
% LL=zeros(i_CE-1,1);
% SR=zeros(i_CE-1,1);
% for i_iter=1:i_CE-1
%     LL(i_iter) = median(cell2mat(bestPlanVecTemp(6,:,i_iter)));
%     SR(i_iter) = median(cell2mat(bestPlanVecTemp(8,:,i_iter)));
% end
% figure;
% scatter(LL,SR)
% 
% figure;
% axis([min(LL)-1, max(LL)+1, min(SR)-0.1, max(SR)+0.1])
% for k=1:length(LL)
%     text(LL(k),SR(k),num2str(k))
% end