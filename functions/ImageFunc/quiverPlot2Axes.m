function quiverPlot2Axes(ax,ax2,x,y,u,v,nameTag,range,scaleMarker,dataText)
% quiverPlot2Axes - Make a quiver plot with colors in 2 overlaying axes
%
% syntax: quiverPlot2Axes(ax,ax2,x,y,u,v,nameTag,range,scaleMarker,dataText)
%   ax          - reference to first axes
%   ax2         - reference to second axes
%   x           - x-coordinates
%   y           - y-coordinates
%   u           - displacement in x-direction
%   y           - displacement in y-direction
%   nameTag     - name of the plot
%   range       - minimum and maximum value for color range scatter plot
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


if nargin<10
    dataText = 'Value %g';
end
if nargin<9
    scaleMarker = 1;
end

% Check matlab version
vM = version('-release');
vM = str2double(vM(1:4));
% Old version of MATLAB cannot handle two colormaps, convert image to rgb values
if vM<2015
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


data = sqrt(u.^2+v.^2);
if nargin<8
    range = [0,max(data)];
end
cmap = jet(256);
c_x = linspace(range(1),range(2),size(cmap,1));
RGBvec = getRGBvec(cmap,c_x,data,'exact');

% Plot
msize = coorMarkerSize('arrow',scaleMarker);
hold(ax, 'on')
h = quiverColor(x,y,u,v,msize,ax,RGBvec);
hold(ax, 'off')
usrData = reshape(repmat(data,1,7)',length(data)*7,1);
set(h,'Tag',nameTag,'Userdata',{dataText,usrData}) % For data cursor in StatSTEM

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
if vM<2015
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
    
    ylabel(h2,['Displacement (',char(197),')'])
    warning('on','all')
else
    h1 = colorbar(ax);
    set(h1,'Visible','off','HitTest','off')
    pos = get(h1,'Position');
    h2 = colorbar(ax2,'Position',pos);
    ylabel(h2,['Displacement (',char(197),')'])
end
% Create UIMenu for colors
createUIMenu2Axes(ax2,h2,h,usrData,range,'quiver')
axes(ax); % Make axes 1 current axis