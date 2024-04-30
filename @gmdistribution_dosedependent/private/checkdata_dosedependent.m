function checkdata_dosedependent(X,obj)
%CHECKDATA Check the size of data
%   CHECKDATA(X) returns an error if data X is not a 2 dimensional numeric
%   matrix.
%
%   CHECKDATA(X.OBJ) returns an error if the columns of X does not equal
%   the OBJ.NDimensions.

%    Copyright 2007 The MathWorks, Inc.

if ndims(X)>2 || ~isnumeric(X)
    error(message('stats:gmdistribution:RequiresMatrixData'));
end

if nargin>1
[n, d] = size(X);
if d ~= obj.NDimensions
    error(message('stats:gmdistribution:XSizeMismatch', obj.NDimensions));
end

end