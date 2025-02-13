function obj = calcOctahedralTilt(obj)
% calcOctahedralTilt - calculate the octahedral tilt per unit cell
%
%   syntax: obj = calcOctahedralTilt(obj)
%       obj - strainMapping file
%
% Run indexColumns first
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check if coordinates (0,0.5) and (0.5,0) are present in projected unit
% cell
if isempty(obj.suitOctaTilt)
    error('Cannot calculate the octahedral tilt, columns must be indexed and coordinates at (0,0.5) and (0.5,0) must be present in the projected unit cell')
end

unit = obj.projUnit;
dirTeta_ab = obj.dirTeta;
teta = obj.teta(1);

% Crystal parameters
teta_ab = unit.ang;

% define rotation matrices
% rotate over -teta to align coordinates with x-axis
Ra = [cos(-obj.teta(1)) -sin(-obj.teta(1));sin(-obj.teta(1)) cos(-obj.teta(1))];

% rotate over -teta_ab (angle between projected lattice vectors ab
Rab = [cos(-dirTeta_ab*teta_ab) -sin(-dirTeta_ab*teta_ab);sin(-dirTeta_ab*teta_ab) cos(-dirTeta_ab*teta_ab)];
% combined to rotate over -teta-teta_ab to align b-direction with respect
% to x-axis
Rb = Ra*Rab;

% Find per unit cell the octahedral tilt
minIndA = min(obj.indices(:,1));
maxIndA = max(obj.indices(:,1));
minIndB = min(obj.indices(:,2));
maxIndB = max(obj.indices(:,2));
IndA = minIndA:maxIndA;
IndB = minIndB:maxIndB;
coorUC = obj.projUnit.coor2D;
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
if nO<1
    error('No oxygen atoms present in unit cell')
elseif nO>2
    error('Too many oxygen atoms present in unit cell')
end

ang = zeros(maxIndA-minIndA+1,maxIndB-minIndB+1);
if dirTeta_ab==1
    shiftB = 1;
else
    shiftB = -1;
end

% figure, plot(obj.coordinates(:,1), obj.coordinates(:,2),'.'), axis equal, hold on

if nO==2
    obj.message = '[100]-direction indentified, octahedral tilt calculate per unit cell by using oxygen atoms at the left,right,top, and bottom.';
    for i=1:(maxIndA-minIndA+1)
        for j=1:(maxIndB-minIndB+1)
            % Find the 4 (or 2) coordinates
            indCor = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j) & obj.typesN==1;
            % indL = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j)-dirTeta_ab & obj.typesN==type2;
            % indR = obj.indices(:,1)==IndA(i)+1 & obj.indices(:,2)==IndB(j)-dirTeta_ab & obj.typesN==type2;
            % indB = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j)-dirTeta_ab & obj.typesN==type1;
            % indT = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j) & obj.typesN==type1;
            indL = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j)+1 & obj.typesN==type2;
            indR = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j) & obj.typesN==type2;
            indB = obj.indices(:,1)==IndA(i)+1 & obj.indices(:,2)==IndB(j) & obj.typesN==type1;
            indT = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j) & obj.typesN==type1;
            
            if sum(indL)==1 && sum(indR)==1 && sum(indB)==1 && sum(indT)==1

                % plot(obj.coordinates(indCor,1), obj.coordinates(indCor,2), 'ro')
                % plot(obj.coordinates(indL,1), obj.coordinates(indL,2), 'go')
                % plot(obj.coordinates(indR,1), obj.coordinates(indR,2), 'go')
                % plot(obj.coordinates(indT,1), obj.coordinates(indT,2), 'go')
                % plot(obj.coordinates(indB,1), obj.coordinates(indB,2), 'go')

                %coorCor = obj.coordinates(indCor,1:2);
                % Angle in a-direction
                dirA = obj.coordinates(indR,1:2)-obj.coordinates(indL,1:2);
                dirA = Ra*dirA';
                angA = atan2(dirA(2),dirA(1));

                % Angle in b-direction
                dirB = obj.coordinates(indT,1:2)-obj.coordinates(indB,1:2);
                dirB = Rb*dirB';
                angB = atan2(dirB(2),dirB(1));

                ang(i,j) = mean([angA,angB])/2/pi*360; % In degrees
            else
                ang(i,j) = NaN;
            end
        end
    end
elseif nO==1
    obj.message = '[110]-direction indentified, octahedral tilt calculate per unit cell by using oxygen atoms at the left and right in the a-direction.';
    for i=1:(maxIndA-minIndA+1)
        for j=1:(maxIndB-minIndB+1)
            % Find the 4 (or 2) coordinates
            indCor = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j) & obj.typesN==1;
            indL = obj.indices(:,1)==IndA(i)+1 & obj.indices(:,2)==IndB(j) & obj.typesN==type1; 
            indR = obj.indices(:,1)==IndA(i) & obj.indices(:,2)==IndB(j) & obj.typesN==type1;
            
            if sum(indL)==1 && sum(indR)==1
                %coorCor = obj.coordinates(indCor,1:2);
                % Angle in a-direction
                dirA = obj.coordinates(indR,1:2)-obj.coordinates(indL,1:2);
                dirA = Ra*dirA';
                angA = atan2(dirA(2),dirA(1));

                ang(i,j) = angA/2/pi*360; % In degrees
            else
                ang(i,j) = NaN;
            end
        end
    end
end

NA = maxIndA-minIndA+1;
NB = maxIndB-minIndB+1;
IndA = repmat(IndA(1:NA)',1,NB);
IndB = repmat(IndB(1:NB),NA,1);

% Check dir
ind1 = ang(1:2:end,1:2:end);
mean1 = mean(ind1(~isnan(ind1)));
if isnan(mean1)
    mean1 = 0;
end
ind2 = ang(2:2:end,2:2:end);
mean2 = mean(ind2(~isnan(ind2)));
if isnan(mean2)
    mean2 = 0;
end
% Reverse octahedral tilt as clock - counter-clock wise pattern is espected
ang(1:2:end,2:2:end) = -ang(1:2:end,2:2:end);
ind3 = ang(1:2:end,2:2:end);
mean3 = mean(ind3(~isnan(ind3)));
if isnan(mean3)
    mean3 = 0;
end
ang(2:2:end,1:2:end) = -ang(2:2:end,1:2:end);
ind4 = ang(2:2:end,1:2:end);
mean4 = mean(ind4(~isnan(ind4)));
if isnan(mean4)
    mean4 = 0;
end
m = mean1+mean2-mean3-mean4;
if m<0
    ang=-ang;
end

% Remove NaN
indOK = ~isnan(ang);
ang = ang(indOK);
IndA = IndA(indOK);
IndB = IndB(indOK);
obj.octahedralTiltP = [IndA,IndB,ang];

