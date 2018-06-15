function showImage(tab,h)
% showImage - Show an image in the StatSTEM interface
%
%   In this function all necessary steps are taken to show a specific image
%   in the StatSTEM interface
%
%   syntax: showImage(tab,h)
%       tab     - reference to the selected tab
%       h       - structure holding references to the StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

usr = get(tab,'Userdata');
fNames = fieldnames(usr.figOptions.selOpt);
indOK = strncmp(fNames,'optionsImage',12);
fNames = fNames(indOK);
% Find previous selected option
oldRow = 0;
for n=1:length(fNames)
    if strcmp(get(usr.figOptions.selOpt.(fNames{n}),'Visible'),'on')
        oldRow = str2double(fNames{n}(13:end));
        break;
    end
end
str = get(usr.figOptions.selImg.listbox,'String');
value = get(usr.figOptions.selImg.listbox,'Value');
nameTag = str{value};
if value==oldRow && any(strcmp(fieldnames(usr.images),'ax'))
    return
end

% Now show only the correct figure options panels
maxVal = length(str);
for n=1:maxVal
    if n==value
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Enable','on','Visible','on')
    else
        set(usr.figOptions.selOpt.(['optionsImage',num2str(n)]),'Enable','off','Visible','off')
    end
end

% Delete axes and panel (panel for memory leakage)
if isfield(usr,'images')
    % Copy colormap if possible
    if isfield(usr.images,'ax')
        delete(usr.images.ax)
    end
    if isfield(usr.images,'ax2')
        delete(usr.images.ax2)
    end
    if isfield(usr.images,'img')
        delete(usr.images.img)
    end
end
usr.images.img = uipanel('Parent',usr.images.main,'units','normalized','Position',[0 0 1 1],'ShadowColor',[0.8 0.8 0.8],'ForegroundColor',[0.8 0.8 0.8],'HighlightColor',[0.8 0.8 0.8],'BackgroundColor',[0.8 0.8 0.8]);
usr.images.ax2 = axes('Parent',usr.images.img,'units','normalized');axis off
usr.images.ax = axes('Parent',usr.images.img,'units','normalized');

% Update axes in all file variables
fNames = fieldnames(usr.file);
for n=1:length(fNames)
    usr.file.(fNames{n}).ax = usr.images.ax;
    usr.file.(fNames{n}).ax2 = usr.images.ax2;
end

% Update userdata
set(tab,'Userdata',usr);

% Show the image by using the given function
out = possibleImagesStatSTEM();
fNames = fieldnames(out);
for n=1:length(fNames)
    if strcmp(out.(fNames{n}).name,nameTag)
        break
    end
end
func = out.(fNames{n}).func;
input = out.(fNames{n}).input;
loc = strfind(input,'.');
if ~isempty(loc)
    input = input(1:loc(1)-1);
end
% Check for optional inputs
optInput = out.(fNames{n}).optInput;
if ~isempty(optInput)
    optStr = '';
    for i=1:length(optInput)
        optStr = [optStr,',usr.file.'];
        optInpInt = optInput{i};
        loc = strfind(optInpInt,'.');
        if ~isempty(loc)
            optInpInt = optInpInt(1:loc(1)-1);
        end
        optStr = [optStr,optInpInt];
    end
else
    optStr = '';
end

eval([func,'(usr.file.',input,optStr,')'])
% Check if image is shown or a plot is made
chld = get(usr.images.ax,'Children');
pos = [0.1300 0.1100 0.7750 0.8150];
imgShown = 0;
indImg = false(length(chld),1);
% Check matlab version
v = version('-release');
v = str2double(v(1:4));
plotIn3D = false;
for i=1:length(chld)
    if v<2015 && strcmp(get(chld(i),'Type'),'image')
        indImg(i) = true;
    elseif isa(chld(i),'matlab.graphics.primitive.Image')
        indImg(i) = true;
    end
    % Show rotate 3D option for surface plots
    if strcmp(get(chld(i),'Type'),'surface')
        plotIn3D = true;
    end
end
if any(indImg)
    pos = [0.01 0.01 0.94 0.94];
    imgShown = 1;
end
set(usr.images.ax,'units','normalized','Position',pos)
xlim = get(usr.images.ax,'XLim');
ylim = get(usr.images.ax,'YLim');
set(usr.images.ax2,'units','normalized','Position',pos,'XLim',xlim,'YLim',ylim)


% Check whether scalebar must be shown
if imgShown
    val = get(usr.figOptions.optFig.scalebar,'Value');
    if val
        dim = str2double(get(usr.figOptions.optFig.scaleVal,'String'));
        plotScalebar(usr.images.ax,dim);
    end
end

% Enable or disable general figure options
if imgShown
    set(usr.figOptions.optFig.scalebar,'Enable','on')
    set(usr.figOptions.optFig.scaleVal,'Enable','on')
    set(usr.figOptions.optFig.scaleTxt,'Enable','inactive')
    set(usr.figOptions.optFig.mstext,'Enable','inactive')
    set(usr.figOptions.optFig.msval,'Enable','on')
    set(usr.figOptions.optFig.colors,'Enable','on')
else
    if plotIn3D
        set(usr.figOptions.optFig.mstext,'Enable','inactive')
        set(usr.figOptions.optFig.msval,'Enable','on')
    else
        set(usr.figOptions.optFig.mstext,'Enable','off')
        set(usr.figOptions.optFig.msval,'Enable','off')
    end
    set(usr.figOptions.optFig.scalebar,'Enable','off')
    set(usr.figOptions.optFig.scaleVal,'Enable','off')
    set(usr.figOptions.optFig.scaleTxt,'Enable','off')
    set(usr.figOptions.optFig.colors,'Enable','off')
end

% Show all the selected figure options
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
for n=1:size(data,1)
    if data{n,1}
        showHideFigOptions(tab,data{n,2},true)
    end
end
% If zooming is turned on, turn it off and on again
zoomReset(h)