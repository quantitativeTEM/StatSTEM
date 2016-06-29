function [file,message,dx] = loadMatFile(PathName,FileName)
% loadMatFile - Load a matlab file suitable for StatSTEM
%
%   syntax: [file,message,dx] = loadMatFile(PathName,FileName)
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

file = load([PathName,FileName,'.mat']);
message = '';
dx = 'ok';
if isfield(file,'input')
    if ~isfield(file.input,'dx')
        file.input.dx = 0.1;
        dx = 'ask';
    end
    if ~isfield(file.input,'coordinates')
        file.input.coordinates = [];
    end
else
    fName = fieldnames(file);
    if length(fName)==1 && isa(file.(fName{1}),'double')
        file.input.obs = file.(fName{1});
        file = rmfield(file,fName{1});
        file.input.dx = 0.1;
        file.input.coordinates = [];
        dx = 'ask';
    else
        message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
        errordlg('Invalid input structure')
        return
    end
end

s = size(file.input.obs);
if s(1)==1 || s(2)==1
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid structure']);
    errordlg('Invalid structure')
    return
end
if ~isa(file.input.obs,'double')
    message = sprintf(['The file ', FileName, ' cannot be loaded, observation is not loaded in double precision']);
    errordlg('Invalid structure')
    return
end

% Check if atom types are specified
if ~isempty(file.input.coordinates)
    if size(file.input.coordinates,2)==2
        file.input.coordinates(:,3) = 1;
    end
end

% Create types field, if not existing
if ~any(strcmp(fieldnames(file.input),'types'))
    if isempty(file.input.coordinates)
        file.input.types = {'1'};
    else
        num = max(file.input.coordinates(:,3));
        str = cell(num,1);
        for n=1:num
            str{n,1} = num2str(n);
        end
        file.input.types = str;
    end
end

% % Check if file is made by GUI, if not correct coordinates by shifting them
% % 1 pixel
% shift = file.input.dx; %pixel
% if isfield(file,'GUI')
%     if file.GUI
%         shift = 0;
%     end
% end
% if ~isempty(file.input.coordinates)
%     file.input.coordinates(:,1:2) = file.input.coordinates(:,1:2) + shift;
% end
if isfield(file,'output')
    names = fieldnames(file.output);
    if any(strcmp(names,'BetaX'))
        file.output.coordinates = [file.output.BetaX,file.output.BetaY];
        file.output = rmfield(file.output,{'BetaX','BetaY'});
    end    
%     file.output.coordinates = file.output.coordinates + shift;
end