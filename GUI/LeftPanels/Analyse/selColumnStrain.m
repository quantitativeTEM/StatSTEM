function selColumnStrain(hObject,event,h)
% selColumnStrain - Select specific columns for the strainmapping routine
%
% This function enables the user to select specific column in the StatSTEM
% interface which will only be used for the atomcounting routine
%
%   syntax: selColumnStrain(hObject,event,h)
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
% First turn off figure selection options
[h_pan,h_zoom,h_cursor] = turnOffFigureSelection(h);

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
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

% Check if colorbar is shown
if strcmp(get(h.colorbar(1),'State'),'off')
    sColBar = 0;
else
    sColBar = 1;
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
    if any(strcmp(fieldnames(usr.file),'strainmapping'))
        quest = questdlg('Select a region for strain mapping will remove previous results, continue?','Warning','Yes','No','No');
        drawnow; pause(0.05); % MATLAB hang 2013 version
        switch quest
            case 'Yes'
                deleteStrainMapping(tab,h)
                usr = get(tab,'Userdata');
            case 'No'
                return
        end
    end
    
    %% Image preparation
    str = get(usr.figOptions.selImg.listbox,'String');
    val = get(usr.figOptions.selImg.listbox,'Value');
    value = find(strcmp(str,'Observation'));
    value1 = find(strcmp(str,'Model'));
    
    % Show observation if observation or model is not shown
    if val~=value && val~=value1
        showImage(tab,'Observation',h)
        usr = get(tab,'Userdata');
    elseif val==value1
        value = value1;
    end

    % Make sure only fitted coordinates are shown
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
    nameTag = 'Fitted coordinates';
    ind = strcmp(data(:,2),nameTag);
    N = find(ind);
    for n=1:length(ind)
        if n==N
            state = true;
        else
            state = false;
        end
        if data{n,1}~=state
            showHideFigOptions(tab,value,data{n,2},state,h,sColBar)
            data{n,1} = state;
        end
    end
    %Update data
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data)

    %% Make all text field unfocusable
    focusFields(h,false)

    %% Select region
    % Let user select a region
    userdata = get(h.right.tabgroup,'Userdata');
    userdata.callbackrunning = true; % For other routines
    set(h.right.tabgroup,'Userdata',userdata);
    title(usr.images.ax,'Select region, press ESC to exit')

    % Get coordinates
    usr.fitOpt.strain.selCoor = gregion_AxInFig(usr.images.ax,h.fig,h_pan,h_zoom,h_cursor);

    title(usr.images.ax,'')
    userdata = get(h.right.tabgroup,'Userdata');
    userdata.callbackrunning = false; % For other routines
    set(h.right.tabgroup,'Userdata',userdata);

    % Update userdata
    set(tab,'Userdata',usr)

    %% Make all text field focusable
    focusFields(h,true)

    %% Update figure options
    if ~isempty(usr.fitOpt.strain.selCoor)
        nameTag2 = 'Coor strainmapping';
        % Add option region strainmapping
        data(ind,1) = {false};
        data = [data;{true nameTag2}];
        % Update data
        set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data);
        % Show selected coordinates and hide fitted coordinates
        showHideFigOptions(tab,value,nameTag2,true,h,sColBar)
        showHideFigOptions(tab,value,nameTag,false,h,sColBar)

        value2 = find(strcmp(str,'Model'));
        if value==value2
            value2 = find(strcmp(str,'Observation'));
        end
        data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value2)]),'Data');
        data = [data;{false nameTag2}];
        % Update data
        set(usr.figOptions.selOpt.(['optionsImage',num2str(value2)]),'Data',data);
            
        % Make text button appear red
        hObject.setForeground(java.awt.Color(1,0,0))
        set(hObject,'Text','Delete selected region')
    end
else
    %% Preparation
    % Delete previous analysis is necessary
    usr = get(tab,'Userdata');
    if any(strcmp(fieldnames(usr.file),'strainmapping'))
        quest = questdlg('Deleting the region will remove previous strain mapping results, continue?','Warning','Yes','No','No');
        drawnow; pause(0.05); % MATLAB hang 2013 version
        switch quest
            case 'Yes'
                deleteStrainMapping(tab,h)
                usr = get(tab,'Userdata');
            case 'No'
                return
        end
    end
    usr.fitOpt.strain.selCoor = [];
    set(tab,'Userdata',usr)
    
    % Update the images
    str = get(usr.figOptions.selImg.listbox,'String');
    value = get(usr.figOptions.selImg.listbox,'Value');
    nameTag = 'Coor strainmapping';
    
    % Delete options from all figure options
    for n=1:length(str)
        data = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
        if ~isempty(data)
            ind = strcmp(data(:,2),nameTag);
            if any(ind) && value==n
                showHideFigOptions(tab,value,nameTag,false,h,sColBar)
            end
            if any(ind)
                data = data(~ind,:);
                set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
            end
        end
    end
    
    % Make text button appear black
    hObject.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
    set(hObject,'Text','Select columns in image')
end
    

%% Update GUI
% Update userdata
set(tab,'Userdata',usr)

% Check if other function is started
if ~isempty(userdata.function)
    f = userdata.function;
    userdata.function = [];
    set(h.right.tabgroup,'Userdata',userdata);
    eval([f.name,'(f.input{:})'])
    if strcmp(f.name,'deleteFigure')
        return
    end
end
