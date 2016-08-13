function [h ] = plotFill( meanValues,std,color,opacity )
meanValues=meanValues(:);
std=std(:);
x_f=1:length(meanValues);
x_b=fliplr(x_f);
y_f=meanValues'+std';
y_b=fliplr(meanValues'-std');
h=fill([x_f,x_b],[y_f,y_b],color,'edgecolor','none');
set(h,'facealpha',opacity);
hold on;
plot(meanValues,color);

end

