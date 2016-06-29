function bins = getBinsHist(ax)
% getBinsHist - Find the number of bins in a histogram
%
%       syntax: bins = getBinsHist(ax)
%           ax   - reference to the axes
%       	bins - the number of bins in a histogram
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Get reference to the histogram and determine the bins
data = get(ax,'Userdata');
val = strcmp(data(:,1),'histogram');
h_hist = data{val,2};
bins = size(get(h_hist,'XData'),2);
