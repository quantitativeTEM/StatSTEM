function [angle,dirAngle] = guessAngleAdir(coordinates,ref,a,b,teta_ab,space)
% guessAngleAdir - Automatically guess directions of a and b-direction
%
%   syntax: [angle,err] = guessAngleAdir(coordinates,ref,a,b,teta_ab,space)
%       coordinates - coordinates from which direction must be found [x,y]
%       ref         - reference coordinate [x,y]
%       dirAngle    - direction of the angle between a and b (+ or -)
%       a           - a lattice parameter
%       b           - b lattice parameter
%       teta_ab     - angle between a and b lattice parameter (mrad)
%       angle       - Measured angle of a lattice direction
%       err         - Message with possible errors
%       space       - Distance to find closest values (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check for inputs
if nargin<6
    space = min([a/4,b/4]);
end

%% Preparation
% Angle between a and b direction
Rab = [cos(teta_ab) -sin(teta_ab);sin(teta_ab) cos(teta_ab)];
ang = zeros(4,1);

%% Find most central coordinates and find rotation
% a-dir - positive
distPa = sqrt( (coordinates(:,1)-ref(1,1) ).^2 + (coordinates(:,2)-ref(1,2) ).^2 );
indCa = abs(distPa-a)<space;
if any( indCa )
    aDir = [coordinates(indCa,1)-ref(1,1),coordinates(indCa,2)-ref(1,2)];
    distA = abs(distPa(indCa)-a);
    % Find direction of b-lattice
    [dirAngle,aDir] = guessDirAngleB(coordinates,ref,aDir,b,teta_ab,distA);
    ang(1,1) = atan(aDir(2)/aDir(1));
    addAngle = atan2(aDir(2),aDir(1))-ang(1,1);
else
    error('Cannot find a-lattice direction, no b-lattice coordinates found. Select other a-direction of check unit cell parameters');
end

% a-dir - negative
distNa = sqrt( (coordinates(:,1)-ref(1,1)+aDir(1) ).^2 + (coordinates(:,2)-ref(1,2)+aDir(2) ).^2 );
if min(distNa)<space
    indCa2 = find( distNa==min(distNa) );
    aDir2 = coordinates(indCa2(1),:) - ref;
    ang(2,1) = atan(aDir2(2)/aDir2(1));
else
    ang(2,1) = NaN;
end

% b-dir - positive
intDir = (Rab*aDir')'*b/a;
distPb = sqrt( (coordinates(:,1)-ref(1,1)-intDir(1) ).^2 + (coordinates(:,2)-ref(1,2)-intDir(2) ).^2 );
if min(distPb)<space
    indCb = find( distPb==min(distPb) );
    bDir = coordinates(indCb(1),:) - ref;
    ang(3,1) = atan(bDir(2)/bDir(1))+0.5*pi;
    if ang(3,1)>0.5*pi
        ang(3,1) = ang(3,1)-pi;
    end
else
    ang(3,1) = NaN;
end

% b-dir - negative
distNb = sqrt( (coordinates(:,1)-ref(1,1)+intDir(1) ).^2 + (coordinates(:,2)-ref(1,2)+intDir(2) ).^2 );
if min(distNb)<space
    indCb2 = find( distNb==min(distNb) );
    bDir2 = coordinates(indCb2(1),:) - ref;
    ang(4,1) = atan(bDir2(2)/bDir2(1))+0.5*pi;
    if ang(4,1)>0.5*pi
        ang(4,1) = ang(4,1)-pi;
    end
else
    ang(4,1) = NaN;
end

%% Find avarage
% Remove NaN from average
indOK = ~isnan(ang);
angle = mean(ang(indOK))+addAngle;
