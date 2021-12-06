function [io,c,nx,eq,ed] = kmeans(x,N)
% KMEANS : k-means clustering
% c = kmeans(x,nc)
%	x       - d*n samples
%	nc      - number of clusters wanted
%	c       - calculated membership vector
% algorithm taken from Sing-Tze Bow, 'Pattern Recognition'

% Copyright (c) 1995 Frank Dellaert
% All rights Reserved

[d,n] = size(x);

%------------------------------------------------------------------------
% step 1: Arbitrarily choose nc samples as the initial cluster centers
%------------------------------------------------------------------------
nc=N(1);
ir=randperm(d);
ir=ir(:)';
c=x(ir(1:nc),:);
%[indAng,distAng]=knn(VCP(:,1:NCP),ERACP(:,1:NCP),ParamPrdc.NumA*2,'Norm-2');
io=NaN*ones([d,1]);
moved=d;

xn=min(x(:,1:2));
xx=max(x(:,1:2));
figure('DoubleBuffer','on')
subplot(1,2,1)
set(gca,'DataAspectRatio',[1 1 1],'box','on',...
   'XLimMode','manual','YLimMode','manual',...
   'Xlim',[xn(:,1) xx(:,1)],'YLim',[xn(:,1) xx(:,2)]);
hold on
subplot(2,2,2)
cla,hold on,box on
subplot(2,2,4)
cla,hold on,box on


ita=1;Veqa=[];Veqa2=[];Veda=[];
it=0;Veq=[];Veq2=[];Ved=[];
while(ita<length(N))
   [in,dn]=MLknn(x,c,1,'Norm-2');
   for i=1:nc
      ix=find(in==i);
      nx(i,1)=size(ix,1);
      c(i,:)=nanmean(x(ix,:),1);
      d(i,:)=nanmean(dn(ix,:).^2,1);
   end
   moved=sum(io~=in,1);
   io=in;
   
   
   it=it+1;
   eq=nanmean(d,1);
   %[in,dn]=knn(c,c,nc,'Norm-2');
   %ed=nanmean(nansum(dn.^2,2)./(size(c,1)-1),1);
   ed=nanmean(sqrt(nansum((c-repmat(nanmean(c,1),[size(c,1),1])).^2,2)),1);
   
   Ved=[Ved ed];
   Veq=[Veq eq];
   
   
   %if moved==0
      
      Cx=c(:,1);
      Cy=c(:,2);
      subplot(1,2,1)
      cla
      
      [Vx,Vy]=voronoi(Cx,Cy);
      plot(Vx,Vy,'b-',Cx,Cy,'r.');
      plot(Cx(end),Cy(end),'ko');
      %trisurf(delaunay(Cx,Cy),Cx,Cy,nx);
      %shading interp
      subplot(2,2,2)
      cla
      
      plot(Veq,'b-');
      plot(Ved,'k-');
      set(gca,'Xlim',[0 it]);
      
      
     if moved==0
      ita=ita+1;
      
      nc=N(ita);
      c=[c;x(ir((N(ita-1)+1):N(ita)),:)];
      subplot(2,2,4),cla
      Veda=[Veda ed];
      Veqa=[Veqa eq];
      
      
      plot(N(1:ita-1),log(Veqa),'b-');
      
      legend({['eq=' num2str(eq)]})
      set(gca,'FontName','Arial','FontSize',7)
      %plot((Veda+Veqa)/2,'k-');
      %set(gca,'Xlim',[0 ita]);
   end
   drawnow
   
end



