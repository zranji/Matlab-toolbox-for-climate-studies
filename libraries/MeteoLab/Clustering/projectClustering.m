function [PatternsGroup,PatternDistanceGroupCenter]=projectClustering(Data,Cluster)

% clear all
% cd('C:/Work/Work/MeteoLab/'),init
% workPath='C:/Work/Work/Swen/';cd(workPath)
% cm=flipud(hot);close all
% lon=[-180:5:180];lat=[-90:5:90];
% [lon,lat]=meshgrid(lon,lat);dmn.nod=[lon(:) lat(:)]';Ngrid=size(dmn.nod,2);
% dmn.startDate='01-Jan-1971';dmn.endDate='31-Dec-2000';dmn.step='24:00';
% dmn.par={'SLP',0,0,0;'SLP',0,6,0;'SLP',0,12,0;'SLP',0,18,0;'SLP',0,24,0};
% alcances=[0 6 12 18 24];coeficientes=[1 2 2 2 1];
% ERA-40
% ctl='//oceano/gmeteo/DATA/ECMWF/ERA40/SD_Global/era40.ctl';
% dates=datevec([datenum(dmn.startDate):datenum(dmn.endDate)]');ndata=size(dates,1);data=repmat(NaN,ndata,Ngrid);
% for i=1:5
	% dmn1=dmn;dmn1.par=dmn.par(i,:);
	% [pattern,dmn1,fcDate]=loadGCM(dmn1,ctl,'dates',dates,'anHour','Analysis','ds',0);
	% for j=1:ndata
		% data(j,:)=nansum([data(j,:);coeficientes(i)*pattern(j,:)]);
	% end
	% clear pattern fcDate
% end
% data=0.125*data;
% Validamos la funcion makeClustering
% Clustering=makeClustering(data,'lamb',27,'location',dmn.nod','center',[-5 40]);
% [PatternsGroup,PatternDistanceGroupCenter]=projectClustering(data,Clustering);

switch lower(Cluster.Type),
	case 'lamb',
		PatternsGroup=lambtyping(Data,Cluster.lambCenter,'location',Cluster.Location);
		PatternDistanceGroupCenter=repmat(NaN,size(Data,1),1);
        for k=1:Cluster.NumberCenters,
            iC=find(PatternsGroup==k);
            if(~isempty(iC))
				PatternDistanceGroupCenter(iC)=nansum((Data(iC,:)-repmat(Cluster.Centers(k,:),length(iC),1)).^2,2);
            end
        end
	otherwise
		[PatternsGroup,PatternDistanceGroupCenter]=MLknn(Data,Cluster.Centers,1,'Norm-2');
end
