function [betaX_b, betaY_b, rho_b, eta_b] = selectParameters(betaX, betaY, rho, eta, radius,i)
% selectParameters - select parameter of columns in selected in part of image
%
%   syntax: [betaX_b, betaY_b, rho_b, eta_b] = selectParameters(betaX, betaY, rho, eta, radius,i)
%       betaX   - x-coordinates of all columns
%       betaY   - y-coordinates of all columns
%       rho     - the width of all columns
%       eta     - the height of all columns
%       radius  - radius for selecting neighbouring columns
%       i       - indice of selected column
%       betaX_b - x-coordinates of selected columns
%       betaY_b - y-coordinates of selected columns
%       rho_b   - the width of selected columns
%       eta_b   - the height of selected columns
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
betaX_translated = betaX - betaX(i);
betaY_translated = betaY - betaY(i);

% find columns in circle around atom column with radius 'radius'
radius2 = radius.^2;
r = betaX_translated.^2+betaY_translated.^2;
index = le(r,radius2);
index(i) = 0;

betaX_b = betaX(index);
betaY_b = betaY(index);
rho_b = rho(index);
eta_b = eta(index);

% index = le(abs(betaX_translated),radius).*le(abs(betaY_translated),radius) % box around atom columns with size 'radius'