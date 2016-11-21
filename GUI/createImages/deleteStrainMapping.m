function deleteStrainMapping(tab,h,keep)
% deleteStrainMapping - Delete the strain maps from the StatSTEM interface
%
%   In this function all necessary steps are taken to delete the strain
%   mapping results from the StatSTEM interface. 
%
%       syntax: deleteStrainMapping(tab,h)
%           tab  - reference to the selected tab
%       	h    - structure holding references to the StatSTEM interface
%           keep - Define from which structure results should be kept
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<3
    keep = 0;
else
    switch keep
        case 'Displacement map'
            keep = 3;
        case 'Ref strainmapping'
            keep = 1;
        otherwise
            keep = 0;
    end
end

% Get handle to panels in tab
usr = get(tab,'Userdata');

% Find selected image
value = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');

%% First delete all references to the strain mapping
for n=1:length(str)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
    nameTags = cell(4,1);
    nameTags{1,1} = [char(949),'_xx'];
    nameTags{2,1} = [char(949),'_xy'];
    nameTags{3,1} = [char(949),'_yy'];
    nameTags{4,1} = [char(969),'_xy'];
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),nameTags{1,1});
        for k=2:4
            ind = ind | strcmp(data(:,2),nameTags{k,1});
        end
    end
    if any(ind)
        names = data(ind,:);
        % Remove option
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
        for k=1:size(names,1)
            if names{k,1} && value==n
                showHideFigOptions(tab,value,names{k,2},false,h,0,[],[])
                usr = get(tab,'Userdata');
                break
            end
        end
    end
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'Displacement map');
    end
    if any(ind) && keep<3
        % Remove option
        shown = data{ind,1};
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
        if shown && n==value
            % Delete displacement map if necessary
            deleteImageObject(usr.images.ax,'Displacement map')
        end
    end
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'a & b lattice');
    end
    if any(ind) && keep<2
        shown = data{ind,1};
        % Remove option
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
        if shown && n==value
            % Delete selected coordinates if necessary
            deleteImageObject(usr.images.ax,'a & b lattice')
        end
    end
    if isempty(data)
        ind = [];
    else
        ind = strcmp(data(:,2),'Ref strainmapping');
    end
    if any(ind) && keep<1
        shown = data{ind,1};
        % Remove option
        data = data(~ind,:);
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
        if shown && n==value
            % Delete selected coordinates if necessary
            deleteImageObject(usr.images.ax,'Ref strainmapping')
        end
    end
end
set(tab,'Userdata',usr);

%% Last steps, update GUI files
% Now delete strain mapping results from file
if keep>=1
    refCoor = usr.file.strainmapping.refCoor;
end
if keep>=2
    teta = usr.file.strainmapping.teta;
    a = usr.file.strainmapping.a;
    b = usr.file.strainmapping.b;
    dirTeta = usr.file.strainmapping.dir_teta_ab;
end
if keep>=3
    coor_ref = usr.file.strainmapping.coor_relaxed;
    types = usr.file.strainmapping.types;
    indices = usr.file.strainmapping.indices;
end
usr.file = rmfield(usr.file,'strainmapping');
if keep>=1
    usr.file.strainmapping.refCoor = refCoor;
end
if keep>=2
    usr.file.strainmapping.teta = teta;
    usr.file.strainmapping.a = a;
    usr.file.strainmapping.b = b;
    usr.file.strainmapping.dir_teta_ab = dirTeta;
end
if keep>=3
    usr.file.strainmapping.coor_relaxed = coor_ref;
    usr.file.strainmapping.types = types;
    usr.file.strainmapping.indices = indices;
end
% Update parameters
set(tab,'Userdata',usr)
% Update panels
updateLeftPanels(h,usr.file,usr.fitOpt)