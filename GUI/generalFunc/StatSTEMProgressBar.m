classdef StatSTEMProgressBar < handle
    % StatSTEMProgressBar - Native MATLAB progress bar using panel width

    properties (Access = private)
        Container
        FillPanel
        BarText
    end

    methods
        function obj = StatSTEMProgressBar(container, fillPanel, barText)
            obj.Container = container;
            obj.FillPanel  = fillPanel;
            obj.BarText    = barText;
        end

        function setValue(obj, val)
            val = max(0, min(100, val));
            set(obj.FillPanel, 'Position', [0 0 val/100 1]);
            set(obj.Container, 'Title', sprintf('%d%%', round(val)));
            drawnow;
        end

        function val = getValue(obj)
            pos = get(obj.FillPanel, 'Position');
            val = pos(3) * 100;
        end
    end
end