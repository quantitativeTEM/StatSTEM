function export3Dcoor(obj,FileName)
% export3Dcoor - export the 3D coordinates as a text file
%
% The fraction specified in pForCoor is only saved
%
% syntax: export3Dcoor(obj,FileName)
%   obj      - mod3D file
%   FileName - filename used to store variable
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Ask user where to 
p = mfilename('fullpath');
loc = strfind(p,filesep);
p = p(1:loc(end-1));
addpath([p,filesep,'LoadFiles']);
if nargin<2
    % Check default path
    PathName = getDefaultPath();
    % Let the user select an input file
    supFiles = {'*.xyz','XYZ File (*.xyz)'};
    [FileName,PathName] = uiputfile(supFiles,'Store as xyz file',PathName);
    if FileName==0
        return
    end
    updatePath(PathName)
    FileName = [PathName,filesep,FileName];
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
coor3D = [obj.coordinates(index,1),obj.coordinates(index,2),obj.z(index,1)];
types = obj.types(index);

% save as xyz file
N = length(coor3D(:,1));
fID = fopen(FileName,'w');
fprintf(fID,sprintf([num2str(N),'\n\n']));
for n=1:N
    line = [types{n},'\t',num2str(coor3D(n,1)),'\t',num2str(coor3D(n,2)),'\t',num2str(coor3D(n,3)),'\n'];
    fprintf(fID,sprintf(line));
    if ~isempty(obj.GUI)
        obj.waitbar.setValue(n/N*100)
        % For aborting function
        drawnow
        if get(obj.GUI,'Userdata')==0
            fclose(fID);
            error('Saving 3D model as xyz file cancelled')
        end
    end
end
fclose(fID);
        