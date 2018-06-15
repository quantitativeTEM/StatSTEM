function [file,message,FileName] = loadStatSTEMfile(FileName,takeMean)
% loadStatSTEMfile - function to load a file or TEM image for a statistical
% analysis
%
% syntax: file = loadStatSTEMfile(FileName,takeMean)
%       file     - Structure containing StatSTEM files (input, output, analysis)
%       takeMean - In case of image stack, take the mean image (optional, normally user make graphically selection)
%       message  - String indicating the status
%       FileName - path to file

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<2
    takeMean = false;
end

% Make sure function are available
p = mfilename('fullpath');
loc = strfind(p,filesep);
p = p(1:loc(end));
addpath([p,filesep,'LoadFiles']);
if nargin<1
    % Check default path
    PathName = getDefaultPath();
    % Let the user select an input file
    supFiles = {'*.mat;*.ser;*.dm3;*.dm4;*.txt;*.TXT','Supported Files (*.mat,*.ser,*.dm3,*.dm4,*.txt)';...
        '*.mat','MATLAB Files (*.mat)';'*.ser','SER Files (*.ser)';...
        '*.dm3;*.dm4','DM Files (*.dm3,*dm4)';...
        '*.txt;*.TXT','TXT Files (*.txt)';'*.*',  'All Files (*.*)'};
    [FileName,PathName] = uigetfile(supFiles,'Select a file',PathName);
    if FileName==0
        file = [];
        message = 'Loading new file cancelled';
        return
    end
    updatePath(PathName)
    FileName = [PathName,filesep,FileName];
end
[~, ~, ext] = fileparts(FileName);
switch ext
    case '.mat'
        [file,message] = loadMatFile(FileName);
    case {'.txt','.TXT'}
        [file,message] = loadTXTFile(FileName);
    case '.ser'
        [file,message] = loadSERfile(FileName,takeMean);
    case {'.dm3','.dm4'}
        [file,message] = loadDMfile(FileName,takeMean);
end
