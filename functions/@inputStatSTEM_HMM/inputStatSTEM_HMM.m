classdef inputStatSTEM_HMM < StatSTEMfile
% inputHMM - class to hold input parameters for fitting a hidden Markov
% Model to a time series of ADF STEM images
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2019, EMAT, University of Antwerp
% Author: A. De wael
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
    
    properties % input values
        libraries = []; % library of simulated cross-sections
        O = []; % observed sequence
        G = 0; % maximum number of atoms in a column
        num_components = 0;
    end
        
    properties % additional input values for displaying results
        obs_T = []; % observations: all ADF STEM images
        model_T = []; % fitted models for all ADF STEM images
        % coordinates & dx is already in the StatSTEMfile class
        coordinates_T = []; % coordinates of all columns throughout all images
    end
    
    methods
        outputHMM = analyseFactorialHMM(inputHMM);
    end
    
    methods
        function obj = inputStatSTEM_HMM(O,libraries,G,obs_T,model_T,coordinates_T,dx)
            obj.O = O;
            obj.libraries = libraries;
            obj.G = G;
            if libraries(1) == 0
                obj.num_components = G + 1;
            else
                obj.num_components = G;
            end
            obj.obs_T = obs_T;
            obj.model_T = model_T;
            obj.coordinates_T = coordinates_T;
            obj.dx = dx;
        end
        
        function obj = set.O(obj,val)
            % Check if input is not empty
            if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2)>1 ) )
                obj.O = val;
            else
                error('StatSTEMfile: Observed sequence matrix O not properly defined')
            end
        end
            
        function obj = set.libraries(obj,val)
            % Check if input is not empty
            if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2)>=0 ) )
                if size(val,1) == 1 && size(val,2) > 1
                    obj.libraries = val';
                elseif size(val,2) == 1 && size(val,1) > 1
                    obj.libraries = val;
                end
            else
                error('StatSTEMfile: libraries not properly defined')
            end
        end
        
        function obj = set.G(obj,val)
            % Check if input is not empty
            if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2)==1 ) )
                obj.G = val;
            else
                error('StatSTEMfile: G not properly defined')
            end
        end
        
%         function obj = set.obs_T(obj,val)
%             % Check if input is not empty
%             if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2) >=0 && size(val,3) >=0 ) )
%                 obj.obs_T = val;
%             else
%                 error('StatSTEMfile: G not properly defined')
%             end
%         end
        
        
    end
        
        
end