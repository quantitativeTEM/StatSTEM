function zoomAxinFig(h,state)
% zoomAxinFig - Turn zoom on or off in the StatSTEM interface
%
% This function replaces the standard zoom function of MATLAB to enable
% zooming by scrolling in the GUI
%
%   syntax: zoomAxinFig(h,state)
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
if strcmp(state,'off')
    % Zooming in
    data = get(h.zoom.in,'Userdata');
    if size(data,1)==2
        set(h.zoom.in,'Userdata',data(1,:))
    end
    set(h.zoom.in,'State','off')
    zoomIn_AxinFig(h.zoom.in,[],h,h.zoom.out)
    % Zooming out
    data = get(h.zoom.out,'Userdata');
    if size(data,1)==2
        set(h.zoom.out,'Userdata',data(1,:))
    end
    set(h.zoom.out,'State','off')
    zoomIn_AxinFig(h.zoom.out,[],h,h.zoom.in)
elseif strcmp(state,'in')
    % Zooming in
    set(h.zoom.in,'State','on')
    zoomIn_AxinFig(h.zoom.in,[],h,h.zoom.out)
elseif strcmp(state,'out')
    % Zooming in
    set(h.zoom.out,'State','on')
    zoomIn_AxinFig(h.zoom.out,[],h,h.zoom.in)
end