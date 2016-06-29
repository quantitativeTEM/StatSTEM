function insertColorbar(hObject,event,h)
% insertColorbar - Insert colorbar
%
% Evaluate which figure is shown to insert to correct colorbar with label
%
%   syntax: insertColorbar(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to the StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));

% Turn off all editing in the figure
plotedit(h.fig,'off')

tab = loadTab(h);
if isempty(tab)
    set(hObject,'State','off');
    return
end

usr = get(tab,'Userdata');

state = get(hObject,'State');
if strcmp(state,'on')
    if v<2015
        h_bar = colorbar('peer',usr.images.ax);
    else
        h_bar = colorbar(usr.images.ax);
    end
    set(hObject,'State','on');
else
    a = get(usr.images.img,'Children');
    for n=1:length(a)
        if isa(a(n),'matlab.graphics.illustration.ColorBar')
            c = get(a(1),'UIContextMenu');
            m = findall(c,'Label','Interactive Colormap Shift');
            set(m,'Checked','off')
            break
        end
    end
    if v<2015
        colorbar('peer',usr.images.ax,state)
    else
        colorbar(usr.images.ax,state)
    end
    return
end

acounts = 0;
val = get(usr.figOptions.selImg.listbox,'Value');
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
if ~isempty(data)
    ind = strcmp(data(:,2),'Atom Counts');
    if any(ind)
        acounts = data{ind,1};
    end
end

% Now create uicontextmenu, dependend on plotted atomcounts

c = uicontextmenu;

% Create menu items for the uicontextmenu
m1 = uimenu(c,'Label','Delete','Callback',{@delBar,h_bar});

if acounts
    ylabel(h_bar,'Number of atoms')
else
    m2 = uimenu(c,'Label','Location','Separator','on');
    m3 = uimenu(c,'Label','Standard Colormaps','Separator','on');
    m4 = uimenu(c,'Label','Interactive Colormap Shift','Callback',{@shiftCmap,h.fig,h_bar,usr.images.ax,h});
    m5 = uimenu(c,'Label','Open Colormap Editor','Callback',{@cmEdit,usr.images.ax});

    % Locations
    l1 = uimenu(m2,'Label','Outside North','Callback',{@changeLoc,h_bar});
    l2 = uimenu(m2,'Label','Outside South','Callback',{@changeLoc,h_bar});
    l3 = uimenu(m2,'Label','Outside West','Callback',{@changeLoc,h_bar});
    l4 = uimenu(m2,'Label','Outside East','Callback',{@changeLoc,h_bar});
    l5 = uimenu(m2,'Label','North','Callback',{@changeLoc,h_bar});
    l6 = uimenu(m2,'Label','South','Callback',{@changeLoc,h_bar});
    l7 = uimenu(m2,'Label','West','Callback',{@changeLoc,h_bar});
    l8 = uimenu(m2,'Label','East','Callback',{@changeLoc,h_bar});

    % Standard Colormaps
    sc1 = uimenu(m3,'Label','cool','Callback',{@changeCmap,usr.images.ax});
    sc2 = uimenu(m3,'Label','gray','Callback',{@changeCmap,usr.images.ax});
    sc3 = uimenu(m3,'Label','hot','Callback',{@changeCmap,usr.images.ax});
    sc4 = uimenu(m3,'Label','hsv','Callback',{@changeCmap,usr.images.ax});
    sc5 = uimenu(m3,'Label','jet','Callback',{@changeCmap,usr.images.ax});
    sc6 = uimenu(m3,'Label','parula(default)','Callback',{@changeCmap,usr.images.ax});
end

set(h_bar,'UIContextMenu',c)


function changeLoc(hObject,event,h_bar)

loc = get(hObject,'Label');
switch loc
    case 'Outside North'
        loc = 'northoutside';
    case 'Outside South'
        loc = 'southoutside';
    case 'Outside West'
        loc = 'westoutside';
    case 'Outside East'
        loc = 'eastoutside';
end

set(h_bar,'Location',loc)

function delBar(hObject,event,h_bar)

colorbar(h_bar,'off')

function changeCmap(hObject,event,ax)

cmap = get(hObject,'Label');
if strcmp(cmap,'parula(default)')
    cmap = 'parula';
end
colormap(ax,cmap)

function cmEdit(~,~,ax)
axes(ax)
colormapeditor;

function shiftCmap(hObject,event,hf,hb,ha,h)

if strcmp(get(hObject,'Checked'),'off')
    set(hObject,'Checked','on')
    focusFields(h,false,'all')
    
    % Now make GUI wait until colorbar shift is done
    userdata = get(h.right.tabgroup,'Userdata');
    userdata.callbackrunning = true;
    set(h.right.tabgroup,'Userdata',userdata);
    % Start routine
    shiftCBar_BarInFig(hb,ha,hf,hObject)
    
    % Update userdata
    userdata = get(h.right.tabgroup,'Userdata');
    userdata.callbackrunning = false; % For peak location routines
    set(h.right.tabgroup,'Userdata',userdata);
    focusFields(h,true,'all')
    
    % Check if other function is started
    if ~isempty(userdata.function)
        f = userdata.function;
        userdata.function = [];
        set(h.right.tabgroup,'Userdata',userdata);
        eval([f.name,'(f.input{:})'])
    end
else
    set(hObject,'Checked','off')
end