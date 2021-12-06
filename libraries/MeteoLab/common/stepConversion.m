function y=stepConversion(step,period)
if norm(stepvec(step))~=0
    step=stepvec(step);
end
period=stepvec(period);
n1=find(step~=0);
n2=find(period~=0);
valor1=step(n1);
valor2=period(n2);
factores=[60 60 24 30 365];
y=zeros(1,6);
if n2>n1
    aux=1/valor2;
    for i=n1:n2-1
        aux=aux*factores(i);
    end
    y(n2)=aux*valor1;
elseif n1==n2
    y(n1)=valor1/valor2;
else
    aux=valor1;
    for i=n2:n1-1
        aux=aux/factores(i);
    end
    y(n2)=aux/valor2;
end