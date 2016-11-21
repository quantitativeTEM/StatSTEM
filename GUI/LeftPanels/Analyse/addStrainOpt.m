function addStrainOpt(tab)
% addStrainOpt - Add options in StatSTEM to show strainmapping resuls
%
%   syntax: addStrainOpt(tab)
%       tab - reference to tab containing the data
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Get references of tab panel
usr = get(tab,'Userdata');

str = get(usr.figOptions.selImg.listbox,'String');
val1 = find(strcmp(str,'Observation'));
val2 = find(strcmp(str,'Model'));
data1 = get(usr.figOptions.selOpt.(['optionsImage',num2str(val1)]),'Data');
data2 = get(usr.figOptions.selOpt.(['optionsImage',num2str(val2)]),'Data');

if any(strcmp(fieldnames(usr.file),'strainmapping'))
    if any(strcmp(fieldnames(usr.file.strainmapping),'refCoor'))
        data1 = [data1;{false,'Ref strainmapping'}];
        data2 = [data2;{false,'Ref strainmapping'}];
    end
    
    if any(strcmp(fieldnames(usr.file.strainmapping),'teta'))
        data1 = [data1;{false,'a & b lattice'}];
        data2 = [data2;{false,'a & b lattice'}];
    end
    
    if any(strcmp(fieldnames(usr.file.strainmapping),'coor_relaxed'))
        data1 = [data1;{false,'Displacement map'}];
        data2 = [data2;{false,'Displacement map'}];
    end
    
    if any(strcmp(fieldnames(usr.file.strainmapping),'eps_xx'))
        nameTags{1,1} = [char(949),'_xx'];
        nameTags{2,1} = [char(949),'_xy'];
        nameTags{3,1} = [char(949),'_yy'];
        nameTags{4,1} = [char(969),'_xy'];
        for n=1:4
            data1 = [data1;{false,nameTags{n,1}}];
            data2 = [data2;{false,nameTags{n,1}}];
        end
    end
end

set(usr.figOptions.selOpt.(['optionsImage',num2str(val1)]),'Data',data1);
set(usr.figOptions.selOpt.(['optionsImage',num2str(val2)]),'Data',data2);