function zoomReset(h)
% zoomReset - Reset zoom function
%
% This function replaces the standard zoom functions of MATLAB to enable
% zooming by scrolling in the GUI
%
%   syntax: zoomReset(h,state)
%       h       - structure holding references to GUI interface
%       state   - zoom state ('off', 'on', or 'off')
%
% See also: zoomIn_AxinFig, zoomOut_AxinFig

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Reset zoom function if neccessary
ind = strcmp(get(h.zoom.in,'State'),'on');
if any(ind)
    data = get(h.zoom.in,'Userdata');
    if size(data,1)<1
        data = {'' ;'Restart'};
    else
        data{2,1} = 'Restart';
    end
    set(h.zoom.in,'Userdata',data)
    zoomIn_AxinFig(h.zoom.in,[],h,h.zoom.out)
end
ind = strcmp(get(h.zoom.out,'State'),'on');
if any(ind)
    data = get(h.zoom.out,'Userdata');
    if size(data,1)<1
        data = {'' ;'Restart'};
    else
        data{2,1} = 'Restart';
    end
    set(h.zoom.out,'Userdata',data)
    zoomOut_AxinFig(h.zoom.out,[],h,h.zoom.in)
end

% Check for rotatie function
rotate3d off
tab = loadTab(h);
plotIn3D = false;
if ~isempty(tab)
    usr = get(tab,'Userdata');
    chld = get(usr.images.ax,'Children');
    for i=1:length(chld)
        % Show rotate 3D option for surface plots
        if strcmp(get(chld(i),'Type'),'surface')
            plotIn3D = true;
        end
    end
end
a = findall(h.fig);
b = findall(a,'ToolTipString','Rotate 3D');
if plotIn3D
    set(b,'Visible','on')
else
    set(b,'Visible','off')
end