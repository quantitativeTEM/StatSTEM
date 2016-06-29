function updateDX(jObject,event,h)
% updateDX - Callback for using a new pixel size value
%
%   syntax: updateDX(jObject,event,h)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

str = get(jObject,'Text');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    error = 1;
elseif isnan(num)
    error = 1;
elseif num<0 || abs(num)~=num
    error = 1;
else
    error = 0;
end

% Continue, load tab and userdata
tab = loadTab(h);
if isempty(tab)
    return
end
% Load image
usr = get(tab,'Userdata');

% If the number is incorrect, cancel operation
if error
    set(jObject,'Text',num2str(usr.file.input.dx));
    h_error = errordlg('Error: Please insert a positive number');
    waitfor(h_error)
    return
end

% If nothing changed, don't update anything
if usr.file.input.dx == num
    return
else
    dxOld = usr.file.input.dx;
    usr.file.input.dx = num;
end

%% Update file parameters
% Update input coordinates
if ~isempty(usr.file.input.coordinates)
    usr.file.input.coordinates = [usr.file.input.coordinates(:,1:2)/dxOld*num usr.file.input.coordinates(:,3)];
end

% Update the fitted parameters if possible
if any(strcmp(fieldnames(usr.file),'output'))
    % The fitted coordinates
    usr.file.output.coordinates = usr.file.output.coordinates*num/dxOld;
    % Fitted width gaussians
    usr.file.output.rho = usr.file.output.rho*num/dxOld;
    % The volumes
    usr.file.output.volumes = usr.file.output.volumes*(num/dxOld)^2;
end

% The selected region and histogram for atomcounting
if ~isempty(usr.fitOpt.atom.selCoor)
    usr.fitOpt.atom.selCoor = usr.fitOpt.atom.selCoor*num/dxOld;
end
if ~isempty(usr.fitOpt.atom.minVol)
    usr.fitOpt.atom.minVol = usr.fitOpt.atom.minVol*(num/dxOld)^2;
end
if ~isempty(usr.fitOpt.atom.maxVol)
    usr.fitOpt.atom.maxVol = usr.fitOpt.atom.maxVol*(num/dxOld)^2;
end

    
% Update the atom counting results if possible
if any(strcmp(fieldnames(usr.file),'atomcounting'))
    % The selected coordinates
    usr.file.atomcounting.coordinates = usr.file.atomcounting.coordinates*num/dxOld;
    % The selected volumes
    usr.file.atomcounting.volumes = usr.file.atomcounting.volumes*(num/dxOld)^2;
    % The estimated locations
    usr.file.atomcounting.estimatedLocations = usr.file.atomcounting.estimatedLocations*(num/dxOld)^2;
    % The estimated width
    usr.file.atomcounting.estimatedWidth = usr.file.atomcounting.estimatedWidth*(num/dxOld)^2;
    
    % Update all fitted mixture models
    for n=1:length(usr.file.atomcounting.estimatedDistributions)
        usr.file.atomcounting.estimatedDistributions{1,n}.mu = usr.file.atomcounting.estimatedDistributions{1,n}.mu*(num/dxOld)^2;
        usr.file.atomcounting.estimatedDistributions{1,n}.Sigma = usr.file.atomcounting.estimatedDistributions{1,n}.Sigma*(num/dxOld)^4;
    end
end

% Update file
set(tab,'Userdata',usr)

%% Update shown image
str = get(usr.figOptions.selImg.listbox,'String');
val = get(usr.figOptions.selImg.listbox,'Value');
showImage(tab,str{val},h)