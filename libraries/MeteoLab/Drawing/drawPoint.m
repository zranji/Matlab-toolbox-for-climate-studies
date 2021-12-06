function drawPoint(data,location,varargin)
%drawFilledBox  Scatter plot for a set of coloured boxes/squares in a map (e.g. grid points or stations).
%   drawFilledBox(DATA,LOC,varargin) displays tiles with colors DATA
%   at the geographical locations specified by the vector LOC.
%   If DATA is a matrix, a different subplot will be displayed
%   for each of the rows.
%   -> Buiding on 'drawStations' function.
%
%   Input:
%	DATA		: values to be plotted (in rows). A single row (1,n) produces a
%                 single plot and a matrix (m,n) produces a mosaic following
%                 the standard display: left-right, top-bottom.
%	LOC		    : matrix of size (n,2) with longitude and latitude coordinates.
%	varargin	: Optional arguments
%	    'lattice'	-   vector [a b] to draw the mosaic in a lattice (m<a*b).
%                       By default a=b=sqrt(m)
%		'clim'      -   vector of bounds for the color plot.
%       'size'      -   Size of the mosaics in degrees (1 by default).
%		'titles'	-   cell of size m with the plot titles
%		'colormap'	-   colormap used in the plots
%		'colorbar'	-   true or {false} to draw the colorbars
%		'resolution'	-	{'low'}, or 'high' to draw the contours map with the coastlines;
%							high resolution is restricted to the Iberian peninsula.
%		'xlim'			-   longitude bounds for the drawing area (automatic by default)
%		'ylim'			-   latitude bounds for the drawing area (automatic by default)
%		'markPoints'	-   vector(d,2) or cell{m}(dm,2) of locations to mark particular points
%                           (cities, centers of grid boxes, etc.).
%
% Example:
%       LOC=[-3.9 43.4; -3.7 40.5; -6.4 36.5; 2.15 41.3];   % Map wit h4 points
%       DATA=[2 1 1.5 3; 1 3 2.5 1];                        % 2 samples (maps)
%		drawFilledBox(DATA,LOC,'lattice',[2 1],'xlim',[-10,5],'ylim',[35,45],'colorbar',true)
%       % Drawing with marked locations:
%       markLOC{1}=[-3.9 43.4;-3.7 40.5]; % LOCs for first sample
%       markLOC{2}=[-6.4 36.5];           % LOCs for second sample
%       drawFilledBox(DATA,LOC,'markPoints',markLOC,'colorbar','true')
%
%       % Drawing the mean temperature in Europe (2 degree tiles)
%       GSN.Network={'GSN'};
%       GSN.Stations={'europe.stn'};
%       GSN.Variable={'Tmax'};
%       [data,GSN]=loadStations(GSN,'dates',{'1-Jan-1981','31-Dec-1981'});
%       dat=nanmean(data); loc=GSN.Info.Location;
%		drawFilledBox(dat,loc,'size',2,'colorbar','true')
%       Drawing a point in Salamanca:
%       drawFilledBox(dat,loc,'size',2,'colorbar','true','markPoints',[-5.5 40.95])

if ~isempty(data)
	[ndata,Nest]=size(data);lattice=[round(sqrt(ndata)) ceil(sqrt(ndata))];
	clfen=[min(prctile(data,10)) max(prctile(data,90))];gridBox=0;
	tam=ndata;
else
	clfen=[NaN NaN];lattice=[1 1];gridBox=1;tam=-1;
end
if isnumeric(location)
	Loc=location;if size(Loc,1)<size(Loc,2),Loc=Loc';end
elseif isfield(location,'Info')
	Loc=location.Info.Location;
elseif isfield(location,'nod')
	Loc=location.nod';
else
	error('location must be a Nest x 2 matrix or a structure containing the field Info (loadObservations) or nod (loadGCM)')
end
xL=[min(Loc(:,1)),max(Loc(:,1))];nx=length(unique(Loc(:,1)));
yL=[min(Loc(:,2)),max(Loc(:,2))];ny=length(unique(Loc(:,2)));
load('meteocolor');colorm=colormap(meteocolor(10:4:end-10,:));set(gca,'visible','off');
fileName='worldcoastlo.bin';resolution='low';admin=0;projFile=[];
titulos={};xlabels={};cb=false;msize=4;markPoints={};marker='o';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'lattice', lattice = varargin{i+1};
        case 'xlim', xL=varargin{i+1};
        case 'ylim', yL=varargin{i+1};
        case 'clim', clfen=varargin{i+1};
        case 'titles', titulos=varargin{i+1};
        case 'xlabels', xlabels=varargin{i+1};
        case 'colormap', colorm=varargin{i+1};
        case 'colorbar', cb=varargin{i+1};
        case 'size', msize=varargin{i+1};
        case 'markpoints', markPoints=varargin{i+1};
        case 'marker', marker=varargin{i+1};
        case 'gridbox', gridBox=varargin{i+1};
		case 'admin', 
			switch varargin{i+1},
				case {1,'yes','true'}, admin=1;
				otherwise, admin=0;
			end
		case 'resolution',
			switch varargin{i+1},
				case 'low', fileName='worldcoastlo.bin';resolution='low';
				case 'high', fileName='worldcoasthi.bin';resolution='high';
			end
        case 'projection', projFile=varargin{i+1}; 
		otherwise, warning('Unknown optional argument: %s',varargin{i});
    end
end

if(~isstr(marker))
	error('Only a raster drawing can use polygon markers.');
end
tam=min(prod(lattice),tam);
if abs(xL(2)-xL(1))<eps,xL=[xL(1)-0.5 xL(2)+0.5];else,xL=[xL(1)-(xL(2)-xL(1))*0.1 xL(2)+(xL(2)-xL(1))*0.1];end
if abs(yL(2)-yL(1))<eps,yL=[yL(1)-0.5 yL(2)+0.5];else,yL=[yL(1)-(yL(2)-yL(1))*0.1 yL(2)+(yL(2)-yL(1))*0.1];end
if size(clfen,1)==1,
	clfen=repmat(clfen,abs(tam),1);
end
if (isnumeric(markPoints))
    markP=cell(abs(tam),1);
    markP(1:end)={markPoints};
    markPoints=markP;
end
if tam==-1
	clfen=[NaN NaN];lattice=[1 1];gridBox=1;tam=-1;
    subplot(lattice(1),lattice(2),1),hold on
	drawStations(Loc,'size',msize,'marker',marker,'filled','false','resolution',resolution,'israster','false','xlim',xL,'ylim',yL,'admin',admin,'projection', projFile);
    set(gca,'visible','on','XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
	if(~isempty(titulos))
		text(0.5,1,titulos{1},'Units','normalized','VerticalAlignment','bottom','HorizontalAlignment','center','interpreter','none');
	end
	if(~isempty(xlabels))
		text(0.5,0,xlabels{1},'Units','normalized','VerticalAlignment','top','HorizontalAlignment','center','interpreter','none');
	end
	if ~isempty(markPoints)
		plot(markPoints{1}(:,1),markPoints{1}(:,2),'.k');
	end
	hold off
else
    for k=1:tam
        subplot(lattice(1),lattice(2),k),hold on
		drawStations(Loc,'size',msize,'color',data(k,:)','colormap',colorm,'marker',marker,'filled','true','resolution',resolution,'israster','false','xlim',xL,'ylim',yL,'colorbar',cb,'admin',admin,'projection', projFile);
        set(gca,'clim',[clfen(k,1)-0.001 clfen(k,2)+0.001],'visible','on','XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
		if(~isempty(titulos))
			text(0.5,1,titulos{k},'Units','normalized','VerticalAlignment','bottom','HorizontalAlignment','center','interpreter','none');
		end
		if(~isempty(xlabels))
			text(0.5,0,xlabels{k},'Units','normalized','VerticalAlignment','top','HorizontalAlignment','center','interpreter','none');
		end
		if ~isempty(markPoints)
			plot(markPoints{k}(:,1),markPoints{k}(:,2),'.k');
		end
		hold off
	end
end
