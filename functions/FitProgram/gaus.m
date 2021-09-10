function q = gaus(R,rho)
% gaus - Gaussian peak
%
% Determine the value of a gaussian peak
%
%   syntax: q = gaus(R,rho)
%       R   - square of radius from center (coordinate)
%       rho - width
%       q   - output value
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

q = exp(-R/(2*rho^2));
q(R > (3*rho)^2) = 0; %then q contains 99% of the original inetnsity