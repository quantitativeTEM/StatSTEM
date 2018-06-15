function showFigureWithOption(h,fig,figOpt,reshow)
% showFigureWithOption - Show an image and figure options in the StatSTEM interface
%
%   In this function all necessary steps are taken to show a specific image
%   in the StatSTEM interface
%
%   syntax: showFigureWithOption(h,fig,figOpt,reshow)
%       h       - structure holding references to the StatSTEM interface
%       fig     - name fo figure to be shown
%       figOpt  - figure options to be shown (cell array)
%       reshow  - remake figure to be shown
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<4
    reshow = 0;
end

if isempty(fig) && isempty(figOpt{1}) && reshow==0
    return
end

tab = loadTab(h);
usr = get(tab,'Userdata');
str = get(usr.figOptions.selImg.listbox,'String');
valFig = get(usr.figOptions.selImg.listbox,'Value');
if isempty(fig)
    fig = str{valFig};
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(valFig)]),'Data');
    if ~isempty(data)
        figOpt = data(cell2mat(data(:,1)),2);
    else
        figOpt = [];
    end
end
ind = strcmp(str,fig);
if ~any(ind)
    hwait = warndlg(['Figure ''',fig,''' not present, shown figure not changed']);
    waitfor(hwait)
else
    % Prepare figure and figure options
    val = find(ind);
    set(usr.figOptions.selImg.listbox,'Value',val);

    % Select figure options
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
    dataOld = data;
    for n=1:size(data,1)
        data{n,1} = false;
    end
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data)
    if reshow
        set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Visible','off')
    end

    % Show image
    showImage(tab,h)
    usr = get(tab,'Userdata');

    % Update userdata
    set(tab,'Userdata',usr)

    % Show selected figure options, if possible
    if ~isempty(data)
        for i=1:length(figOpt)
            ind = strcmp(data(:,2),figOpt{i});
            if any(ind)
                data{ind,1} = true;
            end
        end
        % Check if options are already shown
        showOpt = true(length(data(:,1)),1);
        if val==valFig
            for i=1:length(data(:,1))
                ind = strcmp(dataOld(:,2),data{i,2});
                if any(ind)
                    if dataOld{ind,1} && ~reshow
                        showOpt(i,1) = false;
                    elseif dataOld{ind,1}
                        showHideFigOptions(tab,dataOld{ind,2},false)
                    end
                end
            end
        end
        % Show fig options
        for n=1:size(data,1)
            if showOpt(n,1) || data{n,1}==0
                showHideFigOptions(tab,data{n,2},data{n,1})
            end
        end
    else
        for n=1:size(dataOld,1)
            showHideFigOptions(tab,dataOld{n,2},false)
        end
    end
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data)
end
usr = get(tab,'Userdata');