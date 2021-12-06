function Y1=prediccionDetWm(indAnlg,indWeight,Y0,Parm)
na=Parm.NumA;
ndy=size(Y0,1);

[nd,ne]=size(Parm.NumA);
if ((ne ~= 1 & ne~=size(Y0,2)) | (nd~=1 & nd~=size(indAnlg,1)))
   error(['Las dimensiones de NumA no son las correctas: ' num2str([nd ne])]);
end

for k=1:size(Y0,2)
   for l=1:size(indAnlg,1)   
      na=Parm.NumA(mod(l,nd)+1,mod(k,ne)+1);
	  ni=indAnlg(l,:);
      
      nw=indWeight(l,:);
%       i=find(ni>=1 & ni<=ndy);
if isempty(Parm.IndEx)
    i=find(ni>=1 & ni<=ndy);
else
       i = find(ni>=1 & ni<=ndy & (ni>(Parm.IndEx(l)+Parm.NEx) | ni<(Parm.IndEx(l)-Parm.NEx)));
end
      
      ni=ni(i);
      nw=nw(i);
      
      i=find(~isnan(Y0(ni,k)'));
      ni=ni(i);
      nw=nw(i);
      
      %ni=ni(~isnan(Y0(ni,k)'));
      sni=min([na,length(ni)]);
      
      y0=Y0(ni(1:sni),k)';
      Y1(l,k)=sum(y0.*nw(1:sni))/sum(nw(1:sni));
   end
   %disp(num2str(k))
end