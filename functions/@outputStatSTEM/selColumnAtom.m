function obj = selColumnAtom(obj,state)
% selColumnAtom - Select specific columns for analysis
%
% This function enables the user to select specific column in the StatSTEM
% interface which will only be used for the atomcounting routine
%
%   syntax: selColumnAtom(obj,state)
%       obj   - outputStatSTEM file
%       state - logical indicating to add or remove a selected region (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% if nargin<2
%     state = 1;
% end

state = 1;

if state
    if obj.GUI==0
        figure;
        showModel(obj);
        hold on
        plotFitCoordinates(obj)   
    end
    
    %% Select axis -- use obj.ax directly to avoid gca unreliability in GUI
    if ~isempty(obj.ax) && ishandle(obj.ax)
        ax = obj.ax;
    else
        ax = gca;
    end
    axes(ax);
    hold on;

    %% Select region
    title(ax,'Select region, press ESC to exit')
    % Pass ax explicitly so gregion_AxInFig uses the correct axes
    coor = gregion_AxInFig(ax);
    title(ax,'')
    obj.selRegion = coor;
else
    obj.selRegion = [];
end
