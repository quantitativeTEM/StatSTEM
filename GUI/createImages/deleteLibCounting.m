function deleteLibCounting(tab,h)
% deleteLibCounting - Delete the library counts from the StatSTEM interface
%
%   In this function all necessary steps are taken to delete the library
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

%% First delete all references to the atom counting
for n=1:length(str)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'Lib Counts');
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
            deleteAtomCounts(h,tab,obs,'Lib Counts')
            usr = get(tab,'Userdata');
        end
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
    end
end
set(tab,'Userdata',usr);

%% Last steps, update GUI files
% Now delete atom counting results from file
usr.file = rmfield(usr.file,'libcounting');
% Update parameters
set(tab,'Userdata',usr)
% Update panels
updateLeftPanels(h,usr.file,usr.fitOpt)