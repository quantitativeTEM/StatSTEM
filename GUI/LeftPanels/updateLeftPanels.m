function updateLeftPanels(h, file, upEdit)
% updateLeftPanels - Update fields and buttons in the left panels
%
%   syntax: updateLeftPanels(h, file, upEdit)
%       h      - reference to all GUI objects
%       file   - structure containing the file information
%       upEdit - boolean indicating whether text editfields should be updated
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin < 3, upEdit = true; end
if nargin < 2, file = struct;  end

hfUS = get(h.fig,'Userdata');
fitting = ~isempty(hfUS);

if isempty(file), file = struct; end

updateButtonsLeft(h, 'Preparation', file, fitting, upEdit)
updateButtonsLeft(h, 'Fit Model',   file, fitting, upEdit)
updateButtonsLeft(h, 'Analysis',    file, fitting, upEdit)


% -------------------------------------------------------------------------
function updateButtonsLeft(h, option, file, fitting, upEdit)

switch option
    case 'Preparation', optName = 'prep';
    case 'Fit Model',   optName = 'fit';
    case 'Analysis',    optName = 'ana';
end

N = sum(strncmp(fieldnames(h.left.(optName)), 'panel', 5));
for n = 1:N
    M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)])), 'row', 3));
    for m = 1:M
        K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)])), 'option', 6));
        for k = 1:K
            ref = h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]);
            setButtonProp(ref, file, fitting, upEdit);
        end
    end
    if isfield(h.left.(optName).(['panel',num2str(n)]), 'advanced')
        M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced), 'panel', 5));
        for m = 1:M
            K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)])), 'row', 3));
            for k = 1:K
                L = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)])), 'option', 6));
                for l = 1:L
                    ref = h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]);
                    setButtonProp(ref, file, fitting, upEdit);
                end
            end
        end
    end
end


% -------------------------------------------------------------------------
function setButtonProp(ref, file, fitting, upEdit)
% Normalise string properties to cell arrays
if ischar(ref.input),    ref.input    = {ref.input};    end
if ischar(ref.optInput), ref.optInput = {ref.optInput}; end
if ischar(ref.output),   ref.output   = {ref.output};   end
if ischar(ref.equalTo),  ref.equalTo  = {ref.equalTo};  end

if isempty(ref), return; end

fNames = fieldnames(file);
state  = true;

% ----- Enable/disable logic ----------------------------------------------
if strcmp(ref.func, 'abortFit')
    state = false;
end
if fitting
    state = strcmp(ref.func, 'abortFit');
elseif isempty(file) && ~isa(ref,'textfield')
    state = false;
elseif isa(ref,'editfield') && ref.enable == 0
    state = false;
elseif ~isempty(file) && ~isa(ref,'textfield')
    % Check required inputs
    for i = 1:length(ref.input)
        if ~state, break; end
        [in1, in2] = splitDot(ref.input{i});
        if isempty(in1)
            % no requirement
        elseif strcmp(in1(1), '*')
            % wildcard — always pass
        elseif ~any(strcmp(fNames, in1))
            state = false;
        elseif ~isempty(in2)
            if ~any(strcmp(fieldnames(file.(in1)),in2))
                state = false;
            end
        end
    end
    % Check actWhen conditions
    if ~isempty(ref.actWhen) && ~isempty(ref.actWhen{1})
        for n = 1:size(ref.actWhen, 1)
            if ~state, break; end
            [in1, in2] = splitDot(ref.actWhen{n,2});
            if isempty(fNames)
                state = false;
            elseif ~any(strcmp(fNames, in1)) && ~isempty(in1)
                state = false;
            elseif any(strcmp(fNames, in1)) && ~isempty(in2)
                if ~any(strcmp(fieldnames(file.(in1)),in2)) || file.(in1).(in2)~=ref.actWhen{n,1}
                    state = false;
                end
            end
        end
    end
end

% Apply enable state using native MATLAB set()
if state
    set(ref.button, 'Enable', 'on');
else
    set(ref.button, 'Enable', 'off');
end

% ----- Selection state (checkbox / radiobutton) --------------------------
if any(strcmp(fieldnames(ref), 'selWhen')) && ~isempty(ref.selWhen) && ~isempty(ref.selWhen{1})
    selState = true;
    [in1, in2] = splitDot(ref.selWhen{1,2});
    if isempty(fNames)
        selState = false;
    elseif ~any(strcmp(fNames, in1)) && ~isempty(in1)
        selState = false;
    elseif any(strcmp(fNames, in1)) && ~isempty(in2)
        if ~any(strcmp(fieldnames(file.(in1)),in2)) || file.(in1).(in2)~=ref.selWhen{1,1}
            selState = false;
        end
    end
    set(ref.button, 'Value', double(selState));
end

% ----- Toggle button: derive its state from equalTo field ----------------
if isa(ref, 'togglebutton') && ~isempty(ref.equalTo) && ~isempty(ref.equalTo{1})
    togState = true;
    [in1, in2] = splitDot(ref.equalTo{1});
    if ~isempty(in1)
        if ~any(strcmp(fNames, in1))
            togState = true;
        elseif ~isempty(in2)
            if ~any(strcmp(fieldnames(file.(in1)),in2))
                togState = true;
            else
                togState = false;
            end
        end
    end
    ref.state = togState;
    set(ref.button, 'Value', double(~togState));
end

% ----- Update displayed values -------------------------------------------
if ~any(strcmp(fieldnames(ref), 'equalTo')), return; end

inName  = ref.equalTo{1};
oldName = '';
if any(strcmp(fieldnames(ref), 'keepName')) && ref.keepName
    oldName = ref.name;
end

if isempty(inName), return; end

[in1, in2] = splitDot(inName);
val = '';
if ~isempty(in2)
    try
        val = file.(in1).(in2);
    catch
        val = ref.name;
    end
end

if isa(ref, 'editfield') && upEdit
    if ischar(val)
        newName = val;
    else
        try
            newName = num2str(val);
        catch
            newName = '';
        end
    end
    set(ref.button, 'String', [newName, oldName]);

elseif isa(ref, 'popupmenu')
    % Build option list
    if isempty(val)
        newName = {};
    elseif ischar(val)
        newName = {val};
    elseif iscell(val)
        newName = val;
    else
        try
            newName = {num2str(val)};
        catch
            newName = {};
        end
    end
    if ischar(oldName)
        oldName = {oldName};
    end

    if ref.keepName
        opt = [newName; oldName];
    else
        opt = newName;
    end
    if isempty(opt), opt = {''}; end

    % Only update if options have actually changed (avoids flicker)
    currentOpts = get(ref.button, 'String');
    if ~isequal(currentOpts, opt)
        set(ref.button, 'String', opt, 'Value', 1);
    end

    % Select the currently active option
    try
        [in1s, in2s] = splitDot(ref.selOptInput);
        if isempty(in2s)
            optSel = file.(in1s);
        else
            optSel = file.(in1s).(in2s);
        end
        ind = find(strcmp(opt, optSel), 1);
        if ~isempty(ind)
            set(ref.button, 'Value', ind);
        end
    catch
        % field not present — leave selection unchanged
    end
end


% -------------------------------------------------------------------------
function [in1, in2] = splitDot(str)
% Split 'struct.field' into in1='struct', in2='field'.
% If no dot is present, in1=str, in2=''.
loc = strfind(str, '.');
if isempty(loc)
    in1 = str;
    in2 = '';
else
    in1 = str(1:loc(1)-1);
    in2 = str(loc(1)+1:end);
end
