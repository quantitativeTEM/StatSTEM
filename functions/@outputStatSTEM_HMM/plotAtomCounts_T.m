function plotAtomCounts_T(outputHMM)
% plotAtomCounts_T - plot the atom counts
%
%   syntax: plotAtomCounts_T(outputHMM,inputHMM)
%       outputHMM - outputStatSTEM_HMM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

ax = gca;
if isempty(outputHMM.ax2)
    img = get(ax,'Parent');
    ax2 = axes('Parent',img,'units','normalized');
    axes(ax)
else
    ax2 = outputHMM.ax2;
end

nameTag = 'Atom Counts';
scaleMarker = outputHMM.mscale;
range = [0,max(outputHMM.H_viterbi(:))];

SliderT = findobj(gcf, 'type', 'uicontrol','style','slider');
t = round(get(SliderT(end), 'Value'));

data = outputHMM.H_viterbi(t,:)';

[ah,ah1,ah2] = scatterPlot2Axes(ax,ax2,outputHMM.coordinates_T(:,1:2,t),data,range,nameTag,scaleMarker,'Thickness: %g atoms');

addlistener(SliderT, 'Value', 'PostSet', @callbackfn);

    function callbackfn(source,eventdata)
        t = round(get(eventdata.AffectedObject, 'Value'));
        data = outputHMM.H_viterbi(t,:)';
        
        delete(ah);
        delete(ah1);
        delete(ah2);
        [ah,ah1,ah2] = scatterPlot2Axes(ax,ax2,outputHMM.coordinates_T(:,1:2,t),data,range,nameTag,scaleMarker,'Thickness: %g atoms');
    end
end