classdef StatSTEMfile
% StatSTEMfile - a class which contains StatSTEM files

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

    properties
        dx = 1; % The pixel size in angstrom (standard at 1)
        coordinates = []; % A (n x 3) vector containing the x- and y-coordinates (in angstrom) and the (3rd column) type number
        types = {'1'}; % Names of the atom types in cell array (k x 1)
        numWorkers = feature('numCores'); % Number of cores for parallel computing
        peakShape = 1; % Different peak shapes (1 = 'Gauss', 2 = 'Lorentz')    
    end

    properties (Hidden)
        name = ''; % String indicating the name of the file
        GUI = []; % Reference to StatSTEM GUI (zero means no reference)
        ax = []; % Reference to axes in StatSTEM GUI
        ax2 = []; % Reference to axes in StatSTEM GUI
        waitbar = []; % Reference to waitbar in StatSTEM GUI
        mscale = 1; % Scale multiplied by marker size that will be used
        actType = {}; % Active column type to run (some) functions on
        message = ''; % Store message that can be shown in StatSTEM after function finished running
    end
    
    methods
        out = updateDX(obj,varargin)
    end
    
    methods
        function obj = set.name(obj,val)
            % Check if input is a string
            if isa(val,'char')
                obj.name = val;
            else
                error('StatSTEMfile: Not a proper file name is given')
            end
        end
        
        function obj = set.dx(obj,val)
            % Check if input is correct
            if isa(val,'double') && ~isempty(val) && val>0
                obj.dx = val;
            else
                errordlg('StatSTEMfile: Pixel size not properly defined')
            end
        end
        
        function obj = set.coordinates(obj,val)
            % Check if input is correct
            if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2)==3 ) )
                obj.coordinates = val;
            elseif isa(val,'double') && ( size(val,1)>=0 && size(val,2)==2 )
                val = [val,ones(size(val,1),1)];
                obj.coordinates = val;
            else
                error('StatSTEMfile: Coordinates vector not properly defined')
            end
        end
        
        function obj = set.types(obj,val)
            % Check if input is correct
            if isempty(val)
            elseif isa(val,'cell') && size(val,1)>0 && size(val,2)==1
                obj.types = val;
            else
                error('StatSTEMfile: Type vector not properly defined')
            end
        end
        
        function val = get.types(obj)
            val = obj.types;
            if size(obj.coordinates,1)>0
                % Make sure enough names are generated
                M = max(obj.coordinates(:,3));
                N = length(val);
                if N<M
                    typeN = cell(M,1);
                    for m=1:M
                        typeN{m} = num2str(m);
                    end
                    typeN(1:N,1) = val;
                    val = typeN;
                end
            end
        end
        
        function obj = set.numWorkers(obj,val)
            % Check if input is correct
            maxVal = feature('numCores');
            if isa(val,'double') && val>0 && val<=maxVal
                obj.numWorkers = val;
            else
                obj.numWorkers = maxVal;
                warning(['StatSTEMfile: numWorkers must be a positive number that is not greater than the number',...
                    ' of physical cores of your computer, it is set to one if the parallel toolbox is not present in MATLAB'])
            end
        end
        
        function obj = set.actType(obj,val)
            % Make sure type is stored as a cell
            if isa(val,'char')
                obj.actType = {val};
            elseif isa(val,'cell')
                obj.actType = val;
            else
                error('StatSTEMfile: Not a proper file actType is given')
            end
        end
        
        function val = get.actType(obj)
            % Check if a value is already present, if not select first type
            val = obj.actType;
            if isempty(val) || isempty(val{1})
                ts = obj.types;
                if ~isempty(ts)
                    val = ts(1);
                end
            end
        end
        
        function val = get.numWorkers(obj)
            % Check matlab version
            v = version('-release');
            v = str2double(v(1:4));
            if v<2015
                val = 1;
            else
                val = obj.numWorkers;
            end
        end
        
        function obj = set.message(obj,val)
            % Check if input is a string
            if isa(val,'char')
                obj.message = val;
            else
                error('StatSTEMfile: Not a proper message is given')
            end
        end
        
        function obj = clearMessage(obj)
            obj.message = '';
        end
    end
end