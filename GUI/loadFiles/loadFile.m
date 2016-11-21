function loadFile(hObject,event,h)
% loadFile - Load a file into the StatSTEM interface
%
%   syntax: loadFile(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Load reference to adding tab
tabs = get(h.right.tabgroup,'Children');
tab = tabs(length(tabs));
usr = get(tab,'Userdata');

% Let the user select an input file
[FileName,userdata.PathName] = uigetfile({'*.mat;*.txt;*.TXT','Supported Files (*.mat,*.txt)';'*.mat','MATLAB Files (*.mat)';'*.txt;*.TXT','TXT Files (*.txt)';'*.*',  'All Files (*.*)'}, ...
   'Select a file',userdata.PathName);

if FileName==0
    return
else
    % Update userdata
    set(h.right.tabgroup,'Userdata',userdata)
end
[~, usr.FileName, ext] = fileparts(FileName);
usr.PathName = userdata.PathName;
switch ext
    case '.mat'
        [usr.file,message,dx] = loadMatFile(userdata.PathName,usr.FileName);
    case '.txt'
        [usr.file,message,dx] = loadTXTFile(userdata.PathName,usr.FileName);
end
if ~isempty(message)
    newMessage(message,h)
    return
end

% Ask for pixel size
if strcmp(dx,'ask')
    dx = inputdlg(['Please give the pixel size (',char(197),')'],'Pixel Size',[1 50]);
    drawnow; pause(0.05); % MATLAB hang 2013 version
    if ~isempty(dx)
        dx = str2double(dx{1});
        if ~isempty(dx) && ~isnan(dx)
            usr.file.input.dx = dx;
            set(tab,'Userdata',usr);
        end
    end
end
        


%% The empty tab will be used to load the file to
% Create an axes and panel to show images
usr.images.img = uipanel('Parent',usr.images.main,'units','normalized','Position',[0 0 1 1],'ShadowColor',[0.8 0.8 0.8],'ForegroundColor',[0.8 0.8 0.8],'HighlightColor',[0.8 0.8 0.8],'BackgroundColor',[0.8 0.8 0.8]);
usr.images.ax2 = axes('Parent',usr.images.img,'units','normalized');axis off
usr.images.ax = axes('Parent',usr.images.img,'units','normalized');

% Create listboxs for selecting which figure is shown
usr.figOptions.selImg.listbox = uicontrol('Parent',usr.figOptions.selImg.main,'Style','listbox','units','normalized','Position',[0 0 1 1],'String',{},'CallBack',{@imageChanged,tab,h});
% Load standard peak finder options
usr.fitOpt.peakfinding = standardPeakOptions(usr.file.input.obs);
% Load standard fit options
usr.fitOpt.model = standardFitOptions;
% Load standard atom counting options
usr.fitOpt.atom = standardAtomOptions;
% Load standard strainmapping options
usr.fitOpt.strain = standardStrainOptions;
% Update userdata of tab
set(tab,'Userdata',usr);

% Create all possible images
createObservation(tab,h);
usr = get(tab,'Userdata');
if any(strcmp(fieldnames(usr.file.input),'rho'))
    types = max(usr.file.input.coordinates(:,3));
    usr.fitOpt.model.rho_start = zeros(types,1);
    for i = 1:types
        try
            rho_temp = usr.file.input.rho(usr.file.input.coordinates(:,3) == i);
        catch
            if any(strcmp(fieldnames(usr.file),'output'))
                rho_temp = usr.file.output.rho(usr.file.input.coordinates(:,3) == i);
            else
                rho_temp=0.5;
            end
        end
        usr.fitOpt.model.rho_start(i)= median(rho_temp);
    end
    % Update userdata of tab
    set(tab,'Userdata',usr);
end

% Create model if fitted model is available
if any(strcmp(fieldnames(usr.file),'output'))
    createModel(tab,h,0)
    createHist(tab,h,0)
    usr = get(tab,'Userdata');
    
    % Update fit options
    usr.fitOpt.model.fitzeta = 0;
    usr.fitOpt.model.zeta = usr.file.output.zeta;
    set(tab,'Userdata',usr)
end

% Create atom counting figures if it is available
if any(strcmp(fieldnames(usr.file),'atomcounting'))
    % Create new figure for ICL
    createICL(tab,h,0)
    % Plot and add reference to selected minimum in figure
    addMinICL(tab,1,h)
    % Create new figure for SI vs thickness
    createThickSI(tab,h,0)
    % The histogram, add GMM
    createGMM(tab,1)
    % The atom counts (show atom counting results in observation)
    createAtomCounts(tab,h,0)
    
    % Update userdata
    usr = get(tab,'Userdata');
    
    % Update fit atoms
    usr.fitOpt.atom.n_c = length(usr.file.atomcounting.ICL);
    % Update selected region in image, histogram and atom types
    if any(strcmp(fieldnames(usr.file.atomcounting),'selRegion'))
        usr.fitOpt.atom.selCoor = usr.file.atomcounting.selRegion;
    end
    if any(strcmp(fieldnames(usr.file.atomcounting),'minVol'))
        usr.fitOpt.atom.minVol = usr.file.atomcounting.minVol;
    end
    if any(strcmp(fieldnames(usr.file.atomcounting),'maxVol'))
        usr.fitOpt.atom.maxVol = usr.file.atomcounting.maxVol;
    end
    if any(strcmp(fieldnames(usr.file.atomcounting),'selType'))
        usr.fitOpt.atom.selType = usr.file.atomcounting.selType;
    end
    
    if ~isempty(usr.fitOpt.atom.selCoor) || (~isempty(usr.fitOpt.atom.minVol) && ~isempty(usr.fitOpt.atom.maxVol))
        str = get(usr.figOptions.selImg.listbox,'String');
        nameTag = 'Coor atomcounting';
        % Add option region atomcounting
        value = find(strcmp(str,'Model'));
        data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
        data = [data;{false nameTag}];
        % Update data
        set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data);

        value2 = find(strcmp(str,'Observation'));
        data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value2)]),'Data');
        data = [data;{false nameTag}];
        % Update data
        set(usr.figOptions.selOpt.(['optionsImage',num2str(value2)]),'Data',data);
    end
    
    % Update userdata
    set(tab,'Userdata',usr)
end

if any(strcmp(fieldnames(usr.file),'strainmapping'))
    addStrainOpt(tab)
    usr = get(tab,'Userdata');
end

% Update the name of the tab and the tooltipstring
if length(usr.FileName)>18
    tabName = [usr.FileName(1:15),'...'];
else
    tabName = usr.FileName;
end
set(tab,'Title',tabName,'ButtonDown',[]);
v = version('-release');
v = str2double(v(1:4));
c = uicontextmenu;
m1 = uimenu(c,'Label','Close image','Callback',{@closeImage,tab,h});
set(tab,'UIContextMenu',c);
if v>2014
    set(tab,'TooltipString',usr.FileName);
end

% Show new file
set(h.right.tabgroup,'SelectedTab',tab)

% Give file parameter, to know that it was opened in the GUI
% usr.file.GUI = 1;

% Update the userdata of the tab
set(tab,'Userdata',usr);

% Enable the store button
set(h.left.loadStore.save,'Enable','on')

% Add a new empty tab
createEmptyTab(h.right.tabgroup)

% Enable figure options button
set(usr.figOptions.optFig.scalebar,'Enable','on')
set(usr.figOptions.optFig.scaleVal,'Enable','on')
set(usr.figOptions.optFig.scaleTxt,'Enable','inactive')
set(usr.figOptions.optFig.mstext,'Enable','inactive')
set(usr.figOptions.optFig.msval,'Enable','on')
set(usr.figOptions.optFig.colors,'Enable','on')

% Enable color button
set(usr.figOptions.optFig.colors,'Callback',{@editColors,h},'Enable','on')

% Enable export button
set(usr.figOptions.export.but,'Callback',{@exportFigure,h},'Enable','on')

% Update left panels
updateLeftPanels(h,usr.file,usr.fitOpt)

% Update message
message = sprintf(['The file ', FileName, ' was successfully loaded']);
newMessage(message,h)

% Store new pathname
fileID = fopen(h.startPath,'wt');
str = strrep(userdata.PathName,'\','\\');
fprintf(fileID, str);
fclose(fileID);
