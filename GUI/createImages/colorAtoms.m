function color = colorAtoms(in)
% colorAtoms - define color for different atom types
%
%   syntax: colorAtoms(in)
%       in    - a list of types
%       color - rgb valuse for each type
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
num = mod(in,5);
num(num==0)=5;
map(1:5,:) = [0 1 0;1 0 1;  0 1 1;0.87 0.49 0;1 0 0];
color = map(num,:);