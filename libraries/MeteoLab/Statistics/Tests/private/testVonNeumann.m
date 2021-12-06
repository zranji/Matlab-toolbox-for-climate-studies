function [pValue,T,N]=testVonNeumann(Y)
% Esta funcion realiza el test de homogeneidad de VonNeumann. 
% Input:      - Y: matriz de datos a analizar. Cada columna es una estacion.
% Output:     - pValue: El nivel de significancia del test.
%             - T: El valor del estadistico para cada estacion.
%             - N: El numero de datos utilizado para cada estacion.
%  
% valores criticos:
%   n       10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   32   34   36   38   40   42   44   46   48   50   55   60   65   70   75   80   85   90   95  100
% .005    0.62 0.67 0.71 0.74 0.78 0.81 0.84 0.87 0.89 0.92 0.94 0.96 0.98 1.00 1.02 1.04 1.05 1.07 1.08 1.10 1.11 1.13 1.16 1.18 1.20 1.22 1.24 1.25 1.27 1.28 1.29 1.33 1.35 1.38 1.40 1.42 1.44 1.45 1.47 1.48 1.49
% .010    0.72 0.77 0.81 0.84 0.87 0.90 0.93 0.96 0.98 1.01 1.03 1.05 1.07 1.09 1.10 1.12 1.13 1.15 1.16 1.18 1.19 1.21 1.23 1.25 1.27 1.29 1.30 1.32 1.33 1.35 1.36 1.39 1.41 1.43 1.45 1.47 1.49 1.50 1.52 1.53 1.54
% .025    0.89 0.93 0.96 1.00 1.03 1.05 1.08 1.10 1.13 1.15 1.17 1.18 1.20 1.22 1.23 1.25 1.26 1.27 1.28 1.30 1.31 1.33 1.35 1.36 1.38 1.39 1.41 1.42 1.43 1.45 1.46 1.48 1.50 1.52 1.54 1.55 1.57 1.58 1.59 1.60 1.61
% .050    1.04 1.08 1.11 1.14 1.17 1.19 1.21 1.24 1.26 1.27 1.29 1.31 1.32 1.33 1.35 1.36 1.37 1.38 1.39 1.40 1.41 1.43 1.45 1.46 1.48 1.49 1.50 1.51 1.52 1.53 1.54 1.56 1.58 1.60 1.61 1.62 1.64 1.65 1.66 1.66 1.67
% .100    1.23 1.26 1.29 1.32 1.34 1.36 1.38 1.40 1.41 1.43 1.44 1.45 1.46 1.48 1.49 1.50 1.51 1.51 1.52 1.53 1.54 1.55 1.57 1.58 1.59 1.60 1.61 1.62 1.63 1.63 1.64 1.66 1.67 1.68 1.70 1.71 1.71 1.72 1.73 1.74 1.74

% significancias [0.005,0.01,0.025,0.05,0.1] y con mas de 10 datos.

critValue=[0.005;0.01;0.025;0.05;0.1];
muestra=[10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32,34,36,38,40,42,44,46,48,50,55,60,65,70,75,80,85,90,95,100];
alpha=[0.62 0.67 0.71 0.74 0.78 0.81 0.84 0.87 0.89 0.92 0.94 0.96 0.98 1.00 1.02 1.04 1.05 1.07 1.08 1.10 1.11 1.13 1.16 1.18 1.20 1.22 1.24 1.25 1.27 1.28 1.29 1.33 1.35 1.38 1.40 1.42 1.44 1.45 1.47 1.48 1.49;...
    0.72 0.77 0.81 0.84 0.87 0.90 0.93 0.96 0.98 1.01 1.03 1.05 1.07 1.09 1.10 1.12 1.13 1.15 1.16 1.18 1.19 1.21 1.23 1.25 1.27 1.29 1.30 1.32 1.33 1.35 1.36 1.39 1.41 1.43 1.45 1.47 1.49 1.50 1.52 1.53 1.54;...
    0.89 0.93 0.96 1.00 1.03 1.05 1.08 1.10 1.13 1.15 1.17 1.18 1.20 1.22 1.23 1.25 1.26 1.27 1.28 1.30 1.31 1.33 1.35 1.36 1.38 1.39 1.41 1.42 1.43 1.45 1.46 1.48 1.50 1.52 1.54 1.55 1.57 1.58 1.59 1.60 1.61;...
    1.04 1.08 1.11 1.14 1.17 1.19 1.21 1.24 1.26 1.27 1.29 1.31 1.32 1.33 1.35 1.36 1.37 1.38 1.39 1.40 1.41 1.43 1.45 1.46 1.48 1.49 1.50 1.51 1.52 1.53 1.54 1.56 1.58 1.60 1.61 1.62 1.64 1.65 1.66 1.66 1.67;...
    1.23 1.26 1.29 1.32 1.34 1.36 1.38 1.40 1.41 1.43 1.44 1.45 1.46 1.48 1.49 1.50 1.51 1.51 1.52 1.53 1.54 1.55 1.57 1.58 1.59 1.60 1.61 1.62 1.63 1.63 1.64 1.66 1.67 1.68 1.70 1.71 1.71 1.72 1.73 1.74 1.74];
[n,Nest]=size(Y);
aux=NaN*zeros(length(critValue),n);
for i=1:length(critValue)
    aux(i,:)=interp1(muestra,alpha(i,:),[1:n],'spline');
end
alpha=aux;clear aux
media=nanmean(Y);
pValue=zeros(Nest,1)+NaN;
N=sum(~isnan(Y),1)';
T=nansum((Y(1:n-1,:)-Y(2:n,:)).^2)./nansum((Y-repmat(media,n,1)).^2);T=T';
for i=1:Nest
    if N(i)>=10
        if ~isnan(T(i))
            b=find(alpha(:,N(i))>=T(i));
            if ~isempty(b)
                pValue(i)=critValue(min(b));
            end
        end
    end
    if (mod(i-1,floor(Nest/10))==0)
        disp([num2str(i) '/' num2str(Nest)]);
    end
end