function [tab, usr] = newFuncCheck(hObject, event, func, h, button, name)
% newFuncCheck - Stop other running functions and start a new one,
%               removing previous results as needed.
%
%   syntax: [tab,usr] = newFuncCheck(hObject,event,func,h,button,name)
%       hObject - Reference to the uicontrol that triggered the callback
%       event   - callback event data
%       func    - name of the function to run
%       h       - structure holding references to StatSTEM interface
%       button  - StatSTEM button object (or [] for non-button callbacks)
%       name    - name of the calling function (mfilename)
%       tab     - reference to selected tab in StatSTEM
%       usr     - userdata of selected tab
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

tab = [];
usr = [];

% Normalise button string properties to cell arrays
if ~isempty(button) && isobject(button)
    if ischar(button.input),    button.input    = {button.input};    end
    if ischar(button.optInput), button.optInput = {button.optInput}; end
    if ischar(button.output),   button.output   = {button.output};   end
end

% Turn off zoom, pan and datacursor
turnOffFigureSelection(h);

% Determine if this is a non-button (regular MATLAB) callback
if isempty(button)
    noBut = 1;
    button.func = '';
else
    noBut = 0;
end

% Check whether another callback is already running
userdata = get(h.right.tabgroup, 'Userdata');
if userdata.callbackrunning && ~strcmp(button.func, 'abortFit')
    override = 0;
    if isfield(userdata,'startQue') && ~isempty(userdata.startQue)
        elapsed = toc(userdata.startQue);
        if elapsed > 2.5
            override = 1;
        else
            override = -1;
        end
    end

    if override <= 0
        % Interrupt the running callback via figure focus
        % (replaces java.awt.Robot key-press — figure(h.fig) re-raises
        %  the window and uicontrol interrupts any waitfor loops)
        figure(h.fig);
    end

    userdata.function.name = name;
    if noBut
        userdata.function.input = {hObject, event, h};
    else
        userdata.function.input = {hObject, event, func, h, button};
    end
    if override == 0
        userdata.startQue = tic;
    elseif override == 1
        userdata.startQue = [];
    end
    set(h.right.tabgroup, 'Userdata', userdata);
    if override ~= 1
        return
    end
end

% Check if the triggering control is enabled
if noBut
    if ~strcmp(get(hObject,'Enable'), 'on')
        return
    end
else
    if ~strcmp(get(hObject,'Enable'), 'on')
        return
    end
end

% Turn off plot editing
plotedit(h.fig, 'off');

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes);
    return
else
    usr  = get(tab, 'Userdata');
    file = usr.file;
end

% For editfields: validate that the current text is a valid number
if isa(button,'editfield')
    strE = get(button.button, 'String');
    num  = str2double(strE);
    if isnan(num)
        tab = [];
        usr = [];
    end
    e2 = button.equalTo;
    valOld = [];
    if ~isempty(e2)
        fN  = e2{1};
        loc = strfind(fN,'.');
        if ~isempty(loc)
            outName = fN(1:(loc(1)-1));
            outRest = fN((loc(1)+1):end);
            if isfield(file,outName) && isprop(file.(outName),outRest)
                valOld = file.(outName).(outRest);
                if valOld == num
                    tab = [];
                    usr = [];
                end
            end
        end
    end
    if isempty(tab)
        if ~isempty(valOld)
            set(button.button, 'String', num2str(valOld));
        end
        return
    end
end

if noBut
    return
end

%% Ask to remove previous results (determined by required outputs)
fNamesIn    = fieldnames(file);
indOK2Remove = true(length(fNamesIn),1);

if size(button.input,1) ~= 1
    button.input = button.input';
end
inputButton = [button.input, button.optInput];

for n = 1:length(inputButton)
    if isempty(inputButton{n}), continue; end
    inInt = inputButton{n};
    loc   = strfind(inInt,'.');
    if isempty(loc)
        inName = inInt;
    else
        inName = inInt(1:(loc(1)-1));
    end
    ind = strcmp(fNamesIn, inName);
    if any(ind)
        indOK2Remove(ind,1) = false;
    end
end

ind2Remove = false(length(fNamesIn),1);
for n = 1:length(button.output)
    outInt = button.output{n};
    loc    = strfind(outInt,'.');
    if isempty(loc)
        outName = outInt;
        outRest = '';
    else
        outName = outInt(1:(loc(1)-1));
        outRest = outInt((loc(1)+1):end);
    end
    if isempty(outRest) && ~isempty(outName) && length(fNamesIn) > 1
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
end

ind2Remove = ind2Remove & indOK2Remove;
file = rmfield(file, fNamesIn(ind2Remove));

% Check if file changed and prompt user if so
fNames = fieldnames(file);
if length(fNames) ~= length(fNamesIn)
    if any(strcmp(fNames,'output')) && ~any(strcmp(fNames,'output'))
        if length(fNames) > 2
            str = 'The fitted model and all analysis will be deleted, continue?';
        else
            str = 'The fitted model will be deleted, continue?';
        end
    else
        str = 'The previous analysis will be deleted, continue?';
    end

    quest = questdlg(str, 'Warning', 'Yes', 'No', 'No');
    drawnow; pause(0.05);
    if strcmp(quest,'No')
        tab = [];
        usr = [];
        return
    end

    % For popupmenus: remember current selection so it can be restored
    if isa(button,'popupmenu')
        indP = get(hObject, 'Value');
    end

    updateStatSTEM(h, file);

    if isa(button,'popupmenu')
        set(hObject, 'Value', indP);
    end
end

usr = get(tab, 'Userdata');
