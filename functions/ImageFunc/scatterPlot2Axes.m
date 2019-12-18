function [h,h1,h2] = scatterPlot2Axes(ax,ax2,coordinates,data,range,nameTag,scaleMarker,dataText)
% scatterPlot2Axes - Make a scatter plot with colorbar in second axes
%
% syntax: scatterPlot2Axes(ax,ax2,coordinates,data,range,nameTag,scaleMarker)
%   ax          - reference to first axes
%   ax2         - reference to second axes
%   coordinates - coordinates (2x1 sized vector with [x,y])
%   data        - data for scatter plot
%   range       - minimum and maximum value for color range scatter plot
%   nameTag     - name of the plot
%   scaleMarker - relative scale of the marker size
%   dataText    - String shown for data cursor
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<8
    dataText = 'Value %g';
end

cmap = jet(256);
c_x = linspace(range(1),range(2),size(cmap,1));
RGBvec = getRGBvec(cmap,c_x,data,'exact');

% Check matlab version
v = version('-release');
v = str2double(v(1:4));
% Old version of MATLAB cannot handle two colormaps, convert image to rgb values
if v<2015
    warning('off','all')
    % Change observation back to original non-rgb image
    child = get(ax,'Children');
    warning('on','all')
    for i=1:length(child)
        if strcmp(get(child(i),'Type'),'image')
            obs = get(child(i),'CData');
            if size(obs,3)==1
                minplaneimg = min(min(obs));
                obs = (floor(((obs - minplaneimg) ./ (max(max(obs)) - minplaneimg)) * 255)); 
                obs = ind2rgb(obs,gray(256));
                set(child(i),'CData',obs);
            end
            break
        end
    end
end

% Plot
msize = coorMarkerSize('s',scaleMarker);
hold(ax, 'on')
h=scatter(ax,coordinates(:,1),coordinates(:,2),msize,RGBvec,'filled','Marker','s','Tag',nameTag);
hold(ax,'off')
set(h,'Userdata',{dataText,data}) % For data cursor in StatSTEM

% Plot in second graph for StatSTEM to ensure that it recognises it as the
% active axes for colors
plot(ax2,[],[],'Tag',nameTag)
colormap(ax2,'jet')
caxis(ax2,range);

% Check if underscore is present
loc = strfind(nameTag,'_');
if ~isempty(loc)
    nameTag = [nameTag(1:loc(1)),'{',nameTag(loc(1)+1:end),'}'];
end

% Plot colorbar
if v<2015
    warning('off','all')
    h1 = colorbar('peer',ax);
    set(h1,'Visible','off','HitTest','off')
    drawnow
    pos = get(h1,'Position');
    h2 = colorbar('peer',ax2,'Position',pos);
    if nameTag(1)==char(949)
        nameTag = ['\epsilon',nameTag(2:end)];
    elseif nameTag(1)==char(969)
        nameTag = ['\omega',nameTag(2:end)];
    end
    
    ylabel(h2,nameTag)
    warning('on','all')
else
    h1 = colorbar(ax);
    set(h1,'Visible','off','HitTest','off')
    pos = get(h1,'Position');
    h2 = colorbar(ax2,'Position',pos);
    ylabel(h2,nameTag)
end
% Create UIMenu for colors
createUIMenu2Axes(ax2,h2,h,data,range)
axes(ax); % Make axes 1 current axis
