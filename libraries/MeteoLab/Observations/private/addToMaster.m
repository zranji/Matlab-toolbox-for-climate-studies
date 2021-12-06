function Maestro=addToMaster(Maestro,Nuevas)

for j=1:size(Nuevas,1)
   i=strmatch(Nuevas(j,1:5),Maestro(:,1:5),'exact');
   if isempty(i)
      Maestro=[Maestro; Nuevas(j,:)];
   end
end


% To save the resulting matrix to a file
%
%fid = fopen('Master.txt','w');
%for i=1:size(Master,1)
%   fprintf(fid,'%s\n',Master(i,:));
%end
%fclose(fid);