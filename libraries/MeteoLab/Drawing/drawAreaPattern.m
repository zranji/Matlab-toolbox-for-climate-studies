function drawAreaPattern(dmn,varargin)
%drawAreaPattern(dmn)
%
%Plots the grid defining an atmosphiric pattern given by a 'domain'
%
%	varargin	: optional parameters
%		'resolution'	-	{'low'}, or 'high' to draw the contours map with the coastlines;
%									high resolution is restricted to the Iberian peninsula.
%		'xlim'				-  vector of 'x' bounds for the drawing area
%		'ylim'				-  vector of 'y' bounds for the drawing area
%	
%	Examples:
%		drawareapattern(dmn)
%    drawareapattern(dmn,'resolution','low','xlim',[-20 20],'ylim',[20 60])

fileName='worldcoastlo.bin';
xLims=[]; yLims=[];
admin=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'xlim', xLims=varargin{i+1};
        case 'ylim', yLims=varargin{i+1};
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
    end
end

fidbnd=fopen(fileName,'rb','ieee-be');
bnd=fread(fidbnd,[2,inf],'single')';
fclose(fidbnd);
if admin
	fidbnd=fopen('admin.bin','rb','ieee-be');
	bnd1=fread(fidbnd,[2,inf],'single')';
	fclose(fidbnd);
	bnd=[bnd;NaN NaN;bnd1];
end

dmn=parseDomain(dmn);

if(isempty(dmn.nod))
    [xi,yi]=meshgrid(dmn.lon,dmn.lat);
    xi=xi';yi=yi';
elseif(size(dmn.nod,1)==2)
    xi=dmn.nod(1,:);    
    yi=dmn.nod(2,:);    
else
    [xi,yi]=meshgrid(dmn.lon,dmn.lat);
    xi=xi';yi=yi';
    xi=xi(dmn.nod);
    yi=yi(dmn.nod);
end


axes;
hold on
line(bnd(:,1),bnd(:,2),'Color','k','linestyle','-');

if isempty(xLims)
    xLims=[min(xi) max(xi)];
    yLims=[min(yi) max(yi)];
end

set(gca	,'ylim',yLims,'xlim',xLims)

plot(xi,yi,'.k')