function [file,message] = loadSERfile(FileName,takeMean)
% loadSERfile - Load a SER file suitable for StatSTEM
%
%   syntax: [file,message,dx] = loadSERfile(FileName,option)
%       FileName - Filename
%       takeMean - In case of image stack, take the mean image (optional, normally user make graphically selection)
%       file     - Structure containing the file information
%       message  - message for indicating if anything goes wrong
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%
% The script is an addapted version of the serReader() script made by 
% Peter Ercius 2009/08/06
%--------------------------------------------------------------------------

if nargin<2
    takeMean = false;
end

message = '';
file = [];
fID = fopen(FileName,'rb');

%% Version of SER file and offsets for retrieving data
fseek(fID,0,-1);
byteOrder = fread(fID,1,'int16'); % Not needed here
series = fread(fID,1,'int16'); % Not needed here
version = fread(fID,1,'int16');
if version >= 544
    newFormat = 1;
else
    newFormat = 0;
end

dataDim = fread(fID,1,'int32');
fread(fID,1,'int32');
totNumElements = fread(fID,1,'int32'); % Total number of datasets in file
valNumElements = fread(fID,1,'int32'); % Valid number of datasets in file
if valNumElements == 0
    message = sprintf(['The file ', FileName, ' cannot be loaded, no valid images present']);
    errordlg('Invalid structure')
    fclose(fID);
    return
end

% if valNumElements>1
%     q = questdlg(['SER file contains in total: ',num2str(valNumElements),' images and only one image is supported. What should be done?'],...
%         'Image Stack','Select 1 image','Take average','Select 1 image');
%     if isempty(q)
%         message = sprintf(['The file ', FileName, ' is not loaded, no option selected for image stack']);
%         fclose(fID)
%     end
%     if strcmp(q,'Take average')
%         selElements = 1:valNumElements;
%     else
%         selElements = [];
%         while isempty(selElements)
%             n = inputdlg('Number of image that should be selected','Image stack',1,{'1'});
%             if ~isempty(n)
%                 n = str2double(n{1});
%                 if mod(n,1)==0 && n>=1 && n<=valNumElements;
%                     selElements = n;
%                 end
%             end
%         end
%     end
% else
%     selElements = 1;
% end

selElements = 1:valNumElements;

if newFormat == 1
    offsetDataInfo = fread(fID,1,'int64'); %the offset (in bytes) to the beginning of the data offset array
else
    offsetDataInfo = fread(fID,1,'int32'); %the offset (in bytes) to the beginning of the data offset array
end


%% Get arrays containing byte offsets for data and tags
fseek(fID,offsetDataInfo,-1); %seek in the file to the offset arrays
%Data offset array (the byte offsets of the individual data elements)
if newFormat == 1
    offsetData = fread(fID,totNumElements,'int64');
else
    offsetData = fread(fID,totNumElements,'int32');
end

%% Get data
N = length(selElements);
data = cell(N,1);
calibration = zeros(2,N);
if dataDim == hex2dec('4120') % 1D dataset
    % 1D dataset not supported for StatSTEM
    message = sprintf(['The file ', FileName, ' cannot be loaded, no 2D dataset present']);
    errordlg('Invalid structure')
    fclose(fID);
    return
elseif dataDim == hex2dec('4122') % 2D dataset
    k=0;
    for n=selElements
        fseek(fID,offsetData(n),-1);
        calOffsetX = fread(fID,1,'float64'); % Not needed here
        calDx = fread(fID,1,'float64');  % Not needed here
        calElementX = fread(fID,1,'int32');  % Not needed here
        calOffsetY = fread(fID,1,'float64');  % Not needed here
        calDy = fread(fID,1,'float64');
        calElementY = fread(fID,1,'int32');
        dataType = fread(fID,1,'int16');
        Type = getSERType(dataType);

        arraySizeX = fread(fID,1,'int32');
        arraySizeY = fread(fID,1,'int32');
        k=k+1;
        data{k} = fread(fID,[arraySizeX arraySizeY],Type);
        calibration(:,k) = [calDx calDy]';
    end
end

%% Convert file to StatSTEM structure
fclose(fID);

% Average image if mulple images are loaded
[sx,sy] = size(data{1});
obs = zeros(sx,sy,N);
for n=1:N
    obs(:,:,n) = data{n};
end

% Take mean value if needed
if takeMean
    obs = mean(obs,3);
end

% Images are rotated when reading ser files;
obs = rot90(obs);
dx = mean(calibration(:,1))*10^10;

% Convert to inputStatSTEM file
file.input = inputStatSTEM(obs,dx);

% Update FileName
loc = strfind(FileName,filesep);
FileName = FileName(loc(end)+1:end);
file.input.name = FileName;





function Type = getSERType(dataType)
switch dataType
    case 1
        Type = 'uint8';
    case 2
        Type = 'uint16';
    case 3
        Type = 'uint32';
    case 4
        Type = 'int8';
    case 5
        Type = 'int16';
    case 6
        Type = 'int32';
    case 7
        Type = 'float32';
    case 8
        Type = 'float64';
    otherwise
        error('Unsupported data type') %complex data types are unsupported currently
end