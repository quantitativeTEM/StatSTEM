function [angle,dirAngle] = guessAngleAdir(strainmapping)
% guessAngleAdir - Automatically guess directions of a and b-direction
%
%   syntax: [angle,err] = guessAngleAdir(strainmapping)
%       strainmapping - strainMapping file
%       angle         - Measured angle of a lattice direction
%       dirAngle      - direction of the angle between a and b (+ or -)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------


%% Preparation
% Angle between a and b direction
teta_ab = strainmapping.projUnit.ang;
Rab = [cos(teta_ab) -sin(teta_ab);sin(teta_ab) cos(teta_ab)];
ang = zeros(4,1);

% Select coordinates
coordinates = strainmapping.coordinates;
ref = strainmapping.refCoor(:,1:2);
dist = sqrt( (coordinates(:,1)-ref(1,1) ).^2 + (coordinates(:,2)-ref(1,2) ).^2 );
indRef = find(dist==min(dist));
type = coordinates(indRef(1),3);
indT = strainmapping.coordinates(:,3)==type;
coordinates = coordinates(indT,1:2);

% Get a and b values
a = strainmapping.projUnit.a;
b = strainmapping.projUnit.b;

% Get space
space = strainmapping.space;

%% Find most central coordinates and find rotation
% a-dir - positive
distPa = sqrt( (coordinates(:,1)-ref(1,1) ).^2 + (coordinates(:,2)-ref(1,2) ).^2 );
indCa = abs(distPa-a)<space;
if any( indCa )
    aDir = [coordinates(indCa,1)-ref(1,1),coordinates(indCa,2)-ref(1,2)];
    distA = abs(distPa(indCa)-a);
    % Find direction of b-lattice
    [dirAngle,aDir] = guessDirAngleB(strainmapping,aDir,distA);
    ang(1,1) = atan(aDir(2)/aDir(1));
    addAngle = atan2(aDir(2),aDir(1))-ang(1,1);
else
    error('Cannot find a-lattice direction. Select maunally other a-direction of check unit cell parameters');
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
