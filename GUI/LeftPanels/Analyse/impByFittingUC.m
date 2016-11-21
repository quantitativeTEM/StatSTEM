function [teta,e_teta,a,e_a,b,e_b] = impByFittingUC(usr,h,coorT,teta_start,dirTeta)
% impByFittingUC - improve starting values for strain mapping by fitting
%
%   syntax: [teta,e_teta,a,e_a,b,e_b] = impByFittingUC(usr,h,coorT,teta_start,dirTeta)
%       teta       - angle of lattice with respect to image (mrad)
%       e_teta     - error of teta
%       a          - a-lattice (Å)
%       e_a        - error on value of a-lattice (Å)
%       b          - b-lattice (Å)
%       e_b        - error on value of b-lattice (Å)
%       usr        - structure containing all references to the file in StatSTEM
%       h          - structure holding references to StatSTEM interface
%       coorT      - selected coordinates
%       teta_start - start value of teta (mrad)
%       dirTeta    - (+/-) direction of the b-lattice with respect to a
%                    lattice

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if h.left.ana.panel.strainAdv.impFitABut.isSelected
    n_unit = str2double(get(h.left.ana.panel.strainAdv.impFitNUC,'Text'));
    onlyTeta = h.left.ana.panel.strainAdv.impFitParTeta.isSelected;
    if onlyTeta
        [teta,e_teta] = STEMrefPar(coorT,usr.file.strainmapping.refCoor,teta_start,usr.file.input.projUnit.a,usr.file.input.projUnit.b,usr.file.input.projUnit.ang,dirTeta,n_unit);
        a = usr.file.input.projUnit.a;
        e_a = 0;
        b = usr.file.input.projUnit.b;
        e_b = 0;
    else
        [teta,e_teta,a,e_a,b,e_b] = STEMrefPar(coorT,usr.file.strainmapping.refCoor,teta_start,usr.file.input.projUnit.a,usr.file.input.projUnit.b,usr.file.input.projUnit.ang,dirTeta,n_unit);
    end
else
    teta = teta_start;
    e_teta = 0;
    a = usr.file.input.projUnit.a;
    e_a = 0;
    b = usr.file.input.projUnit.b;
    e_b = 0;
end