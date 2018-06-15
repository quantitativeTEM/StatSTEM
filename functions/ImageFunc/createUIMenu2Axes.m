function createUIMenu2Axes(ax,cbar,refP,data,range,type)
% createUIMenu2Axes - create a menu for colorbar in 2nd axes
%
%   syntax: createUIMenu2Axes(cbar,refScatterP)
%       ax          - reference to 2nd axis
%       cbar        - reference to colorbar
%       refScatterP - reference to plot
%       data        - values shown in plot
%       range       - color range of data [min,max]
%       type        - type of plot ('scatter' or 'quiver')
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<6
    type = 'scatter';
end
switch type
    case 'quiver'
        type = 1;
    otherwise
        type = 2;
end


% Check matlab version
v = version('-release');
v = str2double(v(1:4));

% Find location of main figure
hf = get(refP,'Parent');
stop = 0;
k=0;
while stop==0 && k<100
    k=k+1;
    hInt = get(hf,'Parent');
    if v<2015
        if hInt==0
            stop=1;
        else
            hf=hInt;
        end
    else
        if isa(hInt,'matlab.ui.Root')
            stop=1;
        else
            hf=hInt;
        end
    end
end

% Create uicontextmenu
c = uicontextmenu;
m1 = uimenu(c,'Label','Delete','Callback',{@delBar,ax});
m2 = uimenu(c,'Label','Open Colormap Editor','Callback',{@cmEdit,ax,hf,refP,data,type});
m3 = uimenu(c,'Label','Reset Range Colors','Callback',{@resetCrangeAx2,ax,refP,range,data,type});

set(cbar,'UIContextMenu',c)

function delBar(~,~,ax)
imgP = get(ax,'Parent');
child = get(imgP,'Children');
warning('off','all') % For old versions MATLAB
% Find old colorbar references and remove them
for i=1:length(child)
    if strcmp(get(child(i),'Tag'),'Colorbar')
        delete(child(i))
    end
end
warning('on','all') % For old versions MATLAB

function cmEdit(~,~,ax,hf,ref,data,type)
range = caxis(ax);
cmap = colormap(ax);
pos = get(hf,'Position');
range = setRangeUI(range,[pos(1)+pos(3)/2 pos(2)+pos(4)/2]);
caxis(ax,range)
c_x = linspace(range(1),range(2),size(cmap,1));
RGBvec = getRGBvec(cmap,c_x,data,'exact');
if type==1
    set(ref,'FaceVertexCData',RGBvec)
else
    set(ref,'CData',RGBvec)
end

function resetCrangeAx2(~,~,ax,ref,range,data,type)
caxis(ax,range);
cmap = colormap(ax);
c_x = linspace(range(1),range(2),size(cmap,1));
RGBvec = getRGBvec(cmap,c_x,data,'exact');
if type==1
    set(ref,'FaceVertexCData',RGBvec)
else
    set(ref,'CData',RGBvec)
end
