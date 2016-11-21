function [dirAngle,aDir,err] = guessDirAngleB(coordinates,ref,aDir,b,teta_ab,distA,space)
% guessAngleAdir - Automatically guess directions of a and b-direction
%
%   syntax: dirAngle = guessDirAngleB(coordinates,ref,aDir,b,teta_ab,space)
%       coordinates - coordinates from which direction must be found [x,y]
%       ref         - reference coordinate [x,y]
%       dirAngle    - direction of the angle between a and b (+ or -)
%       aDir        - a lattice parameter [x,y]
%       b           - b lattice parameter
%       teta_ab     - angle between a and b lattice parameter (mrad)
%       distA       - distance between adir and coordinates
%       space       - Distance to find closest values (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Preparation
if nargin<7
    space = b/4;
end
% Angle between a and b direction
Rab = [cos(teta_ab) -sin(teta_ab);sin(teta_ab) cos(teta_ab)];

%% Find direction of b lattice
distB = zeros(size(aDir,1),2);

% For each angle rotate positive and negative
l_a = sqrt( aDir(1,1)^2 + aDir(1,2)^2 );
intPosP = (Rab*aDir')'*b/l_a; 
intPosP = [intPosP(:,1)+ref(1,1),intPosP(:,2)+ref(1,2)];
intPosN = (Rab\aDir')'*b/l_a; 
intPosN = [intPosN(:,1)+ref(1,1),intPosN(:,2)+ref(1,2)];
for n=1:size(aDir,1)
    distB(n,1) = min(sqrt( (coordinates(:,1)-intPosP(n,1) ).^2 + (coordinates(:,2)-intPosP(n,2) ).^2 ));
    distB(n,2) = min(sqrt( (coordinates(:,1)-intPosN(n,1) ).^2 + (coordinates(:,2)-intPosN(n,2) ).^2 ));
end
dirB = distB(:,1)>=distB(:,2)-distB(:,1)<distB(:,2);
distB = min(distB(:,1),distB(:,2));
if min(distB)>space
    error('Cannot find a-lattice direction, no b-lattice coordinates found. Select other a-direction of check unit cell parameters');
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