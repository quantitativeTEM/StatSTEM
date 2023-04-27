classdef strainMapping < StatSTEMfile
% strainMapping - class to do strain mapping
%
%   Advanced analysis options are defined for this class based on the
%   coordinates of column locations
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
    
    properties
        projUnit = []; % projUnit structure with projected unit cell parametersproperties
        refCoor = []; % Reference coordinate
        findDirA = 0; % Routine to find a-direction: 0-automatic, 1-user defined 
        impByFit = true; % Option to improve found a-direction by fitting (logical)
        nUC = 3; % Number of unit cells used to improve a,b-direction and angle by fitting
        fitABang = 0; % Indicate what should be improved by fitting: 0-angle and a,b-direction, 1-only the angle
        minSpace = 0; % Distance that may be used to find closest coordinate (0 or empty means, determine from projected unit cell dimensions)
        fUpdate = 0.1; % Update factor for indexing routine to improve lattice parameters (see StatSTEM manual appendix B) (between 0 and 1)
    end
    
    properties (Dependent)
        space % Distance to find closest values in routines
        
        % Run findLatDir to get values
        teta = []; % Angle of a-lattice 
        errTeta = []; % Error in angle measurement (95% confidence interval)
        dirTeta = []; % Positive or negative value indication that angle between a and b-direction is measured in clockwise or anti-clockwise direction
        a = []; % Lattice parameter a in image
        errA = []; % Error on lattice parameter a (95% confidence interval)
        b = []; % Lattice parameter b in image
        errB = []; % Error on lattice parameter b (95% confidence interval)
        aDir = []; % Lattice parameter in a-direction [x,y]
        bDir = []; % Lattice parameter in b-direction [x,y]
        
        % Run indexColumns to get values
        typesN = []; % Types with respect to found indices
        indices = []; % Indices in a- and b-direction with respect to reference coordinate
        
        % Run makeDisplacementMap to get values
        coorExpected = []; % A (n*2)-vector with the relaxed x- and y-coordinates
        
        % Run STEMstrain to get values
        eps_xx % Strain in x-direction
        eps_yy % Strain in y-direction
        eps_xy % Shear strain
        omg_xy % Rotational strain

        % Run STEMstrain_ab to get values
        eps_aa % Strain in x-direction
        eps_bb % Strain in y-direction
        eps_ab % Shear strain
        omg_ab % Rotational strain
        
        % Run measureLatPar to get values
        latticeA = [];% A (n*2) vector with the lattice parameter of the a-direction per coordinate
        latticeB = [];% A (n*2) vector with the lattice parameter of the b-direction per coordinate
        meanLatA_dirA = []; % A (n*(3*types)) vector with the mean lattice parameter a in the a-direction per column type [distance,a type1,error,distance,a type 2,error,...,distance,a type N,error]
        meanLatA_dirB = []; % A (n*(3*types)) vector with the mean lattice parameter a in the b-direction per column type [distance,b type1,error,distance,b type 2,error,...,distance,b type N,error]
        meanLatB_dirA = []; % A (n*(3*types)) vector with the mean lattice parameter b in the a-direction per column type [distance,a type1,error,distance,a type 2,error,...,distance,a type N,error]
        meanLatB_dirB = []; % A (n*(3*types)) vector with the mean lattice parameter b in the b-direction per column type [distance,b type1,error,distance,b type 2,error,...,distance,b type N,error]
        
        % Run shiftAtomCentre to get values
        shiftCenAtom = []; % A (n*2) vector with the shift of the central atoms from the central position in the unit cell
        
        suitOctaTilt = []; % Value indicating whether octahedral tilt can be calculated
        % Run calcOctahedralTilt to get values
        octahedralTilt = []; % A (n*3) vector with the angle in degrees per unit cell ([distance a-dir,distance b-dir,angle])
        meanOctaTilt_dirA = []; % A (n*3) vector with the mean octahedral tilt in degrees in the a-direction [distance,angle,error]
        meanOctaTilt_dirB = []; % A (n*3) vector with the mean octahedral tilt in degrees in the b-direction [distance,angle,error]
    end
    
    properties (SetAccess=public, Hidden) % Private variables to store values after calculations by specific functions
        % Run findLatDir to get values
        tetaP = [];
        errTetaP = [];
        dirTetaP = [];
        aP = [];
        errAP = [];
        bP = [];
        errBP = [];
        
        % Run indexColumns to get values
        typesNP = [];
        indicesP = [];
        
        % Run makeDisplacementMap to get values
        coorExpectedP = [];
        
        % Run STEMstrain to get values
        eps_xxP = [];
        eps_yyP = [];
        eps_xyP = [];
        omg_xyP = [];

        % Run STEMstrain_ab to get values
        eps_aaP = [];
        eps_bbP = [];
        eps_abP = [];
        omg_abP = [];
        
        % Run measureLatPar to get values
        latticeAP = [];
        latticeBP = [];
        
        % Run shiftAtomCentre to get values
        shiftCenAtomP = [];
        
        % Run calcOctahedralTilt to get values
        octahedralTiltP = []; % A (n*3) vector with the angle in degrees per unit cell ([distance a-dir,distance b-dir,angle])
    end
    
    methods
        obj = calcOctahedralTilt(obj)
        strainmapping = findLatDir(strainmapping)
        strainmapping = getTetaAB(strainmapping)
        [angle,dirAngle] = guessAngleAdir(strainmapping)
        [dirAngle,aDir] = guessDirAngleB(strainmapping,aDir,distA)
        strainmapping = indexColumns(strainmapping)
        strainmapping = makeDisplacementMap(strainmapping)
        makeLatticeFig(obj,type,lwidth)
        obj = measureLatPar(obj)
        plotCoordinates(obj)
        plotIndexedCoordinates(obj)
        plotRefCoor(obj)
        obj = shiftAtomCentre(obj)
        showABlattice(obj)
        showDisplacementMap(obj)
        showMeanLatticeA_dirA(obj)
        showMeanLatticeA_dirB(obj)
        showMeanLatticeB_dirA(obj)
        showMeanLatticeB_dirB(obj)
        showMeanOctaTilt_dirA(obj)
        showMeanOctaTilt_dirB(obj)
        showShiftCenAtom(obj)
        showStrainEpsXX(obj)
        showStrainEpsXY(obj)
        showStrainEpsYY(obj)
        showStrainOmgXY(obj)
        showStrainEpsAA(obj)
        showStrainEpsAB(obj)
        showStrainEpsBB(obj)
        showStrainOmgAB(obj)
        strainmapping = STEMrefPar(strainmapping)
        strainmapping = STEMstrain(strainmapping)
        strainmapping = STEMstrain_ab(strainmapping)
    end
    
    methods
        function obj = strainMapping(coordinates,dx,projUnit,refCoor,Name,Value,varargin)
            obj.coordinates = coordinates;
            obj.dx = dx;
            obj.projUnit = projUnit;
            obj.refCoor = refCoor;
            if nargin>7
                varargin = [{Name},{Value},varargin];
            end
            if ~isempty(varargin)
                N = length(varargin);
                for n=1:2:N-1
                    obj.(varargin{n}) = varargin{n+1};
                end
            end
        end
        
        function val = get.space(obj)
            % Get space value
            if ~isempty(obj.minSpace) && obj.minSpace>0
                val = obj.minSpace;
            elseif ~isempty(obj.projUnit)
                val = min([obj.projUnit.a/4,obj.projUnit.b/4]);
            else
                val = [];
            end
        end
        
        function obj = set.fUpdate(obj,val)
            if val<0
                val = 0;
            elseif val>1
                val = 1;
            end
            obj.fUpdate = val;
        end
        
        function val = get.teta(obj)
            val = obj.tetaP;
        end
        
        function val = get.errTeta(obj)
            val = obj.errTetaP;
        end
        
        function val = get.dirTeta(obj)
            val = obj.dirTetaP;
        end
        
        function val = get.a(obj)
            val = obj.aP;
        end
        
        function val = get.errA(obj)
            val = obj.errAP;
        end
        
        function val = get.b(obj)
            val = obj.bP;
        end
        
        function val = get.errB(obj)
            val = obj.errBP;
        end
        
        function val = get.coorExpected(obj)
            val = obj.coorExpectedP;
        end
        
        function val = get.typesN(obj)
            val = obj.typesNP;
        end
        
        function val = get.indices(obj)
            val = obj.indicesP;
        end
        
        function val = get.eps_xx(obj)
            val = obj.eps_xxP;
        end
        
        function val = get.eps_xy(obj)
            val = obj.eps_xyP;
        end
        
        function val = get.eps_yy(obj)
            val = obj.eps_yyP;
        end
        
        function val = get.omg_xy(obj)
            val = obj.omg_xyP;
        end

        function val = get.eps_aa(obj)
            val = obj.eps_aaP;
        end
        
        function val = get.eps_ab(obj)
            val = obj.eps_abP;
        end
        
        function val = get.eps_bb(obj)
            val = obj.eps_bbP;
        end
        
        function val = get.omg_ab(obj)
            val = obj.omg_abP;
        end
        
        function val = get.latticeA(obj)
            val = obj.latticeAP;
        end
        
        function val = get.latticeB(obj)
            val = obj.latticeBP;
        end
        
        function val = get.shiftCenAtom(obj)
            val = obj.shiftCenAtomP;
        end
        
        function obj = setTeta(obj,teta,dirTeta)
            % Function to load old teta values
            obj.tetaP = teta(1);
            obj.errTetaP = teta(2);
            obj.dirTetaP = dirTeta;
        end
        
        function obj = setAB(obj,a,b)
            % Function to load old a and b parameters
            obj.aP = a(1);
            obj.errAP = a(2);
            obj.bP = b(1);
            obj.errBP = b(2);
        end
        
        function obj = setCoorRelTypeInd(obj,coorRel,types,indices)
            % Function to load old parameters
            obj.coorExpectedP = coorRel;
            obj.typesNP = types;
            obj.indicesP = indices;
        end
        
        function obj = setEps(obj,epsXX,errEpsXX,epsXY,errEpsXY,epsYY,errEpsYY,omgXY,errOmgXY)
            % Function to load old parameters
            obj.eps_xxP = [epsXX,errEpsXX];
            obj.eps_xyP = [epsXY,errEpsXY];
            obj.eps_yyP = [epsYY,errEpsYY];
            obj.omg_xyP = [omgXY,errOmgXY];
        end

        function obj = setEps_ab(obj,epsAA,errEpsAA,epsAB,errEpsAB,epsBB,errEpsBB,omgAB,errOmgAB)
            % Function to load old parameters
            obj.eps_aaP = [epsAA,errEpsAA];
            obj.eps_abP = [epsAB,errEpsAB];
            obj.eps_bbP = [epsBB,errEpsBB];
            obj.omg_abP = [omgAB,errOmgAB];
        end
        
        function val = get.suitOctaTilt(obj)
            % Determine whether it is possible to calculate the octahedral
            % tilt
            coorUC = obj.projUnit.coor2D;
            if isempty(obj.indices) || isempty(coorUC) || ~ (any( coorUC(:,1)==0 & coorUC(:,2)==0.5 ) || any( coorUC(:,1)==0.5 & coorUC(:,2)==0 ) )
                val = [];
            else
                val = true;
            end
        end
        
        function val = get.meanLatA_dirA(obj)
            % Calculate the mean lattice parameter a in the a-direction per
            % column type
            if isempty(obj.latticeA)
                val = [];
                return
            end
            maxT = max(obj.typesN);
            minInd = min(obj.indices(:,1));
            maxInd = max(obj.indices(:,1));
            indVec = minInd:maxInd;
            maxI = maxInd-minInd+1;
            val = zeros(maxI,maxT*3);
            for i=1:maxT
                posInUC = obj.projUnit.coor2D(i,1);
                for j=1:maxI
                    val(j,3*i-2) = (indVec(j)+posInUC);
                    indInt = obj.indices(:,1)==indVec(j) & obj.typesN==i & obj.latticeA(:,1)~=0;
                    if sum(indInt)>0
                        aInt = sqrt(obj.latticeA(indInt,1).^2 + obj.latticeA(indInt,2).^2);
                        val(j,3*i-1) = mean(aInt);
                        val(j,3*i) = std(aInt)/sqrt(sum(indInt));
                    else
                        val(j,3*i-1) = NaN;
                        val(j,3*i) = NaN;
                    end
                end
            end
        end
        
        function val = get.meanLatA_dirB(obj)
            % Calculate the mean lattice parameter a in the b-direction per
            % column type
            if isempty(obj.latticeA)
                val = [];
                return
            end
            maxT = max(obj.typesN);
            minInd = min(obj.indices(:,2));
            maxInd = max(obj.indices(:,2));
            indVec = minInd:maxInd;
            maxI = maxInd-minInd+1;
            val = zeros(maxI,maxT*3);
            for i=1:maxT
                posInUC = obj.projUnit.coor2D(i,1);
                for j=1:maxI
                    val(j,3*i-2) = (indVec(j)+posInUC)*-obj.dirTeta;
                    indInt = obj.indices(:,2)==indVec(j) & obj.typesN==i & obj.latticeA(:,1)~=0;
                    if sum(indInt)>0
                        aInt = sqrt(obj.latticeA(indInt,1).^2 + obj.latticeA(indInt,2).^2);
                        val(j,3*i-1) = mean(aInt);
                        val(j,3*i) = std(aInt)/sqrt(sum(indInt));
                    else
                        val(j,3*i-1) = NaN;
                        val(j,3*i) = NaN;
                    end
                end
            end
        end
        
        function val = get.meanLatB_dirA(obj)
            % Calculate the mean lattice parameter b in the a-direction per
            % column type
            if isempty(obj.latticeB)
                val = [];
                return
            end
            maxT = max(obj.typesN);
            minInd = min(obj.indices(:,1));
            maxInd = max(obj.indices(:,1));
            indVec = minInd:maxInd;
            maxI = maxInd-minInd+1;
            val = zeros(maxI,maxT*3);
            for i=1:maxT
                posInUC = obj.projUnit.coor2D(i,1);
                for j=1:maxI
                    val(j,3*i-2) = (indVec(j)+posInUC);
                    indInt = obj.indices(:,1)==indVec(j) & obj.typesN==i & obj.latticeB(:,1)~=0;
                    if sum(indInt)>0
                        bInt = sqrt(obj.latticeB(indInt,1).^2 + obj.latticeB(indInt,2).^2);
                        val(j,3*i-1) = mean(bInt);
                        val(j,3*i) = std(bInt)/sqrt(sum(indInt));
                    else
                        val(j,3*i-1) = NaN;
                        val(j,3*i) = NaN;
                    end
                end
            end
        end
        
        function val = get.meanLatB_dirB(obj)
            % Calculate the mean lattice parameter b in the b-direction per
            % column type
            if isempty(obj.latticeB)
                val = [];
                return
            end
            maxT = max(obj.typesN);
            minInd = min(obj.indices(:,2));
            maxInd = max(obj.indices(:,2));
            indVec = minInd:maxInd;
            maxI = maxInd-minInd+1;
            val = zeros(maxI,maxT*3);
            for i=1:maxT
                posInUC = obj.projUnit.coor2D(i,1);
                for j=1:maxI
                    val(j,3*i-2) = (indVec(j)+posInUC)*-obj.dirTeta;
                    indInt = obj.indices(:,2)==indVec(j) & obj.typesN==i & obj.latticeB(:,1)~=0;
                    if sum(indInt)>0
                        bInt = sqrt(obj.latticeB(indInt,1).^2 + obj.latticeB(indInt,2).^2);
                        val(j,3*i-1) = mean(bInt);
                        val(j,3*i) = std(bInt)/sqrt(sum(indInt));
                    else
                        val(j,3*i-1) = NaN;
                        val(j,3*i) = NaN;
                    end
                end
            end
        end
        
        function val = get.aDir(obj)
            if isempty(obj.a)
                val = [];
                return
            end
            % Get lattice parameter in a-direction
            ang = obj.teta(1);
            
            % Create rotation matrix to determine direction
            R = [cos(ang) -sin(ang);sin(ang) cos(ang)];
            val = (R*[obj.a(1);0])';
        end
        
        function val = get.bDir(obj)
            if isempty(obj.b)
                val = [];
                return
            end
            % Get lattice parameter in b-direction
            unit = obj.projUnit;
            ang = obj.teta(1);
            dirTeta_ab = obj.dirTeta;
            
            % Crystal parameters
            teta_ab = unit.ang;
            Rab = [cos(dirTeta_ab*teta_ab) -sin(dirTeta_ab*teta_ab);sin(dirTeta_ab*teta_ab) cos(dirTeta_ab*teta_ab)];
            % Create rotation matrix to expand unit cell
            R = [cos(ang) -sin(ang);sin(ang) cos(ang)];
            val = (R*Rab*[obj.b(1);0])';
        end
        
        function val = get.octahedralTilt(obj)
            val = obj.octahedralTiltP;
        end
        
        function val = get.meanOctaTilt_dirA(obj)
            % Calculate the mean octahedral tilt in the a-direction
            if isempty(obj.octahedralTilt)
                val = [];
                return
            end
            minInd = min(obj.octahedralTilt(:,1));
            maxInd = max(obj.octahedralTilt(:,1));
            indVec = minInd:maxInd;
            maxI = maxInd-minInd+1;
            val = zeros(maxI,3);
            for j=1:maxI
                val(j,1) = indVec(j);
                indInt = obj.octahedralTilt(:,1)==indVec(j) & ~isnan(obj.octahedralTilt(:,3));
                if sum(indInt)>0
                    oInt = obj.octahedralTilt(indInt,3);
                    val(j,2) = mean(oInt);
                    val(j,3) = std(oInt)/sqrt(sum(indInt));
                else
                    val(j,2) = NaN;
                    val(j,3) = NaN;
                end
            end
        end
        
        function val = get.meanOctaTilt_dirB(obj)
            % Calculate the mean octahedral tilt in the b-direction
            if isempty(obj.octahedralTilt)
                val = [];
                return
            end
            minInd = min(obj.octahedralTilt(:,2));
            maxInd = max(obj.octahedralTilt(:,2));
            indVec = minInd:maxInd;
            maxI = maxInd-minInd+1;
            val = zeros(maxI,3);
            for j=1:maxI
                val(j,1) = indVec(j)*-obj.dirTeta;
                indInt = obj.octahedralTilt(:,2)==indVec(j) & ~isnan(obj.octahedralTilt(:,3));
                if sum(indInt)>0
                    oInt = obj.octahedralTilt(indInt,3);
                    val(j,2) = mean(oInt);
                    val(j,3) = std(oInt)/sqrt(sum(indInt));
                else
                    val(j,2) = NaN;
                    val(j,3) = NaN;
                end
            end
        end
    end
end
