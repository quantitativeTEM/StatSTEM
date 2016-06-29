function tab = createObservation(tab)
% createObservation - Created an image and option to show the observation
%
%   In this function all necessary steps are taken to show an observation
%   within the StatSTEM interface. A panel will be created to show options 
%   that can be displayed or done with the image
%
%       syntax: createObservation(tab)
%           tab - reference to the tab in the StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Get handle to panels in tab
usr = get(tab,'Userdata');

% Define the nametag
nameTag = 'Input coordinates';

% Find previously selected image
value = get(usr.figOptions.selImg.listbox,'Value');

% First add the figure name to the current list of figures
str = get(usr.figOptions.selImg.listbox,'String');
num = length(str)+1;
set(usr.figOptions.selImg.listbox,'String',[str;{'Observation'}],'Value',num,'Userdata',num)

% Create list via a uitable with possible figure options
columnformat = {'logical','char'};
options = {~isempty(usr.file.input.coordinates),nameTag};
usr.figOptions.selOpt.(['optionsImage',num2str(num)]) = uitable('Parent',usr.figOptions.selOpt.main,'units','normalized',...
    'Position',[0 0 1 1],'ColumnFormat',columnformat,'Data',options,'ColumnEditable',[true false],'RowName',[],'ColumnName',[],...
    'ColumnWidth',{15 110},'CellSelectionCallback',{@optionSelected,tab});

% Hide and disable other buttongroups and shown figures
if value~=num
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Enable','off','Visible','off')
end

% Display the observation and if possible the input coordinates
showObservation(usr.images.ax,usr.file.input.obs,usr.file.input.dx)
plotCoordinates(usr.images.ax,usr.file.input.coordinates,nameTag,'.');

% Update parameters
set(tab,'Userdata',usr)
