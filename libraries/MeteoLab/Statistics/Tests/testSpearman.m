function [r,t,p]=testSpearman_dev(x,y)

% x and y must have equal number of rows
[ndata,nx]=size(x);ny=size(y,2);
if ndata~=size(y,1)
    error('x and y must have equal number of rows.');
end
r=NaN*zeros(nx,ny);
t=NaN*zeros(nx,ny);
% for i=1:nx
%     % Get the ranks of x
%     R=crank(x(:,i));
%     % Find the data length
%     RR=double(~isnan(x(:,i)));
%     for j=1:ny
%         % Get the ranks of y
%         S=crank(y(:,j));
%         SS=double(~isnan(y(:,j))).*RR;
%         % Calculate the correlation coefficient
%         N(i,j)=nansum(SS);
%         r(i,j)=1-6*sum(((R-S).*SS).^2)/(N(i,j)*(N(i,j)^2-1));
%     end
% end
for i=1:nx
    % Find the data length
    RR=double(~isnan(x(:,i)));
    for j=1:ny
        SS=double(~isnan(y(:,j))).*RR;
        % Get the ranks of x
        [R,Ra]=crank(x(find(SS),i));
        % Get the ranks of y
        [S,Sa]=crank(y(find(SS),j));
        % Calculate the correlation coefficient
        N(i,j)=nansum(SS);
        % r(i,j)=1-6*sum((R-S).^2)/(N(i,j)*(N(i,j)^2-1));
		r(i,j)=(N(i,j)*(N(i,j)^2-1)-(Ra+Sa)-6*sum((R-S).^2))/sqrt((N(i,j)*(N(i,j)^2-1)-2*Ra)*(N(i,j)*(N(i,j)^2-1)-2*Sa));
    end
end
% Calculate the t statistic
t(find(abs(r)==1))=Inf;
t(find(abs(r)~=1))=r(find(abs(r)~=1)).*sqrt((N(find(abs(r)~=1))-2)./(1-r(find(abs(r)~=1)).^2));
% if r == 1 | r == -1
%     t = r*inf;
% else
%     t=r.*sqrt((N-2)./(1-r.^2));
% end

% Calculate the p-values
p=2*(1-tcdf(abs(t),N-2));

function [r,ra]=crank(x)

u=unique(x);
[xs,z1]=sort(x);
[z1,z2]=sort(z1);
r=(1:length(x))';
r=r(z2);
ra=0;
for i=1:length(u)
	s=find(u(i)==x);
	r(s)=nanmean(r(s));
	ra=ra+length(s)*(length(s)-1)*(length(s)+1)/2;
end
