clear neu
msizex=clst.msizex;
msizey=clst.msizey;
msize=[msizex msizey];
cp1=1;cp2=2;
NCP=clst.NCP;

noneu=msizex*msizey;
iter=100;
neu(1:noneu,NCP)=0;

%tomamos percentiles¡¡¡¡¡¡
A=prctile(CP(:,1),linspace(99,1,msizex+1));
B=[];
for i=1:msizex
   lista=find(CP(:,1)>=A(i+1) & CP(:,1)<=A(i));
   B=[B;prctile(CP(lista,2),linspace(99,1,msizey))];
end
A=prctile(CP(:,1),linspace(99,1,msizex));

ind=cell(noneu,1);

l=0;nobeta=[];
for i=1:msizex
   for j=1:msizey
      
      l=l+1;
      ind{l}=[i j];
      neu(l,1)=A(i);
      neu(l,2)=B(i,j);
      [xj,err_qua] = MLknn(neu(l,1:2),CP(:,1:2),1,2);
      neu(l,:)=CP(xj,1:NCP);
      if (i==1 & j==1) | (j==msizey & i==msizex) |  (j==1 & i==msizex) | (j==msizey & i==1) 
         nobeta=[nobeta;l];
      end
   end
end   
hold on
plot(neu(:,cp1),neu(:,cp2),'dr','markersize',8);  
hold off
clear ddp
ddp(1:noneu,1:noneu)=0;
for i=1:noneu
   for j=1:noneu
      x1=ind{i}(1);x2=ind{j}(1);
      y1=ind{i}(2);y2=ind{j}(2);
      dx=abs(x1-x2);dy=abs(y1-y2);
      ddp(i,j)=dx^2+dy^2;
   end
end

errmin=inf;
oldneu=neu;
lista=[];
[lista,err_qua] = MLknn(CP(:,1:NCP),neu,1,2);
jk=0;
clf
vecinos=cell(noneu,1);
for l=1:noneu
   vecinos{l}=[l+1 l+msizex];
   if ind{l}(2)==msizey; vecinos{l}=[l+msizex];end
end
%alfa0=.02;
%beta0=.1;
alfa0=10/iter;
beta0=3*10/iter;

for k=1:iter-1
   f=1-k/iter;
   dd=exp(-(1/f)*ddp);
   for i=1:size(dd,1)
      dd(i,:)=size(dd,2)*dd(i,:)/sum(dd(i,:));
   end
   
   %reshape(dd(36,:),8,8)   
   ia=(k/iter)^.1;
   %ia=1;
   
   beta=beta0*f^1;
   alfa=alfa0*f;
   
   fli=[];
   for i=1:noneu
      fli= find(lista==i);[a,b]=sort(err_qua(fli));
      if ~isempty(fli)
         %buscamos los CP mas alejados
         xx=fli(b(end));
         dr=mean(CP(fli,1:NCP));
         dr1=CP(xx,1:NCP);dr=ia*dr+(1-ia)*dr1;
         neu(i,:)=neu(i,:)+(dr-neu(i,:))*alfa;
         
      else
         %si una neurona se queda vacía se le asigna el dato más cercano
         [xj,qua] = MLknn(neu(i,:),CP(:,1:NCP),1,2);
         neu(i,:)=CP(xj,1:NCP);
      end
   end
   oldneu=neu;
   for w=1:noneu
      M=NaN*zeros(msizex,msizey);
      M(ind{w}(1),ind{w}(2))=1;
      for u1=ind{w}(1)-msizex:ind{w}(1)-1
         for u2=ind{w}(2)-msizey:ind{w}(2)-1
            if u1>=0 & u2>=0 & ind{w}(1)+u1<=msizex & ind{w}(2)+u2<=msizey 
               M(ind{w}(1)-u1,ind{w}(2)-u2)=1;
               M(ind{w}(1)-u1,ind{w}(2)+u2)=1;
               M(ind{w}(1)+u1,ind{w}(2)+u2)=1;
               M(ind{w}(1)+u1,ind{w}(2)-u2)=1;
            end
         end
      end
      sz=repmat(dd(w,:)',1,NCP).*repmat(reshape(M',noneu,1),1,NCP);sz=sz/mean(nansum(sz));
      achili=nansum(oldneu.*sz);
      neu(w,:)=neu(w,:)+(achili-neu(w,:))*beta;
   end
   lista=[];
   [lista,err_qua] = MLknn(CP(:,1:NCP),neu,1,'Norm-2');
   
   oldneu=neu;repe=1;
   clf
   
   plot(CP(:,cp1),CP(:,cp2),'.r','markersize',1);   
   hold on
   for l=1:noneu
      for m=1:size(vecinos{l},2)
         ss=vecinos{l}(m);
         if ss>0 & ss<=noneu;line([neu(l,cp1) neu(ss,cp1)], [neu(l,cp2) neu(ss,cp2)],...
               'linewidth',1,'color','k');end
      end
      
   end   
   plot(neu(:,cp1),neu(:,cp2),'.k','markersize',12); 
   title(['Tasa de adaptacion: ' num2str(alfa) ' Tasa de vecindad: '...
         num2str(beta)])% ' población máx: ' num2str(cr) ' en ud: ' num2str(cw)])
   drawnow
   hold off
   Centers=neu;
end

