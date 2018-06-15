function obj = importPeaks(obj)
% importPeaks - Callback for importing peak locations
%
%   syntax: importPeaks(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------


%% Load the user coordinates
% Let the user select a file
PathName = getDefaultPath();
[FileName,PathName] = uigetfile({'*.mat;*.txt;*.TXT','Supported Files (*.mat, *.txt)';'*.mat','MATLAB Files (*.mat)';'*.txt;*.TXT','TEXT Files (*.txt)';'*.*',  'All Files (*.*)'}, ...
   'Select a file',PathName);

if FileName==0
    return
end
updatePath(PathName)
    
[~, FileName, ext] = fileparts(FileName);
switch ext
    case '.mat'
        file = load([PathName,FileName,ext]);
        names = fieldnames(file);
        opt = 1;
        if any(strcmp(names,'input'))
            names2 = fieldnames(file.input);
            if ~any(strcmp(names2,'coordinates'))
                h_mes = errordlg('Make sure input file contains input coordinates');
                waitfor(h_mes)
                return
            end
            
            if  any(strcmp(names,'output'))
                names2 = fieldnames(file.output);
                if any(strcmp(names2,'coordinates'))
                    coorq = questdlg('Which coordinates should be used, input or fitted coordinates?','Loading coordinates','input','fitted','fitted');
                    drawnow; pause(0.05); % MATLAB hang 2013 version
                    waitfor(coorq)
                    if strcmp(coorq,'fitted')
                        opt = 2;
                    end
                end
            end
            
            % Add type if not yet added
            if size(file.input.coordinates,2)==2
                file.input.coordinates(:,3) = 1;
            end
            % Load coordinates
            if opt==2
                if size(file.output.coordinates,2)==2
                    obj.coordinates = [file.output.coordinates file.input.coordinates(:,3)];
                else
                    obj.coordinates = file.output.coordinates;
                end
            else
                obj.coordinates = file.input.coordinates;
            end
        elseif length(names)>1
            h_mes = errordlg('Make sure input file contains input coordinates in a 2-by-n array');
            waitfor(h_mes)
            return
        else
            obj.coordinates = file.(names{1});
        end
    case '.txt'
        coor = dlmread([PathName,FileName,ext]);
        if isempty(coor)
            h_mes = errordlg('Make sure input file contains coordinates in a 2-by-n array (given in Angstrom)');
            waitfor(h_mes)
            return
        elseif size(coor,1)>2 && size(coor,2)>2
            h_mes = errordlg('Make sure input file contains coordinates in a 2-by-n array');
            waitfor(h_mes)
            return
        end
        obj.coordinates = [coor, ones(size(coor,1),1)];
    otherwise
        h_mes = errordlg('File Type not supported (yet)');
        waitfor(h_mes)
        return
end