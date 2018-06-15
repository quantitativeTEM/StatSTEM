classdef listImagesStatSTEM
% listImagesStatSTEM - class to define images that can be shown in StatSTEM
%
    
    properties
        name = ''; % Name of the image/figure
        func = ''; % Function name for showing image
        input = ''; % Specify the needed input for the function ('inputStatSTEM,'outputStatSTEM', etc.)
        figOpt = {}; % Figure options for the image/figure
        optInput = {}; % Optional input for the function ('inputStatSTEM,'outputStatSTEM', etc.)
    end
    
    methods
        function obj = listImagesStatSTEM(name,func,input,optInput)
            obj.name = name;
            obj.func = func;
            obj.input = input;
            if nargin>3
                obj.optInput = optInput;
            end
        end
        
        function obj = addFigOpt(obj,name,func,input,show)
            if nargin<5
                show = false;
            end
            obj.figOpt = [obj.figOpt;{name,func,input,show}];
        end
        
        function obj = removeFigOpt(obj,name)
            ind = strcmp(obj.figOpt(:,1),name);
            if sum(ind)>0
                obj.figOpt = obj.figOpt(~ind,:);
            else
                warning('listImagesStatSTEM: Option not found, nothing is changed')
            end
        end
        
        
        function obj = set.optInput(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.optInput = {value};
            elseif isa(value,'cell')
                N = length(value);
                for n=1:N
                    if ~isempty(value{n}) && ~isa(value{n},'char')
                        error(['listImagesStatSTEM: optInput in cell number ',num2str(n),' should be a string'])
                    end
                end
                obj.optInput = value;
            else
                error('listImagesStatSTEM: optInput should be a string or cell structure with string')
            end
        end
    end
end