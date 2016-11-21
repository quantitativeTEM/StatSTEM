function runFitProgram(hObject,event,h)
% runFitProgram - Button callback for fitting the gaussian model
%
%   syntax: runFitProgram(hObject,event,h)
%       hObject - reference to button
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
% Check if button is enabled
if ~get(hObject,'Enabled')
    return
end
    
% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
	turnOffFigureSelection(h);
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

% Ask to remove model and analysis if necessary
string = 'Fitting the Gaussian model will erase all analysis, continue?';
[quest,usr] = removeQuestionPrep(tab,h,string);
if strcmp(quest,'No')
    return
end
input = usr.file.input;

% Load fit options
FP = usr.fitOpt.model;

% define grid
FP.K = size(input.obs,2);
FP.L = size(input.obs,1);
[FP.X,FP.Y] = meshgrid( (1:FP.K)*input.dx,(1:FP.L)*input.dx);
FP.Xaxis = FP.X(1,:);
FP.Yaxis = FP.Y(:,1);
FP.Xreshape = reshape(FP.X,FP.K*FP.L,1);
FP.Yreshape = reshape(FP.Y,FP.K*FP.L,1);
FP.reshapeobs = reshape(input.obs, FP.K*FP.L,1);
FP.waitbar = h.right.progress.jBar;
FP.abortButton = h.left.fit.panRout.AbortBut;

if FP.widthtype==2
    % For manual width fitting
    FP.widthtype = 1;
    if length(usr.fitOpt.model.rho_start)~=max(input.coordinates(:,3)) || any(FP.rho_start==0)
        errordlg('ERROR: Width not defined for all atom types')
        return
    end
    input.rho = usr.fitOpt.model.rho_start(usr.file.input.coordinates(:,3));
else
    % Don't fit the width again in the test case
    if FP.test
        if ~any(FP.rho_start==0) && length(FP.rho_start)==max(input.coordinates(:,3))
            input.rho = usr.fitOpt.model.rho_start(input.coordinates(:,3));
        end
    end
end
        

% Disable all buttons
hfUS.fitting = 1;
set(h.fig,'Userdata',hfUS);
updateLeftPanels(h,[],usr.fitOpt)

%% Make all text field in preparation panel unfocusable
focusFields(h,false)

% Enable the abort button
EnableBut(h.left.fit.panRout.AbortBut,event,h)

% Display message
message = sprintf(['Fitting procedure on ', usr.FileName, ' started']);
newMessage(message,h)

%% Fit the model
try
    [output,abort] = fitGauss(input,FP);
catch ME
    if h.left.fit.panRout.AbortBut.isEnabled
        % Get position GUI, to center dialog
        pos = get(h.fig,'Position');
        cent = [pos(1)+pos(3)/2,pos(2)+pos(4)/2];
        % Show error
        % Check whether error is unknown (MATLAB error)
        if strcmp(ME.message(1:6),'Error:')
            n1 = strfind(ME.message,'File:');
            n2 = strfind(ME.message,'</a>');
            
            errMes = ['Error in script: ',ME.message(n1+6:n2-1),ME.message(n2+4:end)];
        else
            errMes = ME.message;
        end
        h_err = errordlg(errMes,'Fitting Error');
        set(h_err,'Units','pixels','Visible','off')
        s = get(h_err,'Position');
        set(h_err,'Position',[cent(1)-s(3)/2 cent(2)-s(4)/2 s(3) s(4)],'Visible','on')
    end
    abort = 1;
end

% Disable the abort button
DisableBut(h.left.fit.panRout.AbortBut,event,h)
h.left.fit.panRout.AbortBut.setToolTipText('')

%% Make all text field in preparation panel focusable
focusFields(h,true)

%% Update GUI
if ~abort
    % Now update model
    usr.file.output = output;
    usr.fitOpt.model.zeta = output.zeta;
    set(tab,'Userdata',usr)
    createModel(tab,h,1)
    createHist(tab,h,0)
    
    % Enable export fitted coordinates button
    h.left.fit.panels.Test.CoorBut.setEnabled(true)
    
    % Display message
    message = sprintf(['Gaussian model successfully fitted on: ', usr.FileName]);
    newMessage(message,h)
else
    % Display message
    message = sprintf(['Fitting procedure on ', usr.FileName, ' cancelled']);
    newMessage(message,h)
end

% Enable/Disable buttons
set(h.fig,'Userdata',[]);
updateLeftPanels(h,usr.file,usr.fitOpt)