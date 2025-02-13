function out = possibleImagesStatSTEM()
% possibleImagesStatSTEM - This file contains a list with possible images
%                          that can be shown in StatSTEM
%
%   syntax: out = possibleImagesStatSTEM()
%       out - structure with figure options
%
% see also: listImagesStatSTEM

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, Annick De Backer
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Option1: Observation
out.option1 = listImagesStatSTEM('Observation','showObservation','input.obs');
out.option1 = addFigOpt(out.option1,'Input coordinates','plotCoordinates','input.coordinates',true); % Show this option by default
out.option1 = addFigOpt(out.option1,'Fitted coordinates','plotFitCoordinates','output.coordinates');
out.option1 = addFigOpt(out.option1,'Coor analysis','plotSelCoordinates','output.selCoor');
out.option1 = addFigOpt(out.option1,'Indexed coordinates','plotIndexedCoordinates','strainmapping.indices');
out.option1 = addFigOpt(out.option1,'Atom Counts','plotAtomCounts','atomcounting.Counts');
out.option1 = addFigOpt(out.option1,'Lib Counts','plotAtomCounts','libcounting.Counts');
out.option1 = addFigOpt(out.option1,'Ref strainmapping','plotRefCoor','strainmapping.refCoor');
out.option1 = addFigOpt(out.option1,'a & b lattice','showABlattice','strainmapping.a');
out.option1 = addFigOpt(out.option1,'Displacement map','showDisplacementMap','strainmapping.coorExpected');
out.option1 = addFigOpt(out.option1,'Octahedral tilt','showOctahedralTilt','strainmapping.octahedralTilt');
out.option1 = addFigOpt(out.option1,'Shift central atom','showShiftCenAtom','strainmapping.shiftCenAtom');
out.option1 = addFigOpt(out.option1,'Lattice','makeLatticeFig','strainmapping.latticeA');
out.option1 = addFigOpt(out.option1,[char(949),'_xx'],'showStrainEpsXX','strainmapping.eps_xx');
out.option1 = addFigOpt(out.option1,[char(949),'_xy'],'showStrainEpsXY','strainmapping.eps_xy');
out.option1 = addFigOpt(out.option1,[char(949),'_yy'],'showStrainEpsYY','strainmapping.eps_yy');
out.option1 = addFigOpt(out.option1,[char(969),'_xy'],'showStrainOmgXY','strainmapping.omg_xy');
out.option1 = addFigOpt(out.option1,[char(949),'_aa'],'showStrainEpsAA','strainmapping.eps_aa');
out.option1 = addFigOpt(out.option1,[char(949),'_ab'],'showStrainEpsAB','strainmapping.eps_ab');
out.option1 = addFigOpt(out.option1,[char(949),'_bb'],'showStrainEpsBB','strainmapping.eps_bb');
out.option1 = addFigOpt(out.option1,[char(969),'_ab'],'showStrainOmgAB','strainmapping.omg_ab');

% Option1b: Observation Time Series
out.option1b = listImagesStatSTEM('Observations Time Series','showObservation_T','inputHMM.obs_T');
out.option1b = addFigOpt(out.option1b,'Coordinates Time Series','plotCoordinates_T','outputHMM.coordinates_T',true); % Show this option by default
out.option1b = addFigOpt(out.option1b,'Atom Counts Time Series','plotAtomCounts_T','outputHMM.H_viterbi');

% Option2: Model
out.option2 = listImagesStatSTEM('Model','showModel','output.model','input');
out.option2 = addFigOpt(out.option2,'Input coordinates','plotCoordinates','input.coordinates');
out.option2 = addFigOpt(out.option2,'Fitted coordinates','plotFitCoordinates','output.coordinates',true); % Show this option by default
out.option2 = addFigOpt(out.option2,'Coor analysis','plotSelCoordinates','output.selCoor');
out.option2 = addFigOpt(out.option2,'Indexed coordinates','plotIndexedCoordinates','strainmapping.indices');
out.option2 = addFigOpt(out.option2,'Atom Counts','plotAtomCounts','atomcounting.Counts');
out.option2 = addFigOpt(out.option2,'Lib Counts','plotAtomCounts','libcounting.Counts');
out.option2 = addFigOpt(out.option2,'Ref strainmapping','plotRefCoor','strainmapping.refCoor');
out.option2 = addFigOpt(out.option2,'a & b lattice','showABlattice','strainmapping.a');
out.option2 = addFigOpt(out.option2,'Displacement map','showDisplacementMap','strainmapping.coorExpected');
out.option2 = addFigOpt(out.option2,'Octahedral tilt','showOctahedralTilt','strainmapping.octahedralTilt');
out.option2 = addFigOpt(out.option2,'Shift central atom','showShiftCenAtom','strainmapping.shiftCenAtom');
out.option2 = addFigOpt(out.option2,'Lattice','makeLatticeFig','strainmapping.latticeA');
out.option2 = addFigOpt(out.option2,[char(949),'_xx'],'showStrainEpsXX','strainmapping.eps_xx');
out.option2 = addFigOpt(out.option2,[char(949),'_xy'],'showStrainEpsXY','strainmapping.eps_xy');
out.option2 = addFigOpt(out.option2,[char(949),'_yy'],'showStrainEpsYY','strainmapping.eps_yy');
out.option2 = addFigOpt(out.option2,[char(969),'_xy'],'showStrainOmgXY','strainmapping.omg_xy');
out.option2 = addFigOpt(out.option2,[char(949),'_aa'],'showStrainEpsAA','strainmapping.eps_aa');
out.option2 = addFigOpt(out.option2,[char(949),'_ab'],'showStrainEpsAB','strainmapping.eps_ab');
out.option2 = addFigOpt(out.option2,[char(949),'_bb'],'showStrainEpsBB','strainmapping.eps_bb');
out.option2 = addFigOpt(out.option2,[char(969),'_ab'],'showStrainOmgAB','strainmapping.omg_ab');

% Option2b: Model Time Series
out.option2b = listImagesStatSTEM('Models Time Series','showModel_T','inputHMM.model_T');
out.option2b = addFigOpt(out.option2b,'Coordinates Time Series','plotCoordinates_T','outputHMM.coordinates_T',true); % Show this option by default
out.option2b = addFigOpt(out.option2b,'Atom Counts Time Series','plotAtomCounts_T','outputHMM.H_viterbi');

% Option3: Histogram SCS
out.option3 = listImagesStatSTEM('Histogram SCS','showHistogramSCS','output.volumes');
out.option3 = addFigOpt(out.option3,'GMM components','plotGMMcomp','atomcounting.selMin',true);
out.option3 = addFigOpt(out.option3,'GMM','plotGMM','atomcounting.selMin',true);

% Option4: ICL
out.option4 = listImagesStatSTEM('ICL','showICL','atomcounting');
out.option4 = addFigOpt(out.option4,'Minimum ICL','plotMinICL','atomcounting.selMin',true);

% Option5: SCS vs thickness
out.option5 = listImagesStatSTEM('SCS vs. Thickness','showThickSI','atomcounting');
out.option5 = addFigOpt(out.option5,'Library','plotLib','libcounting.library',true);

% Option6: Mean lattice parameter
out.option6 = listImagesStatSTEM('Mean lattice a in a-dir','showMeanLatticeA_dirA','strainmapping.meanLatA_dirA');

% Option7: Mean lattice parameter
out.option7 = listImagesStatSTEM('Mean lattice a in b-dir','showMeanLatticeA_dirB','strainmapping.meanLatA_dirB');

% Option8: Mean lattice parameter
out.option8 = listImagesStatSTEM('Mean lattice b in a-dir','showMeanLatticeB_dirA','strainmapping.meanLatB_dirA');

% Option9: Mean lattice parameter
out.option9 = listImagesStatSTEM('Mean lattice b in b-dir','showMeanLatticeB_dirB','strainmapping.meanLatB_dirB');

% Option10: Mean lattice parameter
out.option10 = listImagesStatSTEM('Mean octahedral tilt a-dir','showMeanOctaTilt_dirA','strainmapping.meanOctaTilt_dirA');

% Option11: Mean lattice parameter
out.option11 = listImagesStatSTEM('Mean octahedral tilt b-dir','showMeanOctaTilt_dirB','strainmapping.meanOctaTilt_dirB');

% Option12: 3D model
out.option12 = listImagesStatSTEM('3D model','createAxes','model3D');
out.option12 = addFigOpt(out.option12,'Color per type','showModel','model3D');
out.option12 = addFigOpt(out.option12,'Coordination number','showModelCoorNum','model3D.coorNum');

% Option13: MAP probability curve
out.option13 = listImagesStatSTEM('MAP probability','showMAPprob','outputMAP.MAPprob');
