function [h ] = plotFill( meanValues,std,color,opacity,lowerStd )
meanValues=meanValues(:);
std=std(:);
x_f=1:length(meanValues);
x_b=fliplr(x_f);
y_f=meanValues'+std';
if(nargin>4)
    lowerStd = lowerStd(:);
    y_b=fliplr(meanValues'-lowerStd');
else
    y_b=fliplr(meanValues'-std');
end
h=fill([x_f,x_b],[y_f,y_b],color,'edgecolor','none');
set(h,'facealpha',opacity);
hold on;
plot(meanValues,color);

end

