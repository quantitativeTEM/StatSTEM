function [h] = callbackUndoer(h, option)
% callbackUndoer - Remove callbacks from native MATLAB buttons in left panels
%
%   Replaces the previous Java/javaCallback-based implementation.
%
%   syntax: h = callbackUndoer(h, option)
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
    % "Show options" callback is managed by panelMaker - do not clear it.

    % Clear button callbacks in each row
    M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)])), 'row', 3));
    for m = 1:M
        K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)])), 'option', 6));
        for k = 1:K
            ref = h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]);
            clearCallback(ref);
        end
    end

    % Clear button callbacks in advanced sub-panels
    if any(strcmp(fieldnames(h.left.(optName).(['panel',num2str(n)])), 'advanced'))
        M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced), 'panel', 5));
        for m = 1:M
            K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)])), 'row', 3));
            for k = 1:K
                L = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)])), 'option', 6));
                for l = 1:L
                    ref = h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]);
                    clearCallback(ref);
                end
            end
        end
    end
end


% -------------------------------------------------------------------------
function clearCallback(ref)
% Remove all callbacks from the native uicontrol in ref.button.

if isempty(ref)
    return
end

btn = ref.button;
if ~ishandle(btn)
    return
end

switch class(ref)
    case 'textfield'
        return   % no callbacks were ever set

    case 'editfield'
        set(btn, 'Callback', [], 'KeyReleaseFcn', []);

    otherwise
        % pushbutton, togglebutton, radiobutton, checkbox, popupmenu
        set(btn, 'Callback', []);
end
