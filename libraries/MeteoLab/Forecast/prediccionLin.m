function [Y1]=prediccionLogistica(indAnlg,indDist,Y0,X0,X1,Parm)

nn=Parm.Neig;
minN=Parm.MinRg;
%[X,Y]=meshgrid(dmn.lon,dmn.lat);X=X';Y=Y';
%vectorNod=[X(dmn.nod)' Y(dmn.nod)'];
%n=getInd([130 12 1000],dmn);
%[X,Y]=meshgrid(dmn.lon,dmn.lat);X=X';Y=Y';
%vectorNod=[X(dmn.nod)' Y(dmn.nod)'];

nnet=newff([min(X0(:,1:nn),[],1);max(X0(:,1:nn),[],1)]',[1],{'purelin'},'trainMET');

ndy=size(Y0,1);
Y1=ones([size(X1,1),size(Y0,2)])*NaN;
Y2=ones([size(X1,1),size(Y0,2)])*NaN;

[nd,ne]=size(Parm.NumA);
if ((ne ~= 1 & ne~=size(Y0,2)) | (nd~=1 & nd~=size(indAnlg,1)))
   error(['Las dimensiones de NumA no son las correctas: ' num2str([nd ne])]);
end

Y0=rellenaProb(Parm.Umb,Y0,~isnan(Y0));
Y0=1-cumsum(Y0(:,:,1:end-1),3);

for m=1:size(Y0,3)
   for k=1:size(Y0,2)
      for l=1:size(X1,1)   
         na=Parm.NumA(mod(l,nd)+1,mod(k,ne)+1);
         ni=indAnlg(l,:);
         ni=ni(find(ni>=1 & ni<=ndy & (ni>(Parm.IndEx(l)+Parm.NEx) | ni<(Parm.IndEx(l)-Parm.NEx))));
         ni=ni(find(~isnan(Y0(ni,k,m)')));
         sni=min([na,length(ni)]);
         if sni >= minN
            y0=Y0(ni(1:sni),k,m);
            x0=X0(ni(1:sni),1:nn);
            E=inf;
            V=NaN;
            for iT=1:1
            	nnet=init(nnet);
					nnet=train(nnet,x0',y0');
            	EE=sqrt(mse(y0-sim(nnet,x0')'));
               if(EE<E)
                  V=sim(nnet,X1(l,1:nn)')';
                  E=EE;
               end
            end
            Y1(l,k,m)=E;
            Y2(l,k,m)=V;
         else 
            Y1(l,k,m)=NaN;
            Y2(l,k,m)=NaN;
         end
      end
      disp(['Variable ' num2str(m) '/' num2str(size(Y0,3)) ' Station ' num2str(k) '/' num2str(size(Y0,2))])
   end
end
Y1(find(Y1<0))=0;
Y1(find(Y1>1))=1;