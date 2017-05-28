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
    imagesc(mat(find(sum(params.requested_outages,2)),:,i_iter));
%     imagesc(mat(:,:,i_iter));
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