function strainmapping = STEMstrain_ab(strainmapping)
% STEMstrain - determine the strain from coordinates
%
%   syntax: strainmapping = STEMstrain(strainmapping)
%       strainmapping  - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2025, EMAT, University of Antwerp
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
LattPar = [(R*[a;0])';(R*Rab*[b;0])'];  % LattPar vectors on rows

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
eps_aa = zeros(n1,2);
eps_ab = zeros(n1,2);
eps_bb = zeros(n1,2);
omg_ab = zeros(n1,2);


% Define the rotation angles and tranformation to a-b
% teta: angle between a-direction and global x-axis
% teta_ab: angle between a and b lattice vectors

R = [cos(teta) -sin(teta);sin(teta) cos(teta)];
Rab = [cos(dirTeta_ab*teta_ab) -sin(dirTeta_ab*teta_ab);sin(dirTeta_ab*teta_ab) cos(dirTeta_ab*teta_ab)];

T = [(R*[1;0])';(R*Rab*[1;0])']'; % a and b vectors on columns


for n=1:n1  % loop over all atoms

    if types(n,1)~=0
        % Find indices of neighbors
        r_cutoff = 1.1*max([a b]);  % Set radius based on lattice spacing
        distances = vecnorm(coorExp - coorExp(n,:), 2, 2);  % Euclidean distances
        neighbors = find(distances < r_cutoff);
        neighbors(neighbors == n) = [];  % remove self

        numberNeighbors = length(neighbors);

        ref_disp = coorExp(neighbors,:) - coorExp(n,:);
        def_disp = coordinates(neighbors,1:2) - coordinates(n,1:2);

        % Store the current warning state
        warning('error', 'MATLAB:singularMatrix');
        warning('error', 'MATLAB:nearlySingularMatrix');
        warning('error', 'MATLAB:rankDeficientMatrix')

        try
            % Suppress the specific warning
            warning('off', 'MATLAB:singularMatrix');
            warning('off', 'MATLAB:nearlySingularMatrix');
            warning('off', 'MATLAB:rankDeficientMatrix')

            % Project displacements into lattice basis
            ref_disp_ab = ref_disp / T';
            def_disp_ab = def_disp / T';


            % Compute F in a/b space
            F_ab = ref_disp_ab \ def_disp_ab;

            % Compute strain tensors
            % Strain_ab = 0.5 * (F_ab' * F_ab - eye(2)); % valid for very large deformations: GreenLagrangeStrain
            Strain_ab = 0.5 * (F_ab + F_ab') - eye(2); % Cauchy strain
            eps_aa(n) = Strain_ab(1,1);
            eps_bb(n) = Strain_ab(2,2);
            eps_ab(n) = Strain_ab(2,1);

            % Compute the rotation component (antisymmetric part of F)
            R = 0.5 * (F_ab - F_ab');  % Rotation tensor
            omg_ab(n) = R(1,2);
            % omg_ab(n) = rad2deg(omg_ab(n));     % if needed in degrees

        catch ME
            % Check if the error is related to a (nearly) singular matrix
            if strcmp(ME.identifier, 'MATLAB:singularMatrix') || strcmp(ME.identifier, 'MATLAB:nearlySingularMatrix') || strcmp(ME.identifier, 'MATLAB:rankDeficientMatrix')
                eps_aa(n) = NaN;
                eps_bb(n) = NaN;
                eps_ab(n) = NaN;
                omg_ab(n) = NaN;
            else
                % Re-throw the error if it's not related to a singular matrix
                rethrow(ME);
            end
        end
        % Re-enable the warning
        warning('on', 'MATLAB:singularMatrix');
        warning('on', 'MATLAB:nearlySingularMatrix');
        warning('on', 'MATLAB:rankDeficientMatrix')


        if numberNeighbors == 1
            eps_aa(n) = NaN;
            eps_bb(n) = NaN;
            eps_ab(n) = NaN;
            omg_ab(n) = NaN;
        end

    end

end
strainmapping.eps_aaP = eps_aa;
strainmapping.eps_bbP = eps_bb;
strainmapping.eps_abP = eps_ab;
strainmapping.omg_abP = omg_ab;