function initiateFunction(func,button,h,extraInput)
% initiateFunction - Start function invoked by button
%
% syntax: initiateFunction(func,file,button,h)
%       func       - name of the function
%       button     - Matlab reference to button
%       h          - structure holding references to StatSTEM interface
%       extraInput - extra input for function
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(func)
    return
end

if nargin<4
    extraInput = [];
end

% Make sure the correct figure and figure options are shown
showFigureWithOption(h,button.figStart,button.figOptStart)
tab  =loadTab(h);
usr = get(tab,'Userdata');
file = usr.file;

% Make sure StatSTEM is waiting until function finished
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = true;
set(h.right.tabgroup,'Userdata',userdata);
% Check is a function is called which has an abort button option
if button.fitting
    set(h.fig,'Userdata',1)
    % Make sure waitbar is back at 0%
    h.right.progress.jBar.setValue(0);
    % Update message panel
    message = sprintf('Fitting procedure started');
    newMessage(message,h)
end

% Update left panels (for editfield do not update text)
updateLeftPanels(h,file,~isa(button,'editfield'))

% Make field unfocusable
focusFields(h,false)

% Start function
runFunc = [func,'('];
if size(button.input,1)~=1
    button.input = button.input';
end
inputButton = [button.input,button.optInput];

% Remove empty entry
emptyEntry = 0;
indRem = true(length(inputButton),1);
for i=1:length(inputButton)
    if isempty(inputButton{i})
        emptyEntry = 1;
        indRem(i,1) = false;
    end
end
if emptyEntry
    inputButton = inputButton(indRem);
end
    
for n=1:length(inputButton)
    if isempty(inputButton{n})
        continue
    end
    % Remove extra input
    input = inputButton{n};
    loc = strfind(input,'.');
    if ~isempty(loc)
        input = input(1:loc(1)-1);
    end
    
    if n==1
        st = 'file.';
    else
        st = ',file.';
    end
    if isfield(file,input)
        runFunc = [runFunc,st,input];
    end
end
if ~isempty(extraInput)
    runFunc = [runFunc,',extraInput'];
end
runFunc = [runFunc,');'];

% Execute function
errMes = '';
messageFunc = {''};
err = 0;
try
    if isempty(button.output{1})
        eval(runFunc);
    else
        % Gather list of outputs
        N = nargout(func);
        outT = '[out1';
        for i=2:N
            outT = [outT,',out',num2str(i)];
        end
        outT = [outT,'] = '];
        eval([outT,runFunc]);
        out = cell(1,N);
        indEmpty = false(1,N);
        for i=1:N
            out{1,i} = eval(['out',num2str(i)]);
            if isempty(out{1,i})
                indEmpty(1,i) = true;
            end
        end
        % Remove empty cells
        out = out(~indEmpty);
        if isa(out{1},'cell')
            out = out{1};
        end
        N = length(out);
        % Get the list with all the names
        listFC = listStructNamesClass();
        messageFunc = cell(N,1);
        for n=1:N
            ind = find(strcmp(listFC(:,2),class(out{n})));
            file.(listFC{ind(1),1}) = out{n};
            % Store message
            messageFunc{n,1} = file.(listFC{ind(1),1}).message;
            % Delete message
            file.(listFC{ind(1),1}) = clearMessage(file.(listFC{ind(1),1}));
        end
    end
catch ME
    err = 1;
    hfUS = get(h.fig,'Userdata');
    if isempty(hfUS) || hfUS==1
        % Get position GUI, to center dialog
        pos = get(h.fig,'Position');
        cent = [pos(1)+pos(3)/2,pos(2)+pos(4)/2];
        % Show error
        fNames = fieldnames(ME);
        if any(strcmp(fNames,'stack'))
            errMes = sprintf(['Error in script: ',ME.stack(1).name,' at line :',num2str(ME.stack(1).line),'\n',ME.message]);
        else
            errMes = ME.message;
        end
        newMessage(errMes,h)
        h_err = errordlg(errMes,'Function Error');
        set(h_err,'Units','pixels','Visible','off')
        s = get(h_err,'Position');
        set(h_err,'Position',[cent(1)-s(3)/2 cent(2)-s(4)/2 s(3) s(4)],'Visible','on')
        waitfor(h_err)
    else
        set(h.fig,'Userdata',[])
    end
end

% Make sure waitbar is back at 100%
h.right.progress.jBar.setValue(100);

% Update message panel
for i=1:length(messageFunc)
    if ~isempty(messageFunc{i})
        newMessage(messageFunc{i},h)
    end
end

% Indicate in userdata figure that StatSTEM is not busy anymore is busy
hfUS = get(h.fig,'Userdata');
if isempty(hfUS)
    hfUS = 1;
end
if hfUS==0 && strcmp(func,'abortFit')
    message = sprintf('Fitting procedure is aborted by user');
    newMessage(message,h)
end
if button.fitting
    set(h.fig,'Userdata',[]);
end

% Make field focusable
focusFields(h,true)

% Update StatSTEM
updateStatSTEM(h,file);

if err==0
    % Make sure correct figure is shown
    showFigureWithOption(h,button.figEnd,button.figOptEnd,button.reshowFigEnd)
end

% Start new function if needed
startNewFuncCheck(h)