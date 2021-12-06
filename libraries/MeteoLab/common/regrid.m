function Z=regrid(X,loc1,loc2,varargin)

% Function to regrid a matrix into another grid or set of points. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example of calls to the function:
% Z=regrid(X,loc1,loc2,varargin)
% Inputs:
% Z=regrid(X,loc1,loc2,varargin)
%       - X is the NxM matrix to regrid, N is the number of timesteps in rows
% and M is the number of gridpoints or stations in columns. X can also be a
% row vector.
%       - loc1: is the Mx2 matrix containing the location of the
%       gridpoints or stations in X. Notice that it is necessary to have
%       longitude and latitude in columns, respectively.
%       - loc2: is the matrix containing the location for the new
%       gridpoints or stations. Again, the first column corresponds to
%       longitude and the second to latitude.
%       - varargin: different interpolation methods can be applied:
%       'linear', 'nearest'(default option),'cubic'. The 'cubic' method produces smooth surfaces while 'linear' and 'nearest' have  discontinuities in the first and zero-th derivative respectively.  All
%       the methods are based on a Delaunay triangulation of the data. 
% Output:
%       -Z is a matrix which has as many rows as timesteps in X (N) and as many
%       columns as stations or gridpoints in loc2.
% For more details, type: help griddata.
% Examples:
% %Example 1: from grid to grid:
            % %First, define two grids:
            % lon1=-15:2.5:5;lat1=35:2.5:47.5;[lon,lat]=meshgrid(lon1,lat1);loc1=[lon(:) lat(:)];
            % lon2=0:0.5:5;lat2=40:0.5:44;[lon,lat]=meshgrid(lon2,lat2);loc2=[lon(:) lat(:)];
            % %X is the data we would like to interpolate:
            % X=rand(40,size(loc1,1)); % Suppose that 40 is the number of timesteps.
            % figure,drawFilledBox(nanmean(X),loc1,'size',2.5,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
            % Z=regrid(X,loc1,loc2,'method','nearest');
            % figure,drawFilledBox(nanmean(Z),loc2,'size',0.5,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
% %Example 2: from grid to points:
            % %First, define the grid
            % lon1=-15:2.5:5;lat1=35:2.5:47.5;[lon,lat]=meshgrid(lon1,lat1);loc1=[lon(:) lat(:)];
            % %Select the points we would like to interpolate into:
            % loc2=[-5.40 41;2.20 41.40;-6.18 36.32;-0.02 39.59;-8.23 43.22];
            % %X is the data matrix, for the example we randomize it:
            % X=rand(40,size(loc1,1));
            % figure,drawFilledBox(nanmean(X),loc1,'size',2.5,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
            % Z=regrid(X,loc1,loc2,'method','nearest');
            % figure,drawFilledBox(nanmean(Z),loc2,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
% %Example 3: from points to grid:
            % %The original points are:
            % loc1=[-5.40 41;2.20 41.40;-6.18 36.32;-0.02 39.59;-8.23 43.22];
            % %Then, we build a grid:
            % lon2=-15:2.5:5;lat2=35:2.5:47.5;[lon,lat]=meshgrid(lon2,lat2);loc2=[lon(:) lat(:)];
            % X=rand(40,size(loc1,1));
            % figure,drawFilledBox(nanmean(X),loc1,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
            % Z=regrid(X,loc1,loc2,'method','nearest');
            % figure,drawFilledBox(nanmean(Z),loc2,'size',2.5,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
% %Example 4: from points to points:
            % % Define the original and the final set of points
            % loc1=[-5.40 41;2.20 41.40;-6.18 36.32;-0.02 39.59;-8.23 43.22];
            % loc2=[-6.22 39.28;-3.42 42.20;-3.35 37.11;-7.33 43.01;-5.59 37.23;-0.52 41.39];
            % % Build the data matrix
            % X=rand(40,size(loc1,1));
            % figure,drawFilledBox(nanmean(X),loc1,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
            % Z=regrid(X,loc1,loc2);
            % figure,drawFilledBox(nanmean(Z),loc2,'xlim',[-10 5],'ylim',[34 45],'colorbar',true,'clim',[0 1])
% %Example 5: real data in the MLToolbox directory:
            % First, the NCEP Reanalysis data, from 1958 to 2011, in a domain over the Iberian
            % Peninsula is loaded:
%             dmn=readDomain('D:/Ana/MLToolbox/GCMData/NCEP/Iberia_NCEP'); % Path relative to 'MLToolbox/GCMData/NCEP/'; otherwise give full path.
%             dmn1=dmn;dmn1.par=dmn.par(2,:); %Select only temperature
%             [patterns,dmn,fcDate]=loadGCM(dmn1,'D:/Ana/MLToolbox/GCMData/NCEP/Iberia_NCEP');patterns=patterns-273;
%             figure,drawFilledBox(nanmean(patterns),dmn1.nod','size',2.5,'colorbar',true,'clim',[5 12])
%             % Second, load observation data from GSN (Global Station
%             % Network) for European stations:
%             Example.Network={'D:/Ana/MLToolbox/ObservationsData/GSN'}; % Path relative to 'MLToolbox/ObservationsData/'; otherwise give full path.
%             Example.Stations={'Europe.stn'};
%             Example.Variable={'Tmax'}; 
%             period={'01-Jan-1961','31-Dec-2000'};
%             [data,Struct]=loadObservations(Example,'dates',period);
%             %We want to regrid NCEP renalysis into GSN stations:
%             ZI=regrid(patterns,dmn.nod',Struct.Info.Location,'method','nearest');
%             figure,drawFilledBox(nanmean(ZI),Struct.Info.Location,'xlim',[-15 5],'ylim',[35 47.5],'colorbar',true,'clim',[5 12])
%             % And then, regrid again from GSN station to NCEP domain in the Iberian Peninsula:
%             ZII=regrid(ZI,Struct.Info.Location,dmn.nod','method','nearest');
%             figure,drawFilledBox(nanmean(ZII),dmn.nod','colorbar',true,'clim',[5 12],'size',2.5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
method='nearest';[ndata,Nest]=size(X);Ngrid=size(loc2,1);neigh=min(10,Nest);
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'method', method = varargin{i+1};
        case 'neigh', neigh=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}))
            
    end
end
%Inicializo la matriz
Z=repmat(NaN,ndata,Ngrid);
% Según el método de interpolación aplico los distintos casos de griddata
switch lower(method)
    case {'linear','nearest','cubic'}
        for i=1:ndata
            z=griddata(loc1(:,1),loc1(:,2),X(i,:)',loc2(:,1),loc2(:,2),lower(method));
            Z(i,:)=z';
        end
	case {'idw','interp'}
		[lista,dd]=MLknn(loc2,loc1,neigh,2);lista(find(dd(:,1)==0),:)=repmat(lista(find(dd(:,1)==0),1),1,neigh);dd(find(dd(:,1)==0),:)=1;dd=1./dd.^2;dd=dd./repmat(sum(dd,2),1,neigh);
        for i=1:ndata
            aux=repmat(NaN,neigh,Ngrid);for j=1:Ngrid,aux(:,j)=X(i,lista(j,:))';end
            Z(i,:)=nansum(aux.*dd');
        end
    otherwise, warning('Unknown interpolation method')
end
