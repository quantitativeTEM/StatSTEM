function [library,thick] = loadLibrary(FileName)
% loadLibrary - Load a library of simulated values, scattering cross-sections
%
% Load a library of scattering cross-sections in function of column thickness
%
%   Loaded file should contain a (nx1) vector with values per thickness
%
%   syntax: library = loadLibrary(FileName)
%       FileName - Filename of file to be loaded
%       library  - Loaded vector with library values
%       thick    - Corresponding thickness to library values
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

library = [];
thick = [];
if nargin<1
    % Check default path
    PathName = getDefaultPath();

    % First let user select a file
    [FileName,PathName] = uigetfile({'*.mat;*.txt;*.TXT','Supported Files (*.mat,*.txt)';'*.mat','MATLAB Files (*.mat)';'*.txt;*.TXT','TXT Files (*.txt)';'*.*',  'All Files (*.*)'}, ...
       'Select a file',PathName);

    if FileName==0
        return
    end
    [~, FileName, ext] = fileparts(FileName);
else
    [PathName, FileName, ext] = fileparts(FileName);
    PathName = [PathName,filesep];
end

message = '';
switch ext
    case '.mat'
        lib = load([PathName,FileName,ext]);
        names = fieldnames(lib);
        if length(names)==1
            lib = lib.(names{1});
        else
            errordlg(['The file ', FileName, ' cannot be loaded, invalid input structure'])
            return
        end
    case '.txt'
        lib = dlmread([PathName,FileName,ext]);
end

% Test if library has a correct input structure
if isempty(message)
    s = size(lib);
    if length(s)~=2 || min(s)>2 || min(s)==0
        errordlg(['The file ', FileName, ' cannot be loaded, invalid input structure'])
        return
    else
        if s(2)>s(1)
            lib = lib';
        end
        s = size(lib);
        if s(2)==1
            lib = [(1:length(lib))' lib];
        end
    end
end

% Create output structure
thick = lib(:,1);
library = lib(:,2);
