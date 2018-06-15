function obj = shiftAtomCentre(obj)
% shiftAtomCentre - measure shift of central atom with respect to the 
%                   centre of a unit cell
%
% syntax: obj = shiftAtomCentre(obj)
%   obj - strainMapping file
%
% Atoms should be indexed, run makeDisplacementMap first
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check if central atom is present in unit cell
coorU = obj.projUnit.coor2D;
ind = coorU(:,1)==0.5 & coorU(:,2)==0.5;
N = length(coorU(:,1));
if sum(ind)~=1 && N<2
    if N<2
        obj.message = 'Shift central atom cannot be calculated, only 1 atom type present in unit cell';
    elseif sum(ind)==0
        obj.message = 'Shift central atom cannot be calculated, not central atom present in unit cell';
    else
        obj.message = 'Shift central atom cannot be calculated, multiple central atoms present in unit cell';
    end
    h_err = errordlg(obj.message);
    waitfor(h_err)
    return
end
typeC = find(ind);

% Use coordinate closest to (0,0)
dist = (coorU(:,1)).^2+coorU(:,2).^2;
if min(dist)~=0
    obj.message = 'Shift central atom cannot be calculated, no coordinates at (0,0) present in unit cell';
    h_err = errordlg(obj.message);
    waitfor(h_err)
    return
end
ind = find(dist==min(dist));
type = mod(ind(1),N);
if type==0
    type = N;
end

% Find for each central coordinate the expected position and calculate the shift
nAt = length(obj.coordinates(:,1));
indT00 = obj.typesN==type;
coorT00 = obj.coordinates(indT00,1:2);
indT00 = obj.indices(indT00,1:2);
shiftCAtom = zeros(nAt,2);
for i=1:nAt
    if obj.typesN(i,1)==typeC
        indI = obj.indices(i,1:2);
        % Find surrounding coordinates
        indInt00 = indT00(:,1)==indI(1) & indT00(:,2)==indI(2);
        indInt10 = indT00(:,1)==(indI(1)+1) & indT00(:,2)==indI(2);
        indInt01 = indT00(:,1)==indI(1) & indT00(:,2)==(indI(2)+1);
        indInt11 = indT00(:,1)==(indI(1)+1) & indT00(:,2)==(indI(2)+1);
        % Only find expected coordinate if 4 surrounding coordinates are
        % present
        coorSur = zeros(4,2);
        if sum(indInt00)==1 && sum(indInt10)==1 && sum(indInt01)==1 && sum(indInt11)==1
            coorSur(1,:) = coorT00(indInt00,:);
            coorSur(2,:) = coorT00(indInt10,:);
            coorSur(3,:) = coorT00(indInt01,:);
            coorSur(4,:) = coorT00(indInt11,:);
            
            % Store mean value
            shiftCAtom(i,:) = obj.coordinates(i,1:2)-mean(coorSur,1);
        end
    end
end
obj.shiftCenAtomP = shiftCAtom;

