function export3DcoorNum(obj,FileName)
% export3DcoorNum - export the 3D coordinates as a xyz text file
%
%   The coordination number is saved as different atom types which have the
%   correct color in VMD. The fraction specified in pForCoor is only saved
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

if isempty(obj.coorNum)
    error('Coordination number not available')
end

% Ask user where to 
p = mfilename('fullpath');
loc = strfind(p,filesep);
pExplain = [p(1:loc(end)),'ExplanationTypesColors_CoordinationNumber.txt'];
p = p(1:loc(end-1));
addpath([p,'LoadFiles']);
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
else
    loc = strfind(FileName,filesep);
    PathName = FileName(1:loc(end));
end

% Select part of atoms
ind = obj.coorNum~=0;
coor3D = [obj.coordinates(ind,1:2),obj.z(ind,1)];
coorNum = obj.coorNum(ind,:);
N = sum(ind);
types = cell(N,1);
for i=1:13
    indI = coorNum==i;
    switch i
        case 1
            types(indI,1) = {'V'};
        case 2
            types(indI,1) = {'Mg'};
        case 3
            types(indI,1) = {'Au'};
        case 4
            types(indI,1) = {'Na'};
        case 5
            types(indI,1) = {'Se'};
        case 6
            types(indI,1) = {'Zr'};
        case 7
            types(indI,1) = {'Lu'};
        case 8
            types(indI,1) = {'Yb'};
        case 9
            types(indI,1) = {'Al'};
        case 10
            types(indI,1) = {'Np'};
        case 11
            types(indI,1) = {'Ho'};
        case 12
            types(indI,1) = {'Co'};
        otherwise
            indI = coorNum==0 | coorNum>12;
            if ~isempty(indI)
                types(indI,1) = {'Ag'};
            end
    end
end

% Copy explanation
pNExplain = [PathName,'ExplanationTypesColors_CoordinationNumber.txt'];
copyfile(pExplain,pNExplain);

% save as xyz file
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
        