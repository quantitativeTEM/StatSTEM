function counts = matchSCSwithSim(SCS,lib)
% matchSCSwithSim - Find number of atoms per column 
%
%   Number of atoms per column are found by matching experimentally 
%   measured scattering cross-sections with a simulated library. Here each 
%   measured value is matched to the closest library value
%
%   syntax: counts = matchSCSwithSim(SCS,lib)
%       SCS    - Measured scattering cross-sections
%       lib    - Library of scattering cross-sections
%       counts - counting results
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

N = length(SCS);
counts = zeros(N,1);
for n=1:N
    dist = (SCS(n)-lib(:,2)).^2;
    num = lib(dist==min(dist),1);
    counts(n,1) = num(1);
end