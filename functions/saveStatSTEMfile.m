function [message,FileName] = saveStatSTEMfile(varargin)
% saveStatSTEMfile - function to save StatSTEM files 
%
% syntax: [message,FileName] = saveStatSTEMfile(varargin)
%       varargin - StatSTEM files
%       message  - String indicating the status
%       FileName - path to file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<1
    % No input
    message = 'No file to save given';
    FileName = 0;
    return
end

% Convert input to correct structure if not given
if nargin>1 || ~isa(varargin{1},'struct')
    file = struct;
    for i=1:nargin
    % Identify different classes and give them the correct name
        switch class(varargin{i})
            case 'inputStatSTEM'
                file.input = varargin{i};
            case 'outputStatSTEM'
                file.output = varargin{i};
            case 'atomCountStat'
                file.atomcounting = varargin{i};
            case 'atomCountLib'
                file.libcounting = varargin{i};
            case 'strainMapping'
                file.strainmapping = varargin{i};
        end
    end
else
    file = varargin{1};
end

% Make sure functions are available
p = mfilename('fullpath');
loc = strfind(p,filesep);
p = p(1:loc(end));
addpath([p,filesep,'LoadFiles']);
% Check default path
PathName = getDefaultPath();

% Ask user for file location and name
fNames = fieldnames(file);
FileName = file.(fNames{1}).name;
[~, ~, ext] = fileparts(FileName);
s = size(ext);
fName = FileName(1:end-s(1)*s(2));
[FileName,PathName] = uiputfile({'*.mat','MATLAB Files (*.mat)'}, ...
   'Select a location',[PathName filesep fName '.mat']);

if FileName==0
    message = ['Saving file ',fName,' cancelled'];
    return
end
% Store new pathname
updatePath(PathName)

% Update filename in files themself and remove possible references to StatSTEM GUI
for i=1:length(fNames)
    file.(fNames{i}).name = FileName;
    file.(fNames{i}).GUI = [];
    file.(fNames{i}).ax = [];
    file.(fNames{i}).ax2 = [];
    file.(fNames{i}).waitbar = [];
end

% Store file
save([PathName,FileName],'-struct','file');

message = ['File ',FileName,' successfully saved'];
