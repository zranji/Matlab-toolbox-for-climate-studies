function [io,c,nx] = kmeans(x,nc)
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
ir=randperm(d);
ir=ir(1:nc)';
c=x(ir,:);
%[indAng,distAng]=knn(VCP(:,1:NCP),ERACP(:,1:NCP),ParamPrdc.NumA*2,'Norm-2');
io=NaN*ones([d,1]);
moved=d;
while(moved~=0)
   [in]=MLknn(x,c,1,'Norm-2');
   for i=1:nc
      ix=find(in==i);
      if ~isempty(ix)
          nx(i,1)=size(ix,1);
          c(i,:)=nanmean(x(ix,:),1);
      end
   end
   moved=sum(io~=in,1);
   io=in;
   disp(['moved = ' num2str(moved)]);
end



