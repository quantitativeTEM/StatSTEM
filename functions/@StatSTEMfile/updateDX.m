function out = updateDX(obj,varargin)
% updateDX - Callback for using a new pixel size value
%
%   syntax: varargout = updateDX(obj,varargin)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

N = nargin;
if N<2
    error('Second input needed, new pixel size')
end
% Check if last input is a (positive) new pixel size
if isa(varargin{N-1},'double') && varargin{N-1}>0
    dxNew = varargin{N-1};
end
dxOld = obj.dx;

varargin = [{obj},varargin(1:N-2)];

% Gather outputs
out = cell(1,N-1);
for n=1:N-1
    obj = varargin{n};
    if dxNew~=dxOld % If nothing changed, don't update anything
        obj.dx = dxNew;
        if ~isempty(obj.coordinates)
            obj.coordinates(:,1:2) = obj.coordinates(:,1:2)/dxOld*dxNew;
        end
        switch class(obj)
            case 'inputStatSTEM'
                obj.rhoT = obj.rhoT/dxOld*dxNew;
                obj.beta_xmin = obj.beta_xmin/dxOld*dxNew;
                obj.beta_ymin = obj.beta_ymin/dxOld*dxNew;
                obj.beta_xmax = obj.beta_xmax/dxOld*dxNew;
                obj.beta_ymax = obj.beta_ymax/dxOld*dxNew;
                obj.rhomin = obj.rhomin/dxOld*dxNew;
                obj.rhomax = obj.rhomax/dxOld*dxNew;
            case 'outputStatSTEM'
                obj.rho = obj.rho/dxOld*dxNew;
                obj.selRegion = obj.selRegion/dxOld*dxNew;
                obj.rangeVol = obj.rangeVol*(dxNew/dxOld)^2;
            case 'atomCount'
                obj.volumes = obj.volumes*(dxNew/dxOld)^2;
                if isa(obj,'atomCountStat')
                    N = length(obj.estimatedDistributions);
                    for k=1:N
                        obj.estimatedDistributions{1,k}.mu = obj.estimatedDistributions{1,k}.mu*(dxNew/dxOld)^2;
                        obj.estimatedDistributions{1,k}.Sigma = obj.estimatedDistributions{1,k}.Sigma*(dxNew/dxOld)^4;
                    end
                end
            case 'strainMapping'
                obj.refCoor = obj.refCoor/dxOld*dxNew;
                obj.aP = obj.aP/dxOld*dxNew;
                obj.errAP = obj.errAP/dxOld*dxNew;
                obj.bP = obj.bP/dxOld*dxNew;
                obj.errBP = obj.errBP/dxOld*dxNew;
                obj.coorExpectedP = obj.coorExpectedP/dxOld*dxNew;
                obj.latticeAP = obj.latticeAP/dxOld*dxNew;
                obj.latticeBP = obj.latticeBP/dxOld*dxNew;
                obj.shiftCenAtomP = obj.shiftCenAtomP/dxOld*dxNew;
            case 'outputStatSTEM_MAP'
                for i=1:obj.Nmodels
                    obj.models{i}.dx = dxNew;
                    if ~isempty(obj.models{i}.coordinates)
                        obj.models{i}.coordinates(:,1:2) = obj.models{i}.coordinates(:,1:2)/dxOld*dxNew;
                    end
                    obj.models{i}.rho = obj.models{i}.rho/dxOld*dxNew;
                end
                
        end
    end
    out{1,n} = obj;
end
