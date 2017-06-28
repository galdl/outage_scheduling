%% initialization
close all;
num_of_plots = 3;
fontSize=15; %10
fontSizeAxes=15; %10
opacity=0.12;
values = zeros(num_of_plots,i_CE-1,3);
%% value extraction
for j=1:i_CE-1
    stats=cell(6,1);
    for i = 1:length(cell2mat(bestPlanVecTemp(4,:,j)))
        if(~isempty(bestPlanVecTemp{4,i,j}))
            c=c+1;
            stats{1}=[stats{1}, bestPlanVecTemp{4,i,j}];
            stats{2}=[stats{2},bestPlanVecTemp{7,i,j}];
            stats{3}=[stats{3},bestPlanVecTemp{8,i,j}]; %success rate values
            stats{4} = [stats{4},K*success_rate_barrier(bestPlanVecTemp{8,i,j},barrier_struct,params.alpha,1)];
            stats{5}=[stats{5},bestPlanVecTemp{6,i,j}]; %lost load
            if(~isempty(bestPlanVecTemp{9,i,j}))              %one-time fix. remove after used onces (happened since I(j_plan) was not originally used for bestPlanVecTemp{9,i,j})
                stats{6}=[stats{6},bestPlanVecTemp{9,i,j}]; %relative std
            end
        end
    end
    data_to_present = [stats{1}+stats{4};stats{1}-stats{5}*params.VOLL;stats{3}];
    values(:,j,1) = median(data_to_present,2);
    %values(:,j,2) = std([stats{1}-stats{5}*params.VOLL;stats{3};stats{1}+stats{4}],[],2);
    [values(:,j,2),values(:,j,3)] = calc_percentiles(data_to_present,0.75,0.25);
end
%% plot graphs
figure(9);
titles={'Objective values','Oper. costs (RD,WC)','Success rate'};
%this is averaged over months (average planValues per month)
for i_plot=1:num_of_plots
    subplot(1,3,i_plot);
    plotFill(values(i_plot,:,1),values(i_plot,:,2),'b',opacity,values(i_plot,:,3));
    set(gca,'fontsize',fontSizeAxes );
    xlabel('Iteration', 'FontSize', fontSize)
    title(titles{i_plot},'FontSize',fontSize);
    if(i_plot ~= 2)
        ylabel('USD $', 'FontSize', fontSize)
    end
end
set(gcf,'name','Medians with upper and lower quartiles','numbertitle','off')

%% plot histograms
figure(11);
xyHandles = zeros(1,i_CE-1);
%this is averaged over months (average planValues per month)
x_min = 1;
for i_plot=1:i_CE-1
    xyHandles(i_plot) = subplot(4,4,i_plot);
    set(gca,'FontSize',25 );
    [n1,x1] = hist(cell2mat(bestPlanVecTemp(8,:,i_plot)),150);
    x_min = min(x_min,min(x1));
    bar(x1,n1/sum(n1));
    title(num2str(i_plot));
    if(i_plot==1)
        xlabel('Average Sucess Rate', 'FontSize', fontSize)
    end
end

linkaxes(xyHandles,'xy');
ylim([0,0.11]);
xlim([0,1]);
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',15, 'LineWidth', 2);
set(gcf,'name','Histograms of sucess rate across iterations','numbertitle','off')
%% gather frequency of repair matrix
numSize=15;
N_iter=i_CE-1;
if(strcmp(params.caseName,'case96'))
    full_case_name = 'IEEE RTS-96';
else full_case_name = 'IEEE RTS-79';
end
N_plans=zeros(length(N_iter),1);
for i_iter=1:N_iter
    N_plans(i_iter)=length(bestPlanVec{i_iter});
end
mat=zeros([planSize,N_iter]);
h=figure;
ax=zeros(N_iter,1);
to_show = [1,4,6,9,13,15]; %96: [1,4,6,9,13,15],79:[1,4,6,9,13,15]
to_show = 1:12; 

subplot_length=length(to_show);
% for i_iter=1:N_iter
subplot(2,subplot_length,1);
title(['Schedule convergence for ',full_case_name],'FontSize',fontSize+4);

c=0;
for i_iter=to_show
    c=c+1;
    for i_plan=1:N_plans(i_iter)
        if(~isempty(bestPlanVec{i_iter}{1,i_plan}))
            mat(:,:,i_iter)=mat(:,:,i_iter)+bestPlanVec{i_iter}{1,i_plan};
        end
    end
    %     mat(:,:,i_iter)=min(1,mat(:,:,i_iter)./repmat(max(sum(mat(:,:,i_iter),1),epsilon),planSize(1),1));
    mat(:,:,i_iter)=mat(:,:,i_iter)./(N_plans(i_iter)*ones(planSize));
%     ax(i_iter)=subplot(2,6,c+6);
    ax(i_iter)=subplot(1,subplot_length,c);
    imagesc(mat(find(sum(params.requested_outages,2)),:,i_iter));
    title(num2str(i_iter),'FontSize',fontSize);
    %    imagesc(mat(:,:,i_iter));
    colormap('gray')
    colormap(flipud(colormap)); caxis([0,1]);
    set(ax(i_iter), 'fontsize', numSize);
    set(findobj(ax(i_iter),'Type','text'),'FontSize',  numSize);
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    if(i_iter==1)
        xlabel('Month', 'FontSize', fontSize)
        ylabel('Asset Index', 'FontSize', fontSize)
        colorbar;
    end
end


