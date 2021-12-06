function datos=CP2Real(var,time,level,dmn,CP,indCP,EOF,DV,MN);

ind=[];
for p=1:length(var),
   for i=1:length(time)
      for j=1:length(level)
         ind2=findVarPosition(var(p),time(i),level(j),dmn);
         ind=[ind ind2];
      end
   end
end
%keyboard
%Transformamos del espacio de las EOF al real
datos=(CP(:,indCP)*EOF(ind,indCP)');
%Des-estandarizamos los datos
datos=(datos.*repmat(DV(1,ind),[size(CP,1) 1]))+repmat(MN(1,ind),[size(CP,1) 1]);

