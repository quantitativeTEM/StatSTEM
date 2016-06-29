function deleteModel(tab,h)
% deleteModel - Delete the created model
%
%   In this function all necessary steps are taken to delete the fitted 
%   model from the StatSTEM interface.
%
%       syntax: deleteModel(tab)
%           tab  - reference to the selected tab
%       	h    - structure holding references to the StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Get handle to panels in tab
usr = get(tab,'Userdata');

% Define nameTag
nameTag = 'Fitted coordinates';

% Find selected image
value = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');

%% Delete all preparation parameters for atomcounting
for n=1:length(str)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'Coor atomcounting');
    end
    
    if any(ind)
        if data{ind,1} && n==value
            % Delete selected coordinates if necessary
            deleteImageObject(usr.images.ax,'Coor atomcounting')
        end
        
        % Remove option
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data(~ind,:))
    end
end
usr.fitOpt.atom.selCoor = [];
usr.fitOpt.atom.maxVol = [];
usr.fitOpt.atom.minVol = [];
set(tab,'Userdata',usr);

%% Delete all GUI components refering to the model
val_mod = find(strcmp(str,'Model'));

% Remove fitted coordinates from other figure options
for n=1:length(str)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),nameTag);
    end
    if any(ind)
        if data{ind,1} && n==value
            % Delete fitted coordinates if necessary
            deleteImageObject(usr.images.ax,nameTag)
        end
        
        % Remove option
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data(~ind,:))
    end
end
set(tab,'Userdata',usr);

% Check whether model is shown, if so show observation
if strcmp(str{value},'Model')
    value = find(strcmp(str,'Observation'));
    showImage(tab,'Observation',h)
    usr = get(tab,'Userdata');
end

% Figure options
delete(usr.figOptions.selOpt.(['optionsImage',num2str(val_mod)]))
usr.figOptions.selOpt = rmfield(usr.figOptions.selOpt,['optionsImage',num2str(val_mod)]);

% Update stored names of other components
for n=val_mod+1:length(str)
    usr.figOptions.selOpt.(['optionsImage',num2str(n-1)]) = usr.figOptions.selOpt.(['optionsImage',num2str(n)]);
    usr.figOptions.selOpt = rmfield(usr.figOptions.selOpt,['optionsImage',num2str(n)]);
end

% Update listbox
if value>val_mod
    value = value-1;
end
str = [str(1:val_mod-1);str(val_mod+1:end)];
set(usr.figOptions.selImg.listbox,'String',str,'Value',value)

%% Delete all GUI components refering to the histogram
val_hist = find(strcmp(str,'Histogram SCS'));

% Check whether histogram is shown
if strcmp(str{value},'Histogram SCS')
    value = find(strcmp(str,'Observation'));
    showImage(tab,'Observation',h)
    usr = get(tab,'Userdata');
end

% Figure options
delete(usr.figOptions.selOpt.(['optionsImage',num2str(val_hist)]))
usr.figOptions.selOpt = rmfield(usr.figOptions.selOpt,['optionsImage',num2str(val_hist)]);

% Update stored names of other components
for n=val_hist+1:length(str)
    usr.figOptions.selOpt.(['optionsImage',num2str(n-1)]) = usr.figOptions.selOpt.(['optionsImage',num2str(n)]);
    usr.figOptions.selOpt = rmfield(usr.figOptions.selOpt,['optionsImage',num2str(n)]);
end

% Update listbox
if value>val_hist
    value = value-1;
end
str = [str(1:val_hist-1);str(val_hist+1:end)];
set(usr.figOptions.selImg.listbox,'String',str,'Value',value)

%% Last steps, update GUI components
% Delete model from file
usr.file = rmfield(usr.file,'output');
% Also disable export fitted coordinates button
h.left.fit.panels.Test.CoorBut.setEnabled(false)
% Update parameters
set(tab,'Userdata',usr)
