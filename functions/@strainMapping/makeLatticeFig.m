function makeLatticeFig(obj,type,lwidth)
% makeLatticeFig - show lattice in figure
%
%   Lattice is shown for the active type
%
%   syntax: makeLatticeFig(obj,type)
%       obj    - strainMapping file
%       type   - select the column type to be shown
%       lwidth - line width 
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

delete(findall(gca, 'Tag', 'Octahedral tilt'))  % Remove tilt graphics


if isempty(obj.latticeA)
    return
end

if nargin<2
    type = obj.actType;
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end
if isempty(obj.ax2)
    img = get(ax,'Parent');
    ax2 = axes('Parent',img,'units','normalized');
    axes(ax)
else
    ax2 = obj.ax2;
end

if nargin<3
    if isempty(obj.mscale)
        scaleMarker = 1;
    else
        scaleMarker = obj.mscale;
    end
else
    scaleMarker = lwidth;
end

nameTag = 'Lattice';

% Check matlab version
vM = version('-release');
vM = str2double(vM(1:4));
% Old version of MATLAB cannot handle two colormaps, convert image to rgb values
if vM<2015
    warning('off','all')
    % Change observation back to original non-rgb image
    child = get(ax,'Children');
    warning('on','all')
    for i=1:length(child)
        if strcmp(get(child(i),'Type'),'image')
            obs = get(child(i),'CData');
            if size(obs,3)==1
                minplaneimg = min(min(obs));
                obs = (floor(((obs - minplaneimg) ./ (max(max(obs)) - minplaneimg)) * 255)); 
                obs = ind2rgb(obs,gray(256));
                set(child(i),'CData',obs);
            end
            break
        end
    end
end

%% Find type
if isempty(type)
    type = 1;
else
    ind = find(strcmp(obj.types,type));
    if ~isempty(ind)
        type = ind(1);
    else
        type = 1;
    end
end
ind = obj.coordinates(:,3)==type;
coor = obj.coordinates(ind,1:2);
lattA = obj.latticeA(ind,:);
lattB = obj.latticeB(ind,:);
a = sqrt(lattA(:,1).^2 + lattA(:,2).^2);
b = sqrt(lattB(:,1).^2 + lattB(:,2).^2);
N = length(a)*2;


%% Define colors
% range = [obj.a-0.2,obj.a+0.2];
range = [min(min(a(a ~=0)),min(b(b~=0))), max(max(a),max(b))];
xC = linspace(0,1,33);
cmap = [xC',zeros(33,1),ones(33,1)];
xC = linspace(1,0,33);
cmap = [cmap;[ones(32,1),zeros(32,1),xC(2:end)']];
% cmap = jet(512);
c_x = linspace(range(1),range(2),size(cmap,1));
RGBvecA = getRGBvec(cmap,c_x,a,'exact');
RGBvecB = getRGBvec(cmap,c_x,b,'exact');
RGBvec = [RGBvecA;RGBvecB];

% Convert RGB vector to appropriate length for patches
RGBvecP = zeros(4*N,3);
for i=1:N
    RGBvecP( (1+4*(i-1)):4*i ,:) = repmat(RGBvec(i,:),4,1);
end


%% Select axis
ax = gca;
axis(ax);
hold on;
msize = coorMarkerSize('line',scaleMarker);

%% For lattice parameters in a-direction
% Use patch to make a single plot
R = [cos(0.5*pi) -sin(0.5*pi);sin(0.5*pi) cos(0.5*pi)];
dirAO = (R*(lattA./[a,a])')'*0.1*msize;
dirAO(isnan(dirAO(:,1)),1) = 0;
dirAO(isnan(dirAO(:,1)),2) = 0;
dirBO = (R*(lattB./[b,b])')'*0.1*msize;
dirBO(isnan(dirBO(:,1)),1) = 0;
dirBO(isnan(dirBO(:,1)),2) = 0;
LxA = [coor(:,1)-dirAO(:,1),coor(:,1)+dirAO(:,1),coor(:,1)+lattA(:,1)+dirAO(:,1),coor(:,1)+lattA(:,1)-dirAO(:,1)];
LyA = [coor(:,2)-dirAO(:,2),coor(:,2)+dirAO(:,2),coor(:,2)+lattA(:,2)+dirAO(:,2),coor(:,2)+lattA(:,2)-dirAO(:,2)];
LxB = [coor(:,1)-dirBO(:,1),coor(:,1)+dirBO(:,1),coor(:,1)+lattB(:,1)+dirBO(:,1),coor(:,1)+lattB(:,1)-dirBO(:,1)];
LyB = [coor(:,2)-dirBO(:,2),coor(:,2)+dirBO(:,2),coor(:,2)+lattB(:,2)+dirBO(:,2),coor(:,2)+lattB(:,2)-dirBO(:,2)];

Lx = reshape([LxA;LxB]',N*4,1);
Ly = reshape([LyA;LyB]',N*4,1);

Faces = 1:4*N; Faces = reshape(Faces,4,N)';
cr = caxis(ax);
h = patch(Lx,Ly,[0 0 0],'Visible','off');
set(h,'Faces',Faces,'FaceColor','flat','FaceVertexCData',RGBvecP,'EdgeColor','none','Visible','on');
caxis(ax,cr)
usrData = repmat([a;b],1,4)';
usrData = reshape(usrData,N*4,1);
set(h,'Tag',nameTag,'Userdata',{['Lattice value %g ',char(197)],usrData}) % For data cursor in StatSTEM

% Plot in second graph for StatSTEM to ensure that it recognises it as the
% active axes for colors
plot(ax2,[],[],'Tag',nameTag)
colormap(ax2,cmap)
caxis(ax2,range);

% Plot colorbar
if vM<2015
    warning('off','all')
    h1 = colorbar('peer',ax);
    set(h1,'Visible','off','HitTest','off')
    drawnow
    pos = get(h1,'Position');
    h2 = colorbar('peer',ax2,'Position',pos);
    ylabel(h2,['Lattice parameter (',char(197),')'])
    warning('on','all')
else
    h1 = colorbar(ax);
    set(h1,'Visible','off','HitTest','off')
    pos = get(h1,'Position');
    h2 = colorbar(ax2,'Position',pos);
    ylabel(h2,['Lattice parameter (',char(197),')'])
end
% Create UIMenu for colors
% createUIMenu2Axes(ax2,h2,h,usrData,range,'quiver')
createUIMenu2Axes(ax2, h2, h, usrData, range, 'quiver', true);

axes(ax); % Make axes 1 current axis
