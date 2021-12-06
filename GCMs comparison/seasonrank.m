clc
clear
close all

cd('ncfiles')
nc=dir('*.nc');
obs='REANALYSIS.nc';
lon=ncread(obs,'lon');
lat=ncread(obs,'lat');
[X,Y]=meshgrid(lon,lat);
var={'psl','tas','hurs'};%%,'theta','u'

for k=1:size(var,2)
    clear statu s a C
    vars=ncread(obs,var{k});
    for i=1:size(nc,1)
        fldtmo=ncinfo(nc(i).name);
        a=char(fldtmo.Variables.Name);
        if all(~contains(a,var{k}))
            continue;
        end
        varsm=ncread(nc(i).name,var{k});
        cd ../shapefies
        S=shaperead('AS.shp');
        cd ../ncfiles
        Lon=repmat(lon,size(lat));
        Lat=repmat(lat,size(lon));
        [in,on]=inpolygon(Lon,Lat,S.X',S.Y');
    %     plot(Lon(in),Lat(in),'r+')
        CC=[Lon(in),Lat(in)];
            for x=1:size(lon)
                for y=1:size(lat)
                    CCC=[lon(x) lat(y)];
                    if ismember(CCC,CC,'rows')                    
                        mvars(x,y,:,:)=reshape(squeeze(vars(x,y,:))',12,[]); %% create 128years array
                        spring(x,y)=mean(mean(mvars(x,y,10:11,:))); %% 1:3 can be edited for the other seasons
                        mvarsm(x,y,:,:)=reshape(squeeze(varsm(x,y,:))',12,[]);
                        springm(x,y)=mean(mean(mvarsm(x,y,10:11,:)));
                    else
                        continue
    %                     mvars(x,y,:,:)=NaN;
    %                     mvarsm(x,y,:,:)=NaN;
                    end
                end
            end
            C=allstats(spring(:,:),springm(:,:));
            statu(i,:)=abs(C(:,2)-C(:,1));
    end
%     statu=statu(:,:,2);
    idx=find(all(statu==0,2));
    nc(idx)=[];
    statu(all(~statu,2),:)=[];
    for ii = 1 : size(statu,1)
%         if ii == 1
%            s{ii}='REANALYSIS';
%         else
           a=split(nc(ii).name,{'out_','.nc'});
           s{ii}=a{2,1};
%         end
    end
    T=table(statu(:,1),statu(:,2),statu(:,3),statu(:,4),statu(:,5),statu(:,6),statu(:,7));
    T.Properties.VariableNames ={'Mean','SD','RMSD','CC','Rsquared','RMSE','Bias'};
    T.name = s';
    cd ../statistics/
    save(strcat('statistics-',var{k},'.mat'),'T');
    meanst=mean(statu,3);
    meanst(:,7)=mean(abs(statu(:,7,:)),3); %remove negative value of bias for a meaningful average over stations
    modelrank(meanst,k,var{k},s)
    cd ../ncfiles
end