function obj = numberATypes(obj,item)
% numberATypes - Adding, updating or removing atom types
%
%   syntax: obj = numberATypes(obj,item)
%       obj  - inputStatSTEM file
%       item - selected action
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<2
    item = 'Add';
end

types = obj.types;
switch item
    case 'Add'
        obj.actType = obj.types{1};
        num = length(types)+1;
        name = {num2str(num)};
        uni = 0;
        while uni~=1
            name = inputdlg('Give name for new atom type:','Name',1,name);
            drawnow; pause(0.05); % MATLAB hang 2013 version
            if isempty(name)
                return
            else
                if ~any(strcmp(types,name))
                    uni=1;
                    obj.types = [obj.types;name];
                else
                    h_mes = errordlg('Name not unique, please enter an unique name');
                    waitfor(h_mes)
                end
            end
        end
        obj.actType = obj.types{num};
    case 'Remove'
        obj.actType = obj.types{1};
        num = length(types);
        if num==1
            h_mes = errordlg('Last atom type cannot be removed');
            waitfor(h_mes)
            return
        end
        
        % Select atom type to be removed
        [type,output] = listdlg('ListString',obj.types,'SelectionMode','Single','Name','Remove atom type','PromptString','Select atom type to be removed:','ListSize',[200,250]);
        drawnow; pause(0.05); % MATLAB hang 2013 version
        
        if output==0
            return
        end
        
        % Update file
        types = obj.types([1:type-1,type+1:end]);
        if isempty(obj.coordinates)
            ind = [];
        else
            ind = obj.coordinates(:,3)==type;
        end
        if any(ind)
            quest = questdlg(['Atoms of deleted atom type (',obj.types{type},') still present, what should be done?'],'Warning','Delete','Change atom type','Cancel','Cancel');
            drawnow; pause(0.05); % MATLAB hang 2013 version
            switch quest
                case 'Delete'
                    obj.coordinates = obj.coordinates(ind==0,:);
                case 'Change atom type'
                    [new_type,output] = listdlg('ListString',types,'SelectionMode','Single','Name','Change atom type','PromptString','Select new atom type:');
                    drawnow; pause(0.05); % MATLAB hang 2013 version
                    if output==0
                        return
                    else
                        obj.coordinates(ind,3) = new_type;
                    end
                case 'Cancel'
                    return
            end
            % Change indices types
            for n=type+1:num
                ind = obj.coordinates(:,3)==n;
                obj.coordinates(ind,3) = n-1;
            end
        end
        obj.types = types;
        obj.actType = types{1};
    case 'Names'
        if ~isempty(obj.GUI)
            % Get position GUI, to center dialog
            pos = get(obj.GUI,'Position');
            cent = [pos(1)+pos(3)/2 pos(2)+pos(4)/2];
        else
            screensize = get( 0, 'Screensize' );
            cent = [screensize(3)/2 screensize(4)/2];
        end
        % Edit (or view) names
        obj.types = typeNames(obj.types,'Center',cent);
        obj.actType = obj.types{1};
    otherwise
        obj.actType = item;
end