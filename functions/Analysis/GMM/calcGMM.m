function [x,GMM] = calcGMM(atomcounting,bins)
% calcGMM - Calculate the gaussian mixture model
%
%   syntax: [x,GMM] = calcGMM(atomcounting,bins)
%       atomcounting - structure containing atom counting results
%       bins         - number of bins in histogram
%       x            - the x-value (in the histogram)
%       GMM          - the gaussian mixture model
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Get bins in plotted histogram
x = 0:max(atomcounting.volumes)/1000:max(atomcounting.volumes)+max(atomcounting.volumes)*0.05;
GMM = zeros(atomcounting.selMin, length(x));
for i = 1:atomcounting.selMin
   GMM(i,:) = normaldistribution(x,atomcounting.estimatedLocations(i),atomcounting.estimatedWidth)*atomcounting.estimatedProportions(i)*atomcounting.N*(max(atomcounting.volumes)-min(atomcounting.volumes))/bins;
end