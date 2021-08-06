function outObj = filter( obj, B, A )
%

outObj = obj;

if nargin == 3
  outObj.samples =  filter( B, A, obj.samples );
elseif nargin == 2
  outObj.samples =  filter( B, obj.samples );
end

