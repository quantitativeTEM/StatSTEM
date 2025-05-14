function strainmapping = STEMstrain(strainmapping)
% STEMstrain - determine the strain from coordinates
%
%   syntax: strainmapping = STEMstrain(strainmapping)
%       strainmapping  - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2024, EMAT, University of Antwerp
% Author: A. De Backer
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

N = length(coor(:,1));
coorExp = zeros(N,2);
types = strainmapping.typesN;
for i=1:N
    if types(i,1)~=0
        coorExp(i,:) = refCoor + LattPar(1,:)*indices(i,1) + LattPar(2,:)*indices(i,2) - unit_rot(types(i,1),:);
    end
end

strainmapping.coorExpectedP = coorExp;

coordinates = strainmapping.coordinates;

n1 = size(coordinates,1);
eps_xx = zeros(n1,2);
eps_xy = zeros(n1,2);
eps_yy = zeros(n1,2);
omg_xy = zeros(n1,2);

for n=1:n1  % loop over all atoms

    if types(n,1)~=0
        % Find indices of neighbors
        r_cutoff = 1.1*max([a b]);  % Set radius based on lattice spacing
        distances = vecnorm(coorExp - coorExp(n,:), 2, 2);  % Euclidean distances
        neighbors = find(distances < r_cutoff);
        neighbors(neighbors == n) = [];  % remove self

        numberNeighbors = sum(neighbors);

        ref_disp = coorExp(neighbors,:) - coorExp(n,:);
        def_disp = coordinates(neighbors,1:2) - coordinates(n,1:2);

        % Store the current warning state
        warning('error', 'MATLAB:singularMatrix');
        warning('error', 'MATLAB:nearlySingularMatrix');

        try
            % Suppress the specific warning
            warning('off', 'MATLAB:singularMatrix');
            warning('off', 'MATLAB:nearlySingularMatrix');

            % Compute deformation gradient F: F*solve def_disp = ref_disp
            F = ref_disp \ def_disp;


            % Compute strain tensors
            % Strain = 0.5 * (F' * F - eye(2)); % valid for very large deformations: GreenLagrangeStrain
            Strain = 0.5 * (F + F') - eye(2); % Cauchy strain

            eps_xx(n) = Strain(1,1);
            eps_yy(n) = Strain(2,2);
            eps_xy(n) = Strain(2,1);

            % Compute the rotation component (antisymmetric part of F)
            R = 0.5 * (F - F');  % Rotation tensor
            omg_xy(n) = R(1,2);
            % omg_xy(n) = rad2deg(omg_xy(n));     % if needed in degrees


        catch ME
            % Check if the error is related to a (nearly) singular matrix
            if strcmp(ME.identifier, 'MATLAB:singularMatrix') || strcmp(ME.identifier, 'MATLAB:nearlySingularMatrix')
                eps_xx(n) = NaN;
                eps_yy(n) = NaN;
                eps_xy(n) = NaN;
                omg_xy(n) = NaN;
            else
                % Re-throw the error if it's not related to a singular matrix
                rethrow(ME);
            end
        end
        % Re-enable the warning
        warning('on', 'MATLAB:singularMatrix');
        warning('on', 'MATLAB:nearlySingularMatrix');


        if numberNeighbors == 1
            eps_xx(n) = NaN;
            eps_yy(n) = NaN;
            eps_xy(n) = NaN;
            omg_xy(n) = NaN;
        end
    else
        eps_xx(n) = NaN;
        eps_yy(n) = NaN;
        eps_xy(n) = NaN;
        omg_xy(n) = NaN;
    end
end

strainmapping.eps_xxP = eps_xx;
strainmapping.eps_yyP = eps_yy;
strainmapping.eps_xyP = eps_xy;
strainmapping.omg_xyP = omg_xy;



end