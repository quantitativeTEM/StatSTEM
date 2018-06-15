function obj = autoAddTypes(obj,varargin)
% autoAddTypes - automatically add column types by using a projected unit cell
%
%   Use functions of other StatSTEMfile classes to index columns. Use indices 
%   to add missing column types
%
%   syntax: obj = autoAddTypes(obj,varargin)
%       obj      - inputStatSTEM file
%       varargin - optional input not used
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First create an outputStatSTEM file;
Ncol = length(obj.coordinates(:,1));
output = outputStatSTEM(obj.coordinates,ones(Ncol,1),ones(Ncol,1),0,obj.dx);
output.types = obj.types;

% Find a- and b-direction
strainmapping = getCenCoor(output,obj);
strainmapping = findLatDir(strainmapping);

coor = strainmapping.coordinates(:,1:2);
refCoor = strainmapping.refCoor;
projUnit = strainmapping.projUnit;
teta = strainmapping.teta(1);
a = strainmapping.a(1);
b = strainmapping.b(1);
dir_teta_ab = strainmapping.dirTeta;
space = strainmapping.space;

[indices,types] = STEMindexing(coor,refCoor,projUnit,teta,a,b,dir_teta_ab,space,'allNoWarn',10000,0);

indT = types~=0;
obj.coordinates(:,3) = types;
obj.coordinates = obj.coordinates(indT,:);
indices = indices(indT,:);
types = types(indT,:);
indices = [indices(:,1) - min(indices(:,1)) + 1,indices(:,2) - min(indices(:,2)) + 1]; 

% Get a- and b-direction
coorUnit = projUnit.coor2D;
aDir = strainmapping.aDir;
bDir = strainmapping.bDir;
coorRelUC = [coorUnit(:,1)-coorUnit(1,1),coorUnit(:,2)-coorUnit(1,2)];

%% Put atoms at missing plaxes
Ntypes = length(coorUnit(:,1));
N = max(indices(:,1))-1;
M = max(indices(:,2))-1;
coor_new = zeros(N*M,3*(Ntypes-1));
indOK = false(N*M,1);
for n=1:N
    for m=1:M
        ind1 = indices(:,1)==n & indices(:,2)==m & types==1;
        if sum(ind1)==1
            coor1 = obj.coordinates(ind1,1:2);
            for i=1:Ntypes-1
                indT = indices(:,1)==n & indices(:,2)==m & types==i+1;
                if sum(indT)==0
                    coor_new( (n-1)*M + m, (3*i-2):(3*i-1) ) = coor1 + coorRelUC(i+1,1)*aDir + coorRelUC(i+1,2)*bDir;
                    coor_new( (n-1)*M + m, 3*i) = i+1;
                end
            end
            indOK( (n-1)*M + m,1) = true;
        end
    end
end

Nnew = sum(indOK);
coor_add = zeros(Nnew*(Ntypes-1),3);
for i=1:Ntypes-1
    coor_add( ((i-1)*Nnew+1):i*Nnew ,:) = coor_new(indOK, (3*i-2):3*i);
end

coorTot = [obj.coordinates;coor_add];
obj.coordinates = coorTot;
% Check if column names are the same, if so they should be of the same type
atomNames = unique(projUnit.atom2D,'stable');
for i=1:length(atomNames)
    typInt = find(strcmp(projUnit.atom2D,atomNames{i}));
    for j=1:length(typInt)
        indInt = coorTot(:,3)==typInt(j);
        obj.coordinates(indInt,3) = i;
    end
end
obj.types = atomNames;
obj.actType = obj.types{1};

