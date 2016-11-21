function editColors(hObject,event,h)
% editColors - Edit the colors of the plotted markers
%
%   syntax: editColors(hObject,event,h)
%       hObject - reference to button object
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

% Check if button is enabled
if ~strcmp(get(hObject,'Enable'),'on')
    return
end

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

% Load current color ordering
userdata = get(h.right.tabgroup,'Userdata');
[color,err] = colorAtoms(userdata.pathColor);
if ~isempty(err)
    newMessage(err,h)
end

% Convert colors to cell format
s = size(color);
colors = cell(s(1),s(2));
for n=1:s(1)
    for m=1:s(2)
        colors{n,m} = color(n,m)*255;
    end
end

% Load image values
usr = get(tab,'Userdata');
input = usr.file.input;
types = input.types;

% Get position GUI, to center dialog
pos = get(h.fig,'Position');

% Define new colors
colorsN = defineMarkerColors(types,colors,'center',[pos(1)+pos(3)/2 pos(2)+pos(4)/2]);
s = size(colorsN);
if any(~reshape(cell2mat(colors)==cell2mat(colorsN),s(1)*s(2),1))
    % Colors are changed, store new colors
    T = cell(3+s(1),1);
    T{1,1} = {'Marker colors of the StatSTEM interface'};
    T{2,1} = {''};
    T{3,1} = {'type';'R';'G';'B'};
    for n=4:3+s(1)
        T{n,1} = {num2str(n-3);num2str(colorsN{n-3,1});num2str(colorsN{n-3,2});num2str(colorsN{n-3,3})};
    end
    fid = fopen(userdata.pathColor,'wt');
    for n=1:size(T,1)
        for m=1:size(T{n,1},1)
            fprintf(fid,'%s',T{n,1}{m,1});
            if m~=size(T{n,1},1)
                fprintf(fid,'\t');
            end
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
    
    % Update colors in all figures
    tabs = get(h.right.tabgroup,'Children');
    nT = length(tabs)-1;
    for n=1:nT
        usr = get(tabs(n),'Userdata');
        val = get(usr.figOptions.selImg.listbox,'Value');
        options = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
        for m=1:size(options,1)
            if options{m,1}==true && (strcmp(options{m,2},'Input coordinates') || strcmp(options{m,2},'Fitted coordinates') || strcmp(options{m,2},'Coor atomcounting'))
                showHideFigOptions(tabs(n),val,options{m,2},~options{m,1},h)
                showHideFigOptions(tabs(n),val,options{m,2},options{m,1},h)
            end
        end
    end
end