function usr = plotAtomCounts(tab,coor,counts)
% plotAtomCounts - plot the atom counts
%
%   syntax: usr = plotAtomCounts(tab,coor,counts)
%       tab    - reference to the selected tab
%       coor   - array with the coordinates
%       counts - array with the atom counts
%       usr    - the userdata of the selected tab
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

% Get userdata
usr = get(tab,'Userdata');

% First change image
obsData = get(usr.images.ax,'Children');
for i=1:length(obsData)
    if strcmp(get(obsData(i),'Type'),'image')
        obs = get(obsData(i),'CData');
        dx = get(obsData(i),'XData');
        dx = dx(1);
        break
    end
end
minplaneimg = min(min(usr.file.input.obs));
scaledimg = (floor(((obs - minplaneimg) ./ (max(max(usr.file.input.obs)) - minplaneimg)) * 255)); 
colorimg = ind2rgb(scaledimg,gray(256));

% Now delete old figure axes and panel (panel for memory leakage)
delete(usr.images.ax)
delete(usr.images.img)
usr.images.img = uipanel('Parent',usr.images.main,'units','normalized','Position',[0 0 1 1],'ShadowColor',[0.8 0.8 0.8],'ForegroundColor',[0.8 0.8 0.8],'HighlightColor',[0.8 0.8 0.8],'BackgroundColor',[0.8 0.8 0.8]);
usr.images.ax = axes('Parent',usr.images.img,'units','normalized');
showObservation(usr.images.ax,colorimg,usr.file.input.dx,usr.file.input.dx,usr.file.input.obs)
% Update userdata
set(tab,'Userdata',usr)
ax = usr.images.ax;

% Show all previously selected options
value = get(usr.figOptions.selImg.listbox,'Value');
options = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
for n=1:size(options,1)
    if options{n,1}
        if ~strcmp(options{n,2},'Atom Counts')
            showHideFigOptions(tab,value,options{n,2},true)
        end
    end
end

% Define colormap for counts
colormap(ax,'jet')
caxis(ax,[0 max(counts)]);
if v<2015
    h_bar = colorbar('peer',ax,'HitTest','off');
else
    h_bar = colorbar(ax,'HitTest','off');
end
ylabel(h_bar,'Number of atoms')

cmap = colormap(ax);
c_x = linspace(0,max(counts),size(cmap,1));

% Plot counting results
hold(ax,'on')
msize = coorMarkerSize(ax,'s');
h = zeros(max(counts),1);
for n=1:max(counts)
    % Get coordinates
    ind = counts == n;
    
    % Get color
    color = [interp1(c_x,cmap(:,1),n,'linear') interp1(c_x,cmap(:,2),n,'linear') interp1(c_x,cmap(:,3),n,'linear')];
    
    % Plot coordinates with color
    h1 = plot(ax,coor(ind,1),coor(ind,2),'s','Color',color,'MarkerFaceColor',color,'MarkerSize',msize,'Tag','Atom Counts','Userdata',n);
    if ~isempty(h1)
        h(n) = h1;
    end
end
hold(ax,'off')

% Store reference to histogram
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{'Atom Counts' h}])