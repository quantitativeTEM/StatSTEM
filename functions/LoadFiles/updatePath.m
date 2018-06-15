function updatePath(PathName)
% updatePath - function to update default path
%
% syntax: updatePath(PathName)
%       PathName - New default path

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

fid = fopen( startPathLoc, 'wt' );
fprintf( fid, '%s', PathName);
fclose(fid);