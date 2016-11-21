function FUN = planes(par,coordinates,ref,indices,teta_ab,a,b)
% planes - function to find the angle of the lattice by fitting
%
%   syntax: FUN = planes(par,coordinates,ref,indices,teta_ab,a,b)
%       FUN         - Difference between model and coordinates
%       par         - vector to fit (ang, offset a, offset b, a, b)
%       coordinates - the coordinates [x,y]
%       ref         - the reference coordinate [x,y]
%       indices     - indices of the coordinates (in function of a and b)
%       teta_ab     - angle between a- and b-direction (mrad)
%       a           - a-lattice
%       b           - b-lattice
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

ang = par(1);
offa = par(2);
offb = par(3);
if nargin<6
    a = par(4);
    b = par(5);
end

%% a- and b-direction
R = [cos(ang) -sin(ang);sin(ang) cos(ang)];
Rab = [cos(teta_ab-0.5*pi) -sin(teta_ab-0.5*pi);sin(teta_ab-0.5*pi) cos(teta_ab-0.5*pi)];
aDir = (R*[a;0])';
bDir = (Rab*R*[0;b])';

% Create model coordinates
coorMod = indices(:,1)*aDir + indices(:,2)*bDir;

% Find central coordinate
coorMod = [coorMod(:,1) + ref(1,1) + offa , coorMod(:,2) + ref(1,2) + offb];

FUN = coorMod-coordinates;

