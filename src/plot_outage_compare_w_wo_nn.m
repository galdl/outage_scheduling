% load(return_compare_folder('compare_run_2017-03-26-13-44-32--1--case24')); % NN
% monthlyCost_nn = monthlyCost;
% monthly_success_rate_values_nn = monthly_success_rate_values;
% monthly_lost_load_nn = monthly_lost_load;
% monthlyCost_DA_nn = monthlyCost_DA;
% monthly_lost_load_DA_nn = monthly_lost_load_DA;
% load(return_compare_folder('compare_run_2017-03-26-12-14-27--1--case24')); %no-NN
%% show comparison between no-outage to all (or two) plans

fontSize=15; %10
fontSizeAxes=15; %10
opacity=0.12;
sz = [4,6];
% close all;
figure;
for i_plan = 2:5
    %     i_fig = 1+mod(i_plan-1,4);
    if(mod(i_plan,sz(1))==1)
        set(gcf,'name','Compare operational costs (deduced lost load) -  no outages and outage plan 1','numbertitle','off')
    end
    i_column = 1 + mod(i_plan-1,sz(1));
    i_row = 1;
    loc = sub2ind(sz,i_column,i_row);
    subplot(sz(2),sz(1),loc);
    %% monthly cost fill plots
    %     set(gcf,'name','Compare operational costs (deduced lost load) -  no outages and outage plan 1','numbertitle','off')
    plotFill(monthlyCost(1,:,1),monthlyCost(1,:,2),'r',opacity);
    hold on;
    plotFill(monthlyCost(i_plan,:,1),monthlyCost(i_plan,:,2),'b',opacity);
    plotFill(monthlyCost_nn(i_plan,:,1),monthlyCost(i_plan,:,2),'g',opacity);
    hold off;
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    set(gca,'fontsize',fontSizeAxes );
    %     title('Monthly operational cost (deduced lost load) comparison','FontSize', 17);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Operational cost [$]', 'FontSize', fontSize)
    
    %% success rates
    i_row = 2;
    loc = sub2ind(sz,i_column,i_row);
    subplot(sz(2),sz(1),loc);
    %     set(gcf,'name','Compare success rates - no outages and outage plan 1','numbertitle','off')
    plotFill(monthly_success_rate_values(1,:,1),monthly_success_rate_values(1,:,2),'r',opacity);
    hold on;
    plotFill(monthly_success_rate_values(i_plan,:,1),monthly_success_rate_values(i_plan,:,2),'b',opacity);
    plotFill(monthly_success_rate_values_nn(i_plan,:,1),monthly_success_rate_values(i_plan,:,2),'g',opacity);
    hold off;
    
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    set(gca,'fontsize',fontSizeAxes );
    %     title('Monthly success rate comparison','FontSize', 17);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Sucess rate', 'FontSize', fontSize)
    
    %% lost load
    i_row = 3;
    loc = sub2ind(sz,i_column,i_row);
    subplot(sz(2),sz(1),loc);
    %     set(gcf,'name','Compare lost loads - no outages and outage plan 1','numbertitle','off')
    plotFill(monthly_lost_load(1,:,1),monthly_lost_load(1,:,2),'r',opacity);
    hold on;
    plotFill(monthly_lost_load(i_plan,:,1),monthly_lost_load(i_plan,:,2),'b',opacity);
    plotFill(monthly_lost_load_nn(i_plan,:,1),monthly_lost_load(i_plan,:,2),'g',opacity);
    hold off;
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    set(gca,'fontsize',fontSizeAxes );
    %     title('Monthly lost load comparison','FontSize', 17);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Lost load', 'FontSize', fontSize)
    %% cost  - DA
    i_row = 4;
    loc = sub2ind(sz,i_column,i_row);
    subplot(sz(2),sz(1),loc);
    %     set(gcf,'name','Compare lost loads - no outages and outage plan 1','numbertitle','off')
    plotFill(monthlyCost_DA(1,:,1),monthlyCost_DA(1,:,2),'r',opacity);
    hold on;
    plotFill(monthlyCost_DA(i_plan,:,1),monthlyCost_DA(i_plan,:,2),'b',opacity);
    plotFill(monthlyCost_DA_nn(i_plan,:,1),monthlyCost_DA(i_plan,:,2),'g',opacity);
    hold off;
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    set(gca,'fontsize',fontSizeAxes );
    %     title('Monthly lost load comparison','FontSize', 17);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('DA Cost', 'FontSize', fontSize)
    %% lost load - DA
    i_row = 5;
    loc = sub2ind(sz,i_column,i_row);
    subplot(sz(2),sz(1),loc);
    %     set(gcf,'name','Compare lost loads - no outages and outage plan 1','numbertitle','off')
    plotFill(monthly_lost_load_DA(1,:,1),monthly_lost_load_DA(1,:,2),'r',opacity);
    hold on;
    plotFill(monthly_lost_load_DA(i_plan,:,1),monthly_lost_load_DA(i_plan,:,2),'b',opacity);
    plotFill(monthly_lost_load_DA_nn(i_plan,:,1),monthly_lost_load_DA(i_plan,:,2),'g',opacity);
    hold off;
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    set(gca,'fontsize',fontSizeAxes );
    %     title('Monthly lost load comparison','FontSize', 17);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('DA Lost load', 'FontSize', fontSize)
    %% overall costs - most important
    i_row = 6;
    loc = sub2ind(sz,i_column,i_row);
    subplot(sz(2),sz(1),loc);
    %     set(gcf,'name','Compare lost loads - no outages and outage plan 1','numbertitle','off')
    plotFill(monthlyCost_DA(1,:,1)+monthlyCost(1,:,1)+(monthly_lost_load(1,:,1)+monthly_lost_load_DA(1,:,1))*params.VOLL,...
        monthlyCost_DA(1,:,2)+monthlyCost(1,:,2)+(monthly_lost_load(1,:,2)++monthly_lost_load_DA(1,:,2))*params.VOLL,'r',opacity);
    hold on;
    plotFill(monthlyCost_DA(i_plan,:,1)+monthlyCost(i_plan,:,1)+(monthly_lost_load(i_plan,:,1)+monthly_lost_load_DA(i_plan,:,1))*params.VOLL,...
       monthlyCost_DA(i_plan,:,2)+monthlyCost(i_plan,:,2)+(monthly_lost_load(i_plan,:,2)+monthly_lost_load_DA(i_plan,:,2))*params.VOLL,'b',opacity);
   plotFill(monthlyCost_DA_nn(i_plan,:,1)+monthlyCost_nn(i_plan,:,1)+(monthly_lost_load_nn(i_plan,:,1)+monthly_lost_load_DA_nn(i_plan,:,1))*params.VOLL,...
       monthlyCost_DA_nn(i_plan,:,2)+monthlyCost_nn(i_plan,:,2)+(monthly_lost_load_nn(i_plan,:,2)+monthly_lost_load_DA_nn(i_plan,:,2))*params.VOLL,'g',opacity);
    hold off;
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    set(gca,'fontsize',fontSizeAxes );
    %     title('Monthly lost load comparison','FontSize', 17);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Overall costs [$]', 'FontSize', fontSize)
end
%% show comparison between no-outage to a single (or two) plans
show = 0;
if(show)
    figure;
    i_plan_compare = 5;
    subplot(3,1,1);
    %% monthly cost fill plots
    set(gcf,'name','Compare operational costs (deduced lost load) -  no outages and outage plan 1','numbertitle','off')
    opacity=0.12;
    plotFill(monthlyCost(1,:,1),monthlyCost(1,:,2),'r',opacity);
    hold on;
    plotFill(monthlyCost(i_plan_compare,:,1),monthlyCost(i_plan_compare,:,2),'b',opacity);
    %     plotFill(monthlyCost(8,:,1),monthlyCost(8,:,2),'g',opacity);
    hold off;
    if(strcmp(params.caseName,'case96'))
        plan_legend = 2;
    else plan_legend = 1;
    end
    legend({'No outages - std','No outages - mean',['Outage plan ',num2str(plan_legend),' - std'],['Outage plan ',num2str(plan_legend),' - mean']});
    fontSize=25;
    set(gca,'fontsize',fontSize);
    title('Monthly operational cost (deduced lost load) comparison','FontSize', fontSize);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Operational cost[$]', 'FontSize', fontSize)
    xlim([1,params.numOfMonths]);
    %% success rates
    subplot(3,1,2);
    
    set(gcf,'name','Compare success rates - no outages and outage plan 1','numbertitle','off')
    opacity=0.12;
    plotFill(monthly_success_rate_values(1,:,1),monthly_success_rate_values(1,:,2),'r',opacity);
    hold on;
    plotFill(monthly_success_rate_values(i_plan_compare,:,1),monthly_success_rate_values(i_plan_compare,:,2),'b',opacity);
    %     plotFill(monthly_success_rate_values(8,:,1),monthly_success_rate_values(8,:,2),'g',opacity);
    hold off;
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    set(gca,'fontsize',fontSize);
    title('Monthly success rate comparison','FontSize', fontSize);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Sucess rate', 'FontSize', fontSize)
    xlim([1,params.numOfMonths]);
    %% lost load
    subplot(3,1,3);
    
    set(gcf,'name','Compare lost loads - no outages and outage plan 1','numbertitle','off')
    opacity=0.12;
    plotFill(monthly_lost_load(1,:,1),monthly_lost_load(1,:,2),'r',opacity);
    hold on;
    plotFill(monthly_lost_load(i_plan_compare,:,1),monthly_lost_load(i_plan_compare,:,2),'b',opacity);
    %     plotFill(monthly_lost_load(8,:,1),monthly_lost_load(8,:,2),'g',opacity);    hold off;
    %     legend({'No outages - std','No outages - mean','Outage plan 1 - std','Outage plan 1 - mean'});
    title('Monthly lost load comparison','FontSize', fontSize);
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Lost load', 'FontSize', fontSize)
    xlim([1,params.numOfMonths]);
    %% show maintenance plan we compare to
    figure;
    imagesc(mPlanBatch(:,:,i_plan_compare));
    colormap('gray')
    colormap(flipud(colormap)); caxis([0,1]);
    %     set(ax(i_iter), 'fontsize', numSize);
    %     set(findobj(ax(i_iter),'Type','text'),'FontSize',  numSize);
    set(gca,'fontsize',fontSize);
    % set(gca,'xtick',[])
    % set(gca,'ytick',[])
    xlabel('Month', 'FontSize', fontSize)
    ylabel('Asset Index', 'FontSize', fontSize)
    title(['Visualization of outage plan ',num2str(i_plan_compare)]);
    % colorbar;
end

% ideas:
% show how many recommitments have been done (portion)
% show stack plot of price dist. - load shedding, dynamic load shedding, operational, etc.
% when optimizing - optimize the difference from no-outages (can use only DA values for low variance)
% output lost load on map
% currently trying to lower the RT std, to see why operational cost can be
% higher for no outages
