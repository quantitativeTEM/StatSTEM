function input = outputIsInput(output,input)
% outputIsInput - Make the fitted coordinates the input coordinates
%
%   syntax: input = outputIsInput(output,input)
%       input  - inputStatSTEM file
%       output - outputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Make the fitted coordinates the new input coordinates, and store the
% fitted width
input.coordinates = output.coordinates;
Nt = length(input.types);
rho_temp = zeros(Nt,1);
for i=1:Nt
    ind = input.coordinates(:,3)==i;
    if any(ind)
        rho_temp(i,1) = mean(output.rho(ind));
    else
        rho_temp(i,1) = 0;
    end
end
input.rhoT = rho_temp;

