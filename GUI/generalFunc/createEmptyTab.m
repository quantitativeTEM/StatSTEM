function createEmptyTab(ref)
% createEmptyTab - Create a new tab
%
% Create a new tab on the right panel to hold the references and images of
% an opened file
%
%   syntax: createEmptyTab(ref)
%       ref - Reference to right tab panel
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

n = length(get(ref,'Children'))+1;
userdata = get(ref,'Userdata');

warning('off','all')
tab = uitab(ref,'Title','+');
warning('on','all')
v = version('-release');
v = str2double(v(1:4));
if v>2014
    set(tab,'TooltipString','Load new file');
end

% Get panel sizes
set(tab,'units','pixels')
drawnow
pos_r = get(tab,'Position');
set(tab,'units','normalized')
scale_x = userdata.dim_x/pos_r(3);
scale_y = [userdata.dim_y;pos_r(4)-sum(userdata.dim_y)]/pos_r(4);

% Create panels on tab
handle.images.main = uipanel('Parent',tab,'units','normalized','Position',[0 0 1-scale_x(1) 1],'ShadowColor',[0.8 0.8 0.8],'ForegroundColor',[0.8 0.8 0.8],'HighlightColor',[0.8 0.8 0.8],'BackgroundColor',[0.8 0.8 0.8]);

% Create figure options panel
handle.figOptions.title.main = uipanel('Parent',tab,'units','normalized','Position',[1-scale_x(1) scale_y(2)+scale_y(3) scale_x(1) scale_y(1)],'ShadowColor',[0.95 0.95 0.95],'ForegroundColor',[0.95 0.95 0.95],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.95 0.95 0.95]);
handle.figOptions.title.text = uicontrol('Parent',handle.figOptions.title.main,'units','normalized','Position',[0 0 1 0.9],'Style','Text','String','Figure Options','FontSize',9,'FontWeight','bold','HorizontalAlignment','Center','BackgroundColor',[0.95 0.95 0.95]);
% handle.figOptions.title.but = minimizeButton('Parent',handle.figOptions.title.main,'Position',[0.87 0.05 0.13 0.95],'BackgroundColor',[1,1,1],'Parent2',handle.figOptions.title.text);

% Create panels for showing different images
handle.figOptions.selImg.main = uipanel('Parent',tab,'units','normalized','Position',[1-scale_x(1) scale_y(2)+scale_y(3)/2 scale_x(1) scale_y(3)/2],'Title','Select Image','BackgroundColor',[0.95 0.95 0.95],'FontSize',10);
handle.figOptions.selOpt.main = uipanel('Parent',tab,'units','normalized','Position',[1-scale_x(1) scale_y(2) scale_x(1) scale_y(3)/2],'Title','Select Options','BackgroundColor',[0.95 0.95 0.95],'FontSize',10);

% Create panel for exporting figure(s)
handle.figOptions.export.main = uipanel('Parent', tab,'units','normalized','Position',[1-scale_x(1) 0 scale_x(1) scale_y(2)],'Title','Export figure','BackgroundColor',[0.95 0.95 0.95],'FontSize',10);
handle.figOptions.export.but = uicontrol('Parent',handle.figOptions.export.main,'units','normalized','Position',[0.02 0.2 0.96 0.75],'String','Export','FontSize',10,'Enable','off');

% Update userdata
set(tab,'Userdata',handle);