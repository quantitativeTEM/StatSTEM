function output = GetMAPpos(input1,input2)    
% GetMAPpos - Use detected peak coordinates from maximum a posteriori (MAP)
% rule as input coordinates for new analysis
%
%   syntax: output = GetMAPpos(input)
%   input1: inputStatSTEM object
%   input2: outputStatSTEM_MAP object
%   output: inputStatSTEM object
    
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

output = input1;
output.coordinates = input2.models{input2.NselMod}.coordinates;