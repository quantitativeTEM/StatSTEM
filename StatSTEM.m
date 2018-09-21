function StatSTEM()
% StatSTEM is a interactive program to evaluate HAADF STEM images
% 
%   This function start up a graphical user interface in which images can
%   be loaded and evaluated
%
% syntax: StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

forCompiling = 0; % Put to 1 when compiling

% Load functions
path = mfilename('fullpath');
path = path(1:end-9);
pathF = [path,filesep,'functions']; % Path for loading fit functions
pathG = [path,filesep,'GUI'];       % Path for loading GUI functions
addpath([path,';',genpath(pathF),';',genpath(pathG)])

% Start a splash screen
if forCompiling
    splashImg = imread('splash.png');
else
    splashImg = imread([pathG,filesep,'splash.png']);
    spl = splash(splashImg);
end

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));
if ispc
    warning off all
    opengl hardware
    warning on all
end

% The structure 'h' will be the main structure containing all the
% references to all structures of the GUI

screen = get(0,'ScreenSize');
% Create figure
% screen = [200 200 200 200];
h.fig = figure('units','pixels','outerposition',[screen(3)/2-400 screen(4)/2-300 800 600],'Name','StatSTEM','NumberTitle','off','Visible','off');

% Create main panels
h.left.main = uipanel('Parent', h.fig, 'units', 'normalized', 'Position', [0 0 0.25 1],'BackgroundColor',[0.95,0.95,0.95]);
h.right.main = uipanel('Parent', h.fig, 'units', 'normalized', 'Position', [0.25 0 0.75 1],'BackgroundColor',[0.7 0.7 0.7]);

%% Turn off buttons GUI
h = turnOffUnwantedFigOpt(h);

%% Left main panel
warning('off','all')
if isunix
    h.left.tabgroup = uitabgroup(h.left.main,'units','normalized','Position',[-0.04 0.35 1.07 0.65]);
else
    h.left.tabgroup = uitabgroup(h.left.main,'units','normalized','Position',[0 0.35 1 0.65]);
end
h.left.prep.tab = uitab(h.left.tabgroup,'Title','Preparation');
h.left.fit.tab = uitab(h.left.tabgroup,'Title','Fit Model');
h.left.ana.tab = uitab(h.left.tabgroup,'Title','Analysis');
warning('on','all')

% Create left panels
h = panelMaker(h,'Preparation',forCompiling);
h = panelMaker(h,'Fit Model',forCompiling);
h = panelMaker(h,'Analysis',forCompiling);

% Create panel for loading and storing files
h.left.loadStore.panel = uipanel('Parent',h.left.main,'units','normalized','Position',[0 0 1 0.1],'Title','Load/save files','FontSize',10);%,'ShadowColor',[0.95 0.95 0.95],'ForegroundColor',[0.95 0.95 0.95],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.95 0.95 0.95]);
h.left.loadStore.load = uicontrol('Parent',h.left.loadStore.panel,'units','normalized','Position',[0.02 0.2 0.47 0.75],'String','Load','FontSize',10);
h.left.loadStore.save = uicontrol('Parent',h.left.loadStore.panel,'units','normalized','Position',[0.49 0.2 0.47 0.75],'String','Save','FontSize',10,'Enable','off');

% Create image of StatSTEM
if forCompiling
    imgPan = imread('imgGui.png');
else
    imgPan = imread([pathG,filesep,'imgGui.png']);
end
h = panelStatSTEM(h,imgPan);

%% Create right panels
% Tabgroup for images
warning('off','all')
h.right.tabgroup = uitabgroup(h.right.main,'units','normalized','Position',[0 0.1 1 0.9]);
% Dimensions of panels
% tabs.PathName = h.PathName;
tabs.dim_x = 150;
tabs.dim_y = [50;90];%[22;50];
set(h.right.tabgroup,'Userdata',tabs);
createEmptyTab(h.right.tabgroup)
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; userdata.function = []; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
warning('on','all')

% Create panel for messages
h.right.message.panel = uipanel('Parent',h.right.main,'units','normalized','Position',[0 0 0.7 0.1],'Title','Messages:','ForegroundColor','r','FontSize',10);
h = messagePanel(h);

% Create panel for progress bar
h.right.progress.panel = uipanel('Parent',h.right.main,'units','normalized','Position',[0.7 0 0.3 0.1],'Title','Progress:','ForegroundColor',[51/255,153/255,255/255],'FontSize',10);
[h.right.progress.jBar, h.right.progress.mBar] = createProgressbar(h.right.progress.panel,[0.003 0 0.994 1]);

%% Rescale everything
% Rescale tabgroup
drawnow
set(h.left.main,'units','pixels')
pos = get(h.left.main,'Position');
set(h.left.main,'units','normalized')
scale_y = 58/pos(4);
set(h.left.tabgroup,'Position',[0 scale_y 1 1-scale_y])
set(h.right.tabgroup,'Position',[0 scale_y 1 1-scale_y])
set(h.left.loadStore.panel,'Position',[0 0 1 scale_y])
set(h.right.message.panel,'Position',[0 0 0.7 scale_y])
set(h.right.progress.panel,'Position',[0.7 0 0.3 scale_y])

% Rescale panels
userdata = get(h.right.tabgroup,'Userdata');
tabs = get(h.right.tabgroup,'Children');
set(tabs(1),'units','pixels')
drawnow
pos_r = get(tabs(1),'Position');
set(tabs(1),'units','normalized')
scale_x = userdata.dim_x/pos_r(3);
scale_y = [userdata.dim_y;pos_r(4)-sum(userdata.dim_y)]/pos_r(4);
for n=1:length(tabs)
    % Get handle of tabs
    usr = get(tabs(n),'Userdata');
    set(usr.images.main,'Position',[0 0 1-scale_x(1) 1])
%     set(usr.figOptions.title.main,'Position',[1-scale_x(1) scale_y(1)+scale_y(2) scale_x(1) scale_y(1)]);
    set(usr.figOptions.selImg.main,'Position',[1-scale_x(1) scale_y(1)+scale_y(2)+scale_y(3)/2 scale_x(1) scale_y(3)/2]);
    set(usr.figOptions.selOpt.main,'Position',[1-scale_x(1) scale_y(1)+scale_y(2) scale_x(1) scale_y(3)/2]);
    set(usr.figOptions.optFig.main,'Position',[1-scale_x(1) scale_y(1) scale_x(1) scale_y(2)]);
    set(usr.figOptions.export.main,'Position',[1-scale_x(1) 0 scale_x(1) scale_y(1)]);
end

% After the addition of panels, check figure size
h.fig_size = get(h.fig,'Position');

%% Create calllback functions
createCallbacks(h,true)

% Update state buttons
updateLeftPanels(h)

%% Make screen visible and insert java image
% Limit minimum size and make window appear on full screen
% set(h.fig,'Position',[1 1 screen(3) screen(4)])
set(h.fig,'Visible','on')
if ~forCompiling
	close(spl) % Close splash window
end
waitfor(h.fig,'Visible','on')
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jFrame = get(handle(h.fig), 'JavaFrame');
% Change icon of window
splashImg = im2java(splashImg);
jicon=javax.swing.ImageIcon(splashImg);
jFrame.setFigureIcon(jicon);
jProx = [];
while isempty(jProx)
    pause(0.01)
    if v<2015
        jProx = jFrame.fHG1Client.getWindow();
    else
        jProx = jFrame.fHG2Client.getWindow();
    end
end
jProx.setMinimumSize(java.awt.Dimension(800, 600));