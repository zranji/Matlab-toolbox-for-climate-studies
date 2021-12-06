function cb = cbar(loc, force);
%  cb = cbar(loc, 'force');
%
%  where loc = 'l', 'r', 'b', 't' puts a single colorbar
%  at the left, right, bottom, or top of the current
%  figure.
%
%  force = 1 will force the subplot on the figure, 
%  regardless of whether it fits or not.  Naturally,
%  the default is force = 0.
%  Example: figure,pcolor(randn(30,30)),shading flat,cbar('r',1);
if nargin < 1; loc = 'r'; end;
if nargin < 2; force = 0; end;

Paper_Orient = get(gcf, 'PaperOrientation');
if strcmp(lower(Paper_Orient(1)), 'r');
  error('Sorry, I have not tested Rotated orientations');
end
Child = get(gcf, 'Children');
Clim = get(gca, 'Clim');
pos = repmat(NaN, [length(Child) 4]);
for i = 1:length(Child);
  pos(i,:) = get(Child(i), 'Position');
end
minx=min(pos(:,1));
maxx=max(pos(:,1)+pos(:,3));
miny=min(pos(:,2));
maxy=max(pos(:,2)+pos(:,4));
switch lower(loc(1))
	case 'r'
	if (1-maxx > 0.075) | force;
		PlotSz = (maxy-miny)./(1+0.5*(maxy-miny));
		ax = axes('Position',[maxx+0.025 miny+0.5*((maxy-miny)-PlotSz) 0.025 PlotSz]);
		YAxisLoc = 'Right';
		XAxisLoc = 'Bottom';
	else
		error('There might not be enough room.  Try a different location');
	end
	case 'l'
	if minx > 0.1 | force;
		PlotSz = (maxy-miny)./(1+0.5*(maxy-miny));
		ax = axes('Position',[minx-0.075 miny+0.5*((maxy-miny)-PlotSz) 0.025 PlotSz]);
		YAxisLoc = 'Left';
		XAxisLoc = 'Bottom';
	else
		error('There might not be enough room.  Try a different location');
	end
	case 'b'
	if miny > 0.1 | force;
		PlotSz = (maxx-minx)./(1+0.5*(maxx-minx));
		ax = axes('Position',[minx+0.5*((maxx-minx)-PlotSz) miny-0.075 PlotSz 0.025],'XAxisLocation', 'bottom','YTick', []);
		YAxisLoc = 'Left';
		XAxisLoc = 'Bottom';
	else
		error('There might not be enough room.  Try a different location');
	end
	case 't'
	if (1-maxy) > 0.125 | force;
		PlotSz = (maxx-minx)./(1+0.5*(maxx-minx));
		ax = axes('Position',[minx+0.5*((maxx-minx)-PlotSz) maxy+0.05 PlotSz 0.025],'XAxisLocation', 'top','YTick', []);
		YAxisLoc = 'Left';
		XAxisLoc = 'Top';
	else
		error('There might not be enough room.  Try a different location');
	end
end
cb=colorbar(ax);
% set(ax,'XAxisLocation', XAxisLoc, 'YAxisLocation', YAxisLoc,'ClimMode','Manual','Clim',Clim);
set(ax,'XAxisLocation', XAxisLoc, 'YAxisLocation', YAxisLoc,'YTickLabel',linspace(Clim(1),Clim(2),5)','ClimMode','Manual','Clim',Clim);
