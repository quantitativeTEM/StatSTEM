function [file,message] = loadTXTFile(FileName)
% loadTXTFile - Load a text file suitable for StatSTEM
%
%   syntax: [file,message,dx] = loadTXTFile(PathName,FileName)
%       FileName - Filename
%       file     - Structure containing the file information
%       message  - message for indicating if anything goes wrong
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

obs = dlmread(FileName);
message = '';
s = size(obs);
if s(1)==1 || s(2)==1
    file = [];
    loc = strfind(FileName,filesep);
    FileName = FileName(loc(end)+1:end);
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid structure']);
    errordlg('Invalid structure')
    return
end
file.input = inputStatSTEM(obs);

% Update FileName
loc = strfind(FileName,filesep);
FileName = FileName(loc(end)+1:end);
file.input.name = FileName;