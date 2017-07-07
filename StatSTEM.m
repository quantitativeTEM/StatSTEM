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
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------


% Load functions
path = mfilename('fullpath');
path = path(1:end-9);
pathF = [path,filesep,'functions']; % Path for loading fit functions
pathG = [path,filesep,'GUI'];       % Path for loading GUI functions
addpath([path,';',genpath(pathF),';',genpath(pathG)])

% Start a splash screen
splashImg = imread([pathG,filesep,'splash.png']);
spl = splash(splashImg);

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));
if ispc
    opengl hardware
end

% Load the standard pathname
h.startPath = [path,filesep,'startPath.txt'];
if exist(h.startPath, 'file')==0
    if ispc
        h.PathName = getenv('USERPROFILE'); 
    else
        h.PathName = getenv('HOME');
    end
    fid = fopen( h.startPath, 'wt' );
    fprintf( fid, '%s', h.PathName);
    fclose(fid);
else
    fileID = fopen(h.startPath);
    h.PathName = textscan(fileID, '%s', 'delimiter', '\n');
    h.PathName = h.PathName{1}{1};
    fclose(fileID);
end

h.datPath = [path,filesep,'datPath.txt']; % [path,filesep,'GUI',filesep,'datPath.txt'];
if exist(h.datPath, 'file')==0
    if ispc
        pname = getenv('USERPROFILE'); 
    else
        pname = getenv('HOME');
    end
%     pname = [path,filesep,'Database',filesep];
    fid = fopen( h.datPath, 'wt' );
    fprintf( fid, '%s', pname);
    fclose(fid);
end

% StatSTEM colors
pathColor = [path,filesep,'StatSTEMcolors.txt']; % [path,filesep,'GUI',filesep,'StatSTEMcolors.txt'];

% The structure 'h' will be the main structure containing all the
% references to all structures of the GUI

screen = get(0,'ScreenSize');
% Create figure
% screen = [200 200 200 200];
h.fig = figure('units','pixels','outerposition',[screen(3)/2-400 screen(4)/2-300 800 600],'Name','StatSTEM','NumberTitle','off','Visible','off');

% Create main panels
h.left.main = uipanel('Parent', h.fig, 'units', 'normalized', 'Position', [0 0 0.25 1],'BackgroundColor',[0.95,0.95,0.95]);
h.right.main = uipanel('Parent', h.fig, 'units', 'normalized', 'Position', [0.25 0 0.75 1],'BackgroundColor',[0.7 0.7 0.7]);

% Store references for zooming
a = findall(h.fig);
h.zoom.in = findall(a,'ToolTipString','Zoom In');
h.zoom.out = findall(a,'ToolTipString','Zoom Out');

%% Left main panel
warning('off','all')
if isunix
    h.left.tabgroup = uitabgroup(h.left.main,'units','normalized','Position',[-0.04 0.35 1.07 0.65]);
else
    h.left.tabgroup = uitabgroup(h.left.main,'units','normalized','Position',[0 0.35 1 0.65]);
end
h.left.peak.tab = uitab(h.left.tabgroup,'Title','Preparation');
h.left.fit.tab = uitab(h.left.tabgroup,'Title','Fit Model');
h.left.ana.tab = uitab(h.left.tabgroup,'Title','Analysis');
warning('on','all')

% Create left panels
h = panelPrep(h);
h = panelFitModel(h);
h = panelAnalysis(h);

% Create panel for loading and storing files
h.left.loadStore.panel = uipanel('Parent',h.left.main,'units','normalized','Position',[0 0 1 0.1],'Title','Load/save files','FontSize',10);%,'ShadowColor',[0.95 0.95 0.95],'ForegroundColor',[0.95 0.95 0.95],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.95 0.95 0.95]);
h.left.loadStore.load = uicontrol('Parent',h.left.loadStore.panel,'units','normalized','Position',[0.02 0.2 0.47 0.75],'String','Load','FontSize',10);
h.left.loadStore.save = uicontrol('Parent',h.left.loadStore.panel,'units','normalized','Position',[0.49 0.2 0.47 0.75],'String','Save','FontSize',10,'Enable','off');

% Create image of StatSTEM
imgPan = imread([pathG,filesep,'imgGUI.png']);
h = panelStatSTEM(h,imgPan);

%% Create right panels
% Tabgroup for images
warning('off','all')
h.right.tabgroup = uitabgroup(h.right.main,'units','normalized','Position',[0 0.1 1 0.9]);
% Dimensions of panels
tabs.PathName = h.PathName;
tabs.dim_x = 150;
tabs.dim_y = [50;90];%[22;50];
tabs.pathColor = pathColor;%[path,filesep,'GUI',filesep,'StatSTEMcolors.txt'];
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
    set(usr.figOptions.selImg.main,'Position',[1-scale_x(1) scale_y(1)+2*scale_y(2)/3 scale_x(1) scale_y(2)/3]);
    set(usr.figOptions.selOpt.main,'Position',[1-scale_x(1) scale_y(1)+scale_y(2)/3 scale_x(1) scale_y(2)/3]);
    set(usr.figOptions.optFig.main,'Position',[1-scale_x(1) scale_y(1) scale_x(1) scale_y(2)/3]);
    set(usr.figOptions.export.main,'Position',[1-scale_x(1) 0 scale_x(1) scale_y(1)]);
end

% After the addition of panels, check figure size
h.fig_size = get(h.fig,'Position');

%% Turn off buttons GUI
% Turn off figure options which are not necessary
a = findall(h.fig);
b = findall(a,'Label','&File');
set(b,'Visible','off')
b = findall(a,'Label','&Edit');
set(b,'Visible','off')
b = findall(a,'Label','&View');
set(b,'Visible','off')
b = findall(a,'Label','&Insert');
set(b,'Visible','off')
b = findall(a,'Label','&Tools');
set(b,'Visible','off')
b = findall(a,'Label','&Desktop');
set(b,'Visible','off')
b = findall(a,'Label','&Window');
set(b,'Visible','off')
b = findall(a,'Label','&Help');
set(b,'Visible','off')
b = findall(a,'ToolTipString','New Figure');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Open File');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Save Figure');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Print Figure');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Edit Plot');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Brush/Select Data');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Rotate 3D');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Link Plot');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Hide Plot Tools');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Show Plot Tools and Dock Figure');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Insert Colorbar');
h.colorbar = b;
set(b,'ClickedCallback',{@insertColorbar,h})
set(h.zoom.in,'ClickedCallback',{@zoomIn_AxinFig,h,h.zoom.out})
set(h.zoom.out,'ClickedCallback',{@zoomOut_AxinFig,h,h.zoom.in})
b = findall(a,'ToolTipString','Data Cursor');
set(b,'ClickedCallback',{@insertDatacursor,h})
b = findall(a,'ToolTipString','Pan');
set(b,'ClickedCallback',{@insertPan,h})

%% Define callback functions
% For GUI main frame
if v<2015
    set(h.fig,'ResizeFcn',{@Resize_figure,h});
    set(h.right.tabgroup,'SelectionChangeFcn',{@fileChanged,h});
else
    set(h.fig,'SizeChangedFcn',{@Resize_figure,h});
    set(h.right.tabgroup,'SelectionChangedFcn',{@fileChanged,h});
end
set(tabs(1),'ButtonDownFcn',{@loadFile,h})

% Callbacks for preparation panel
h = prepCallbacks(h);

% Callbacks for fit model panel
h = fitCallbacks(h);

% Callbacks for fit model panel
h = anaCallbacks(h);

% Load and save files
set(h.left.loadStore.load,'CallBack',{@loadFile,h});
set(h.left.loadStore.save,'CallBack',{@saveFile,h});

% Update state buttons
fitOpt.peakfinding = standardPeakOptions;
fitOpt.model = standardFitOptions;
fitOpt.atom = standardAtomOptions;
updateLeftPanels(h,[],fitOpt)

% Limit minimum size and make window appear on full screen
% set(h.fig,'Position',[1 1 screen(3) screen(4)])
set(h.fig,'Visible','on')
close(spl) % Close splash window
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
set(h.fig,'CloseRequestFcn',{@deleteFigure,h})
set(h.fig,'DeleteFCN',{@deleteFigure,h})