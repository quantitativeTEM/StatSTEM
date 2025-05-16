function showOctahedralTilt(obj,lwidth)
% showOctahedralTilt - make a octahedral tilt map in image
%
%   syntax - showOctahedralTilt(obj)
%       obj - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2025, EMAT, University of Antwerp
% Author: A. De Backer
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check whether coordinates are present
if isempty(obj.octahedralTilt)
    return
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

if nargin<2
    if isempty(obj.mscale)
        scaleMarker = 1;
    else
        scaleMarker = obj.mscale;
    end
else
    scaleMarker = lwidth;
end

nameTag = 'Octahedral tilt';


%% compute parameters for plotting
coordAngle = zeros(size(obj.octahedralTilt,1),2);
coordL = zeros(size(obj.octahedralTilt,1),2);
coordR = zeros(size(obj.octahedralTilt,1),2);
coordB = zeros(size(obj.octahedralTilt,1),2);
coordT = zeros(size(obj.octahedralTilt,1),2);

coorUC = obj.projUnit.coor2D;
unit = obj.projUnit;


% For 110 use only 1 oxyen atom, for 100 use 2 oxygen atoms in unit cell)
indO = strcmp(unit.atom2D,'O');
if any(indO)
    nO = sum(indO);
    if nO==1
        type1 = find(coorUC(:,1)==0.5 & coorUC(:,2)==0.5);
        if ~isempty(type1)
            type1 = type1(1);
        else
            error('Unit cell invalid, no oxgyen atoms present at (0.5,0.5)')
        end
    elseif nO==2
        type1 = find(coorUC(:,1)==0.5 & coorUC(:,2)==0);
        type2 = find(coorUC(:,1)==0 & coorUC(:,2)==0.5);
        if ~isempty(type1) && ~isempty(type2)
            type1 = type1(1);
            type2 = type2(1);
        else
            error('Unit cell invalid, no oxgyen atoms present at (0.5,0) and (0,0.5)')
        end
    end
else
    type1 = find(coorUC(:,1)==0.5 & coorUC(:,2)==0);
    type2 = find(coorUC(:,1)==0 & coorUC(:,2)==0.5);
    if ~isempty(type1) && ~isempty(type2)
        % 100 direction
        nO = 2;
        type1 = type1(1);
        type2 = type2(1);
    else
        % 110 direction
        type1 = find(coorUC(:,1)==0.5 & coorUC(:,2)==0.5);
        if ~isempty(type1)
            nO = 1;
            type1 = type1(1);
        end
    end
end

for  i = 1:length(obj.octahedralTilt)
    indexCoordinate = find(ismember(obj.indices,obj.octahedralTilt(i,1:2),'rows')); % returns multiple indices for different types
    coordAngle(i,:) = obj.coordinates(indexCoordinate(obj.typesN(indexCoordinate) == 1),1:2); % Pb is the first set of coordinates, indexCoordinate(1) selects Pb coordinate
    % find also the coordinates for the surrounding atoms
    indL = obj.indices(:,1) == obj.octahedralTilt(i,1) & obj.indices(:,2) == obj.octahedralTilt(i,2)+1 & obj.typesN == type2;
    indR = obj.indices(:,1)== obj.octahedralTilt(i,1) & obj.indices(:,2)==obj.octahedralTilt(i,2) & obj.typesN==type2;
    indB = obj.indices(:,1)== obj.octahedralTilt(i,1)+1 & obj.indices(:,2)==obj.octahedralTilt(i,2) & obj.typesN==type1;
    indT = obj.indices(:,1)== obj.octahedralTilt(i,1) & obj.indices(:,2)==obj.octahedralTilt(i,2) & obj.typesN==type1;

    coordL(i,:) = obj.coordinates(indL,1:2);
    coordR(i,:) = obj.coordinates(indR,1:2);
    coordB(i,:) = obj.coordinates(indB,1:2);
    coordT(i,:) = obj.coordinates(indT,1:2);

end

%%

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

%%
% Assume: coordL, coordT, coordR, coordB are N x 2 matrices
N = size(obj.octahedralTilt, 1);

% Vertices: each quad has 4 points, total = N*4 vertices
vertices = zeros(N*4, 2);
faces = zeros(N, 4);  % Each face has 4 indices into vertices

for i = 1:N
    idx = (i-1)*4 + (1:4);  % indices for the i-th quad
    vertices(idx, :) = [coordL(i,:); coordT(i,:); coordR(i,:); coordB(i,:)];
    faces(i, :) = idx;  % the i-th face
end

%% 1. Define color range
angles = obj.octahedralTilt(:,3);
range = [min(angles), max(angles)];

%% 2. Create custom colormap
cmap = jet(512);                 % More precision
c_x = linspace(range(1), range(2), size(cmap, 1));

%% 3. Map angles to RGB colors using your helper
RGBvec = getRGBvec(cmap, c_x, angles, 'exact');  % size = [N x 3]

%% 4. Expand face colors to match patch vertices (4 vertices per face)
RGBvecP = repelem(RGBvec, 4, 1);  % size = [4N x 3]


% Plot all patches at once
hold(ax, 'on')

% Plot all patches at once with transparent faces but no edges
hold(ax, 'on')

cr = caxis(ax);
hPatch = patch(ax, 'Faces', faces, 'Vertices', vertices, ...
               'FaceVertexCData', RGBvecP, ...
               'FaceColor', 'flat', ...
               'EdgeColor', 'none', ...
               'FaceAlpha', 0.5, ...
               'LineWidth', scaleMarker, ...
               'Visible', 'on', ...
               'Tag', nameTag);

% Preallocate line handles array
hEdges = gobjects(N,1);

% Draw edges as colored lines matching faces, save handles
for i = 1:N
    faceVerts = vertices(faces(i,:), :);  % 4x2 vertices for face i
    faceColor = RGBvec(i, :);              % RGB color for this face
    edgeCoords = [faceVerts; faceVerts(1,:)];  % close loop
    
    hEdges(i) = plot(ax, edgeCoords(:,1), edgeCoords(:,2), ...
                     '-', 'Color', faceColor, 'LineWidth', scaleMarker, 'Tag', nameTag);
end

% Plot corner dots (optional)
cornerCoords = [coordL; coordT; coordR; coordB];  % 4N x 2
hDots = plot(ax, cornerCoords(:,1), cornerCoords(:,2), ...
             'r.', 'MarkerSize', scaleMarker*2.5, 'Tag', nameTag);

caxis(ax, cr)

% Link the axes and make the second axes transparent
linkaxes([ax, ax2]); % Synchronize the axes
ax2.XLim = ax.XLim; % Match the X limits
ax2.YLim = ax.YLim; % Match the Y limits
ax2.DataAspectRatio = ax.DataAspectRatio; % Match the aspect ratio
ax2.Color = 'none'; % Make the second axes transparent
ax2.XColor = 'none'; % Hide the X axis on the second axes
ax2.YColor = 'none'; % Hide the Y axis on the second axes

hold(ax, 'off')


% Add a colorbar for the distance visualization
plot(ax2,[],[],'Tag',nameTag)
colormap(ax2, cmap); % Apply the jet colormap to the second axes
caxis(ax2, range); % Scale the colorbar to the distance range
% c=colorbar(ax2, 'Position', [0.85, 0.15, 0.03, 0.7], 'FontSize',20, 'FontWeight', 'bold'); % Adjust colorbar position
% ylabel(c, 'octahedral tilt (degrees)', 'FontSize', 20)

% Plot colorbar

h1 = colorbar(ax);
set(h1,'Visible','off','HitTest','off')
pos = get(h1,'Position');
h2 = colorbar(ax2,'Position',pos);
ylabel(h2, nameTag, 'Tag','Colorbar')

% hold(ax,'off')
% Create UIMenu for colors
% createUIMenu2Axes(ax2,h2,hPatch,angles, range, 'quiver',hEdges)
createUIMenu2Axes(ax2, h2, hPatch, angles, range, 'quiver', ...
    @(RGBvec) updateEdgeColorsLines(hEdges, RGBvec));
axes(ax); % Make axes 1 current axis

function updateEdgeColorsLines(hEdges, RGBvec)
    for k = 1:numel(hEdges)
        if isgraphics(hEdges(k))
            set(hEdges(k), 'Color', RGBvec(k,:));
        end
    end

