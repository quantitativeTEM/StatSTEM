function javaCallback(h,varargin)
% javaCallback - Creates a callback function for a java object
%
%   syntax: javaCallback(h,varargin)
%       h        - structure holding references to java object
%       varargin - callback structure and functions
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check version MATLAB
v = version('-release');
v = str2double(v(1:4));

if v<2015
    h = handle(h,'callbackproperties');
end
set(h,varargin{:})