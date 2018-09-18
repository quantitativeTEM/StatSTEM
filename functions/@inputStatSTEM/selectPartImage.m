function obj = selectPartImage(obj)
% selectPartImage - select part from image
%
%   syntax: obj = selectPartImage(obj)
%       obj  - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(obj.GUI)
    figure;
    showObservation(obj);
    hold on
    plotCoordinates(obj);
end
%% Select axis
ax = gca;
hold(ax,'on');

%% Select part of image
title(ax,'Select part of image to keep, press ESC to exit')
coor = gsquare_AxInFig();
title(ax,'')
hold(ax,'off');
if ~isempty(coor)
    X = obj.Xaxis;
    Y = obj.Yaxis;
    if coor(1,1)>coor(2,1)
        coor(:,1) = [coor(2,1);coor(1,1)];
    end
    if coor(1,2)>coor(2,2)
        coor(:,2) = [coor(2,2);coor(1,2)];
    end
    indX = X>=coor(1,1) & X<=coor(2,1);
    indY = Y>=coor(1,2) & Y<=coor(2,2);
    obj.obs = obj.obs(indY,indX);
    
    if ~isempty(obj.coordinates)
        % Keep coordinates in area
        A = [coor(1,:);[coor(2,1),coor(1,2)];coor(2,:);[coor(1,1),coor(2,2)];coor(1,:)];
        ind = inpolygon(obj.coordinates(:,1),obj.coordinates(:,2),A(:,1),A(:,2));
        obj.coordinates = obj.coordinates(ind,:);

        % Shift coordinates
        obj.coordinates(:,1) = obj.coordinates(:,1)-max(floor(coor(1,1)/obj.dx),0)*obj.dx;
        obj.coordinates(:,2) = obj.coordinates(:,2)-max(floor(coor(1,2)/obj.dx),0)*obj.dx;
    end
end

