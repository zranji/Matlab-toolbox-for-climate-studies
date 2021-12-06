function [fbo,fbp]=countREL(Obsr,Prdc,P)
P=P(1:end);
nP=length(P);
fbo(nP-1,size(Prdc,2),size(Prdc,3))=0;
fbp(nP-1,size(Prdc,2),size(Prdc,3))=0;

indn=~isnan(Obsr) & ~isnan(Prdc);
ind=find(indn);
o(size(Obsr,1),size(Obsr,2),size(Obsr,3))=0;
o(ind)=Obsr(ind)>0;
h(size(Prdc,1),size(Prdc,2),size(Prdc,3))=0;
for l=2:nP
      h(ind)= Prdc(ind)>P(l-1) & Prdc(ind)<=P(l);
      %h(ind)= Prdc(ind).*h(ind);
      fbp(l-1,:,:)=sum(h,1);
      h(ind)= h(ind) & o(ind);
      fbo(l-1,:,:)=sum(h,1);
 end
