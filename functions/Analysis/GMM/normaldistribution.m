function value = normaldistribution(y,mu,sigma) 
% normaldistribution - create a normaldistribution
%
%   syntax: value = normaldistribution(y,mu,sigma) 
%       y     - position in distrubtion
%       mu    - center of distribution
%       sigma - width of distribution
%       value - output value
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
normalisation = sqrt(2*pi)*sigma;
T_exp = -(y-mu).^2;
N_exp = 2*sigma^2;
tot_exp = exp(T_exp./N_exp);
value = tot_exp./normalisation;
