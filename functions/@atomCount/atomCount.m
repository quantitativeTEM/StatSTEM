classdef (Abstract) atomCount < StatSTEMfile
%
% atomCount - Abstract class to hold atom counts

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
    properties (Dependent)
        N % Number of columns
        Counts % The number of atoms per atomic column
        TotalNumberAtoms % The total number of atoms in the image
    end
    
    methods
        function val = get.Counts(obj)
            val = getCounts(obj);
        end
        
        function val = get.N(obj)
            val = size(obj.coordinates,1);
        end
        
        function val = get.TotalNumberAtoms(obj)
            val = sum(obj.Counts);
        end
    end
    
    methods (Abstract)
        % Abstract method for atom counting
        val = getCounts(obj)
    end
    
    methods 
        model = create3Dmodel(atomcounting,strainmapping)
    end
end