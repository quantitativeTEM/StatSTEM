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
val = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');

state = get(hObject,'State');
if strcmp(state,'off')
    showImage(tab,str{val},h,0,1)
    return
end

sAx = 0;
val = get(usr.figOptions.selImg.listbox,'Value');
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
if ~isempty(data)
    ind = strcmp(data(:,2),'Atom Counts') | strcmp(data(:,2),'Lib Counts');
    ind2 = strcmp(data(:,2),[char(949),'_xx']) | strcmp(data(:,2),[char(949),'_xy']) | strcmp(data(:,2),[char(949),'_yy']) | strcmp(data(:,2),[char(969),'_xy']);
    if any(ind) || any(ind2)
        for n=1:length(ind)
            k = n;
            if ind(n) && data{n,1}
                sAx = 1;
                state = 'off';
                ylab = 'Number of atoms';
                break
            elseif ind2(n) && data{n,1}
                sAx = 1;
                state = 'off';
                ylab = [data{n,2}(1),'_{',data{n,2}(3:4),'}'];
                break
            end
        end
    end
end

% Redefine limits of axes, if no colorbar is shown
warning('off','all') % For old versions MATLAB
child = get(usr.images.img,'Children');
n1 = 0;
for i=1:length(child)
    if strcmp(get(child(i),'Tag'),'Colorbar')
        n1 = i;
    end
end
if n1~=0
    % Also remove colorbar if already shown
    if v<2015
        colorbar('peer',usr.images.ax2,'Off')
    else
        colorbar(usr.images.ax2,'Off')
    end
else
%     posOut = get(usr.images.ax,'OuterPosition');
%     set(usr.images.ax,'OuterPosition',[-0.1 -0.1 1.1 1.1])
end
warning('on','all') % For old versions MATLAB

if v<2015
    warning('off','all')
    h_bar = colorbar('peer',usr.images.ax);
    set(h_bar,'Visible',state,'Tag','Colorbar')
    if sAx
        pos = get(h_bar,'Position');
        h_bar2 = colorbar('peer',usr.images.ax2,'Position',pos);
        set(h_bar2,'Tag','Colorbar2')
    end
    warning('on','all')
else
    h_bar = colorbar(usr.images.ax,'Visible',state,'Tag','Colorbar');
    if sAx
        pos = get(h_bar,'Position');
        h_bar2 = colorbar(usr.images.ax2,'Position',pos,'Tag','Colorbar2');
    end
end
set(hObject,'State','on');

% Now create uicontextmenu, dependend on plotted atomcounts
c = uicontextmenu;

% Create menu items for the uicontextmenu
m1 = uimenu(c,'Label','Delete','Callback',{@delBar,tab,str{val},h});

if sAx
    switch data{k,2}
        case 'Atom Counts'
            ra = [0,max(usr.file.atomcounting.Counts)];
            ylab = 'Atom Counts';
        case 'Lib Counts'
            ra = [0,max(usr.file.libcounting.Counts)];
            ylab = 'Atom Counts';
        case [char(949),'_xx']
            ra = max( [max(usr.file.strainmapping.eps_xx),-min(usr.file.strainmapping.eps_xx)] );
            ra = [-ra,ra];
            ylab = '\epsilon_{xx}';
        case [char(949),'_xy']
            ra = max( [max(usr.file.strainmapping.eps_xy),-min(usr.file.strainmapping.eps_xy)] );
            ra = [-ra,ra];
            ylab = '\epsilon_{xy}';
        case [char(949),'_yy']
            ra = max( [max(usr.file.strainmapping.eps_yy),-min(usr.file.strainmapping.eps_yy)] );
            ra = [-ra,ra];
            ylab = '\epsilon_{yy}';
        case [char(969),'_xy']
            ra = max( [max(usr.file.strainmapping.omg_xy),-min(usr.file.strainmapping.omg_xy)] );
            ra = [-ra,ra];
            ylab = '\omega_{xy}';
    end
    ylabel(h_bar2,ylab)
    m2 = uimenu(c,'Label','Open Colormap Editor','Callback',{@cmEdit,usr.images.ax2,usr.images.ax,h.fig,data(k,:)});
    m3 = uimenu(c,'Label','Reset Range Colors','Callback',{@resetCrangeAx2,usr.images.ax2,usr.images.ax,ra,data(k,:)});
    set(h_bar,'UIContextMenu',[])
    set(h_bar2,'UIContextMenu',c)
elseif val==1 || val==2
    m2 = uimenu(c,'Label','Location','Separator','on');
    m3 = uimenu(c,'Label','Standard Colormaps','Separator','on');
    m4 = uimenu(c,'Label','Interactive Colormap Shift','Callback',{@shiftCmap,h.fig,h_bar,usr.images.ax,h});
    m5 = uimenu(c,'Label','Open Colormap Editor','Callback',{@cmEdit,usr.images.ax,usr.images.ax,h.fig});
    m6 = uimenu(c,'Label','Reset Range Colors','Callback',{@resetCrange,usr.images.ax,[min(min(usr.file.input.obs)),max(max(usr.file.input.obs))]});

    % Locations
    l1 = uimenu(m2,'Label','Outside North','Callback',{@changeLoc});
    l2 = uimenu(m2,'Label','Outside South','Callback',{@changeLoc});
    l3 = uimenu(m2,'Label','Outside West','Callback',{@changeLoc});
    l4 = uimenu(m2,'Label','Outside East','Callback',{@changeLoc});
    l5 = uimenu(m2,'Label','North','Callback',{@changeLoc});
    l6 = uimenu(m2,'Label','South','Callback',{@changeLoc});
    l7 = uimenu(m2,'Label','West','Callback',{@changeLoc});
    l8 = uimenu(m2,'Label','East','Callback',{@changeLoc});

    % Standard Colormaps
    sc1 = uimenu(m3,'Label','cool','Callback',{@changeCmap,usr.images.ax});
    sc2 = uimenu(m3,'Label','gray','Callback',{@changeCmap,usr.images.ax});
    sc3 = uimenu(m3,'Label','hot','Callback',{@changeCmap,usr.images.ax});
    sc4 = uimenu(m3,'Label','hsv','Callback',{@changeCmap,usr.images.ax});
    sc5 = uimenu(m3,'Label','jet','Callback',{@changeCmap,usr.images.ax});
    sc6 = uimenu(m3,'Label','parula(default)','Callback',{@changeCmap,usr.images.ax});
    set(h_bar,'UIContextMenu',c)
else
    set(h_bar,'UIContextMenu',c)
end

function resetCrange(hObject,event,ax,limits)
caxis(ax,limits);

function resetCrangeAx2(hObject,event,ax,ax2,range,data)
caxis(ax,range);
axes(ax2)
cmap = colormap(ax);
c_x = linspace(range(1),range(2),size(cmap,1));
usrData = get(ax2,'Userdata');
ind = strcmp(usrData(:,1),data{2});
if any(strcmp({'Atom Counts';'Lib Counts'},data{2}))
    mode = 'exact';
    values = get(usrData{ind,2},'ZData');
else
    mode = 'int';
    values = get(usrData{ind,2},'Userdata');
end
RGBvec = getRGBvec(cmap,c_x,values,mode);
set(usrData{ind,2},'CData',RGBvec)

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
set(hObject,'Location',loc)

function delBar(hObject,event,tab,name,h)
showImage(tab,name,h,0)

function changeCmap(hObject,event,ax)

cmap = get(hObject,'Label');
if strcmp(cmap,'parula(default)')
    cmap = 'parula';
end
colormap(ax,cmap)

function cmEdit(~,~,ax,ax2,hfig,data)
if nargin<6
    axes(ax)
    range = caxis(ax);
    pos = get(hfig,'Position');
    range = setRangeUI(range,[pos(1)+pos(3)/2 pos(2)+pos(4)/2]);
    caxis(ax,range)
else
    axes(ax2)
    range = caxis(ax);
    cmap = colormap(ax);
    pos = get(hfig,'Position');
    range = setRangeUI(range,[pos(1)+pos(3)/2 pos(2)+pos(4)/2]);
    caxis(ax,range)
    c_x = linspace(range(1),range(2),size(cmap,1));
    usrData = get(ax2,'Userdata');
    ind = strcmp(usrData(:,1),data{2});
    if any(strcmp({'Atom Counts';'Lib Counts'},data{2}))
        mode = 'exact';
        values = get(usrData{ind,2},'ZData');
    else
        mode = 'int';
        values = get(usrData{ind,2},'Userdata');
    end
    RGBvec = getRGBvec(cmap,c_x,values,mode);
    set(usrData{ind,2},'CData',RGBvec)
end


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