function options = standardAtomOptions()
% standardAtomOptions - Generate the standard options for atomcounting
%
%   syntax: options = standardAtomOptions()
%       options - structure containing the atomcounting options
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% All coordinates will be selected
options.selCoor = [];

% All types will be selected
options.selType = [];

% The maximum number of components that will be estimated is 50
options.n_c = 50;

% No outliers in the histogram os SI will be neglected
options.minVol = [];
options.maxVol = [];

% The selected minimum in the ICL (empty in case no minimum is selected
options.minICL = [];

options.offset = 0;