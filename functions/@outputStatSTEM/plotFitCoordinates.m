function plotFitCoordinates(obj,type)
% plotFitCoordinates - plot fitted coordinates in image
%
%   syntax - plotFitCoordinates(obj,type)
%       obj  - outputStatSTEM file
%       type - number of type to be plotted (optional)
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

if nargin>1
    indT = coor(:,3)==type;
    coor = coor(indT,:);
end

marker = '+';
msize = coorMarkerSize(marker,obj.mscale);
clor = colorAtoms(1:max(coor(:,3)));

hold(gca, 'on')
for k=1:max(coor(:,3))
    indices = find(coor(:,3)==k);
    if ~isempty(indices)
        plot(gca,coor(indices,1),coor(indices,2),marker,'Color',clor(k,:),'MarkerSize',msize,'Tag','Fitted coordinates');
    end
end
hold(gca,'off')