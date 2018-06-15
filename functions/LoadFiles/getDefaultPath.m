function PathName = getDefaultPath()
% getDefaultPath - function to load txt file containing default path
%
% syntax: PathName = getDefaultPath()
%       PathName - Default path

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

p = mfilename('fullpath');
loc = strfind(p,filesep);
p = p(1:loc(end-1));
% Check default path
startPathLoc = [p,filesep,'startPath.txt'];
if exist(startPathLoc, 'file')==0
    if ispc
        PathName = getenv('USERPROFILE'); 
    else
        PathName = getenv('HOME');
    end
    fid = fopen( startPathLoc, 'wt' );
    fprintf( fid, '%s', PathName);
    fclose(fid);
else
    fid = fopen(startPathLoc);
    PathName = textscan(fid, '%s', 'delimiter', '\n');
    PathName = PathName{1}{1};
    fclose(fid);
end

