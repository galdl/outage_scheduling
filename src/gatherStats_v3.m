% figure;
bestPlanVec(i_CE:end)=[];
N_iter=length(bestPlanVec);
allCosts=cell(N_iter,1);
allLL=cell(N_iter,1);

objectiveStd=zeros(N_iter,1);
objectiveMean=zeros(N_iter,1);
LLMean=zeros(N_iter,1);
LLStd=zeros(N_iter,1);

percentile=1:25;

for i_iter=1:N_iter
    %     xHandles(i_iter)=subplot(ceil(sqrt(N_iter)),ceil(sqrt(N_iter)),i_iter);
    %         currentHandle=subplot(3,3,i_iter);
    title(['Iteration ',num2str(i_iter)]);
    allCosts{i_iter}=cell2mat(bestPlanVec{i_iter}(4,:));
    %         allCosts{i_iter}=cell2mat(bestPlanVec{i_iter}(4,:));
    
    allLL{i_iter}=cell2mat(bestPlanVec{i_iter}(6,:));
    
%     hist(allCosts{i_iter});
    objectiveStd(i_iter)=std(allCosts{i_iter});
    objectiveMean(i_iter)=mean(allCosts{i_iter});
    LLStd(i_iter)=std(allLL{i_iter});
    LLMean(i_iter)=mean(allLL{i_iter});
    %     LLMean(i_iter)*params.VOLL
end
% linkaxes(xHandles,'xy');
%% plot

figure;
errorbar(objectiveMean,objectiveStd,'r');
fontSize=17;
set(gca,'fontsize',20);
title('Convergence of 0.15-percentile of Objective Value','FontSize', 17);
xlabel('Iteration Count', 'FontSize', fontSize)
ylabel('Objective Cost[$]', 'FontSize', fontSize)
% xlim([0,11])
figure;
errorbar(LLMean,LLStd,'r');
fontSize=17;
set(gca,'fontsize',16);
title('Convergence of 0.15-percentile of LL Value','FontSize', 14);
xlabel('Iteration Count', 'FontSize', fontSize)
ylabel('Objective Cost[$]', 'FontSize', fontSize)
% hold on;
% errorbar(2.75e6*ones(size(objectiveMean)),3e4*ones(size(objectiveMean)));
% hold off;
% legend({'Optimization solutions','Oldest-first'})
%% save all-costs vectors from different runs and plot histograms
% bus0to5=cell2mat(bestPlanVec{i_iter}(4,:));
figure;
[ xHandle1 ] = plotPdf( 1,bus0to5);
[ xHandle2 ] = plotPdf( 2,bus2to5);
[ xHandle3 ] = plotPdf( 3,bus3to5);
linkaxes([xHandle1,xHandle2,xHandle3],'xy');
%% plot all convergences in one figure
figure;
% objectiveMeanNoProjects=objectiveMean;
% objectiveStdNoProjects=objectiveStd;

% objectiveMeanProject2to5=objectiveMean;
% objectiveStdProject2to5=objectiveStd;

% objectiveMeanProject3to5=objectiveMean;
% objectiveStdProject3to5=objectiveStd;

errorbar(objectiveMeanNoProjects,objectiveStdNoProjects);
hold on;
errorbar((1:length(objectiveMeanProject2to5))+0.1,objectiveMeanProject2to5,objectiveStdProject2to5);
hold on;
errorbar((1:length(objectiveMeanProject3to5))+0.2,objectiveMeanProject3to5,objectiveStdProject3to5);
hold off;
fontSize=17;
set(gca,'fontsize',20);
title('Convergence of 0.15-percentile of Objective Value','FontSize', 17);
xlabel('Iteration Count', 'FontSize', fontSize)
ylabel('Objective Cost[$]', 'FontSize', fontSize)
%% fill
figure;
opacity=0.12;
 plotFill(objectiveMeanNoProjects,objectiveStdNoProjects,'r',opacity);
 hold on;
 plotFill( objectiveMeanProject2to5,objectiveStdProject2to5,'b',opacity);
 plotFill( objectiveMeanProject3to5,objectiveStdProject3to5,'g',opacity);
hold off;
legend({'No projects - std','No projects - mean','Project 1 - std','Project 1 - mean','Project 2 - std','Project 3 - mean'});
fontSize=17;
set(gca,'fontsize',20);
title('Convergence of Objective Value for Asset Management Optimization using Cross-Entropy','FontSize', 17);
xlabel('Iteration Count', 'FontSize', fontSize)
ylabel('Objective Cost[$]', 'FontSize', fontSize)
%% gather frequency of repair matrix
numSize=10;
fontSize=17;
N_iter=i_CE-1;

N_plans=zeros(length(N_iter),1);
for i_iter=1:N_iter
    N_plans(i_iter)=length(bestPlanVec{i_iter});
end
mat=zeros([planSize,N_iter]);
figure;
ax=zeros(N_iter,1);
for i_iter=1:N_iter
    for i_plan=1:N_plans(i_iter)
        if(~isempty(bestPlanVec{i_iter}{1,i_plan}))
            mat(:,:,i_iter)=mat(:,:,i_iter)+bestPlanVec{i_iter}{1,i_plan};
        end
    end
    %     mat(:,:,i_iter)=min(1,mat(:,:,i_iter)./repmat(max(sum(mat(:,:,i_iter),1),epsilon),planSize(1),1));
    mat(:,:,i_iter)=mat(:,:,i_iter)./(N_plans(i_iter)*ones(planSize));
    ax(i_iter)=subplot(3,5,i_iter);
    imagesc(mat(find(params.requested_outages),:,i_iter));
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


% subplot(2,4,7);
%
%     imagesc(1-oldestFirst);
%     colormap('gray'); caxis([0,1]);
%  set(gca,'xtick',[])
%     set(gca,'ytick',[])
% title('Convergence of 0.15-percentile of Maintenance Plans','FontSize', 14);
% xlabel('Month', 'FontSize', fontSize)
% ylabel('Asset Index', 'FontSize', fontSize)
%% only same plans
percentile=7
obj=cell(N_iter,1);
% c=zeros(N_iter,1);
for i_iter=1:N_iter
    best=bestPlanVec{i_iter}{1,1};
    for j_plan=1:N_plans(i_iter)
        if(sum(abs(bestPlanVec{i_iter}{1,j_plan}-best))==0)
            obj{i_iter}=[obj{i_iter},bestPlanVec{i_iter}{4,j_plan}];
            %         c(i_iter)=c(i_iter)+1;
        end
    end
    mean(obj{i_iter}(1:min(length(obj{i_iter}),percentile)))
    % mean(obj{i_iter})
    % mean(obj{:})
    %     mean(obj{i_iter})
    % obj{i_iter}
    % std(obj{i_iter})
    
end

