function [ob,nob,hi,fa]=countROC(Obsr,Prdc,P)
P=P(1:end);
nP=length(P);
hi(nP,size(Prdc,2),size(Prdc,3))=0;
ob(1,size(Prdc,2),size(Prdc,3))=0;
fa(nP,size(Prdc,2),size(Prdc,3))=0;
nob(1,size(Prdc,2),size(Prdc,3))=0;

indn=~isnan(Obsr) & ~isnan(Prdc);
ind=find(indn);
i=find(sum(indn,1)==0);

o(size(Obsr,1),size(Obsr,2),size(Obsr,3))=0;
no(size(Obsr,1),size(Obsr,2),size(Obsr,3))=0;
h(size(Prdc,1),size(Prdc,2),size(Prdc,3))=0;

o(ind)=Obsr(ind)>0;
no(ind)=~o(ind);
nob(1,:,:)=sum(no,1);
ob(1,:,:)=sum(o,1);
for l=1:nP
   h(ind)=Prdc(ind)>P(l) & o(ind);
   hi(l,:,:)=sum(h,1);
   
   h(ind)=Prdc(ind)>P(l) & no(ind);
   fa(l,:,:)=sum(h,1);
 end
