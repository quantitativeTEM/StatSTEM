function strainmapping = makeDisplacementMap(strainmapping)
% makeDisplacementMap - Calculate the displacement from the expected coordinates
%
%   syntax: strainmapping = makeDisplacementMap(strainmapping)
%       strainmapping - strainMapping file
%
% The function indexColumns should be executed before this function works
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

indices = strainmapping.indices;
if isempty(indices)
    return
end

%% With the found angle find the relaxed coordinates
coor = strainmapping.coordinates(:,1:2);
refCoor = strainmapping.refCoor(:,1:2);
unit = strainmapping.projUnit;
teta = strainmapping.teta(1);
a = strainmapping.a(1);
b = strainmapping.b(1);
dirTeta_ab = strainmapping.dirTeta;

% Crystal parameters
teta_ab = unit.ang;
Rab = [cos(dirTeta_ab*teta_ab) -sin(dirTeta_ab*teta_ab);sin(dirTeta_ab*teta_ab) cos(dirTeta_ab*teta_ab)];
aDir = [a,0];
bDir = (Rab*[b;0])';
unitCoor = unit.coor2D(:,1)*aDir + unit.coor2D(:,2)*bDir;

% Create rotation matrix to expand unit cell
R = [cos(teta) -sin(teta);sin(teta) cos(teta)];
unit_rot = ( R*unitCoor' )'; 
LattPar = [(R*[a;0])';(R*Rab*[b;0])'];

% figure(11), scatter(coor(:,1), coor(:,2), 20, indices(:,1),'filled'); axis equal
% figure(12), scatter(coor(:,1), coor(:,2), 20, indices(:,2), 'filled'); axis equal
% clf(15)
% figure(15), plot(refCoor(:,1), refCoor(:,2),'k+'), hold on, axis equal
        % plot(coor(:,1), coor(:,2), 'bx')

N = length(coor(:,1));
coorExp = zeros(N,2);
types = strainmapping.typesN;
for i=1:N
    if types(i,1)~=0
        coorExp(i,:) = refCoor + LattPar(1,:)*indices(i,1) + LattPar(2,:)*indices(i,2) - unit_rot(types(i,1),:);
        % plot(coor(i,1), coor(i,2), 'k+')         
        % plot(coorExp(i,1), coorExp(i,2), 'ro')
    end
end

strainmapping.coorExpectedP = coorExp;


% Make sure old strain maps are removed
strainmapping.eps_xxP = [];
strainmapping.eps_yyP = [];
strainmapping.eps_xyP = [];
strainmapping.omg_xyP = [];

% Make sure old strain maps are removed
strainmapping.eps_aaP = [];
strainmapping.eps_bbP = [];
strainmapping.eps_abP = [];
strainmapping.omg_abP = [];