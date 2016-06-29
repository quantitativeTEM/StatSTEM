function createModel(tab,show)
% createModel - Created an image and option to show the fitting model
%
%   In this function all necessary steps are taken to show the fitted model
%   within the StatSTEM interface. A panel will be created to show options 
%   that can be displayed or done with the image.
%
%       syntax: createModel(tab,show)
%           tab  - reference to the tab in the StatSTEM interface
%           show - Logical value indicating whether the image must be shown
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<2
    show = 0;
end

% Get handle to panels in tab
usr = get(tab,'Userdata');

% Define nameTag
nameTag = 'Fitted coordinates';

% Find previously selected image
value = get(usr.figOptions.selImg.listbox,'Value');

% First add the figure name to the current list of figures
str = get(usr.figOptions.selImg.listbox,'String');
num = length(str)+1;
set(usr.figOptions.selImg.listbox,'String',[str;{'Model'}])
if show
    set(usr.figOptions.selImg.listbox,'Value',num,'Userdata',num)
else
    set(usr.figOptions.selImg.listbox,'Value',value,'Userdata',value)
end

% Create panel for selecting figure options
columnformat = {'logical','char'};
% Show same options as for observation, only all options are deselected
valObs = find(strcmp(str,'Observation'));
optionsObs = get(usr.figOptions.selOpt.(['optionsImage',num2str(valObs)]),'Data');
s = size(optionsObs,1);
options = [num2cell(false(s,1)) optionsObs(:,2)];
options = [options;{true,nameTag}];
usr.figOptions.selOpt.(['optionsImage',num2str(num)]) = uitable('Parent',usr.figOptions.selOpt.main,'units','normalized',...
    'Position',[0 0 1 1],'ColumnFormat',columnformat,'Data',options,'ColumnEditable',[true false],'RowName',[],'ColumnName',[],...
    'ColumnWidth',{15 110},'CellSelectionCallback',{@optionSelected,tab},'Enable','off','Visible','off');

% Add option to observation
valObs = strcmp(str,'Observation');
set(usr.figOptions.selOpt.(['optionsImage',num2str(valObs)]),'Data',[optionsObs;{false,nameTag}]);

% Depending on status, show or hide figure
if show
    % Show new panel and hide previous panel
    set(usr.figOptions.selOpt.(['optionsImage',num2str(num)]),'Enable','on','Visible','on')
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Enable','off','Visible','off')
    
    % Show model with fitted coordinates
    showObservation(usr.images.ax,usr.file.output.model,usr.file.input.dx,usr.file.input.dx,usr.file.input.obs)
    % Plot fitted coordintes
    plotCoordinates(usr.images.ax,[usr.file.output.coordinates(:,1) usr.file.output.coordinates(:,2) usr.file.input.coordinates(:,3)],nameTag,'+');
end

% Update parameters
set(tab,'Userdata',usr)
