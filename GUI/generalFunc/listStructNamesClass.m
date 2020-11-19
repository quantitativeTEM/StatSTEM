function out = listStructNamesClass()
% listStructNamesClass - Gives a list with fieldnames used in StatSTEM and
%                        the corresponding classnames
%
%   syntax: out = listStructNamesClass()
%       out - cellstructure containing the field- and classnames
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% The fieldnames and classnames are:
out(1,:) = {'fieldname','classname'};
out(2,:) = {'input','inputStatSTEM'};
out(3,:) = {'output','outputStatSTEM'};
out(4,:) = {'outputMAP','outputStatSTEM_MAP'};
out(5,:) = {'atomcounting','atomCountStat'};
out(6,:) = {'libcounting','atomCountLib'};
out(7,:) = {'strainmapping','strainMapping'};
out(8,:) = {'model3D','mod3D'};
out(9,:) = {'inputHMM','inputStatSTEM_HMM'};
out(10,:) = {'outputHMM','outputStatSTEM_HMM'};
