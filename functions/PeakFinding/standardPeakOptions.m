function options = standardPeakOptions(obs)
% standardPeakOptions - Generate the standard options for peak finding
%
%   syntax: options = standardPeakOptions(obs)
%       obs     - the observation
%       options - structure containing the peak finding options
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Standard threshold value
if nargin<1
    options.thres = 0;
else
    options.thres = max( min(max(obs,[],1)) , min(max(obs,[],2)) );
end

% Filter 1
options.filter1.type = 'gaussian';
options.filter1.val = 2;

% Filter 2
options.filter2.type = 'none';
options.filter2.val = 1;

% Filter 3
options.filter3.type = 'none';
options.filter3.val = 1;


