function drawStations(Network,varargin)
%drawStations(Network)
%
%Plots the location of the stations (or grid points) of the network
%
%	varargin	: optional parameters
%		'ID'	        -	cell of IDs containing the stations of interest.
%		'resolution'	-	{'low'}, or 'high' to draw the contours map with the coastlines;
%							high resolution is restricted to the Iberian peninsula.
%		'size'			-   is the radius of the circle representing the stations {4}.
%		'marker'		-   is the marker symbol {'+'},'o', ...
%		'color'		    -   color {b}, k, r, ...
%		'xlim'			-   longitude bounds for the drawing area
%		'ylim'			-   latitude bounds for the drawing area
%
%	Examples (scatter plot): 
%
%       net.Network={'GSN'}
%       net.Stations={'Spain.stn'}
%       drawStations(net,'xlim',[-10 4],'ylim',[36 44],'size',6)
%       % Drawing Barcelona (code 8181) and Salamanca (code 8202)
%		drawStations('GSN','ID',{'8181','8202'},'xlim',[-10 4],'ylim',[36 44]) 
%
%  Examples (raster plot):
%       net.Network={'INMGrid02'};
%       net.Stations={'grid.stn'};
%       drawStations(net,'size',0.2,'color',rand([1500 1]),'israster','true')
%
%   ONLY FOR INM DATA
%       net.Network={'INM'};
%       net.Stations={'homogeneas.stn'};
%       drawStations(net,'xlim',[-14 5],'ylim',[34 44],'size',4,'resolution','high')


radio=4;	
fileName='worldcoastlo.bin';projFile=[];
xLims=[]; yLims=[];
color='b';
marker='+';
filled=false;
cm=jet;
ID=[];
israster=false;
cb=false;
ismap=false;
p=[[-.5 -.5];[-.5 .5];[.5 .5];[.5 -.5]];
np=size(p,1);
admin=0;
center=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'id', ID= varargin{i+1};
        case 'size', radio= varargin{i+1};
        case 'color', color= varargin{i+1};
        case 'marker', marker= varargin{i+1};
        case 'filled', filled= varargin{i+1};
        case 'israster', israster= any(strcmp(varargin{i+1},{'true' 'yes'})); 
        case 'ismap', ismap= any(strcmp(varargin{i+1},{'true' 'yes'})); 
        case 'colormap', cm= varargin{i+1};
        case 'colorbar', cb= varargin{i+1};
        case 'xlim', xLims=varargin{i+1};
        case 'ylim', yLims=varargin{i+1};
        case 'center', center=varargin{i+1};
        case 'admin', 
            switch varargin{i+1},
                case {1,'yes','true'}, admin=1;
                otherwise, admin=0;
            end
        case 'resolution',
            switch varargin{i+1},
                case 'low', fileName='worldcoastlo.bin';
                case 'high', fileName='worldcoasthi.bin';
            end
        case 'projection', projFile=varargin{i+1}; 
        otherwise
            warning(sprintf('Option ''%s'' not defined',varargin{i}))
    end
end
if(~isstr(marker))
    if ~israster
        error('Only a raster drawing can use polygon markers.');
    end
    p=marker;
    np=size(p,1);
end

if(~isfield(Network,'Info') & ~isnumeric(Network))
    % Obtaining the path for the network (from a structure or a path-string).
    datCam=getAreaStationZonePath(Network);
    if(isempty(ID))
        % Looking for the stn file in the current directory
        if(~iscell(Network.Stations))
            error('Stations must be a cell: {''file.stn''}')
        end
        d=dir(Network.Stations{1});
        if isempty(d)
            stnFil=[datCam '/' Network.Stations{1}];    % Using the network's path
        else
            stnFil=[Network.Stations{1}];               % Using the current directory
        end
        [ID]=textread(stnFil,'%s','whitespace',',\n');
        ID=strvcat(ID); 
    end
    [id,nam,lon,lat,alt,meta]=textread([datCam '/Master.txt'],'%s%s%f%f%f%s','whitespace',',\n');   
    loc=[lon,lat];
    [b,iN]=ismember(cellstr(ID),id);
    iN=iN(find(iN>0));   
    Loc=loc(iN,:);
    if(isempty(Loc)) 
        warning('No station loaded. Make sure that Stations is a cell of the form {''file.stn''}');
    end
elseif isnumeric(Network)
    Loc=Network;
else
    Loc=Network.Info.Location;
end
if center~=0
    Loc(find(Loc(:,1)>=center-180),1)=Loc(find(Loc(:,1)>=center-180),1)-360;
end
if isempty(xLims)
    maxx=max(Loc(:,1));minx=min(Loc(:,1));
    maxy=max(Loc(:,2));miny=min(Loc(:,2));
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
    xLims=[minx maxx]; yLims=[miny maxy];
end
% ha=axes('units','normal','position',[0 0 1 1],'DataAspectRatioMode','Manual','DataAspectRatio',[1 1 1],...
%     'box','on','xlimmode','manual','ylimmode','manual',...
%     'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...   
%     'XLim',xLims,'YLim',yLims);
ha=gca;
set(gca,'units','normal','DataAspectRatioMode','Manual','DataAspectRatio',[1 1 1],...
    'box','on','xlimmode','manual','ylimmode','manual',...
    'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...   
    'XLim',xLims,'YLim',yLims);
if isempty(projFile)
	if(ismap)
		if(strcmpi(fileName,'worldcoasthi.bin'))
			s=worldhi(yLims,xLims);
		else
			s=worldlo(yLims,xLims);
		end
		for i=1:length(s)
			if i==1,
				bnd=[s(i).long,s(i).lat];
			else,
				bnd=[bnd;[NaN,NaN];[s(i).long,s(i).lat]];
			end
		end
	else
		fidbnd=fopen(fileName,'rb','ieee-be');
		bnd=fread(fidbnd,[2,inf],'single')';
		fclose(fidbnd);
	end
	if admin
		fidbnd=fopen('admin.bin','rb','ieee-be');
		bnd1=fread(fidbnd,[2,inf],'single')';
		fclose(fidbnd);
		bnd=[bnd;NaN NaN;bnd1];
	end
else
	fidbnd=fopen(projFile,'rb','ieee-be');
	bnd=fread(fidbnd,[2,inf],'single')';
	fclose(fidbnd);
end
if ~israster
    if length(radio)==1 & length(color)==1
        plot(Loc(:,1),Loc(:,2),marker,'MarkerSize',radio);
    else
        if(any(strcmp(filled,{'true' 'yes'})))
            h=scatter(Loc(:,1),Loc(:,2),radio,color,marker,'filled');
        else
            h=scatter(Loc(:,1),Loc(:,2),radio,color,marker);
        end
        set(h,'markerEdgeColor','k');
        %set(ha,'position',[0.1 0.1 0.8 0.8])
        colormap(cm);
        if cb, colorbar; end
    end
else
    x=Loc(:,1);y=Loc(:,2);c=color';
    nx=length(x);
    px=repmat(p(:,1),[1,nx]);
    py=repmat(p(:,2),[1,nx]);
	if size(radio,2)==1,radio=repmat(radio,1,2);end
    if size(radio,1)>1
        px=px.*repmat(radio(:,1)*2,[np,1]);
        py=py.*repmat(radio(:,2)*2,[np,1]);
    else
        px=px.*radio(:,1)*2;
        py=py.*radio(:,2)*2;
    end            
    % if length(radio)>1
        % px=px.*repmat(radio*2,[np,1]);
        % py=py.*repmat(radio*2,[np,1]);
    % else
        % px=px.*radio*2;
        % py=py.*radio*2;
    % end
    X=px+repmat(x',[np,1]);
    Y=py+repmat(y',[np,1]);
    patch(X,Y,c,'EdgeColor','none');
    %set(ha,'position',[0.1 0.1 0.8 0.8])
    colormap(cm);
    if cb, colorbar; end
end
if center~=0
	indCross=find(bnd(:,1)>=center-180);indPoly=indCross;
	indNaN=find(isnan(bnd(:,1)));
	for i=1:length(indCross)
		try
			indPoly(i)=min(find(indNaN-indCross(i)>0));
		catch
			indPoly(i)=length(indNaN)+1;
		end
	end
	indPoly=unique(indPoly);indC=[];
	for i=1:length(indPoly)
		if indPoly(i)<length(indNaN)+1 & indPoly(i)>1
			indC=[indC;[indNaN(indPoly(i)-1):indNaN(indPoly(i))]'];
		elseif indPoly(i)==1
			indC=[indC;[1:indNaN(indPoly(i))]'];
		else
			indC=[indC;[indNaN(end):size(bnd,1)]'];
		end
	end
	bnd(indC,1)=bnd(indC,1)-360;
end
hold on;
line(bnd(:,1),bnd(:,2),'Color',[0.5 0.5 0.5],'linestyle','-');
set(gca,'units','normal','DataAspectRatioMode','Manual','DataAspectRatio',[1 1 1],...
    'box','on','xlimmode','manual','ylimmode','manual',...
    'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...   
    'XLim',xLims,'YLim',yLims);
