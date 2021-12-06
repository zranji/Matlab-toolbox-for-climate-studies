function [Lines,strl]=getLines(name,varargin)
if nargin<2
   type='Array';
else
   type=varargin{1};
end


fid=fopen(name,'rb');
k=1;
while ~feof(fid)
   dum=fgetl(fid);
   strl(k,1)=size(dum,2);
   cellTemp{k,1}=dum;
   k=k+1;
end
fclose(fid);

if strcmpi(type,'Array')
   Lines=strvcat(cellTemp);
elseif strcmpi(type,'Cell')
   Lines=cellTemp;
end

