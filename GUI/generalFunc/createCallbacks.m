function createCallbacks(h,state)
% createCallbacks - Create callbacks for all StatSTEM buttons
%
%   syntax: createCallbacks(h,state)
%       h     - structure holding references to StatSTEM interface
%       state - boolean indicating whether callbacks are created or removed
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));

% Get references to all tabs
tabs = get(h.right.tabgroup,'Children');
if state
    % Calllback figure 
    set(h.colorbar,'ClickedCallback',{@insertColorbar,h})
    set(h.zoom.in,'ClickedCallback',{@zoomIn_AxinFig,h,h.zoom.out})
    set(h.zoom.out,'ClickedCallback',{@zoomOut_AxinFig,h,h.zoom.in})
    set(h.datacursor,'ClickedCallback',{@insertDatacursor,h})
    set(h.pan,'ClickedCallback',{@insertPan,h})
    
    % For GUI main frame
    if v<2015
        set(h.fig,'ResizeFcn',{@Resize_figure,h});
        set(h.right.tabgroup,'SelectionChangeFcn',{@fileChanged,h});
    else
        set(h.fig,'SizeChangedFcn',{@Resize_figure,h});
        set(h.right.tabgroup,'SelectionChangedFcn',{@fileChanged,h});
    end
    
    set(tabs(length(tabs)),'ButtonDownFcn',{@loadFile,h})
    
    % Load and save files
    set(h.left.loadStore.load,'CallBack',{@loadFile,h});
    set(h.left.loadStore.save,'CallBack',{@saveFile,h});
    
    % Callbacks for preparation panel
    callbackMaker(h,'Preparation');
    
    % Callbacks for fit model panel
    callbackMaker(h,'Fit Model');
    
    % Callbacks for fit model panel
    callbackMaker(h,'Analysis');
    
    % Callback for closing StatSTEM
    set(h.fig,'CloseRequestFcn',{@deleteFigure,h})
    set(h.fig,'DeleteFCN',{@deleteFigure,h})
else
    % Calllback figure 
    set(h.colorbar,'ClickedCallback',[])
    set(h.zoom.in,'ClickedCallback',[])
    set(h.zoom.out,'ClickedCallback',[])
    set(h.datacursor,'ClickedCallback',[])
    set(h.pan,'ClickedCallback',[])
    
    % For GUI main frame
    if v<2015
        set(h.fig,'ResizeFcn',[]);
        set(h.right.tabgroup,'SelectionChangeFcn',[]);
    else
        set(h.fig,'SizeChangedFcn',[]);
        set(h.right.tabgroup,'SelectionChangedFcn',[]);
    end
    set(tabs(length(tabs)),'ButtonDownFcn',[])
    
    % Load and save files
    set(h.left.loadStore.load,'CallBack',[]);
    set(h.left.loadStore.save,'CallBack',[]);
    
    % Callbacks for preparation panel
    callbackUndoer(h,'Preparation');
    
    % Callbacks for fit model panel
    callbackUndoer(h,'Fit Model');
    
    % Callbacks for fit model panel
    callbackUndoer(h,'Analysis');
    
    % Callback for closing StatSTEM
    set(h.fig,'CloseRequestFcn',[])
    set(h.fig,'DeleteFCN',[])
end