function index = selectColumns(betaX, betaY, Box, i)
% selectColumns - select columns in part of image
%
%   syntax: index = selectColumns(betaX, betaY, Box, i)
%       betaX - x-coordinates
%       betaY - y-coordinates
%       Box   - size of selected image part
%       i     - indice of selected column
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

% find columns in selected Box
index = abs(betaX_translated)<Box & abs(betaY_translated)<Box;
index(i) = 0;

% betaX_b = betaX(index);
% betaY_b = betaY(index);
% rho_b = rho(index);
% eta_b = eta(index);
