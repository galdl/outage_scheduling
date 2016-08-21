function varargout = scatterheat(x,y,varargin)
% [handle, matrix] = scatterheat(x,y,varargin)
%  Create a heat map of the scattplot of vector y against vector x.
% ------------------------------------------------------------------------
% VARIABLE INPUTS (varargin) 
%    - 'xgrid' Manually define length of grid intervall on x-axis. 
%    - 'ygrid' Manually define length of grid intervall on y-axis
%    - 'xpos' Manually define the position of a grid line on the x-axis
%    - 'ypos' Manually define the position of a grid line on the y-axis
%    - 'colorrange' Allows to narrow the color range.
%                   Scalar between 200 (default) and 1 
%                   which represents number of colors in scale.
%    - 'colorbar' Flag to indicate if a (log)colorbar should be displayed.
%                 0 -> no colorbar (default)
%                 1 -> colorbar
% ------------------------------------------------------------------------
% OUTPUT
%    - handle Image handle.
%    - matrix Matrix from which plot is created
% ------------------------------------------------------------------------
% % EXAMPLES
%  x1=[];
%  x2=[];
%  y1=[];
%  y2=[];
%  for i=1:10
%      x1=[x1 i*randn(1,round(1000/i))/2];
%      x2=[x2 2+i*randn(1,round(1000/i))/2];
%      y1=[y1 i*randn(1,round(1000/i))/2];
%      y2=[y2 2+i*randn(1,round(1000/i))/2];
%  end
%  x=[x1 x2];
%  y=[y1 y1];
%  plot(x,y,'*');
%  figure
%  scatterheat(x,y,'colorbar',1);
%  figure
%  scatterheat(x,y,'colorbar',1,'colorrange',140);
%  figure
%  scatterheat(x,y,'xgrid',1,'ygrid',1,'colorbar',1,'colorrange',140);
%  figure
%  scatterheat(x,y,'xgrid',5,'ygrid',5,'colorrange',75,'colorbar',1);
%  figure
%  scatterheat(x,y,'xgrid',5,'ygrid',5,'colorrange',75,'colorbar',1,'xpos',2.5);
% ------------------------------------------------------------------------
% TIP
%    For an interesting and meaningful result it might be useful to
%    try different values for 'xgrid', 'ygrid' and especially 'colorrange'.
%
% ========================================================================
%                    Background Information
% ------------------------------------------------------------------------
%  Function to create scatter heat plots.
%  
%    Stephanie Lackner                   Version 1.5
%    www.columbia.edu/~sl3382            May 1, 2014
%    sl3382@columbia.edu           
% ========================================================================

%% Get information from input
if mod(nargin,2)
    error('Every input parameter must have a value! \n');
end

param=struct();
for i=1:((nargin-2)/2)
    name=varargin{2*i-1};
    value=varargin{2*i};
    param=setfield(param,name,value);
end

l=length(x);

%% Define parameters

% Reference scatter plot
plot(x,y,'*');
xticks=get(gca,'xtick');
yticks=get(gca,'ytick');

% Axis Limits
if min(y)<=yticks(1)
    y_low=min(y);
else
    y_low=yticks(1);
end
if min(x)<=xticks(1)
    x_low=min(x);
else
    x_low=xticks(1);
end
if max(y)>=yticks(end)
    y_up=max(y);
else
    y_up=yticks(end);
end
if max(x)>=xticks(end)
    x_up=max(x);
else
    x_up=xticks(end);
end

% Grid Size
if isfield(param,'xgrid')
    xgrid=param.xgrid;
else
    xgrid=(x_up-x_low)/100;
end
if isfield(param,'ygrid')
    ygrid=param.ygrid;
else
    ygrid=(y_up-y_low)/100;
end

% Adjust grid position
if isfield(param,'ypos');
    dist=param.ypos-y_low;
    if dist>0
        y_low=param.ypos-ygrid*ceil(dist/ygrid);
    else
        y_low=param.ypos;
    end
    num_y=ceil((y_up-y_low)/ygrid);
    y_up=y_low+num_y*ygrid;
end
if isfield(param,'xpos');
    dist=param.xpos-x_low;
    if dist>0
        x_low=param.xpos-xgrid*ceil(dist/xgrid);
    else
        x_low=param.xpos;
    end
    num_x=ceil((x_up-x_low)/xgrid);
    x_up=x_low+num_x*xgrid;
end

n=round((y_up-y_low)/ygrid);
m=round((x_up-x_low)/xgrid);

%% Create Heat Scatter Plot
matrix=zeros(n,m);

for i=1:l  
    mi=ceil((x(i)-x_low)/xgrid);
    if mi==0
        mi=1;
    end
    ni=ceil((y(i)-y_low)/ygrid);
    if ni==0
        ni=1;
    end
    matrix(ni,mi)=matrix(ni,mi)+1;
end

%NaN value (for colorrange)
maxs=max(max(matrix));
mins=min(setdiff(matrix,min(matrix)));

if isfield(param,'colorrange')
    if param.colorrange<1 || param.colorrange>200
        error('colorrange has to be between 1 and 200');
    end
    scale=param.colorrange; 
else
    scale=200;
end
color_distance=(maxs-mins)/scale;
nanpoint=mins-(201-scale)*color_distance;
matrix(matrix==0)=min(0,nanpoint);

handle=imagesc([x_low+xgrid/2 x_up-xgrid/2],[y_low+ygrid/2 y_up-ygrid/2],matrix);
set(gca,'YDir','normal');

% Axis Definition
if max(x)>=x_up
    x_up=x_up+xgrid;
end
if max(y)>=y_up
    y_up=y_up+ygrid;
end
if min(x)<=x_low
    x_low=x_low-xgrid;
end
if min(y)<=y_low
    y_low=y_low-ygrid;
end
axis([x_low x_up y_low y_up]);

colormap([1 1 1; jet(200)]);

if isfield(param,'colorbar')
    if param.colorbar==1
        cbar_ax=colorbar;
        clim=get(cbar_ax,'ylim');
        if scale==200
            set(cbar_ax,'ylim',[0 clim(2)]);
        else
            set(cbar_ax,'ylim',[mins clim(2)]);
        end
    end
end

for k = 1:nargout
    if k==1
        varargout{k} = handle;
    elseif k==2
        varargout{k} = matrix;
    end
end

end










