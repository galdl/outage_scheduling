function [h ] = plotFill( meanValues,std,color,opacity,lowerStd,trunc_max,trunc_min,x_vals )   
meanValues=meanValues(:);
std=std(:);
x_f=1:length(meanValues);
if(nargin>=8) %x_vals exists
   x_f=x_vals;
end
x_b=fliplr(x_f);
y_f=meanValues'+std';
if(nargin>=6) %trunc_max exists
    y_f = min(y_f,trunc_max);
end
if(nargin>4 && ~isempty(lowerStd))
    lowerStd = lowerStd(:);
    y_b=fliplr(meanValues'-lowerStd');
else
    y_b=fliplr(meanValues'-std');
    if(nargin>=7) %trunc_min exists
       y_f = max(y_b,trunc_min);
    end
end
h=fill([x_f,x_b],[y_f,y_b],color,'edgecolor','none');
set(h,'facealpha',opacity);
hold on;
if(nargin>=8) %x_vals exists
   plot(x_vals,meanValues,color);
else
   plot(meanValues,color);
end

end

