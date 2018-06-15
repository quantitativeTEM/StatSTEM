function focusFields(h,state)
% focusFields - Change focus state in StatSTEM interface
%
% Change focusable state of all textfields in the left panels 
%
%   syntax: focusFields(h,state,f)
%       h     - reference to all GUI objects
%       state - Make focusable of unfocusable ('on'/'off')
%       f     - Specify which left panel ('prep'/'fit'/'ana'/'all')
%
%   Standard the focus state of the objects in all left panels are changed
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Only pass relevant variable, to speed up process
hToPass.fig = h.fig;
hToPass.zoom.in = h.zoom.in;
hToPass.zoom.out = h.zoom.out;

% Create callbacks for each panel
focusTabs(h.left.prep,hToPass,state)
focusTabs(h.left.fit,hToPass,state)
focusTabs(h.left.ana,hToPass,state)

% Now the tab itself
tab = get(h.right.tabgroup,'SelectedTab');
usr = get(tab,'Userdata');
% Find selected image
value = get(usr.figOptions.selImg.listbox,'Value');
% Now enable or disable the listbox and figure options
if state
    set(usr.figOptions.selImg.listbox,'Callback',{@imageChanged,tab,h},'Enable','on')
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'CellSelectionCallback',{@optionSelected,tab},'Enable','on')
    set(usr.figOptions.optFig.scaleVal,'Enable','on','ButtonDownFcn',[])
    set(usr.figOptions.optFig.msval,'Enable','on','ButtonDownFcn',[])
else
    set(usr.figOptions.selImg.listbox,'Callback',[],'Enable','inactive');
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'CellSelectionCallback',[],'Enable','inactive')
    set(usr.figOptions.optFig.scaleVal,'Enable','inactive','ButtonDownFcn',{@pressEsc,h.right.tabgroup})
    set(usr.figOptions.optFig.msval,'Enable','inactive','ButtonDownFcn',{@pressEsc,h.right.tabgroup})
end

function focusTabs(hBase,hToPass,state)
% Main panel
setFocusJavaPanel(hBase.jmain,state,hToPass);

% Find in each panel the subpanels and text fields
N = sum(strncmp(fieldnames(hBase),'panel',5));
for n=1:N
    % Change subpanel, header and textfield of header 
    setFocusJavaPanel(hBase.(['panel',num2str(n)]).panel,state,hToPass);
    if isfield(hBase.(['panel',num2str(n)]),'header')
        setFocusJavaPanel(hBase.(['panel',num2str(n)]).header,state,hToPass);
    end
    
    % Number of rows
    M = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)])),'row',3));
    for m=1:M
        % Change row its subpanel
        setFocusJavaPanel(hBase.(['panel',num2str(n)]).(['row',num2str(m)]).panel,state,hToPass);
        
        % Change for text- and editfields
        K = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).(['row',num2str(m)])),'option',6));
        for k=1:K
            if isa(hBase.(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]),'textfield') || ...
                    isa(hBase.(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]),'editfield')
            	setFocusJavaPanel(hBase.(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]).button,state,hToPass);
            end
        end
    end
    
    % Advanced panel
    if any(strcmp(fieldnames(hBase.(['panel',num2str(n)])),'advanced'))
        setFocusJavaPanel(hBase.(['panel',num2str(n)]).advanced.main,state,hToPass)
        
        % For subpanels
        M = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).advanced),'panel',5));
        for m=1:M
            % Change subpanel, header and textfield of header 
            setFocusJavaPanel(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).panel,state,hToPass);
            if isfield(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]),'headerText')
                setFocusJavaPanel(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).headerText,state,hToPass);
            end
            
            % Number of rows
            K = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)])),'row',3));
            for k=1:K
                % Change row its subpanel
                setFocusJavaPanel(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).panel,state,hToPass);
                
                % Number of options
                L = sum(strncmp(fieldnames(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)])),'option',6));
                for l=1:L
                    if isa(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]),'textfield') || ...
                            isa(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]),'editfield')
                        setFocusJavaPanel(hBase.(['panel',num2str(n)]).advanced.(['panel',num2str(m)]).(['row',num2str(k)]).(['option',num2str(l)]).button,state,hToPass);
                    end
                end
            end
        end
    end
end


function setFocusJavaPanel(ref,state,h)
% Change focus options of java object
ref.setFocusable(state)
if ~state
    javaCallback(ref,'MouseEnteredCallback',{@buttonPressed,@reqFocus,h},'MouseExitedCallback',{@buttonPressed,[]})
else
    javaCallback(ref,'MouseEnteredCallback',[],'MouseExitedCallback',[],'MouseReleasedCallback',[])
end

function pressEsc(hObject,event,tabgroup)
% pressEsc - Cancel operation and request focus
%

% Check if other routine is running
userdata = get(tabgroup,'Userdata');
if (userdata.callbackrunning)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
end
uicontrol(hObject)

