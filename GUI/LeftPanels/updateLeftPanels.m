function updateLeftPanels(h,file,upEdit)
% updateLeftPanels - Update fields and buttons in the left panels
%
%   syntax: updateLeftPanels(h,file,upEdit)
%       h      - reference to all GUI objects
%       file   - Structure containing the file information
%       upEdit - boolean indicating whether text editfield should be updated
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<3
    upEdit = true;
end
if nargin<2
    file = struct;
end
hfUS = get(h.fig,'Userdata');
if ~isempty(hfUS)
    fitting = 1;
else
    fitting = 0;
end
if isempty(file)
    file = struct;
end
updateButtonsLeft(h,'Preparation',file,fitting,upEdit)
updateButtonsLeft(h,'Fit Model',file,fitting,upEdit)
updateButtonsLeft(h,'Analysis',file,fitting,upEdit)

    %%
    function updateButtonsLeft(h,option,file,fitting,upEdit)
    switch option
        case 'Preparation'
            optName = 'prep';
        case 'Fit Model'
            optName = 'fit';
        case 'Analysis'
            optName = 'ana';
    end

    % Check matlab version, and switch opengl
    v = version('-release');
    v = str2double(v(1:4));

    N = sum(strncmp(fieldnames(h.left.(optName)),'panel',5));
    for n=1:N
        M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)])),'row',3));
        for m=1:M
            K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)])),'option',6));
            for k=1:K
                ref = h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]);
                setButtonProp(ref,file,fitting,upEdit)
            end
        end
        % Check for advanced panels
        if isfield(h.left.(optName).(['panel',num2str(n)]),'advanced')
            M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced),'panel',5));
            for m=1:M
                K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)])),'row',3));
                for k=1:K
                    L = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)])),'option',6));
                    for l=1:L
                        ref = h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]);
                        setButtonProp(ref,file,fitting,upEdit)
                    end
                end
            end
        end
    end
    
    %%
    function setButtonProp(ref,file,fitting,upEdit)
    fNames = fieldnames(file);
    state = true;
    %% Deal with exceptions for enabling of button
    % When func is abortFit
    if strcmp(ref.func,'abortFit')
        state = false;
    end
    if fitting
        state = false;
        % Except when func is abortFit
        if strcmp(ref.func,'abortFit')
            state = true;
        end
    elseif isempty(file) && ~isa(ref,'textfield')
        state = false;
    elseif isa(ref,'editfield') && ref.enable==0
        state = false;
    elseif ~isempty(file) && ~isa(ref,'textfield')
        % Check if necessary input is present in file
        input = ref.input;
        for i=1:length(input)
            if state==false
                break;
            end
            in1 = input{i};
            loc = strfind(in1,'.');
            if isempty(loc)
                in2 = '';
            else
                in2 = in1(loc(1)+1:end);
                in1 = in1(1:loc(1)-1);
            end
            if isempty(fNames)
                state = false;
            elseif ~isempty(in1) && strcmp(in1(1),'*')
                % Don't change anything
            elseif ~any(strcmp(fNames,in1)) && ~isempty(in1)
                state = false;
            elseif any(strcmp(fNames,in1)) && ~isempty(in2)
                if ~any(strcmp(fieldnames(file.(in1)),in2))
                    state = false;
                elseif isempty(file.(in1).(in2))
                    state = false;
                end
            end
        end
        
        % Check if button may be active
        if ~isempty(ref.actWhen) && ~isempty(ref.actWhen{1})
            for n=1:size(ref.actWhen,1)
                in1 = ref.actWhen{n,2};
                loc = strfind(in1,'.');
                if isempty(loc)
                    in2 = '';
                else
                    in2 = in1(loc(1)+1:end);
                    in1 = in1(1:loc(1)-1);
                end
                if isempty(fNames)
                    state = false;
                elseif ~any(strcmp(fNames,in1)) && ~isempty(in1)
                    state = false;
                elseif any(strcmp(fNames,in1)) && ~isempty(in2)
                    if ~any(strcmp(fieldnames(file.(in1)),in2))
                        state = false;
                    elseif file.(in1).(in2)~=ref.actWhen{n,1}
                        state = false;
                    end
                end
            end
        end
    end
    ref.button.setEnabled(state)
    
    %% Check if button should be selected
    if any(strcmp(fieldnames(ref),'selWhen')) && ~isempty(ref.selWhen) && ~isempty(ref.selWhen{1})
        state = true;
        in1 = ref.selWhen{1,2};
        loc = strfind(in1,'.');
        if isempty(loc)
            in2 = '';
        else
            in2 = in1(loc(1)+1:end);
            in1 = in1(1:loc(1)-1);
        end
        if isempty(fNames)
            state = false;
        elseif ~any(strcmp(fNames,in1)) && ~isempty(in1)
            state = false;
        elseif any(strcmp(fNames,in1)) && ~isempty(in2)
            if ~any(strcmp(fieldnames(file.(in1)),in2))
                state = false;
            elseif file.(in1).(in2)~=ref.selWhen{1,1}
                state = false;
            end
        end
        ref.button.setSelected(state)
    end
    % For togglebutton
    if isa(ref,'togglebutton')
        state = false;
        in1 = ref.equalTo{1};
        loc = strfind(in1,'.');
        if isempty(loc)
            in2 = '';
        else
            in2 = in1(loc(1)+1:end);
            in1 = in1(1:loc(1)-1);
        end
        if isempty(fNames)
            state = true;
        elseif ~any(strcmp(fNames,in1)) && ~isempty(in1)
            state = true;
        elseif any(strcmp(fNames,in1)) && ~isempty(in2)
            if ~any(strcmp(fieldnames(file.(in1)),in2))
                state = true;
            elseif isempty(file.(in1).(in2))
                state = true;
            end
        end
        ref.state = state;
    end
    
    %% Change names if necessary
    if any(strcmp(fieldnames(ref),'equalTo'))
        inName = ref.equalTo{1};
        oldName = '';
        if any(strcmp(fieldnames(ref),'keepName'))
            if ref.keepName
                oldName = ref.name;
            end
        end 
        % Check if field is present and not empty
        if isempty(inName)
            % Nothing happens
        else
            in1 = inName;
            loc = strfind(in1,'.');
            if isempty(loc)
                val = '';
            else
                in2 = in1(loc(1)+1:end);
                in1 = in1(1:loc(1)-1);
                try
                    val = file.(in1).(in2);
                catch
                    val = ref.name;
                end
            end
            if isa(ref,'editfield') && upEdit
                % String is needed
                if isa(val,'char')
                    newName = val;
                else
                    try
                        newName = num2str(val);
                    catch
                        newName = '';
                    end
                end
                set(ref.button,'Text',[newName,oldName])
            elseif isa(ref,'popupmenu')
                if isempty(val)
                    newName = {};
                elseif isa(val,'char')
                    newName = {val};
                elseif isa(val,'cell')
                    newName = val;
                else
                    try
                        newName = {num2str(val)};
                    catch
                        newName = {};
                    end
                end
                if isa(oldName,'char')
                    oldName = {oldName};
                elseif isa(oldName,'cell')
                    % Correct
                else
                    try
                        oldName = {num2str(oldName)};
                    catch
                        oldName = {};
                    end
                end
                % Check if options have been changed
                oldJMod = get(ref.button,'Model');
                if ref.keepName
                    opt = [newName;oldName];
                else
                    opt = newName;
                end
                if isempty(opt)
                    opt = {''};
                end
                same = 1;
                if length(opt)==oldJMod.getSize
                    for i=0:oldJMod.getSize-1
                        if ~strcmp(oldJMod.getElementAt(i),opt{i+1})
                            same = 0;
                        end
                    end
                else
                    same = 0;
                end
                if same==0
                    ref.button.setModel(javax.swing.DefaultComboBoxModel(opt))
                end
                % Find active option
                try
                    loc = strfind(ref.selOptInput,'.');
                    if isempty(loc)
                        optSel = file.(ref.selOptInput);
                    else
                        in2 = ref.selOptInput(loc(1)+1:end);
                        in1 = ref.selOptInput(1:loc(1)-1);
                        optSel = file.(in1).(in2);
                    end
                    ind = find(strcmp(opt,optSel));
                    if ~isempty(ind)
                        ref.button.setSelectedIndex(ind(1)-1)
                    end
                catch
                    % don't do anything
                end
            end 
        end
    end