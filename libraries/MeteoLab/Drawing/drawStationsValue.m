function drawStationsValue(DATA,LOC,varargin)
%drawStationsValue  Scatter plot for geographical locations.
%   drawStationsValue(DATA,LOC,varargin) displays colored circles (relative
%   units) or tiles (absolute untis) at the geopraphical locations specified
%   by the vector LOC. If DATA is a matrix, a different subplot will be displayed
%   for each of the rows.
%   -> Buiding on 'drawAreaStations' function.
%
%   Input:
%	DATA		: values to be plotted (in rows). A single row 1*n produces a
%                 single plot and a matrix m*n produces a mosaic following
%                 the standard display: left-right, top-bottom.
%	LOC		    : matrix of size m*2 with longitude and latitude coordinates.
%	varargin	: Optional arguments
%	    'lattice'	-   vector [a b] to draw the mosaic in a lattice (n<a*b).
%                       By default a=b=sqrt(n)
%		'clim'  -   vector of bounds for the color plot.
%       'marker'    -   {'o'} for points (relative units), 't' for tiles (absolute)
%       'size'      -   Size of the mosaics (in points for circles and degrees for squares).
%		'titles'	-   cell of size m with the plot titles
%		'colormap'	-   colormap used in the plots
%		'colorbar'	-   true or {false} to draw the colorbars
%		'resolution'	-	{'low'}, or 'high' to draw the contours map with the coastlines;
%							high resolution is restricted to the Iberian peninsula.
%		'xlim'			-   longitude bounds for the drawing area (automatic by default)
%		'ylim'			-   latitude bounds for the drawing area (automatic by default)
%
% Example:
%       LOC=[-3.9 43.4; -3.7 40.5; -6.4 36.5; 2.15 41.3];   % 4 points
%       DATA=[2 1 1.5 3; 1 3 2.5 1];                        % 2 samples
%		drawStationsValue(DATA,LOC,'lattice',[2 1],'xlim',[-10,5],'ylim',[35,45],'colorbar',true)
%
%       % Drawing the mean temperature in Europe (1 degree tiles)
%       GSN.Network={'GSN'};
%       GSN.Stations={'europe.stn'};
%       GSN.Variable={'Temp'};
%       [data,GSN]=loadStations(GSN,'dates',{'1-Jan-1970','31-Dec-1999'});
%       dat=nanmean(data); loc=GSN.Info.Location;
%		drawStationsValue(dat,loc,'marker','t','size',1,'colorbar','true')

% % figure
lattice=[round(sqrt(size(DATA,1))) ceil(sqrt(size(DATA,1)))];
% boxsize=[0.001 0.001 0.8 1];

xL=[];
yL=[];
clfen=[];
titulos={};
xlabels={};
colorm=[];
cb=false;
resolution='low';
marker='o';
msize=20;
israster='false';
admin=0;projFile=[];
center=0;
fs = 8;
sig = nan(size(DATA));
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'center', center=varargin{i+1};
        case 'lattice', lattice = varargin{i+1};
        case 'xlim', xL=varargin{i+1};
        case 'ylim', yL=varargin{i+1};
        case 'clim', clfen=varargin{i+1};
        case 'titles', titulos=varargin{i+1};
        case 'xlabels', xlabels=varargin{i+1};
        case 'colormap', colorm=varargin{i+1};
        case 'colorbar', cb=varargin{i+1};
        case 'size', msize=varargin{i+1};
        case 'marker', marker=varargin{i+1};
        case 'israster', israster=varargin{i+1};
        case 'resolution', resolution=varargin{i+1};
        case 'admin', admin=varargin{i+1};
        case 'projection', projFile=varargin{i+1};
        case 'fs', fs=varargin{i+1};
        case 'sig', sig=varargin{i+1};
    end
end
if marker=='t', marker='s';israster='true'; msize=msize/2; end
% axisX=boxsize(1);
% axisY=boxsize(2);
% axisW=(boxsize(3)-boxsize(1))/lattice(2);
% axisH=(boxsize(4)-boxsize(2))/lattice(1);

if isempty(xL)
    maxx=max(LOC(:,1));minx=min(LOC(:,1));
    maxy=max(LOC(:,2));miny=min(LOC(:,2));
    Dx=maxx-minx;
    Dy=maxy-miny;
    if Dx>0,
        maxx=maxx+Dx*.1;
        minx=minx-Dx*.1;
    else
        maxx=maxx+0.5;minx=minx-0.5;
    end
    if Dy>0,
        maxy=maxy+Dy*.1;miny=miny-Dy*.1;
    else
        maxy=maxy+0.5;miny=miny-0.5;
    end
    xL=[minx maxx]; yL=[miny maxy];
end
% xL=sort(xL);
% yL=sort(yL);

fidbnd=fopen('worldcoasthi.bin','rb','ieee-be');
bnd=fread(fidbnd,[2,inf],'single')';
fclose(fidbnd);

if isempty(colorm),
    colorm=flipud(hot);
    colorm=colorm(5:end,:);
end
colormap(colorm);
set(gca,'visible','off');

tam=min(prod(lattice),size(DATA,1));
for k=1:tam
    %Draws from left->right, top->bottom
    j=rem(k-1,lattice(2))+1;
    i=floor((k-1)/lattice(2))+1;
    if isempty(clfen),
        clfen=[min(prctile(DATA,10)) max(prctile(DATA,90))];
    end
    hold on
    subplot(lattice(1),lattice(2),k)
    % axes('xtick',[],'ytick',[],'xlimmode','manual','xlim',xL,...
    % 'ylimmode','manual','ylim',yL,...
    % 'climmode','manual','clim',[clfen(1)-0.001 clfen(2)+0.001],...
    % 'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1],...
    % 'units','Normal');%,...
    % 'Position',[axisX+(j-1)*axisW axisY+(lattice(1)-i)*axisH axisW*0.9 axisH*0.9]);
    
    drawStations(LOC,'size',msize,'color',DATA(k,:)','colormap',colorm,'marker',marker,...
        'filled','true','resolution',resolution,'israster',israster,...
        'xlim',xL,'ylim',yL,'colorbar',cb,'admin',admin,'projection', projFile,'center',center);
    if sum(~isnan(sig(k,:))) ~= 0
        hold on
        % %         plot(LOC(find(sig(k,:)),1),LOC(find(sig(k,:)),2),'s','MarkerSize',msize,'MarkerEdgeColor','k')
        plot(LOC(find(sig(k,:)),1),LOC(find(sig(k,:)),2),'.k','MarkerSize',msize*17.5)
    end
    set(gca,'FontSize',fs);
    set(gca,'clim',[clfen(1)-0.001 clfen(2)+0.001]);
    set(gca,'visible','on','XTickMode','manual','XTick',[],...
        'YTickMode','manual','YTick',[]);
    if(~isempty(titulos))
        text(0.5,1,titulos{k},...
            'Units','normalized',...
            'VerticalAlignment','bottom',...
            'HorizontalAlignment','center','FontSize',fs);
    end
    if(~isempty(xlabels))
        text(0.5,0,xlabels{k},...
            'Units','normalized',...
            'VerticalAlignment','top',...
            'HorizontalAlignment','center','FontSize',fs);
    end
    hold off
end
