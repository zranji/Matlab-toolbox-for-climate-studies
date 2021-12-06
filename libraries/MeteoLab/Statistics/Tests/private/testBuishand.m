function [pValue,T,N,K]=testBuishand(Y,varargin)
% Esta funcion realiza el test de homogeneidad de Buishand. 
% Input:      - Y: matriz de datos a analizar. Cada columna es una estacion.
%	       - 'window'      - window size to aggregate the data (e.g. 365 for
%                     years is the data is daily). The default value is 1.
% 	       - 'missing'     - Maximum rate of missing data within each window to be
% 	                  considered not a NaN (movingAverage function). Default zero.
% Output:     - pValue: El nivel de significancia del test.
%             - T: El valor del estadistico para cada estacion.
%             - N: El numero de datos utilizado para cada estacion.
%  
% valores criticos:
%   n     20     30      40      50      70      100
% 0.01   1.60   1.70    1.74    1.78    1.81     1.86
% 0.05   1.43   1.50    1.53    1.55    1.59     1.62
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
alpha=[1.60,1.70,1.74,1.78,1.81,1.86;...
        1.43,1.50,1.53,1.55,1.59,1.62];
[n,Nest]=size(Y);
aux=NaN*zeros(length(critValue),n);
for i=1:length(critValue)
    aux(i,:)=interp1(muestra,alpha(i,:),[1:n],'spline');
end
alpha=aux;clear aux

pValue=zeros(Nest,1)+NaN;
K=repmat(NaN,Nest,2);
T=zeros(Nest,1)+NaN;
N=sum(~isnan(Y),1)';
media=nanmean(Y);
desviacion=nanstd(Y);
for i=1:Nest
    ind=find(~isnan(Y(:,i)));
    S=zeros(N(i)+1,1);
    S(1)=0;
    for j=1:N(i)
        S(j+1)=nansum(Y(ind(1:j),i)-media(i)*ones(j,1));
    end
	[a1,a2]=max(S);K(i,1)=a2;[a11,a21]=min(S);K(i,2)=a21;
    R=(a1-a11)/desviacion(i);
    T(i)=R/sqrt(N(i));
    if ~isnan(T(i))
        if N(i)>=15
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