function [tab,usr] = newFuncCheck(jObject,event,func,h,button,name)
% newFuncCheck - Stop other running functions and start new function,
%                remove previous results
%
% syntax: [tab,usr] = newFuncCheck(jObject,event,func,h,button,name)
%       jObject - Reference to button
%       event   - java event
%       func    - name of the function
%       h       - structure holding references to StatSTEM interface
%       button  - Matlab reference to button
%       name    - functionname that started this function
%       tab     - reference to selected tab in StatSTEM
%       usr     - reference to userdate in selected tab
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%Initial values
tab = [];
usr = [];

% First turn off zoom, pan and datacursor
turnOffFigureSelection(h);

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
% Check if java button is called
if isempty(button)
    noBut=1;
    button.func = '';
else
    noBut=0;
end
if (userdata.callbackrunning) && ~strcmp(button.func,'abortFit')
    override = 0;
    if isfield(userdata,'startQue') && ~isempty(userdata.startQue)
        if toc(userdata.startQue)>2.5
            override = 1;
        else
            override = -1;
        end
    end
    % If other function should be stopped
    if override<=0
        robot = java.awt.Robot;
        robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
        robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
        % Make sure figure is still shown
        figure(h.fig)
    end
    % If so store function name and variables and cancel other function
    userdata.function.name = name;
    if noBut % No java callback is callback, but normal MATLAB button
        userdata.function.input = {jObject,event,h};
    else
        userdata.function.input = {jObject,event,func,h,button};
    end
    if override==0
        userdata.startQue = tic;
    elseif override==1
        userdata.startQue = [];
    end
    set(h.right.tabgroup,'Userdata',userdata)
    if override~=1
        return %Otherwise continue
    end
end

% Check if button is enabled
if noBut
    if ~strcmp(get(jObject,'Enable'),'on')
        return
    end
else
    if ~get(jObject,'Enabled')
        return
    end
end

% Turn off all editing in the figure
plotedit(h.fig,'off')

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
else
    % Load file
    usr = get(tab,'Userdata');
    file = usr.file;
end

% If button is an editfield, check if value is an updated number
if isa(button,'editfield')
    strE = get(button.button,'Text');
    num = str2double(strE);
    if isnan(num)
        tab = [];
        usr = [];
    end
    e2 = button.equalTo;
    valOld = [];
    if ~isempty(e2)
        % Only use first input
        fN = e2{1};
        loc = strfind(fN,'.');
        if ~isempty(loc)
            outName = fN(1:(loc(1)-1));
            outRest = fN((loc(1)+1):end);
            if isfield(file,outName) && isprop(file.(outName),outRest)
                % Check if value if different
                valOld = file.(outName).(outRest);
                if valOld==num
                    tab=[];
                    usr=[];
                end
            end
        end
    end
    if isempty(tab)
        set(button.button,'Text',num2str(valOld))
        return
    end
end

% Return if no java button is called
if noBut
    return
end

%% Ask to remove previous results (determined by active left panel)
% Check what the necessary input is, this cannot be deleted
fNamesIn = fieldnames(file);
indOK2Remove = true(length(fNamesIn),1);
if size(button.input,1)~=1
    button.input = button.input';
end
inputButton = [button.input,button.optInput];
for n=1:length(inputButton)
    if isempty(inputButton{n})
        continue
    end
    inInt = inputButton{n};
    loc = strfind(inInt,'.');
    if isempty(loc)
        inName = inInt;
    else
        inName = inInt(1:(loc(1)-1));
    end
    ind = strcmp(fNamesIn,inName);
    if any(ind)
        indOK2Remove(ind,1) = false;
    end
end

% Check what the output variable are, which might need to be deleted
ind2Remove = false(length(fNamesIn),1);
for n=1:length(button.output)
    outInt = button.output{n};
    loc = strfind(outInt,'.');
    if isempty(loc)
        outName = outInt;
        outRest = '';
    else
        outName = outInt(1:(loc(1)-1));
        outRest = outInt((loc(1)+1):end);
    end
    % Indicate which previous results should be deleted
    if isempty(outRest)
        if ~isempty(outName) && length(fNamesIn)>1
            switch outName
                case {'input','output'}
                    indOK = ~strcmp(fNamesIn,'input');
                case {'atomcounting','libcounting','strainmapping'}
                    indOK = strcmp(fNamesIn,outName) | strcmp(fNamesIn,'model3D');
                otherwise
                    indOK = strcmp(fNamesIn,outName);
            end
            ind2Remove(indOK) = true;
        end
    else
        % Don't remove anything, file will be updated
    end
end
ind2Remove = ind2Remove & indOK2Remove;
fileOld = file;
file = rmfield(file,fNamesIn(ind2Remove));

% Check if file is update
fNames = fieldnames(file);
upd = 0;
if length(fNames)~=length(fNamesIn)
    upd = 1;
    % Check if output was present
    if any(strcmp(fNames,'output')) && ~any(strcmp(fNames,'output'))
        if length(fNames)>2
            str = 'The fitted model and all analysis will be deleted, continue?';
        else
            str = 'The fitted model will be deleted, continue?';
        end
    else
        str = 'The previous analysis will be deleted, continue?';
    end
end
%% Update StatSTEM, if necessary
if upd==1
    quest = questdlg(str,'Warning','Yes','No','No');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    if strcmp(quest,'No')
        tab = [];
        usr = [];
        return
    end
    
    if isa(button,'popupmenu')
        % Get index and restore after update
        indP = get(jObject,'SelectedIndex');
    end

    % Update StatSTEM
    updateStatSTEM(h,file);
    
    if isa(button,'popupmenu')
        % Get index and restore after update
        set(jObject,'SelectedIndex',indP);
    end
end

usr = get(tab,'Userdata');
