function [h] = callbackMaker(h, option)
% callbackMaker - Attach callbacks to native MATLAB buttons in left panels
%
%   Replaces the previous Java/javaCallback-based implementation.
%
%   syntax: h = callbackMaker(h, option)
%       h       - structure holding references to StatSTEM interface
%       option  - 'Preparation', 'Fit Model', or 'Analysis'
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K. H. W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

switch option
    case 'Preparation', optName = 'prep';
    case 'Fit Model',   optName = 'fit';
    case 'Analysis',    optName = 'ana';
end

N = sum(strncmp(fieldnames(h.left.(optName)), 'panel', 5));
for n = 1:N
    % "Show options" callback is wired in panelMaker with full relayout logic.
    % Do not override it here.

    % Wire buttons in each row
    M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)])), 'row', 3));
    for m = 1:M
        K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)])), 'option', 6));
        for k = 1:K
            ref = h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]);
            makeCallback(ref, h);
        end
    end

    % Wire buttons in advanced sub-panels
    if any(strcmp(fieldnames(h.left.(optName).(['panel',num2str(n)])), 'advanced'))
        M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced), 'panel', 5));
        for m = 1:M
            K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)])), 'row', 3));
            for k = 1:K
                L = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)])), 'option', 6));
                for l = 1:L
                    ref = h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]);
                    makeCallback(ref, h);
                end
            end
        end
    end
end


% -------------------------------------------------------------------------
function makeCallback(ref, h)
% Attach the appropriate Callback (and KeyReleaseFcn for editfields) to the
% native uicontrol stored in ref.button.

if isempty(ref)
    return
end

func = ref.func;
btn  = ref.button;

switch class(ref)
    case 'textfield'
        % Static label — no callback needed
        return

    case 'editfield'
        % Fire on Enter key and on focus-lost
        set(btn, ...
            'KeyReleaseFcn', {@focusNext}, ...
            'Callback',      {@updateTextVal, func, h, ref});

    case 'togglebutton'
        set(btn, 'Callback', {@startNewFuncToggle, func, h, ref});

    case 'pushbutton'
        set(btn, 'Callback', {@startNewFunc, func, h, ref});

    case 'radiobutton'
        set(btn, 'Callback', {@updateRadioVal, func, h, ref});

    case 'checkbox'
        set(btn, 'Callback', {@updateCheckVal, func, h, ref});

    case 'popupmenu'
        set(btn, 'Callback', {@popupPressed, func, h, ref});
end
