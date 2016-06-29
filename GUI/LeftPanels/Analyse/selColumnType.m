function selColumnType(hObject,event,h)
% selColumnType - Select specific columns for the atomcounting routine
%
% This function enables the user to select specific column in the StatSTEM
% interface which will only be used for the atomcounting routine. Columns
% are selected based on atom type
%
%   syntax: selColumnType(hObject,event,h)
%       hObject - Reference to button
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

%% Preparation of function
% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
    turnOffFigureSelection(h);
    % Is so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Check if button is enabled
if ~get(hObject,'Enabled')
    return
end

% Turn off all editing in the figure
plotedit(h.fig,'off')

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

% Determine state
color = hObject.getForeground;
if get(color,'Red')==0
    %% Preparation
    % Delete previous analysis is necessary
    usr = get(tab,'Userdata');
    if any(strcmp(fieldnames(usr.file),'atomcounting'))
        quest = questdlg('Select a region for atom counting will remove previous atom counting results, continue?','Warning','Yes','No','No');
        drawnow; pause(0.05); % MATLAB hang 2013 version
        switch quest
            case 'Yes'
                deleteAtomCounting(tab,h)
                usr = get(tab,'Userdata');
            case 'No'
                return
        end
    end
    
    types = usr.file.input.types;
        
    % Select atom type for atomcounting
    [type,output] = listdlg('ListString',types,'SelectionMode','Single','Name','Select atom type','PromptString','Select atom type for atomcounting:','ListSize',[200,250]);
    drawnow; pause(0.05); % MATLAB hang 2013 version
    
    if output==0
        return
    end
    usr.fitOpt.atom.selType = type;
    
    % Update userdata
    set(tab,'Userdata',usr)

    %% Update figure options
    if ~isempty(usr.fitOpt.atom.selType)
        str = get(usr.figOptions.selImg.listbox,'String');
        val = get(usr.figOptions.selImg.listbox,'Value');
        nameTag = 'Coor atomcounting';
        addOpt = isempty(usr.fitOpt.atom.selCoor) && isempty(usr.fitOpt.atom.minVol) && isempty(usr.fitOpt.atom.maxVol);
        value = find(strcmp(str,'Model'));
        value2 = find(strcmp(str,'Observation'));
        if addOpt
            % Add option region atomcounting
            data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
            data = [data;{true nameTag}];
            % Update data
            set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data);

            data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value2)]),'Data');
            if val==value
                data_old = data;
            end
            data = [data;{false nameTag}];
            % Update data
            set(usr.figOptions.selOpt.(['optionsImage',num2str(value2)]),'Data',data);
        end
        % Reshow the image, or update the figure options
        value3 = find(strcmp(str,'Histogram SCS'));
        if val==value3
            showImage(tab,'Histogram SCS',h)
        elseif val==value || val==value2
            if ~addOpt
                showHideFigOptions(tab,val,nameTag,false)
            end
            showHideFigOptions(tab,val,nameTag,true)
        end
        usr = get(tab,'Userdata');
        
        % Make text button appear red
        hObject.setForeground(java.awt.Color(1,0,0))
        set(hObject,'Text','Delete selection on type')
    end
else
    %% Preparation
    % Delete previous analysis is necessary
    usr = get(tab,'Userdata');
    if any(strcmp(fieldnames(usr.file),'atomcounting'))
        quest = questdlg('Deleting the selected type will remove previous atom counting results, continue?','Warning','Yes','No','No');
        drawnow; pause(0.05); % MATLAB hang 2013 version
        switch quest
            case 'Yes'
                deleteAtomCounting(tab,h)
                usr = get(tab,'Userdata');
            case 'No'
                return
        end
    end
    usr.fitOpt.atom.selType = [];
    set(tab,'Userdata',usr)
    
    % Update the images
    str = get(usr.figOptions.selImg.listbox,'String');
    value = get(usr.figOptions.selImg.listbox,'Value');
    val = find(strcmp(str,'Histogram SCS'));
    if val==value
        showImage(tab,'Histogram SCS',h)
        usr = get(tab,'Userdata');
    end
    
    % Image processing
    nameTag = 'Coor atomcounting';
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
    if isempty(usr.fitOpt.atom.selCoor)  && isempty(usr.fitOpt.atom.minVol) && isempty(usr.fitOpt.atom.maxVol)
        % Delete coordinates from images (if shown) and figure options
        if ~isempty(data)
            ind = strcmp(data(:,2),nameTag);
            if any(ind)
                if data{ind,1}
                    showHideFigOptions(tab,value,nameTag,false)
                end
            end
        end

        % Now delete options from all figure options
        for n=1:length(str)
            data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
            if ~isempty(data)
                ind = strcmp(data(:,2),nameTag);
                if any(ind)
                    data = data(~ind,:);
                    set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
                end
            end
        end
    else
        % Update coordinates in image, if shown
        if ~isempty(data)
            ind = strcmp(data(:,2),nameTag);
            if any(ind)
                if data{ind,1}
                    showHideFigOptions(tab,value,nameTag,false)
                    showHideFigOptions(tab,value,nameTag,true)
                end
            end
        end
    end
    
    % Make text button appear black
    hObject.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
    set(hObject,'Text','Select columns on type')
end
    

%% Update GUI
% Update userdata
set(tab,'Userdata',usr)
