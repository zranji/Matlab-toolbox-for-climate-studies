function SOAT=getMeans(Ptnd,D,d,fcDate,method,VALID_PERCENTAGE)

if nargin<6 | isempty(VALID_PERCENTAGE)
    VALID_PERCENTAGE=0.5;
end
if nargin<5 | isempty(method)
    method='mean';
end


if nargin<4
	%indObj=1:size(Ptnd,1);
   %[YY,MM,DD]=datevec((indObj)+datenum(1979,1,1)-1);
   error('El numero de argumentos debe ser cuatro')
else
   YY=fcDate(:,1)';
   MM=fcDate(:,2)';
   DD=fcDate(:,3)';
end


%mesI=[11,0,1];anioI=[1978,1979,1979];
Meses=[31 28 31 30 31 30 31 31 30 31 30 31;...
       31 29 31 30 31 30 31 31 30 31 30 31];
if DD<Meses(1+isLeap(YY),MM)
   YY=YY(1:end-DD);MM=MM(1:end-DD);DD=DD(1:end-DD);
end
P=[];

clear SO SN SNT SP
Yn=min(YY);
Yx=max(YY);
SO=zeros([12 Yx-Yn+1 size(Ptnd,2)])+NaN;
SN=zeros([12 Yx-Yn+1 size(Ptnd,2)])+NaN;
SNT=zeros([12 Yx-Yn+1 1])+NaN;
for mes=1:12
   %fprintf(1,['Month ' datestr(datenum(1979,mes,1),3) '\n']);
   indSrc=find(MM==mes);
   i=1;
   for y=min(YY(indSrc)):max(YY(indSrc))
      ind=indSrc(find(MM(indSrc)==mes & YY(indSrc)==y));
      switch method
          case 'mean'
              [O,N]=nanmean(Ptnd(ind,:),1);
          case 'std'
              [O,N]=nanstd(Ptnd(ind,:),1);
          case 'sum'
              [O,N]=nansum(Ptnd(ind,:),1);
          case 'max'
              [O]=nanmax(Ptnd(ind,:),1);
              N=sum(~isnan(Ptnd(ind,:)),1);
          case 'min'
              [O]=nanmin(Ptnd(ind,:),1);
              N=sum(~isnan(Ptnd(ind,:)),1);
          otherwise
              error(sprintf('Unknown method: %s',method));
      end
      
      SNT(mes,y-Yn+1,1)=Meses(isLeap(y)+1,mes);
      SO(mes,y-Yn+1,:)=reshape(O,[1 1 size(Ptnd,2)]);
      SN(mes,y-Yn+1,:)=reshape(N,[1 1 size(Ptnd,2)]);   
      i=i+1;
   end
end

SOAT=SO;
%if not a 50% of data put NaN
ind=find(SN./repmat(SNT,[1 1 size(SN,3)])<VALID_PERCENTAGE);
SOAT(ind)=NaN;

SOAT=reshape(SOAT,[size(SO,1)*size(SO,2),size(SO,3)]);

%D=3;d=1;

TEMP=NaN*ones([size(SOAT) D]);
ind=1:d:(size(SOAT,1)-D+1);
for i=0:D-1
   TEMP(ind,:,i+1)=SOAT(ind+i,:);
end
SOAT=nanmean(TEMP,3);
clear TEMP TEMP2

SOAT=reshape(SOAT,[size(SO,1),size(SO,2),size(SO,3)]);
