function FUN = planes(par,coordinates,ref,indices,teta_ab,dirTeta,a,b)
% planes - function to find the angle of the lattice by fitting
%
%   syntax: FUN = planes(par,coordinates,ref,indices,teta_ab,a,b)
%       FUN         - Difference between model and coordinates
%       par         - vector to fit (ang, offset a, offset b, a, b)
%       coordinates - the coordinates [x,y]
%       ref         - the reference coordinate [x,y]
%       indices     - indices of the coordinates (in function of a and b)
%       teta_ab     - angle between a- and b-direction (mrad)
%       dirTeta     - direction of angle between a and b
%       a           - a-lattice
%       b           - b-lattice
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

ang = par(1);
offa = par(2);
offb = par(3);
if nargin<7
    a = par(4);
    b = par(5);
end

%% a- and b-direction
R = [cos(ang) -sin(ang);sin(ang) cos(ang)];
Rab = [cos(dirTeta*teta_ab) -sin(dirTeta*teta_ab);sin(dirTeta*teta_ab) cos(dirTeta*teta_ab)];
aDir = (R*[a;0])';
bDir = (Rab*R*[b;0])';

% Create model coordinates
coorMod = indices(:,1)*aDir + indices(:,2)*bDir;

% Find central coordinate
coorMod = [coorMod(:,1) + ref(1,1) + offa , coorMod(:,2) + ref(1,2) + offb];

FUN = coorMod-coordinates;