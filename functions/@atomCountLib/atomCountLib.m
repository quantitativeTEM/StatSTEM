classdef atomCountLib < atomCount
% atomCountLib - class to hold fitted parameters for library atomcounting
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
        volumes = []; % A (n x 1) vector that contains the volume of each atomic column
        library = []; % Library values for atom counting: (nx1) vector containing values for thickness 1-n atoms;
        thick = []; % Corresponding thickness with library values
    end
    
    properties (Dependent, Hidden)
    end
    
    methods
        plotLib(obj)
        plotAtomCounts(obj)
    end
    
    methods
        function obj = atomCountLib(coordinates,volumes,dx,library,thick)
            obj.coordinates = coordinates;
            obj.volumes = volumes;
            obj.dx = dx;
            obj.library = library;
            if nargin>4
                obj.thick = thick;
            end
        end
        
        function val = getCounts(obj)
            val = zeros(obj.N,1);
            try
                lib = [0;obj.library];
            catch
                lib = [0,obj.library];
            end
            try
                tk = [0;obj.thick];
            catch
                tk = [0,obj.thick];
            end
            for n=1:obj.N
                dist = (obj.volumes(n)-lib).^2;
                ind = find(dist==min(dist));
                num = tk(ind(1),1);
                val(n,1) = num(1);
            end
        end
        
        function val = get.thick(obj)
            if isempty(obj.thick)
                val = (1:obj.N)';
            else
                val = obj.thick;
            end
        end
    end
end