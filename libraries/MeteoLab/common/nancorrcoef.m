function [c,n]=nancorrcoef2(x,minimun)
m=size(x,2);
if nargin==1
    minimun=2;
end
c=eye(m);
v=double(~isnan(x));
n=v'*v;
for i=1:m
    aux=x(:,i:end);
    indices=find(repmat(v(:,i),1,m-i+1)+v(:,i:end)<2);
    aux(indices)=NaN;
    xx=repmat(x(:,i),1,m-i+1);
    xx(indices)=NaN;
    media1=nanmean(xx);media2=nanmean(aux);
    c(i,i:end)=(nanmean(xx.*aux)-media1.*media2)./(sqrt(abs(nanmean(xx.^2)-media1.^2)).*sqrt(abs(nanmean(aux.^2)-media2.^2)));
end
c=c+c'-eye(m);c(find(n<minimun))=NaN;