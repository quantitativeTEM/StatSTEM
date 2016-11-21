function showDisplacementMap(ax,coor,coor_rel,name)
% showDisplacementMap - make a displacement map in image
%
%   syntax - showDisplacementMap(ax,coor,coor_rel,name)
%       ax        - handle to axes
%       coor      - coordinates
%       coor_rel  - relaxed coordinates
%       name      - name of object
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

hold(ax, 'on')
ind = coor_rel(:,1)==0 & coor_rel(:,2)==0;
if sum(ind)>2
    h = quiver(ax,coor_rel(~ind,1),coor_rel(~ind,2),coor(~ind,1)-coor_rel(~ind,1),coor(~ind,2)-coor_rel(~ind,2),'Color','r');
else
    h = quiver(ax,coor_rel(:,1),coor_rel(:,2),coor(:,1)-coor_rel(:,1),coor(:,2)-coor_rel(:,2),'Color','r');
end
hold(ax,'off')

% Store reference to coordinates
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{name h}])