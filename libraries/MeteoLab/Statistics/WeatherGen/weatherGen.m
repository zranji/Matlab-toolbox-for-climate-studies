function [simb,xwg]=weatherGen(data,threshold,order,N,type)
%[simb,xwg,i,c]=weatherGen(data,threshold,order,N,type)
%observed data, list of thresholds, order of the process and size of sample.
%Type can be 'markov' (discrete process for the symbols given by the thresholds) or 
%			    'wg' (real values of precipitation are simulated from an exponential).
%Example:
%			load datoSanSebastian
%			weatherGen(data,[0,0.5,10,20,inf],1,100,'markov')
%Output:
% simb=   Simulated symbolic data
% xwg=    amounths for rainy days (for type='wg' option)
% c =     Markov probabilities

symbols=size(threshold,2)-1;

% Computing Markov probabilities. Maximum order = 2
i(size(data,1),1)=0;
for k=1:size(threshold,2)-1,
    i(find(data(:)>=threshold(k) & data(:)<threshold(k+1)))=k;
end
i(find(isnan(data(:))))=NaN;
ii=i(~isnan(data(:)));

c=zeros(symbols,symbols,symbols);

n=0;
for k=order+1:size(data,1)
   s=0;for kk=0:order; s=s+i(k-kk);end
   if(~isnan(s))
      if(order==0)
         c(:,:,i(k))=c(:,:,i(k))+1;n=n+1;
      elseif(order==1)
         c(:,i(k-1),i(k))=c(:,i(k-1),i(k))+1;n=n+1;
      else  
         c(i(k-2),i(k-1),i(k))=c(i(k-2),i(k-1),i(k))+1;n=n+1;
      end
   end
end

%Normalization of the distribution function
%cumsum can be used at this step
for k=2:symbols
   c(:,:,k)=c(:,:,k)+c(:,:,k-1);
end
for k=1:symbols
   c(:,:,k)=c(:,:,k)./c(:,:,symbols);
end

% Simulating symbolic data
simb=ones(N,1); simwg=[];
for k=1:3
   simb(k)=1;
end
for k=3:N
   u=rand;
   simb(k)=min(find(c(simb(k-2),simb(k-1),:)>=u));
end

% Calculating autocorrelation of observed and simulated data
long=30;
for k=1:long
   c1=corrcoef(ii(k:end,1),ii(1:end-k+1,1));
   c2=corrcoef(simb(k:end,1),simb(1:end-k+1,1));
   cc1(k)=c1(1,2);
   cc2(k)=c2(1,2);
end
figure;
ind=1:long;
plot(ind,cc1,'k',ind,cc2,'r')
xlabel('n'); ylabel('autocorrelation');
legend('observed\_data','Markov\_data')

% Generating real amounths for rainy days
% for type='wg' option
xwg=[];
if(~isequal(type,'markov'))
   dp=find(data(:,1)>0); %dias de lluvia
   mu=nanmean(data(dp,1));
   dd=zeros(size(find(simb>1),1),1);
   for k=1:size(dd,1)
      y=rand;
      dd(k,1)=-mu*log(1-y);
   end
   xwg=zeros(N,1);
   xwg(find(simb>1))=dd;
   
   % Making the sequence symbolic
   simwg(N,1)=0;
   for k=1:size(threshold,2)-1,
      simwg(find(xwg(:)>=threshold(k) & xwg(:)<threshold(k+1)))=k;
   end
   % Computing autocorrelation
   for k=1:long
      c3=corrcoef(simwg(k:end,1),simwg(1:end-k+1,1));
      cc3(k)=c3(1,2);
   end
   plot(ind,cc3,'b');
   xlabel('n'); ylabel('autocorrelation');
   legend('observed\_data','Markov\_data','WG\_data')
end

