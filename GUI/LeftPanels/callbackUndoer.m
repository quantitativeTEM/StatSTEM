function [h] = callbackUndoer(h,option)
% panelMaker - Create panel with java buttons
%
%   syntax: h = callbackMaker(h,option)
%       h       - structure holding references to StatSTEM interface
%       option  - indicate whether the panels are made for the tab
%       panels  - structure containing panel options
%       'Preparation', 'Fit Model' or 'Analysis'
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Create callbacks for each panel
switch option
    case 'Preparation'
        optName = 'prep';
    case 'Fit Model'
        optName = 'fit';
    case 'Analysis'
        optName = 'ana';
end

N = sum(strncmp(fieldnames(h.left.(optName)),'panel',5));
for n=1:N
    % Find in each panel the buttons and the corresponding functions
    % Number of rows
    M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)])),'row',3));
    for m=1:M
        % Number of options
        K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).(['row',num2str(m)])),'option',6));
        for k=1:K
            ref = ['h.left.',optName,'.panel',num2str(n),'.row',num2str(m),'.option',num2str(k)];
            undoJavaCallback(h,ref)
        end
    end
    
    % Advanced panel
    if any(strcmp(fieldnames(h.left.(optName).(['panel',num2str(n)])),'advanced'))
        javaCallback(h.left.(optName).(['panel',num2str(n)]).advanced.mainBut,...
            'MouseEnteredCallback',[],'MouseExitedCallback',[])
        M = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced),'panel',5));
        for m=1:M
            K = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)])),'row',3));
            for k=1:K
                % Number of options
                L = sum(strncmp(fieldnames(h.left.(optName).(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)])),'option',6));
                for l=1:L
                    ref = ['h.left.',optName,'.panel',num2str(n),'.advanced.panel',num2str(m),'.row',num2str(k),'.option',num2str(l)];
                    undoJavaCallback(h,ref)
                end
            end
        end
    end
end

function undoJavaCallback(h,ref)
% makeJavaCallback - Make callback function for each type of button
%
%   syntax: makeJavaCallback(h,ref)
%       h       - reference to all GUI objects
%       ref     - string containing location of button in h
%       option  - indicate whether the panels are made for the tab
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
jref = [ref,'.button'];
func = eval([ref,'.func']);
switch class(eval(ref))
    case 'textfield'
    case 'editfield'
        eval(['javaCallback(',jref,',''KeyReleasedCallback'',[],''FocusLostCallback'',[])'])
    case 'togglebutton'
        eval(['javaCallback(',jref,',''MouseEnteredCallback'',[],''MouseExitedCallback'',[])'])
    case 'pushbutton'
        eval(['javaCallback(',jref,',''MouseEnteredCallback'',[],''MouseExitedCallback'',[])'])
    case 'radiobutton'
        eval(['javaCallback(',jref,',''MouseEnteredCallback'',[],''MouseExitedCallback'',[])'])
    case 'checkbox'
        eval(['javaCallback(',jref,',''MouseEnteredCallback'',[],''MouseExitedCallback'',[])'])
    case 'popupmenu'
        eval(['javaCallback(',jref,',''PopupMenuWillBecomeInvisibleCallback'',[])']);
end

