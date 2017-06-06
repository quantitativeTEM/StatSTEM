function numberATypes(hObject,event,h,ref2,item,item2)
% numberATypes - Callback adding, updating or removing atom types
%
%   syntax: numberATypes(hObject,event,h,ref2,item,item2)
%       hObject - reference to dropdownmenu
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%       ref2    - reference to dropdownmenu 2
%       item    - selected item in dropdownmenu
%       item 2  - selected item in dropdownmenu 2
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<5
    item = get(hObject,'SelectedItem');
    item2 = get(ref2,'SelectedItem');
end

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
    turnOffFigureSelection(h);
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h,ref2,item,item2};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Check if selected item changed
if strcmp(item,item2)
    return
end

% Check if colorbar is shown
if strcmp(get(h.colorbar(1),'State'),'off')
    sColBar = 0;
else
    sColBar = 1;
end

% Load the selected tab
tab = loadTab(h);
if isempty(tab)
    set(hObject,'SelectedItem',item2)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

switch item
    case 'Add'
        num = get(hObject,'ItemCount');
        str = cell(num,1);
        for n=1:num
            str{n,1} = hObject.getItemAt(n-1);
        end
        
        name = {num2str(num-2)};
        uni = 0;
        while uni~=1
            name = inputdlg('Give name for new atom type:','Name',1,name);
            drawnow; pause(0.05); % MATLAB hang 2013 version
            if isempty(name)
                set(hObject,'SelectedItem',item2)
                return
            else
                if ~any(strcmp(str,name))
                    uni=1;
                    str = [str(1:num-3);name;str(num-2:num)];
                else
                    h_mes = errordlg('Name not unique, please enter an unique name');
                    waitfor(h_mes)
                end
            end
        end
        types = str(1:num-2);
        % Update userdata
        usr = get(tab,'Userdata');
        usr.file.input.types = types;
        set(tab,'Userdata',usr);
        
        % Update menus
        hObject.setModel(javax.swing.DefaultComboBoxModel(str))
        set(hObject,'SelectedItem',str{num-2,1})
        ref2.setModel(javax.swing.DefaultComboBoxModel(str))
        set(ref2,'SelectedItem',str{num-2,1})
        h.left.ana.panel.strainAdv.selType.setModel(javax.swing.DefaultComboBoxModel(types))
    case 'Remove'
        num = get(hObject,'ItemCount');
        if num==4
            h_mes = errordlg('Last atom type cannot be removed');
            waitfor(h_mes)
            set(hObject,'SelectedItem',item2)
            return
        end
        
        str = cell(num,1);
        for n=1:num
            str{n,1} = hObject.getItemAt(n-1);
        end
        
        % Select atom type to be removed
        [type,output] = listdlg('ListString',str(1:num-3,1),'SelectionMode','Single','Name','Remove atom type','PromptString','Select atom type to be removed:','ListSize',[200,250]);
        drawnow; pause(0.05); % MATLAB hang 2013 version
        
        if output==0
            set(hObject,'SelectedItem',item2)
            return
        end
        
        % Update file
        usr = get(tab,'Userdata');
        input = usr.file.input;
        if isempty(input.coordinates)
            ind = [];
        else
            ind = input.coordinates(:,3)==type;
        end
        str2 = str([1:type-1,type+1:num]);
        if any(ind)
            quest = questdlg(['Atoms of deleted atom type (',str{type},') still present, what should be done?'],'Warning','Delete','Change atom type','Cancel','Cancel');
            drawnow; pause(0.05); % MATLAB hang 2013 version
            switch quest
                case 'Delete'
                    string = ['Removal of atom type (',str{type},') will erase the fitted model and all analysis, continue?'];
                    [quest,usr] = removeQuestionPrep(tab,h,string);
                    if strcmp(quest, 'No')
                        set(hObject,'SelectedItem',item2)
                        return
                    end
                    input.coordinates = input.coordinates(ind==0,:);
                case 'Change atom type'
                    [new_type,output] = listdlg('ListString',str2(1:num-4),'SelectionMode','Single','Name','Change atom type','PromptString','Select new atom type:');
                    drawnow; pause(0.05); % MATLAB hang 2013 version
                    if output==0
                        set(hObject,'SelectedItem',item2)
                        return
                    else
                        input.coordinates(ind,3) = find(strcmp(str,str2(new_type)));
                    end
                case 'Cancel'
                    set(hObject,'SelectedItem',item2)
                    return
            end
        end
        % Now update stored atom types reference
        for n=type:num-3
            input.coordinates(input.coordinates(:,3)==n,3) = n-1;
        end
        
        % Update and store file
        usr.file.input = input;
        usr.file.input.types = str2(1:num-4);
        set(tab,'Userdata',usr)
        if any(ind) || type<num-3
            % Update input coordinates in images
            str = get(usr.figOptions.selImg.listbox,'String');
            val = get(usr.figOptions.selImg.listbox,'Value');
            if strcmp(str{val},'Observation') || strcmp(str{val},'Model')
                nameTag = 'Input coordinates';
                nameTag2 = 'Fitted coordinates';
                data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
                ind = strcmp(data(:,2),nameTag);
                if any(ind)
                    if data{ind,1}
                        % Delete and show
                        showHideFigOptions(tab,val,nameTag,false,h,sColBar)
                        showHideFigOptions(tab,val,nameTag,true,h,sColBar)
                    end
                end
                ind = strcmp(data(:,2),nameTag2);
                if any(ind)
                    if data{ind,1}
                        % Delete and show
                        showHideFigOptions(tab,val,nameTag2,false,h,sColBar)
                        showHideFigOptions(tab,val,nameTag2,true,h,sColBar)
                    end
                end
            end
        end
            
        % Update menu
        hObject.setModel(javax.swing.DefaultComboBoxModel(str2))
        set(hObject,'SelectedItem',str2{1})
        ref2.setModel(javax.swing.DefaultComboBoxModel(str2))
        set(ref2,'SelectedItem',str2{1})
        h.left.ana.panel.strainAdv.selType.setModel(javax.swing.DefaultComboBoxModel(str2(1:num-4)))
        
        % Enable/Disable buttons
        updateLeftPanels(h,usr.file,usr.fitOpt)
    case 'Names'
        num = get(hObject,'ItemCount');
        str = cell(num,1);
        for n=1:num
            str{n,1} = hObject.getItemAt(n-1);
        end
        
        % Get position GUI, to center dialog
        pos = get(h.fig,'Position');

        % Edit (or view) names
        str(1:num-3) = typeNames(str(1:num-3),'Center',[pos(1)+pos(3)/2 pos(2)+pos(4)/2]);
        
        % Update userdata
        usr = get(tab,'Userdata');
        usr.file.input.types = str(1:num-3);
        set(tab,'Userdata',usr)
        
        % Update menu
        hObject.setModel(javax.swing.DefaultComboBoxModel(str))
        set(hObject,'SelectedItem',str{1})
        ref2.setModel(javax.swing.DefaultComboBoxModel(str))
        set(ref2,'SelectedItem',str{1})
        % Make selected item same as before in analysis panel
        ind = get(h.left.ana.panel.strainAdv.selType,'SelectedIndex');
        h.left.ana.panel.strainAdv.selType.setModel(javax.swing.DefaultComboBoxModel(str(1:num-3)))
        set(h.left.ana.panel.strainAdv.selType,'SelectedIndex',ind)

    otherwise
        set(ref2,'SelectedItem',item)
end