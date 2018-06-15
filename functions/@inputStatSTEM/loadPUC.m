function [input,strainmapping] = loadPUC(input,strainmapping)
% loadPUC - Load a 2D UC file
%
%   syntax: [input,strainmapping] = loadPUC(input,strainmapping)
%       input         - inputStatSTEM file
%       strainmapping - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(input.projUnit) 
    unit = projUnitCell;
else
    unit = input.projUnit;
end

if ~isempty(input.GUI)
    % Get position GUI, to center dialog
    pos = get(input.GUI,'Position');
    cent = [pos(1)+pos(3)/2 pos(2)+pos(4)/2];
else
    screensize = get( 0, 'Screensize' );
    cent = [screensize(3)/2 screensize(4)/2];
end
PathName = getDefaultDatPath();

% Start GUI
[unit,path2,ok] = projUCgui(unit,'Center',cent,'PathData',PathName);
if path2~=0
    updateDatPath(path2)
end

if nargin<2
    strainmapping = [];
end

if ok
    input.projUnit = unit;
    if nargin>1
        strainmapping.projUnit = unit;
    end
end

    
    
