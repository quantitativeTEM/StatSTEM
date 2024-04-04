function q = lorentz(R2,rho)
% lorentz - Lorentzian peak
%
% Determine the value of a Lorentzian peak
%
%   syntax: q = lorentz(R2,rho)
%       R2   - square of radius from center (coordinate)
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

q = (rho^2+R2).^(-3/2);
q(R2 > (3*rho)^2) = 0; %then q contains 99.7% of the original inetnsity