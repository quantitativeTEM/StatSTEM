function panel = panelStrainMap()
% panelStrainMap - Create panel with buttons for strain mapping
%
%   syntax: panel = panelStrainMap()
%       panel - structure containing the necessary information to create a
%               panel with buttons in StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

panel = struct;

% Start by defining the name
panel.name = 'Strain and more';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Lattice of type:','width',100,...
    'func','measureLatPar','input','strainmapping.indices','output','strainmapping.latticeA',...
    'figEnd','Observation','figOptEnd',{'Lattice'},'reshowFigEnd',true);

panel.row(1).option2 = popupmenu('name','','width',62,'input','strainmapping.indices',...
    'equalTo','input.types','keepName',0,'selOptInput','strainmapping.actType','figEnd','Observation','figOptEnd',{'Lattice'},'reshowFigEnd',true);

panel.row(2).option1 = pushbutton('name','Show shift central atom','width',162,...
    'func','shiftAtomCentre','input','strainmapping.indices','output','strainmapping.shiftCenAtom',...
    'figEnd','Observation','figOptEnd',{'Shift central atom'},'reshowFigEnd',false);

panel.row(3).option1 = pushbutton('name','Calculate octahedral tilt','width',162,...
    'func','calcOctahedralTilt','input','strainmapping.suitOctaTilt','output','strainmapping.octahedralTilt',...
    'figEnd','Mean octahedral tilt a-dir','reshowFigEnd',false);

panel.row(4).option1 = pushbutton('name','Make displacement map','width',162,...
    'input','strainmapping.indices','output','strainmapping.coorExpected','func','makeDisplacementMap',...
    'figEnd','Observation','figOptEnd',{'Displacement map'});

panel.row(5).option1 = pushbutton('name','Make strain map','width',162,...
    'func','STEMstrain','input','strainmapping.indices','output','strainmapping',...
    'figEnd','Observation','figOptEnd',{[char(949),'_xx']});
