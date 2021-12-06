N=100;
x1=rand(N,1)-0.5;  x2=rand(N,1).*2-1; 
x3=x2+x1./2+randn(N,1).*(1/8);
dat=[x1 x2 x3];
[n1 n2]=size(dat);

%Singular value decomposition
[res,valsing,eof]=svd(dat./sqrt(n1-1));
eof

v=diag(valsing).^2;
v./sum(v)*100        %Percentage of explained variance

%Drawing
k=linspace(0,1,2);

figure
plot3(k*eof(1,1),k*eof(2,1),k*eof(3,1),...
   'r',k/2*eof(1,2),k/2*eof(2,2),k/2*eof(3,2),...
   'r--',x1,x2,x3,'k.')
xlabel('x'),ylabel('w'),zlabel('z'),view(-5,10)
