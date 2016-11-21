function usr = updateAtomCounts(tab,coor,counts,nameTag,nameTagOld,scaleMarker)
% updateAtomCounts - update the atom counts
%
%   syntax: usr = updateAtomCounts(tab,coor,counts,nameTag,nameTagOld)
%       tab        - reference to the selected tab
%       coor       - array with the coordinates
%       counts     - array with the atom counts
%       usr        - the userdata of the selected tab
%       nameTag    - reference to new plot of atom counts
%       nameTagOld - reference to old plot of atom counts
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<6
    scaleMarker = 1;
end

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));

% Get userdata
usr = get(tab,'Userdata');
ax = usr.images.ax;

% Delete old plotted atom counts
data = get(usr.images.ax,'UserData');
ind = strcmp(data(:,1),nameTagOld);
h = data{ind,2};
for n=1:length(h)
    try
        delete(h)
    catch
    end
end
data = data(~ind,:);

% Define colormap for counts
colormap(usr.images.ax,'jet')
caxis(usr.images.ax,[0 max(counts)]);
if v<2015
    h_bar = colorbar('peer',usr.images.ax,'HitTest','off');
else
    h_bar = colorbar(usr.images.ax,'HitTest','off');
end
ylabel(h_bar,'Number of atoms')

cmap = colormap(usr.images.ax);
c_x = linspace(0,max(counts),size(cmap,1));

% Plot counting results
hold(usr.images.ax,'on')
msize = coorMarkerSize(usr.images.ax,'s',scaleMarker);
h = zeros(max(counts),1);
for n=1:max(counts)
    % Get coordinates
    ind = counts == n;
    
    % Get color
    color = [interp1(c_x,cmap(:,1),n,'linear') interp1(c_x,cmap(:,2),n,'linear') interp1(c_x,cmap(:,3),n,'linear')];
    
    % Plot coordinates with color
    h1 = plot(usr.images.ax,coor(ind,1),coor(ind,2),'s','Color',color,'MarkerFaceColor',color,'MarkerSize',msize,'Tag',nameTag,'Userdata',n);
    if ~isempty(h1)
        h(n) = h1;
    end
end
hold(ax,'off')

% Store reference to histogram
set(ax,'Userdata',[data;{nameTag h}])