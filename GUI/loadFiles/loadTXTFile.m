function [file,message,dx] = loadTXTFile(PathName,FileName)
% loadTXTFile - Load a text file suitable for StatSTEM
%
%   syntax: [file,message,dx] = loadTXTFile(PathName,FileName)
%       PathName - Pathname
%       FileName - Filename
%       file     - Structure containing the file information
%       message  - message for indicating if anything goes wrong
%       dx       - indicate if dx is known or not ('ok','ask')
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

dx = 'ask';
file.input.obs = dlmread([PathName,FileName,'.txt']);
message = '';
s = size(file.input.obs);
if s(1)==1 || s(2)==1
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid structure']);
    errordlg('Invalid structure')
    return
end
file.input.dx = 0.1;
file.input.coordinates = [];

% Create types field, if not existing
file.input.types = {'1'};