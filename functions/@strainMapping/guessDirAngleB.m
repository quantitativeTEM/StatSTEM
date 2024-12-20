function [dirAngle,aDir] = guessDirAngleB(strainmapping,aDir,distA)
% guessAngleAdir - Automatically guess directions of a and b-direction
%
%   syntax: [dirAngle,aDir] = guessDirAngleB(strainmapping,aDir,distA)
%       strainmapping - strainMapping file
%       dirAngle      - direction of the angle between a and b (+ or -)
%       aDir          - a lattice parameter [x,y]
%       distA         - distance between adir and coordinates
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

% Select coordinates
coordinates = strainmapping.coordinates;
ref = strainmapping.refCoor;
dist = sqrt( (coordinates(:,1)-ref(1,1) ).^2 + (coordinates(:,2)-ref(1,2) ).^2 );
indRef = find(dist==min(dist));
type = coordinates(indRef(1),3);
indT = strainmapping.coordinates(:,3)==type;
coordinates = coordinates(indT,:);

% Get a and b values
b = strainmapping.projUnit.b;

% Get space
space = strainmapping.space;

%% Find direction of b lattice
distB = zeros(size(aDir,1),2);

% For each angle rotate positive and negative
l_a = sqrt( aDir(1,1)^2 + aDir(1,2)^2 );    % distance between reference coordinate and selected coordinate (cfr a lattice parameter)
intPosP = (Rab*aDir')'*b/l_a;               % rotate aDir over positive angle of proj unit cell and scale to magnitude of lattice vector b
intPosP = [intPosP(:,1)+ref(1,1),intPosP(:,2)+ref(1,2)];    % shift to the reference coordinate
% intPosN = (Rab\aDir')'*b/l_a;               % rotate in opposite direction (negative angle)
% intPosN = [intPosN(:,1)+ref(1,1),intPosN(:,2)+ref(1,2)];    % shift to reference coordinate
for n=1:size(aDir,1)
    distB(n,1) = min(sqrt( (coordinates(:,1)-intPosP(n,1) ).^2 + (coordinates(:,2)-intPosP(n,2) ).^2 ));
    % distB(n,2) = min(sqrt( (coordinates(:,1)-intPosN(n,1) ).^2 + (coordinates(:,2)-intPosN(n,2) ).^2 ));
end
dirB = (distB(:,1)>=distB(:,2))-(distB(:,1)<distB(:,2));
distB = min(distB(:,1),distB(:,2));
if min(distB)>space
    error('Cannot find b-lattice direction, no b-lattice coordinates found. Select other a-direction or check unit cell parameters');
end

% Combine both a and b-direction to find most likely guess
dist = distA+distB;
ind = find(dist==min(dist));
aDir = aDir(ind(1),:);
if teta_ab==0.5*pi
    dirAngle = 1;
else
    dirAngle = dirB(ind(1));
end