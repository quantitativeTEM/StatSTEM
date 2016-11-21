function deleteAtomCounting(tab,h)
% deleteAtomCounting - Delete the atom counts from the StatSTEM interface
%
%   In this function all necessary steps are taken to delete the atom
%   counting results from the StatSTEM interface. 
%
%       syntax: deleteAtomCounting(tab,h)
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

% Find selected image
value = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');

%% First delete all references to the atom counting (restore figure if necessary)
for n=1:length(str)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'Atom Counts');
    end
    if any(ind)
        if data{ind,1} && value==n
            data{ind,1} = false;
            set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
            if strcmp(str{n},'Observation')
                obs = usr.file.input.obs;
            elseif strcmp(str{n},'Model')
                obs = usr.file.output.model;
            end
            deleteAtomCounts(h,tab,obs,'Atom Counts')
            usr = get(tab,'Userdata');
        end
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
    end
end
set(tab,'Userdata',usr);

%% Now delete all GUI components refering to the ICL
% Check whether the ICL is shown, if so show observation
if strcmp(str{value},'ICL')
    value = find(strcmp(str,'Observation'));
    showImage(tab,'Observation',h)
    usr = get(tab,'Userdata');
end

% Remove ICL image
val_icl = find(strcmp(str,'ICL'));
if ~isempty(val_icl)
    % Figure options
    delete(usr.figOptions.selOpt.(['optionsImage',num2str(val_icl)]))
    usr.figOptions.selOpt = rmfield(usr.figOptions.selOpt,['optionsImage',num2str(val_icl)]);

    % Update stored names of other components
    for n=val_icl+1:length(str)
        usr.figOptions.selOpt.(['optionsImage',num2str(n-1)]) = usr.figOptions.selOpt.(['optionsImage',num2str(n)]);
        usr.figOptions.selOpt = rmfield(usr.figOptions.selOpt,['optionsImage',num2str(n)]);
    end

    % Update listbox
    if value>val_icl
        value = value-1;
    end
    str = [str(1:val_icl-1);str(val_icl+1:end)];
    set(usr.figOptions.selImg.listbox,'String',str,'Value',value)
end


%% Now delete all GUI components refering to the SCS vs. Thickness
% Check whether histogram is shown
if strcmp(str{value},'SCS vs. Thickness')
    value = find(strcmp(str,'Observation'));
    showImage(tab,'Observation',h)
    usr = get(tab,'Userdata');
end

% Images
val_hist = find(strcmp(str,'SCS vs. Thickness'));
if ~isempty(val_hist)
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
end



%% Now delete all all reference to the fitted GMM
% The GMM
for n=1:length(str)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'GMM');
    end
    if any(ind)
        if data{ind,1} && value==n
            deleteImageObject(usr.images.ax,data{ind,2})
        end
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
    end
end

% The components of the GMM
for n=1:length(str)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'GMM components');
    end
    if any(ind)
        if data{ind,1} && value==n
            deleteImageObject(usr.images.ax,data{ind,2})
        end
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
    end
end

%% Last steps, update GUI files
% Now delete atom counting results from file
usr.file = rmfield(usr.file,'atomcounting');
% Update parameters
set(tab,'Userdata',usr)
% Update panels
updateLeftPanels(h,usr.file,usr.fitOpt)