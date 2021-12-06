function [ind,ndata,U,V]=testHomogeneitySelect(U,V,K,minimo)
i=0;
act=[1:length(U)];
ind=[];ndata=[];
aux2=double(~isnan(V));
while i<K
    indices=setdiff(1:size(V,2),ind);
    aux1=double(~isnan(U(act)));
    aux=abs(aux2(:,indices)-repmat(aux1,1,length(indices)));
    nocomun=sum(aux,1)';
    [a,b]=min(sum(nocomun,2));
    act2=intersect(find(aux1==1),find(aux2(:,indices(b))==1));
    aux2=aux2(act2,:);
    if length(act2)<minimo
        if (i<2); 
            ind=[]; 
        end
        i=K;
    else
        ind=[ind;indices(b)];
        act=act(act2);
        ndata=length(act);
        i=i+1;
    end
end
U=U(act);
V=V(act,ind);