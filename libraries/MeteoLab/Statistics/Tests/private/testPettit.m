function [pValue,T,N,K]=testPettit(Y,varargin)
% Esta funcion realiza el test de homogeneidad de Pettit. 
% Input:      - Y: matriz de datos a analizar. Cada columna es una estacion.
% Output:     - pValue: El nivel de significancia del test.
%             - T: El valor del estadistico para cada estacion.
%             - N: El numero de datos utilizado para cada estacion.
%  
% valores criticos:
% valores criticos:
%    n     20     30      40      50      70      100
% 0.01     71    133     208     293     488      841
% 0.05     57    107     167     235     393      677
%
% Este test solo devuelve dato para aquellas estaciones que tiene
% significancias [0.01, 0.05] y con mas de 15 datos.

window=1;
missing=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
		case 'window'
			window=varargin{i+1};
		case 'missing'
			missing=varargin{i+1};
    end
end
Y=movingAverage(Y(:,:),window,'missing',missing);

critValue=[0.01;0.05];
muestra=[20,30,40,50,70,100];
alpha=[71,133,208,293,488,841;...
        57,107,167,235,393,677];
[n,Nest]=size(Y);
aux=NaN*zeros(length(critValue),n);
for i=1:length(critValue)
    aux(i,:)=interp1(muestra,alpha(i,:),[1:n],'spline');
end
alpha=aux;clear aux
pValue=zeros(Nest,1)+NaN;
N=zeros(Nest,1)+NaN;
T=zeros(Nest,1)+NaN;
K=zeros(Nest,1)+NaN;
for i=1:Nest
    ind=find(~isnan(Y(:,i)));
    N(i)=length(ind);
    if N(i)>=15
        r=zeros(N(i),1)*NaN;
        X=zeros(N(i),1)*NaN;
        aux1=unique(Y(ind,i));
        aux2=sort(Y(ind,i));
        for l=1:length(aux1)
            a=find(aux2==aux1(l));
            b=find(Y(ind,i)==aux1(l));
            if length(a)>1
                r(b)=mean(a);
            else
                r(b)=a;
            end
        end 
        for j=1:N(i)
            X(j)=2*nansum(r(1:j))-j*(N(i)+1);
        end
        [T(i),K(i)]=max(abs(X),[],1);
        aux=alpha(:,N(i));
        if ~isnan(T(i))
            b=find(alpha(:,N(i))<=T(i));
            if ~isempty(b)
                pValue(i)=critValue(min(b));
            end
        end
    end
    if (mod(i-1,floor(Nest/10))==0)
        disp([num2str(i) '/' num2str(Nest)]);
    end
end
