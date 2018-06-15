function strainmapping = findLatDir(strainmapping)
% findLatDir - Make sure that the lattice directions are found
%
%   syntax: strainmapping = findLatDir(strainmapping)
%       strainmapping - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Determine which option is selected (automatic or manual) and find direction of the a-lattice parameter
switch strainmapping.findDirA
    case 0 % Automatic
        [strainmapping.tetaP,strainmapping.dirTetaP] = guessAngleAdir(strainmapping);
    case 1 % Manual
        %% Select coordinate manually
        % Show image if not shown
        if isempty(strainmapping.GUI)
            plotCoordinates(strainmapping)
            plotRefCoor(strainmapping)
        end
        % Select axis
        ax = gca;
        axis(ax);
        hold on;
        % Ask user to give an indication of the a-directions
        title(ax,'Select coordinate in a-direction with respect to reference coordinate, press ESC to exit')
        [x,y] = ginput_AxInFig();
        % Update userdata
        title(ax,'')
        
        if isempty(x) % No coordinate selected, return without updating anything
            return
        end

        % Select coordinates
        coordinates = strainmapping.coordinates;
        ref = strainmapping.refCoor;
        dist = sqrt( (coordinates(:,1)-ref(1,1) ).^2 + (coordinates(:,2)-ref(1,2) ).^2 );
        indRef = find(dist==min(dist));
        type = coordinates(indRef(1),3);
        indT = strainmapping.coordinates(:,3)==type;
        coorT = coordinates(indT,1:2);
        
        % Find lattice direction
        distance = (coorT(:,1)-x).^2+(coorT(:,2)-y).^2;
        indM = find(distance==min(distance));
        coor_int = coorT(indM(1),:);
        aDir = coor_int-strainmapping.refCoor(1,1:2);
        strainmapping.tetaP = atan2(aDir(2),aDir(1));
        strainmapping.dirTetaP = guessDirAngleB(strainmapping,aDir,0);
end

%% Find values of teta, a and b (and improve by fitting if wanted)
strainmapping = getTetaAB(strainmapping);

% Remove previous found results
strainmapping.coorExpectedP = [];
strainmapping.latticeAP = [];
strainmapping.latticeBP = [];
strainmapping.eps_xxP = [];
strainmapping.eps_yyP = [];
strainmapping.eps_xyP = [];
strainmapping.omg_xyP = [];
strainmapping.shiftCenAtomP = [];
strainmapping.octahedralTiltP = [];