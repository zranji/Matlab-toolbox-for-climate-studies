function clim=classKoppen(temp,precip,loc,varargin)
%Function that calculates, for each point, the type of climate according to the
%Koppen-Geiger classification (see http://koeppen-geiger.vu-wien.ac.at/)
%and plots the corresponding map.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Examples of calls to the function: clim=classKoppen(temp,precip,loc,varargin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inputs:
%clim=classKoppen(temp,precip,loc);
%        - temp is the matrix n*m (n=12, m=points) of mean monthly temperatures. The first row must correspond to January. Must
%          be in ºC.
%        - precip is the matrix n*m (n=12, m=points) of mean monthly accumulated precipitation. The first row must correspond to January. Must
%          be in mm.
%        - loc is the matrix m*2 with the coordinates (longitude-latitude) of the points.
%clim=classKoppen(temp,precip,loc,'marker','o','size',2);
%        Varargin (optional arguments of function 'drawStationsValue'):
%        - marker: {'o'} for points (relative units), 't' for tiles (absolute) ('t' by default).
%        - size: size of the mosaics (in points for circles and degrees for squares) (0.5 by default).
%		 - resolution: {'low'}, or 'high' to draw the map with coastlines contours;
%		   'high' is restricted to the Iberian peninsula ('low' by default).
%		 - xlim: longitude bounds for the drawing area.
%		 - ylim: latitude bounds for the drawing area.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Outputs:
%        - clim is the matrix containing the type of climate assigned to each
%        point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
marker='t';
msize=0.5;
reso='low';
xLims=[]; yLims=[];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'marker', marker=varargin{i+1};
        case 'size', msize=varargin{i+1};
        case 'resolution', reso=varargin{i+1};
        case 'xlim', xLims=varargin{i+1};
        case 'ylim', yLims=varargin{i+1};
        otherwise
            warning(sprintf('Option ''%s'' not defined',varargin{i}))
    end
end
%%%
%Koeppen-Geiger climates
labels={'ET' 'EF'...
    'BSh' 'BSk'...
    'BWh' 'BWk'...
    'Af' 'Am' 'As' 'Aw'...
    'Csa' 'Csb' 'Csc'...
    'Cwa' 'Cwb' 'Cwc'...
    'Cfa' 'Cfb' 'Cfc'...
    'Dsa' 'Dsb' 'Dsc' 'Dsd'...
    'Dwa' 'Dwb' 'Dwc' 'Dwd'...
    'Dfa' 'Dfb' 'Dfc' 'Dfd'};
%%%
for isite=1:size(temp,2)
    %%%
    %months comprised in summer and winter in each hemisphere
    if loc(isite,2) >= 0    %northern hemisphere
        summ=4:9;
        win=[1 2 3 10 11 12];
    else      %southern hemisphere
        summ=[1 2 3 10 11 12];
        win=4:9;
    end
    %%%
    %variables needed to establish climate types
    tann=nanmean(temp(:,isite));
    tmin=nanmin(temp(:,isite));
    tmax=nanmax(temp(:,isite));
    %%%
    pann=nansum(precip(:,isite));
    ps=nansum(precip(summ,isite));
    pw=nansum(precip(win,isite));
    pmin=nanmin(precip(:,isite));
    pmax=nanmax(precip(:,isite));
    pmaxs=nanmax(precip(summ,isite));
    pmins=nanmin(precip(summ,isite));
    pmaxw=nanmax(precip(win,isite));
    pminw=nanmin(precip(win,isite));
    if pw >= (2/3*pann)
        pth=2*tann;
    elseif ps >= (2/3*pann)
        pth=(2*tann)+28;
    else
        pth=(2*tann)+14;
    end
    %%%
    %climate types depending on the variables defined before
    %(2006_Kottek_World_map_of_the_Koeppen-Geiger_climate_classification_updated),
    %according to a Boole scheme
    rE=(tmax < 10);

    rET=rE && (0 <= tmax);
    rEF=rE && (tmax < 0);

    rB=(pann < (pth*10));

    rBS=rB && (pann > (5*pth));
    rBSh=rBS && (tann >= 18);
    rBSk=rBS && (tann < 18);

    rBW=rB && (pann <= (5*pth));
    rBWh=rBW && (tann >= 18);
    rBWk=rBW && (tann < 18);

    rA=tmin >= 18;

    rAf=rA && pmin >= 60;
    rAm=rA && (pann >= (25*(100-pmin)));
    rAs=rA && isempty(intersect(find(precip(:,isite)==pmin),win));
    rAw=rA && isempty(intersect(find(precip(:,isite)==pmin),summ));

    rC=(-3 < tmin) && (tmin < 18);

    rCw=rC && (pmaxs > pminw*10) && (pminw < pmins);
    rCwa=rCw && (tmax >= 22);
    rCwb=rCw && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) >= 4);
    rCwc=rCw && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin > -38);

    rCs=rC && (pmaxw > pmins*3) && (pmins < pminw) && (pmins < 40);
    rCsa=rCs && (tmax >= 22);
    rCsb=rCs && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) >= 4);
    rCsc=rCs && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin > -38);

    rCf=rC && (rCs==0) && (rCw==0) ;
    rCfa=rCf && (tmax >= 22);
    rCfb=rCf && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) >= 4);
    rCfc=rCf && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin > -38);

    rD=(tmin <= -3);

    rDw=rD && (pmaxs > pminw*10) && (pminw < pmins);
    rDwa=rDw && (tmax >= 22);
    rDwb=rDw && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) >= 4);
    rDwc=rDw && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin > -38);
    rDwd=rDw && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin <= -38);

    rDs=rD && (pmaxw > pmins*3) && (pmins < pminw) && (pmins < 40);
    rDsa=rDs && (tmax >= 22);
    rDsb=rDs && (tmax < 22) && ((length(find(temp(:,isite) > 10))) >= 4);
    rDsc=rDs && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin > -38);
    rDsd=rDs && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin <= -38);

    rDf=rD && (rDs==0) && (rDw==0);
    rDfa=rDf && (tmax >= 22);
    rDfb=rDf && (tmax < 22) && ((length(find(temp(:,isite) > 10))) >= 4);
    rDfc=rDf && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin > -38);
    rDfd=rDf && (tmax < 22) && ((length(find(temp(:,isite) >= 10))) < 4) && (tmin <= -38);
    %%%
    %vector with all elements '0' but one '1' (which identifies the type of
    %climate for the grid point 'isite')
    rules=[rET rEF...
        rBSh rBSk...
        rBWh rBWk...
        rAf rAm rAs rAw...
        rCsa rCsb rCsc...
        rCwa rCwb rCwc...
        rCfa rCfb rCfc...
        rDsa rDsb rDsc rDsd...
        rDwa rDwb rDwc rDwd...
        rDfa rDfb rDfc rDfd];
    %%%
    %types of climate for every grid point
    tclim=labels(find(rules));
    nclim=length(tclim);
    if isempty(tclim)
        clim{isite,1}='NaN';
        koeppen(isite)=NaN;
    else
        for iclim=1:nclim
            clim(isite,iclim)=tclim(iclim);
        end
        koeppen(isite)=min(find(rules));     %hierarchy of climates
    end
end
clim=clim(:,1);   %retaining only the first type of climate found (there is an established hierarchy)
%%%
%inans=find(isnan(koeppen)==1);
% nnans=length(find(isnan(koeppen)==1));
% if nnans >= 1
% warning('No type of climate has been assigned to %d grid points among the total %d since two or more types could be assigned.',nnans,length(itemp));
% end
%%%
%same colorbar as the one used at 'http://koeppen-geiger.vu-wien.ac.at/'
ckoeppen=[[101 255 255];[160 150 255];...
    [207 142 20];[207 170 85];...
    [255 207 0];[255 255 101];...
    [148 1 1];[254 0 0];[255 154 154];[255 207 207];...
    [0 254 0];[149 255 0];[165 254 0];...
    [181 101 0];[149 102 3];[93 64 2];...
    [0 48 0];[1 79 1];[2 87 2];...
    [253 108 253];[254 182 255];[231 202 253];[202 203 203];...
    [203 182 255];[153 125 178];[138 89 178];[109 36 178];...
    [48 0 48];[101 1 101];[203 0 203];[199 20 135]]./255;
%%%
%Koeppen-Geiger map
drawStationsValue(koeppen,loc,'xlim',xLims,'ylim',yLims,'resolution',reso,'marker',marker,'size',msize,'colorbar',true,'clim',[1 length(ckoeppen)]);
title('Koeppen-Geiger classification');
colormap(ckoeppen)
h=colorbar;
%colorbar legend
set(h,'YTickMode','manual','YTick',[1:length(ckoeppen)],'YTickLabelMode','manual','YTickLabel',labels);
end
