function [pValue,T,N,K,ST]=testSnht(Y,varargin)
% [pValue,T,N]=testSnht(data,varargin)
% 
% Input
% 	data(:,k)   : Daily data series for each of the 'k' stations.
% 	varargin	: optional parameters
%	       - delta:  {5}
%               - criticalValue: {'simulacion'} or 'tabla'. 
%	       - 'window'      - window size to aggregate the data (e.g. 365 for
%                     years is the data is daily). The default value is 1.
% 	       - 'missing'     - Maximum rate of missing data within each window to be
% 	                  considered not a NaN (movingAverage function). Default zero.
% valores criticos:
% n     10     20      30      40      50      60     70     80      90      100      150      250
% 1          9.56   10.45   11.01   11.38          11.89                   12.32
% 2.5 6.25   7.80    8.65    9.25    9.65    9.85   10.1   10.2    10.3     10.4     10.8     11.2
% 5   5.70   6.95    7.65    8.10    8.45    8.65   8.80   8.95    9.05     9.15     9.35     9.70
% 10  5.05   6.10    6.65    7.00    7.25    7.40   7.55   7.70    7.80     7.85     8.05     8.35
% 	
% Output    
% 	pValue      : p-value of the test for each of the stations.
%   T           : statistic of test de Alexandersson.
%   N           : sample size used to run the test.
%   K           : year of shift.
%   ST          : SNHT's statistic.
% 
% Examples
% 
% 		pValue=testSnht(data,'criticalValue','simulacion','delta',5);

window=1;
missing=0;
criticalValue='simulacion';
delta=5;
dispWaiting=1;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'criticalvalue',
            criticalValue=varargin{i+1};
		case 'delta'
			delta=varargin{i+1};
		case 'window'
			window=varargin{i+1};
		case 'missing'
			missing=varargin{i+1};
		case 'disp'
			dispWaiting=varargin{i+1};
    end
end

load('pValueSnht.txt');
muestra=pValueSnht(2:end,1);
critValue=pValueSnht(1,2:end);
alpha=pValueSnht(2:end,2:end)';
Y=movingAverage(Y(:,:),window,'missing',missing);

[n,Nest]=size(Y);
aux=NaN*zeros(length(critValue),n);
for i=1:length(critValue)
    aux(i,:)=interp1(muestra(find(~isnan(alpha(i,:)))),alpha(i,find(~isnan(alpha(i,:)))),[1:n],'spline');
end
alpha=aux;clear aux
pValue=zeros(Nest,1)+NaN;
T=zeros(Nest,1)+NaN;
N=zeros(Nest,1)+NaN;
K=zeros(Nest,1)+NaN;
for i=1:Nest
	novacios=find(~isnan(Y(:,i)));
    dato=Y(novacios,i);
    N(i)=length(dato);
    if N(i)>2*delta+1
        z=pstd(dato);
        Alx=zeros(1,N(i)-1);
        % We do not consider a break in the initial and last delta points.
        for j=1:N(i)-1
            m_ant=mean(z(1:j));
            m_post=mean(z(j+1:N(i)));
            Alx(j)=j*m_ant.^2+(N(i)-j)*m_post.^2;
        end
		ST{i}.Alex=Alx;
        [T(i),K(i)]=nanmax(Alx(delta+1:N(i)-1-delta),2);
		K(i)=novacios(K(i)+delta);
        switch criticalValue
            case 'simulacion'
                cAlex=Alex(N(i),delta);
                if isempty(min(find(T(i)<=cAlex)))
                    pValue(i)=0;
                else
                    pValue(i)=min(find(T(i)<=cAlex));
                end
                pValue(i)=1-pValue(i)/100;  % Passing from confidence to significance (pValue)                
            case 'tabla'
                aux=alpha(:,N(i));
                if ~isnan(T(i))
                    b=find(aux<=T(i));
                    if ~isempty(b)
                        pValue(i)=critValue(max(b));
					else
						pValue(i)=0.5;
                    end
                end
                
        end
    end
	if dispWaiting & (mod(i-1,floor(Nest/10))==0) disp([num2str(i) '/' num2str(Nest)]); end
end


% FUNCIONES AUXILIARES:

function cAlex=Alex(N,delta)
if N>1
    sample=10000;
    z=normrnd(0,1,N,sample);
    Alx=zeros(N-1,sample);
    for i=1:N-1
        m_ant=mean(z(1:i,:));
        m_post=mean(z(i+1:N,:));
        Alx(i,:)=i*m_ant.^2+(N-i)*m_post.^2;
    end
    T=max(Alx(delta:N-delta+1,:));
    cAlex=prctile(T,1:100);
else
    disp('N must be a greater than one')
    cAlex=zeros(1,100);
end