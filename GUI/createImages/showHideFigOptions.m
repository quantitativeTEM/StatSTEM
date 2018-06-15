function showHideFigOptions(tab,option,state,out)
% showHideFigOptions - Show or hide a figure option
%
%   syntax: showHideFigOptions(tab,value,option,state,out)
%       tab     - reference to the selected tab
%       value   - Selected figure (number)
%       option  - The selected figure option
%       state   - Logical, indicate whether option should be shown or hiden
%       out     - structure with figure options
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<5
    out = possibleImagesStatSTEM();
end

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));

usr = get(tab,'Userdata');

% Check if scatter function is shown, if so store reference of plot
% and colorbar
hs = get(usr.images.ax,'Children');
indS = false(length(hs),1);
for i=1:length(hs)
    if v<2015 && strcmp(get(hs(i),'Type'),'hggroup')
        indS(i,1) = 1;
    elseif isa(hs(i),'matlab.graphics.chart.primitive.Scatter') || isa(hs(i),'matlab.graphics.primitive.Patch')
        indS(i,1) = 1;
    end
end
hs = hs(indS);
chld = get(usr.images.img,'Children');
indC = false(length(chld),1);
for i=1:length(chld)
    if strcmp(get(chld(i),'Tag'),'Colorbar')
        indC(i,1) = 1;
    end
end
chld = chld(indC);
if sum(indC)>1 && ~isempty(hs)
    % Store references to colorbar and scatter plots
    indC = false(length(chld),1);
    for i=1:length(chld)
        if strcmp(get(chld(i),'Visible'),'on')
            indC(i,1) = 1;
        end
    end
    chld = chld(indC);
        
    exCbar = 1;
else
    exCbar = 0;
end

switch state
    case true
        % Get function
        str = get(usr.figOptions.selImg.listbox,'String');
        value = get(usr.figOptions.selImg.listbox,'Value');
        fNames = fieldnames(out);
        for n=1:length(fNames)
            if strcmp(out.(fNames{n}).name,str{value})
                break
            end
        end
        ind = strcmp(out.(fNames{n}).figOpt(:,1),option);
        func = out.(fNames{n}).figOpt{ind,2};
        input = out.(fNames{n}).figOpt{ind,3};
        loc = strfind(input,'.');
        if ~isempty(loc)
            input = input(1:loc(1)-1);
        end
        eval([func,'(usr.file.',input,')'])
        
        % Remove old colorbars and scatter data if needed
        if exCbar
            % Check if new scatter plot is made
            hsN = get(usr.images.ax,'Children');
            indS = false(length(hsN),1);
            for i=1:length(hsN)
                if v<2015 && strcmp(get(hsN(i),'Type'),'hggroup')
                    indS(i,1) = 1;
                elseif isa(hsN(i),'matlab.graphics.chart.primitive.Scatter') || isa(hsN(i),'matlab.graphics.primitive.Patch')
                    indS(i,1) = 1;
                end
            end
            hsN = hsN(indS);
            
            % Check if new colorbar is made
            chldN = get(usr.images.img,'Children');
            indC = false(length(chldN),1);
            for i=1:length(chldN)
                if strcmp(get(chldN(i),'Tag'),'Colorbar') && strcmp(get(chldN(i),'Visible'),'on')
                    indC(i,1) = 1;
                end
            end
            chldN = chldN(indC);
            
            if length(hsN)>length(hs) && length(chldN)>length(chld)
                % New scatter plot made, delete old ones with old colorbars
                data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
                for i=1:length(hs)
                    nameTag = get(hs(i),'Tag');
                    delete(hs(i))
                    % Make sure option is deselected
                    indOpt = strcmp(data(:,2),nameTag);
                    if v<2015
                        for j=1:length(data(:,2))
                            if length(data{j,2})>1
                                tagName = data{j,2};
                                indOpt(j) = strcmp(tagName(2:end),nameTag(2:end)) & data{j,1};
                            end
                        end
                    end
                    indOpt = indOpt & ~strcmp(data(:,2),option); % To make sure that new option remains
                    for j=1:length(indOpt)
                        if indOpt(j,1)
                            data{j,1} = false;
                        end
                    end
                end
                set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data);
                for i=1:length(chld)
                    delete(chld(i))
                end
            end
        end
        
    case false
        deleteImageObject(usr.images.ax,option)
        deleteImageObject(usr.images.ax2,option)
        % Delete legends (as they will most likely be outdated)
        axes(usr.images.ax)
        legend('off')
        if exCbar
            % Check if (all) scatter plots still exist
            for i=1:length(hs)
                if ~ishandle(hs(i))
                    % Remove colorbar
                    warning('off','all') % For old versions MATLAB
                    % Find old colorbar references and remove them
                    chld = get(usr.images.img,'Children');
                    for j=1:length(chld)
                        if strcmp(get(chld(j),'Tag'),'Colorbar')
                            delete(chld(j))
                        end
                    end
                    warning('on','all')
                end
            end
        end
end

