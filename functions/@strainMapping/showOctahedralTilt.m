function showOctahedralTilt(obj)
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



minAngles = min(obj.octahedralTilt(:,3)); % Set the minimum angle for scaling
maxAngles = max(obj.octahedralTilt(:,3)); % Set the maximum angle for scaling

% Define a colormap (e.g., jet)
% xC = linspace(0,1,33);
% cmap = [xC',zeros(33,1),ones(33,1)];
% xC = linspace(1,0,33);
% cmap = [cmap;[ones(32,1),zeros(32,1),xC(2:end)']];
% cmap = cool(256);
cmap = jet(65);

hold(ax, 'on')

for i = 1: length(obj.octahedralTilt)

    % Normalize the distance to scale between 1 and 256
    clippedAngles = min(max(obj.octahedralTilt(i,3), minAngles), maxAngles);
    normalizedAngle = round(((clippedAngles - minAngles) / (maxAngles - minAngles)) * 64) + 1;

    % Get the color from the colormap for the line
    dotColor = cmap(normalizedAngle, :);

    % Create a second axes for the color-coded line and points

    h(1) = plot(ax, [coordL(i,1) coordT(i,1) coordR(i,1) coordB(i,1) coordL(i,1)],...
        [coordL(i,2) coordT(i,2) coordR(i,2) coordB(i,2) coordL(i,2)],'-', 'LineWidth', 2, 'Color', dotColor, 'Tag', nameTag);
    h(2) = plot(ax, [coordL(i,1) coordT(i,1) coordR(i,1) coordB(i,1) coordL(i,1)],...
        [coordL(i,2) coordT(i,2) coordR(i,2) coordB(i,2) coordL(i,2)],'r.', 'MarkerSize', 5, 'Tag',nameTag);
    h(3) = fill(ax, [coordL(i,1) coordT(i,1) coordR(i,1) coordB(i,1) coordL(i,1)],...
        [coordL(i,2) coordT(i,2) coordR(i,2) coordB(i,2) coordL(i,2)], dotColor, 'FaceAlpha', 0.5, 'EdgeColor','none', 'Tag', nameTag);
plot(ax2,[],[],'Tag',nameTag)


end

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
colormap(ax2, cmap); % Apply the jet colormap to the second axes
caxis(ax2, [minAngles maxAngles]); % Scale the colorbar to the distance range
% c=colorbar(ax2, 'Position', [0.85, 0.15, 0.03, 0.7], 'FontSize',20, 'FontWeight', 'bold'); % Adjust colorbar position
% ylabel(c, 'octahedral tilt (degrees)', 'FontSize', 20)

% Plot colorbar

h1 = colorbar(ax);
set(h1,'Visible','off','HitTest','off')
pos = get(h1,'Position');
h2 = colorbar(ax2,'Position',pos);
ylabel(h2, nameTag, 'Tag','Colorbar')

% hold(ax,'off')
% % Create UIMenu for colors
% createUIMenu2Axes(ax2,h2,h,obj.octahedralTilt(:,3), [minAngles maxAngles])
% axes(ax); % Make axes 1 current axis

