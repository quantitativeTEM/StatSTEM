function [color,err] = colorAtoms(path,in)
% colorAtoms - define color for different atom types
%
%   syntax: colorAtoms(path,in)
%       color  - rgb valuse for each type
%       path   - reference to text file with colors
%       in     - a list of types
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

err = '';

if exist(path, 'file') == 2
    nofile = 0;
    % Find the number of rows in text file and find where colors are defined
    fid = fopen(path,'rt');
    nLines = 0;
    line = 1;
    st1 = 0;
    st2 = 0;
    C = cell(0,0);
    while line ~= -1
        line = fgets(fid);
        nLines = nLines+1;
        if line ~= -1
            C = textscan(line,'%s','delimiter',{sprintf('\t'),sprintf(' ')});
            C = C{1,1};
            if size(C,1)>3 && st1==0
                if strcmp(C{1},'type') && strcmp(C{2},'R') && strcmp(C{3},'G') && strcmp(C{4},'B')
                    st1 = nLines+1;
                end
            elseif size(C,1)<4 && st1~=0 && st2==0
                st2 = nLines;
            end
        end
    end
    fclose(fid);
    nLines = nLines-1;
    if st2==0
        st2 = nLines;
    end
    
    if st1 ~= 0
        % Read colors
        nC = st2-st1+1;
        color = zeros(nC,3);
        fid = fopen(path,'rt');
        for n=1:nLines
            line = fgets(fid);
            if n>=st1
                C = textscan(line,'%s','delimiter',sprintf('\t'));
                C = C{1,1};
                color(n-st1+1,1) = str2double(C{2})/255;
                color(n-st1+1,2) = str2double(C{3})/255;
                color(n-st1+1,3) = str2double(C{4})/255;
            end
        end
        fclose(fid);
        
        % Check if all values are correct
        if any(reshape(color,nC*3,1)<0) || any(reshape(color,nC*3,1)>1)
            nofile = 1;
        end
    else
        nofile = 1;
    end
else
    nofile = 1;
end

if nofile==1
    T = cell(8,1);
    T{1,1} = {'Marker colors of the StatSTEM interface'};
    T{2,1} = {''};
    T{3,1} = {'type';'R';'G';'B'};
    T{4,1} = {'1';'0';'255';'0'};
    T{5,1} = {'2';'255';'0';'255'};
    T{6,1} = {'3';'0';'255';'255'};
    T{7,1} = {'4';'255';'0';'0'};
    fid = fopen(path,'wt');
    for n=1:size(T,1)
        for m=1:size(T{n,1},1)
            fprintf(fid,'%s',T{n,1}{m,1});
            if m~=size(T{n,1},1)
                fprintf(fid,'\t');
            end
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
    err = 'File with marker colors was corrupted, file is restorted';
    color = [0,1,0;1,0,1;0,1,1;1,0,0];
end

if nargin>1
    nMax = size(color,1);
    num = mod(in,nMax);
    num(num==0)=nMax;
    color = color(num,:);
end