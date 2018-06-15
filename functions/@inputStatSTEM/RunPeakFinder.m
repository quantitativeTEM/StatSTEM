function obj = RunPeakFinder(obj)
% RunPeakFinder - Run a peak finder routine on the image to find coordinates
%
%   syntax: obj = RunPeakFinder(obj)
%       obj - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% First select parameters
parPFR = tunePeakFinderPar(obj.obs);

if parPFR.store==0
    return
end
%% Run automatic peak finding routine
[betaX,betaY] = peakFinder(obj.obs,parPFR);


obj.coordinates = [[betaX betaY]*obj.dx,ones(length(betaX),1)];
