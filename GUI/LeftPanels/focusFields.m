function focusFields(h, state)
% focusFields - Enable or disable interactive fields in the left panels
%
%   When a long-running callback is active (state=false) all editable
%   controls are made inactive so users cannot trigger concurrent actions.
%   When the callback finishes (state=true) they are restored.
%
%   syntax: focusFields(h, state)
%       h     - reference to all GUI objects
%       state - true to enable, false to disable
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

hToPass.fig      = h.fig;
hToPass.zoom.in  = h.zoom.in;
hToPass.zoom.out = h.zoom.out;

% Enable/disable left panel buttons
setFocusPanel(h.left.prep, state);
setFocusPanel(h.left.fit,  state);
setFocusPanel(h.left.ana,  state);

% Enable/disable right-panel controls
tab = get(h.right.tabgroup, 'SelectedTab');
usr = get(tab, 'Userdata');
value = get(usr.figOptions.selImg.listbox, 'Value');

if state
    set(usr.figOptions.selImg.listbox, ...
        'Callback', @(src,evt) imageChanged(src,evt,tab,h), ...
        'Enable',   'on')
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]), ...
        'CellEditCallback', {@optionSelected, tab}, ...
        'Enable',           'on')
    set(usr.figOptions.optFig.scaleVal, 'Enable','on',       'ButtonDownFcn',[])
    set(usr.figOptions.optFig.msval,    'Enable','on',       'ButtonDownFcn',[])
else
    set(usr.figOptions.selImg.listbox, ...
        'Callback', [], ...
        'Enable',   'inactive')
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]), ...
        'CellEditCallback', [], ...
        'Enable',           'inactive')
    set(usr.figOptions.optFig.scaleVal, 'Enable','inactive', ...
        'ButtonDownFcn',{@pressEsc, h.right.tabgroup})
    set(usr.figOptions.optFig.msval,    'Enable','inactive', ...
        'ButtonDownFcn',{@pressEsc, h.right.tabgroup})
end


% -------------------------------------------------------------------------
function setFocusPanel(hBase, state)
% Set Enable state of all editable uicontrols in a panel group.

N = sum(strncmp(fieldnames(hBase), 'panel', 5));
for n = 1:N
    M = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)])), 'row', 3));
    for m = 1:M
        K = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).(['row',num2str(m)])), 'option', 6));
        for k = 1:K
            opt = hBase.(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]);
            if isa(opt,'editfield') || isa(opt,'textfield')
                if state
                    set(opt.button, 'Enable', 'on');
                else
                    set(opt.button, 'Enable', 'inactive');
                end
            end
        end
    end

    % Advanced sub-panels
    if isfield(hBase.(['panel',num2str(n)]), 'advanced')
        M = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).advanced), 'panel', 5));
        for m = 1:M
            K = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)])), 'row', 3));
            for k = 1:K
                L = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)])), 'option', 6));
                for l = 1:L
                    opt = hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]);
                    if isa(opt,'editfield') || isa(opt,'textfield')
                        if state
                            set(opt.button, 'Enable', 'on');
                        else
                            set(opt.button, 'Enable', 'inactive');
                        end
                    end
                end
            end
        end
    end
end


% -------------------------------------------------------------------------
function pressEsc(hObject, ~, tabgroup)
% pressEsc - Cancel operation on ButtonDownFcn of inactive controls

userdata = get(tabgroup, 'Userdata');
if userdata.callbackrunning
    % Send Escape to the figure to interrupt running callbacks
    % (java.awt.Robot is no longer used; we use uicontrol focus instead)
    uicontrol(hObject);
end
