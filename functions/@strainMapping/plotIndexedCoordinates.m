function plotIndexedCoordinates(obj)
% plotIndexedCoordinates - plot indexed coordinates in image
%
%   syntax - plotIndexedCoordinates(obj)
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
coor = obj.coordinates;
if isempty(coor)
    return
end

indT = obj.typesN~=0;
coor = coor(indT,:);
    
marker = '.';
msize = coorMarkerSize(marker,obj.mscale);
clor = colorAtoms(1);
clor = repmat(clor,max(coor(:,3)),1);

hold(gca, 'on')
for k=1:max(coor(:,3))
    indices = find(coor(:,3)==k);
    if ~isempty(indices)
        plot(gca,coor(indices,1),coor(indices,2),marker,'Color',clor(k,:),'MarkerSize',msize,'Tag','Indexed coordinates');
    end
end
hold(gca,'off')