function showABlattice(ax,coor,adir,bdir,name)
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
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check whether coordinates are present
if isempty(coor)
    return
end

data = get(ax,'Userdata');
ind = strcmp(data(:,1),'Limits');
lim = data{ind,2};
lim = max([lim(2)-lim(1),lim(4)-lim(3)]);
lat = min(sqrt(adir(1)^2+adir(2)^2),sqrt(bdir(1)^2+bdir(2)^2));
per = 0.1;
scale = lim*per/lat;

adir = adir*scale;
bdir = bdir*scale;
teta = 0.5*pi;
R = [cos(teta) sin(teta);-sin(teta) cos(teta)];
a = 0.2;
offa = R*adir*a;
if abs(atan2(offa(2),offa(1))-atan2(bdir(2),bdir(1)))<0.5*pi
    offa = R*R*offa;
end
offb = R*bdir*a;
if abs(atan2(offb(2),offb(1))-atan2(adir(2),adir(1)))<0.5*pi
    offb = R*R*offb;
end

hold(ax, 'on')
h(1) = quiver(ax,coor(1,1),coor(1,2),adir(1),adir(2),'Color','w');
h(2) = quiver(ax,coor(1,1),coor(1,2),bdir(1),bdir(2),'Color','w');
h(3) = text(coor(1,1)+adir(1)/2+offa(1),coor(1,2)+adir(2)/2+offa(2),'a','Color',[1 1 1]);
h(4) = text(coor(1,1)+bdir(1)/2+offb(1),coor(1,2)+bdir(2)/2+offb(2),'b','Color',[1 1 1]);
hold(ax,'off')

% Store reference to coordinates
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{name h}])