function showABlattice(obj)
% showABlattice - show lattice directions
%
%   syntax: showABlattice(ax,coor,dir,name)
%       ax     - handle to axes
%       coor   - coordinates
%       adir   - direction of a lattice
%       bdir   - direction of b lattice
%       name   - name of object
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check whether a reference coordinate is present
if isempty(obj.teta) || isempty(obj.a) || isempty(obj.b)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

% data = get(ax,'Userdata');
% ind = strcmp(data(:,1),'Limits');
% lim = data{ind,2};
% lim = max([lim(2)-lim(1),lim(4)-lim(3)]);
% lat = min(sqrt(adir(1)^2+adir(2)^2),sqrt(bdir(1)^2+bdir(2)^2));
% per = 0.1;
% scale = lim*per/lat;

R = [cos(obj.teta) sin(obj.teta);-sin(obj.teta) cos(obj.teta)];
tetaAB = obj.dirTeta*obj.projUnit.ang;
Rab = [cos(tetaAB) sin(tetaAB);-sin(tetaAB) cos(tetaAB)];
adir = R\[obj.a;0];
bdir = R\Rab*[obj.b;0];

R90 = [cos(obj.dirTeta*pi/2) sin(obj.dirTeta*pi/2);-sin(obj.dirTeta*pi/2) cos(obj.dirTeta*pi/2)];
% Shift by 6 pixels
shiftPix = 6;
offa = R90\adir/obj.a*obj.dx*shiftPix;
offb = R90*bdir/obj.b*obj.dx*shiftPix;

hold(ax, 'on')
h(1) = quiver(ax,obj.refCoor(1,1),obj.refCoor(1,2),adir(1),adir(2),'Color','w','AutoScale','off','Tag','a & b lattice','MaxHeadSize',3/obj.a);
h(2) = quiver(ax,obj.refCoor(1,1),obj.refCoor(1,2),bdir(1),bdir(2),'Color','w','AutoScale','off','Tag','a & b lattice','MaxHeadSize',3/obj.b);
h(3) = text(obj.refCoor(1,1)+adir(1)/2+offa(1),obj.refCoor(1,2)+adir(2)/2+offa(2),'a','Color',[1 1 1],'Tag','a & b lattice');
h(4) = text(obj.refCoor(1,1)+bdir(1)/2+offb(1),obj.refCoor(1,2)+bdir(2)/2+offb(2),'b','Color',[1 1 1],'Tag','a & b lattice');
hold(ax,'off')
