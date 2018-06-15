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
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Ensure that old results are removed
name = mfilename;
[tab,usr] = newFuncCheck(hObject,event,[],h,[],name);
if isempty(tab) || isempty(usr)
    return
end
file = usr.file;

% Load image values
input = file.input;
types = input.types;

% Load current color ordering
[color,err,pathColor] = colorAtoms(1:length(types));
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
input = file.input;
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
    fid = fopen(pathColor,'wt');
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
    value = get(usr.figOptions.selImg.listbox,'Value');
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
    for n=1:size(data,1)
        data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
        if data{n,1}
            showHideFigOptions(tab,data{n,2},false)
            showHideFigOptions(tab,data{n,2},true)
        end
    end
end