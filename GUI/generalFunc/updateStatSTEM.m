function updateStatSTEM(h,file)
% updateStatSTEM - Update the file and the graphs in StatSTEM
%
%   syntax: updateStatSTEM(h,file)
%       h    - structure holding references to StatSTEM interface
%       file - Structure containing the file parameters
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First delete removed options
tab = loadTab(h);
usr = get(tab,'Userdata');

% Load old figure
str = get(usr.figOptions.selImg.listbox,'String');
val = get(usr.figOptions.selImg.listbox,'Value');
if ~isempty(str)
    figSel = str{val};
else
    figSel = '';
end

% Create new options
usr.file = file;
set(tab,'Userdata',usr)
out = possibleImagesStatSTEM();
% Check which options can be shown
fNames = fieldnames(out);
fNNew = fieldnames(file);
imgNames = cell(length(fNames),1);
indImg = false(length(fNames),1);
for n=1:length(fNames)
    optSel = out.(fNames{n});
    imgNames{n,1} = optSel.name;
    input = optSel.input;
    loc = strfind(input,'.');
    if isempty(loc)
        in2 = '';
    else
        in2 = input(loc(1)+1:end);
        input = input(1:loc(1)-1);
    end
    
    if any(strcmp(fNNew,input)) && isempty(in2)
        indImg(n,1) = true;
    elseif any(strcmp(fNNew,input)) && ~isempty(in2)
        if any(strcmp(fieldnames(file.(input)),in2)) && ~isempty(file.(input).(in2))
            indImg(n,1) = true;
        end
    end
end
imgNames = imgNames(indImg,:);
indOk = find(indImg);
% Update panel
if isempty(figSel)
    valN = 1;
else
    ind = strcmp(imgNames,figSel);
    if sum(ind)==1
        valN = find(ind);
    else
        valN = 1;
    end
end
set(usr.figOptions.selImg.listbox,'String',imgNames)
set(usr.figOptions.selImg.listbox,'Value',valN)

% Create figure option panels
columnformat = {'logical','char'};
for n=1:length(imgNames)
    % Check if option is already shown
    ind = strcmp(str,imgNames{n});
    if any(ind)
        % Switch order in old list
        optNum = find(ind);
        str{optNum,1} = str{n,1};
        str{n,1} = imgNames{n};
        optOld = usr.figOptions.selOpt.(['optionsImage',num2str(n)]);
        usr.figOptions.selOpt.(['optionsImage',num2str(n)]) = usr.figOptions.selOpt.(['optionsImage',num2str(optNum)]);
        usr.figOptions.selOpt.(['optionsImage',num2str(optNum)]) = optOld;
    else
        sStr = size(str,1);
        if sStr>=n && sStr~=0
            str = [str;str(n,1)];
            str{n,1} = [];
            usr.figOptions.selOpt.(['optionsImage',num2str(sStr+1)]) = usr.figOptions.selOpt.(['optionsImage',num2str(n)]);
        end
        usr.figOptions.selOpt.(['optionsImage',num2str(n)]) = uitable('Parent',usr.figOptions.selOpt.main,'units','normalized',...
            'Position',[0 0 1 1],'ColumnFormat',columnformat,'ColumnEditable',[true false],'RowName',[],'ColumnName',[],...
            'ColumnWidth',{15 110},'CellSelectionCallback',{@optionSelected,tab});
    end
    updFO = 0;
    if n==valN
        if val~=valN
            set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Enable','on','Visible','off')
        else
            updFO = 1;
        end
    else
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Enable','off','Visible','off')
    end
    
    % Load figure options
    figOpt = out.(fNames{indOk(n)}).figOpt;
    if isempty(figOpt)
        data = [];
    else
        data = [figOpt(:,4),figOpt(:,1)];
        indKeep = false(size(figOpt,1),1);
        dataOld = get(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data');
        for m=1:size(figOpt,1)
            % Check if figure option can be shown (necessary input is present
            input = figOpt{m,3};
            loc = strfind(input,'.');
            if isempty(loc)
                in2 = '';
            else
                in2 = input(loc(1)+1:end);
                input = input(1:loc(1)-1);
            end
            if any(strcmp(fNNew,input)) && isempty(in2)
                indKeep(m,1) = true;
            elseif any(strcmp(fNNew,input)) && ~isempty(in2)
                if any(strcmp(fieldnames(file.(input)),in2)) && ~isempty(file.(input).(in2))
                    indKeep(m,1) = true;
                end
            end

            % Copy old setting
            if ~isempty(dataOld)
                indOld = strcmp(dataOld(:,2),data{m,2});
            else
                indOld = 0;
            end
            if any(indOld)
                data{m,1} = dataOld{indOld,1};
                if ~indKeep(m,1) && dataOld{indOld,1} && updFO
                    showHideFigOptions(tab,dataOld{indOld,2},false)
                end
            end
        end
        data = data(indKeep,:);
    end
    % Update panel
    set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Data',data)
end
% Make sure figure option panels of removed options are deleted
for n=1:length(str)
    if ~any(strcmp(imgNames,str{n})) && ~isempty(str{n})
        delete(usr.figOptions.selOpt.(['optionsImage',num2str(n)]))
        usr.figOptions.selOpt = rmfield(usr.figOptions.selOpt,['optionsImage',num2str(n)]);
    end
end

% Update userdata
set(tab,'Userdata',usr)

% Update marker size in all files
str = get(usr.figOptions.optFig.msval,'String');
scaleMarker = str2double(str);
fNNew = fieldnames(usr.file);
for n=1:length(fNNew)
    usr.file.(fNNew{n}).mscale = scaleMarker;
end

% Show image
showImage(tab,h)
usr = get(tab,'Userdata');

% Make sure the loaded files have updated links to StatSTEM figures and properties
fNNew = fieldnames(usr.file);
markerSize = str2double(get(usr.figOptions.optFig.msval,'String'));
for n=1:length(fNNew)
    usr.file.(fNNew{n}).GUI = h.fig;
    usr.file.(fNNew{n}).ax = usr.images.ax;
    usr.file.(fNNew{n}).ax2 = usr.images.ax2;
    usr.file.(fNNew{n}).waitbar = h.right.progress.jBar;
    usr.file.(fNNew{n}).mscale = markerSize;
end
% Update userdata
set(tab,'Userdata',usr)

% Update left panels
updateLeftPanels(h,file)