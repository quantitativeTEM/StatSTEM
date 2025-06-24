function obj = selColumnType(obj,state)
% selColumnType - Select specific columns for analysis
%
% This function enables the user to select specific column in the StatSTEM
% interface which will only be used for an analysis routine. Columns
% are selected based on atom type
%
%   syntax: obj = selColumnType(obj,state)
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

if nargin<2
    state = 1;
end

if state
    types = obj.types;
    if ~isempty(obj.GUI)
        % Get position GUI, to center dialog
        pos = get(obj.GUI,'Position');
        cent = [pos(1)+pos(3)/2 pos(2)+pos(4)/2];
    else
        screensize = get( 0, 'Screensize' );
        cent = [screensize(3)/2 screensize(4)/2];
    end
    % Parameter for listdlg
    s = [200, 250];
    defaultFigPos=get(0, 'defaultfigureposition');
    figpos = [cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)];
    set(0,'defaultfigureposition',figpos);
    
    % Select atom type for atomcounting
    [type,output] = listdlg('ListString',types,'SelectionMode','Multiple','Name','Select atom type',...
        'PromptString','Select atom type for atomcounting:');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    
    % Restore parameters for listdlg
    set(0,'defaultfigureposition', defaultFigPos);
    if output==0
        return
    end
    obj.selType = type;
else
    obj.selType = [];
end
