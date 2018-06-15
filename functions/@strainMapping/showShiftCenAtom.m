function showShiftCenAtom(obj)
% showShiftCenAtom - make a displacement map in image to show the shift of
%                    the central atom in the unit cell
%
%   syntax - showShiftCenAtom(obj)
%       obj - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check whether coordinates are present
if isempty(obj.shiftCenAtom)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end
if isempty(obj.ax2)
    img = get(ax,'Parent');
    ax2 = axes('Parent',img,'units','normalized');
    axes(ax)
else
    ax2 = obj.ax2;
end

nameTag = 'Shift central atom';
scaleMarker = obj.mscale;
ind = obj.shiftCenAtom(:,1)==0 & obj.shiftCenAtom(:,2)==0; % Check if all coordinates are identified

x = obj.coordinates(~ind,1);
y = obj.coordinates(~ind,2);
u = obj.shiftCenAtom(~ind,1);
v = obj.shiftCenAtom(~ind,2);
data = sqrt(u.^2+v.^2);
range = [0,max(data)];

quiverPlot2Axes(ax,ax2,x,y,u,v,nameTag,range,scaleMarker,'Displacement: %g Å')