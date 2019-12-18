classdef outputStatSTEM_HMM < StatSTEMfile
% outputHMM - class to hold output parameters for fitting a hidden Markov
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
        A = [];
        ScalingHybrid = 0;
        Init = [];
        Sigma = 0;
        maxLogLikelihood = 0;
        H_viterbi = [];
        LL_viterbi = 0;
        coordinates_T = [];
    end
        
    methods
        
    end
    
    methods
        function obj = outputStatSTEM_HMM(ScalingHybrid,Sigma,Init,A,H_viterbi,LL_viterbi,coordinates_T)
            obj.A = A;
            obj.ScalingHybrid = ScalingHybrid;
            obj.Init = Init;
            obj.Sigma = Sigma;
            obj.H_viterbi = H_viterbi;
            obj.LL_viterbi = LL_viterbi;
            obj.coordinates_T = coordinates_T;
        end
        
        function val = get.A(obj)
            val = obj.A;
        end
        
        function val = get.Init(obj)
            val = obj.Init;
        end
        
        function val = get.ScalingHybrid(obj)
            val = obj.ScalingHybrid;
        end
        
        function val = get.Sigma(obj)
            val = obj.Sigma;
        end
        
        function val = get.H_viterbi(obj)
            val = obj.H_viterbi;
        end
        
        function val = get.LL_viterbi(obj)
            val = obj.LL_viterbi;
        end
        
    end
        
        
end
