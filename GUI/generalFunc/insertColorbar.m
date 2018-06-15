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
child = get(usr.images.img,'Children');
warning('off','all') % For old versions MATLAB
% Find old colorbar references and remove them
for i=1:length(child)
    if strcmp(get(child(i),'Tag'),'Colorbar')
        delete(child(i))
    end
end
warning('on','all') % For old versions MATLAB

state = get(hObject,'State');
if strcmp(state,'off')
    return
end

val = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');

if v<2015
    warning('off','all')
    h_bar = colorbar('peer',usr.images.ax);
    set(h_bar,'Visible',state)
    warning('on','all')
else
    h_bar = colorbar(usr.images.ax,'Visible',state);
end
set(hObject,'State','on');

% Now create uicontextmenu, dependend on plotted atomcounts
c = uicontextmenu;

% Create menu items for the uicontextmenu
m1 = uimenu(c,'Label','Delete','Callback',{@delBar,tab});
childAx = get(usr.images.ax,'Children');
imgShown=0;
v = version('-release');
v = str2double(v(1:4));
for i=1:length(childAx)
    if v<2015 && strcmp(get(childAx(i),'Type'),'image')
        imgShown = 1;
        break;
    elseif isa(childAx(i),'matlab.graphics.primitive.Image')
        imgShown = 1;
        break;
    end
end
if imgShown
%     m2 = uimenu(c,'Label','Location','Separator','on');
    m2 = uimenu(c,'Label','Standard Colormaps','Separator','on');
    m3 = uimenu(c,'Label','Interactive Colormap Shift','Callback',{@shiftCmap,h.fig,h_bar,usr.images.ax,h});
    m4 = uimenu(c,'Label','Open Colormap Editor','Callback',{@cmEdit,usr.images.ax,usr.images.ax,h.fig});
    img = get(childAx(i),'CData');
    m5 = uimenu(c,'Label','Reset Range Colors','Callback',{@resetCrange,usr.images.ax,[min(min(img)),max(max(img))]});

%     % Locations
%     l1 = uimenu(m2,'Label','Outside North','Callback',{@changeLoc});
%     l2 = uimenu(m2,'Label','Outside South','Callback',{@changeLoc});
%     l3 = uimenu(m2,'Label','Outside West','Callback',{@changeLoc});
%     l4 = uimenu(m2,'Label','Outside East','Callback',{@changeLoc});
%     l5 = uimenu(m2,'Label','North','Callback',{@changeLoc});
%     l6 = uimenu(m2,'Label','South','Callback',{@changeLoc});
%     l7 = uimenu(m2,'Label','West','Callback',{@changeLoc});
%     l8 = uimenu(m2,'Label','East','Callback',{@changeLoc});

    % Standard Colormaps
    sc1 = uimenu(m2,'Label','cool','Callback',{@changeCmap,usr.images.ax});
    sc2 = uimenu(m2,'Label','gray','Callback',{@changeCmap,usr.images.ax});
    sc3 = uimenu(m2,'Label','hot','Callback',{@changeCmap,usr.images.ax});
    sc4 = uimenu(m2,'Label','hsv','Callback',{@changeCmap,usr.images.ax});
    sc5 = uimenu(m2,'Label','jet','Callback',{@changeCmap,usr.images.ax});
    sc6 = uimenu(m2,'Label','parula(default)','Callback',{@changeCmap,usr.images.ax});
    set(h_bar,'UIContextMenu',c)
else
    set(h_bar,'UIContextMenu',c)
end

function resetCrange(hObject,event,ax,limits)
caxis(ax,limits);

% function changeLoc(hObject,event,h_bar)
% 
% loc = get(hObject,'Label');
% switch loc
%     case 'Outside North'
%         loc = 'northoutside';
%     case 'Outside South'
%         loc = 'southoutside';
%     case 'Outside West'
%         loc = 'westoutside';
%     case 'Outside East'
%         loc = 'eastoutside';
% end
% set(hObject,'Location',loc)

function delBar(~,~,tab)
usr = get(tab,'Userdata');
child = get(usr.images.img,'Children');
warning('off','all') % For old versions MATLAB
% Find old colorbar references and remove them
for i=1:length(child)
    if strcmp(get(child(k),'Tag'),'Colorbar')
        delete(child(i))
    end
end
warning('on','all') % For old versions MATLAB

function changeCmap(hObject,event,ax)

cmap = get(hObject,'Label');
if strcmp(cmap,'parula(default)')
    cmap = 'parula';
end
colormap(ax,cmap)

function cmEdit(~,~,ax,ax2,hfig)
axes(ax)
range = caxis(ax);
pos = get(hfig,'Position');
range = setRangeUI(range,[pos(1)+pos(3)/2 pos(2)+pos(4)/2]);
caxis(ax,range)


function shiftCmap(hObject,event,hf,hb,ha,h)

if strcmp(get(hObject,'Checked'),'off')
    set(hObject,'Checked','on')
    focusFields(h,false)
    
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
    focusFields(h,true)
    
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