function [Y1,Y2]=prediccionDetRg(indAnlg,indDist,Y0,X0,X1,Parm)
dmn=Parm.dmn;
nn=Parm.Neig;
minN=Parm.MinRg;
%[X,Y]=meshgrid(dmn.lon,dmn.lat);X=X';Y=Y';
%vectorNod=[X(dmn.nod)' Y(dmn.nod)'];
%n=getInd([130 12 1000],dmn);
[X,Y]=meshgrid(dmn.lon,dmn.lat);X=X';Y=Y';
vectorNod=[X(dmn.nod)' Y(dmn.nod)'];
ndy=size(Y0,1);

Y1=ones([size(X1,1),size(Y0,2)])*NaN;
Y2=ones([size(X1,1),size(Y0,2)])*NaN;

[nd,ne]=size(Parm.NumA);
if ((ne ~= 1 & ne~=size(Y0,2)) | (nd~=1 & nd~=size(indAnlg,1)))
   error(['Las dimensiones de NumA no son las correctas: ' num2str([nd ne])]);
end

for k=1:size(Y0,2)
%  [d,pstn]=sort(sqrt((loc{PTN}(STN(k),1)-vectorNod(:,1)).^2+(loc{PTN}(STN(k),2)-vectorNod(:,2)).^2),1);
   [d,pstn]=sort(sqrt((Parm.loc(k,1)-vectorNod(:,1)).^2+(Parm.loc(k,2)-vectorNod(:,2)).^2),1);
   
   for l=1:size(X1,1)   
      na=Parm.NumA(mod(l,nd)+1,mod(k,ne)+1);
      ni=indAnlg(l,:);
      ni=ni(find(ni>=1 & ni<=ndy & (ni>(Parm.IndEx(l)+Parm.NEx) | ni<(Parm.IndEx(l)-Parm.NEx))));
      ni=ni(find(~isnan(Y0(ni,k)')));
      sni=min([na,length(ni)]);
      if sni >= minN
      	y0=Y0(ni(1:sni),k);
      	x0=[ones([sni,1])  X0(ni(1:sni),pstn(1:nn))];
         [B stats]=lfit(y0,x0);
         Y1(l,k)=[1 X1(l,pstn(1:nn))]*B;
         Y2(l,k)=stats(4);
      else 
         Y1(l,k)=NaN;
         Y2(l,k)=NaN;
      end
   end
   disp(['Variable ' num2str(m) '/' num2str(size(Y0,3)) ' Station ' num2str(k) '/' num2str(size(Y0,2))])
end