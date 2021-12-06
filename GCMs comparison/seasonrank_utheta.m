clc
clear
close all

cd('ncfiles')
nc=dir('*.nc');
obs='REANALYSIS.nc';
lon=ncread(obs,'lon');
lat=ncread(obs,'lat');
[X,Y]=meshgrid(lon,lat);
vars1=ncread(obs,'uas');
vars2=ncread(obs,'vas');
[thetao,mago]=cart2pol(vars1,vars2);
thetao=mod(thetao,2*pi());
thetao=rad2deg(thetao);
thetao=mod((270-thetao),360);
    for i=1:size(nc,1)
        fldtmo=ncinfo(nc(i).name);
        a=char(fldtmo.Variables.Name);
        if all(~contains(a,'uas'))
            continue;
        end
        varsm1=ncread(nc(i).name,'uas');
        varsm2=ncread(nc(i).name,'vas');
        [thetam,magm]=cart2pol(varsm1,varsm2);
        thetam=mod(thetam,2*pi());
        thetam=rad2deg(thetam);
        thetam=mod((270-thetam),360);
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
                        mvars(x,y,:,:)=reshape(squeeze(thetao(x,y,:))',12,[]); %% create 128years array
                        spring(x,y)=mean(mean(thetao(x,y,10:11,:))); %% 1:3 can be edited for the other seasons
                        mvarsm(x,y,:,:)=reshape(squeeze(thetam(x,y,:))',12,[]);
                        springm(x,y)=mean(mean(thetam(x,y,10:11,:)));
                    else
                        continue
    %                     mvars(x,y,:,:)=NaN;
    %                     mvarsm(x,y,:,:)=NaN;
                    end
                end
            end
            C=allstatstheta(spring(:,:),springm(:,:)); %% allstatstheta
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
    save('statistics-theta.mat','T');
    meanst=mean(statu,3);
    meanst(:,7)=mean(abs(statu(:,7,:)),3); %remove negative value of bias for a meaningful average over stations
    modelrank(meanst,1,'theta',s)
    cd ../ncfiles