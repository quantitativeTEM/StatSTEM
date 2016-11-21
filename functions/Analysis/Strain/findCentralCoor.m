function coor_cen = findCentralCoor(coordinates)
% findCentralCoor - Extract most central coordinate from dataset
%
%   syntax: coor_cen = findCentralCoor(coordinates)
%       coordinates - coordinates [x1,y1;x2,y2;...]
%       coor_cen    - most central coordinate
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

dist = sqrt( (coordinates(:,1)-mean(coordinates(:,1)) ).^2 + (coordinates(:,2)-mean(coordinates(:,2)) ).^2 );
ind = find(dist==min(dist));
coor_cen = coordinates(ind(1),:);
