function model = create3Dmodel(counting,strainmapping)
% create3Dmodel - Generate model with 3D coordinates per atom type
%
% syntax: model3D = create3Dmodel(counting,strainmapping)
%   model         - model3D file
%   counting      - atomCount file
%   strainmapping - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check if projected unit cell in strainmapping contains information about
% the z-direction
c = strainmapping.projUnit.c;
if isempty(c) || c==0
    error('Information about the z-direction is missing, please update the projected unit cell and re-index the columns')
end

indices = strainmapping.indices;
if isempty(indices)
    error('Coordinates are not indexed, run the function indexColumns')
end

types = strainmapping.typesN;
if any(types==0)
    error('Not all columns are indexed, make sure all coordinates are indexed')
end

% Check if coordinates in both files are identical
isOK = size(counting.coordinates,1)==size(strainmapping.coordinates,1);
if isOK
    [counting.coordinates(:,1),idx] = sort(counting.coordinates(:,1));
    counting.coordinates(:,2) = counting.coordinates(idx,2);
    Counts = counting.Counts(idx);
    [strainmapping.coordinates(:,1),idx] = sort(strainmapping.coordinates(:,1));
    strainmapping.coordinates(:,2) = strainmapping.coordinates(idx,2);
    types = strainmapping.typesN(idx);
    isOK = all( counting.coordinates(:,1)==strainmapping.coordinates(:,1) & counting.coordinates(:,2)==strainmapping.coordinates(:,2) );
end

if isOK==0
    error('Indexed coordinates and coordinates with atom counts differ, make sure they are identical')
end

% Use all coordinates to find 3D coordinates
coor = counting.coordinates(:,1:2);
coorTypePerCol = cell(counting.N,2);
zInfo = strainmapping.projUnit.zInfo;
atomsPerCol = zeros(length(zInfo),1);
for i=1:length(zInfo)
    atomsPerCol(i,1) = length(zInfo{i})/2;
end

flipSgn = 1; % flip sign depending on (un)even number of atoms in thickest column for nicer 3D model
if mod(max(counting.Counts),2)
    flipSgn = -1;
end

N = counting.N;
NatInCol = zeros(N,1);
for i=1:N
    if types(i,1)~=0
        zInfo = strainmapping.projUnit.zInfo{types(i,1)};
        nAtCol = atomsPerCol(types(i,1),1);
        coorInt = zeros(Counts(i,1)*nAtCol,3);
        typeInt = cell(Counts(i,1)*nAtCol,1);
        coorInt(:,1) = coor(i,1);
        coorInt(:,2) = coor(i,2);
        if Counts(i,1)<3
        end
        for j=1:nAtCol
            coorInt( ((j-1)*Counts(i,1)+1):(j*Counts(i,1)) ,3) = ( (1:Counts(i,1))' - ceil( (Counts(i,1)+1)/2 ) + flipSgn*zInfo{j*2})*c;
            typeInt( ((j-1)*Counts(i,1)+1):(j*Counts(i,1)) ,1) = repmat(zInfo(j*2-1),Counts(i,1),1);
        end
        coorTypePerCol{i,1} = coorInt;
        coorTypePerCol{i,2} = typeInt;
        NatInCol(i,1) = Counts(i,1)*nAtCol;
        if ~isempty(counting.GUI)
            counting.waitbar.setValue(i/N*100)
            % For aborting function
            drawnow
            if get(counting.GUI,'Userdata')==0
                error('Calculation of 3D model is cancelled')
            end
        end
    end
end
% Regroup into 1 matrix
coordinates = zeros(sum(NatInCol),3);
types = cell(sum(NatInCol),1);
lastInd = 0;
for i=1:counting.N
    firstInd = lastInd+1;
    lastInd = lastInd + NatInCol(i,1);
    coordinates(firstInd:lastInd,:) = coorTypePerCol{i,1};
    types(firstInd:lastInd,:) = coorTypePerCol{i,2};
end
clear coorTypePerCol % To release some memory

% Radius for coordination number calculation is now based on a fcc
% structure
maxLat = max([strainmapping.projUnit.a,strainmapping.projUnit.b,c]);
maxLat = max([strainmapping.a,strainmapping.b,c]);
radMin = maxLat*0.8; % A bit more than 1/sqrt(2)
rad = mean([radMin,radMin,maxLat]); % Take the average

% Create 3D model
model = mod3D(coordinates(:,1:2),coordinates(:,3),types,rad);

