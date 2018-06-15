function obj = getCoorNum(obj)
% getCoorNum - Determine the coordinate number of each atom
%
% syntax: obj = getCoorNum(obj)
%   obj - mod3D file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos & A. De Backer
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

obj.coorNumP = [];
if isempty(obj.coorNumPos)
    obj.message = 'Coordination number can only be shown if there is only one atom type present';
    warning(obj.message)
    return
end

% Determine center of structure
a = mean(obj.coordinates(:,1));
b = mean(obj.coordinates(:,2));
c = mean(obj.z(:,1));

% Select part of atoms
R  = (obj.coordinates(:,1)-a).^2 + (obj.coordinates(:,2)-b).^2 + (obj.z(:,1)-c).^2;
N = length(obj.coordinates(:,1));
Nsel = round(N*(100-obj.pForCoor)/100);
Nsel = min([N,Nsel]);
Nsel = max([1,Nsel]);
Rsort = sort(R);
r_ref = Rsort(Nsel);
index = R >= r_ref;
atoms = [obj.coordinates(:,1),obj.coordinates(:,2),obj.z(:,1)];
index = find(index);
N = length(index);

% Find surrounding coordinates
Nat = length(atoms(:,1));
if ~isempty(obj.GUI)
    obj.waitbar.setValue(0)
end
val = zeros(Nat,1);
for k=1:N
    i = index(k);
    x_i = atoms(i,1);
    y_i = atoms(i,2);
    z_i = atoms(i,3);
    R_i = (atoms(:,1)-x_i).^2 + (atoms(:,2)-y_i).^2 + (atoms(:,3)-z_i).^2;
    val(i,1) = sum(R_i < obj.rad^2)-1; 
    if ~isempty(obj.GUI)
        obj.waitbar.setValue(i/N*100)
        % For aborting function
        drawnow
        if get(obj.GUI,'Userdata')==0
            error('Calculation of coordination number is cancelled')
        end
    end
end
obj.coorNumP = val;