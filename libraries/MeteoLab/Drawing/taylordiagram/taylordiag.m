% TAYLORDIAG Plot a Taylor Diagram
%
% [hp ht axl] = taylordiag(STDs,RMSs,CORs,['option',value])
%
% Plot a Taylor diagram from statistics of different series.
%
% INPUTS:
%	STDs: Standard deviations
%	RMSs: Centered Root Mean Square Difference
%	CORs: Correlation
%
%	Each of these inputs are one dimensional with same length. First
%	indice corresponds to the reference serie for the diagram. For exemple
%	STDs(1) is the standard deviation of the reference serie and STDs(2:N)
%	are the standard deviations of the other series.
%
%	Note that by definition the following relation must be true for all series i:
%	RMSs(i) - sqrt(STDs(i).^2 + STDs(1)^2 - 2*STDs(i)*STDs(1).*CORs(i)) = 0
%	This relation is checked and if not verified an error message is sent. Please see
%	Taylor's JGR article for more informations about this.
%	You can use the ALLSTATS function to avoid this to happen, I guess ;-). You can get
%	it somewhere from: http://codes.guillaumemaze.org/matlab
%
% OUTPUTS:
% 	hp: returns handles of plotted points
%	ht: returns handles of the text legend of points
%	axl: returns a structure of handles of axis labels
%
% LIST OF OPTIONS:
%	For an exhaustive list of options to customize your diagram, please call the function
%	without arguments:
%		>> taylordiag
%
% SHORT TUTORIAL (see taylordiag_test.m for more informations):
%	 An easy way to get compute inputs is to use the ALLSTATS function you can get from:
%	 	http://codes.guillaumemaze.org/matlab
%	 Let's say you gathered all the series you want to put in the Taylor diagram in a
%	 single matrix BUOY(N,nt) with N the number of series and nt their (similar) length.
%	 If BUOY(1,:) is the serie of reference for the diagram:
%		 for iserie = 2 : size(BUOY,1)
%		    S = allstats(BUOY(1,:),BUOY(iserie,:));
%		    MYSTATS(iserie,:) = S(:,2); % We get stats versus reference
%		 end%for iserie
%		 MYSTATS(1,:) = S(:,1); % We assign reference stats to the first row
%	 Note that the ALLSTATS function can handle NaNs, so be careful to compute statistics
%	 with enough points !
%	 Then you're ready to simply run:
%		taylordiag(MYSTATS(:,2),MYSTATS(:,3),MYSTATS(:,4));
%
% REF: 	K. Taylor
%		Summarizing multiple aspects of model performance in a single diagram
%		Journal of Geophysical Research-Atmospheres, 2001, V106, D7.
%
% Rev. by Guillaume Maze on 2010-02-10: Help more helpful ! Options now displayed by call.
% Copyright (c) 2008 Guillaume Maze.
% http://codes.guillaumemaze.org
% All rights reserved.

% This version of the taylordiag function includes some modifications developed by Marco Turco 
% to include a new dimension to the diagram . This new option let the user include a colour to 
% each point in the diagram which could represent other statistics or error scores (e.g. bias) 
% which are not included in the original version of the diagram.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 	* Redistributions of source code must retain the above copyright notice, this list of
% 	conditions and the following disclaimer.
% 	* Redistributions in binary form must reproduce the above copyright notice, this list
% 	of conditions and the following disclaimer in the documentation and/or other materials
% 	provided with the distribution.
% 	* Neither the name of the Laboratoire de Physique des Oceans nor the names of its contributors may be used
%	to endorse or promote products derived from this software without specific prior
%	written permission.
%
% THIS SOFTWARE IS PROVIDED BY Guillaume Maze ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Guillaume Maze BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% Example:
% X=randn(365,100);
% mean.Obs=nanmean(X);std.Obs=nanstd(X);
% We consider two diferent methods
% mean.Pred=repmat(NaN,2,Nest);
% std.Pred=repmat(NaN,2,Nest);
% Y1=randn(365,100);% Method1
% mean.Pred(1,:)=nanmean(Y1);std.Pred(1,:)=nanstd(Y1);
% Y2=randn(365,100);% Method2
% mean.Pred(2,:)=nanmean(Y2);std.Pred(2,:)=nanstd(Y2);
% Taylor.std=repmat(NaN,1,3);
% Taylor.rho=repmat(NaN,1,3);
% Taylor.rmse=repmat(NaN,1,3);
% stdObs=mean.Obs/nanstd(mean.Obs');
% stdPrd=mean.Pred/nanstd(mean.Obs');
% Taylor.std=[nanstd(stdObs') nanstd(stdPrd')];
% Taylor.rho(1)=1;Taylor.rmse(1)=0;
% for n=1:2
	% aux=nancorrcoef([stdObs' stdPrd(n,:)']);
	% Taylor.rho(1+n)=aux(1,2);
	% Taylor.rmse(n+1)=sqrt(nanmean(((stdPrd(n,:)'-nanmean(stdPrd(n,:)'))-(stdObs'-nanmean(stdObs'))).^2));
% end
% labels={'obs';'M1';'M2'};labelsColor={'k';'r';'b'};
% marker={'.';'o';'s'};color={'k';'r';'b'};colorEdge={'k';'r';'b'};
% figure;
% taylordiag(Taylor.std,Taylor.rmse,Taylor.rho,'labels',labels,'labelscolor',labelsColor,'markersize',10,'marker',marker,'frontsize',10,'markerfacecolor',color,'markeredgecolor',colorEdge)
% Taylor.std=repmat(NaN,1,3);
% Taylor.rho=repmat(NaN,1,3);
% Taylor.rmse=repmat(NaN,1,3);
% stdObs=std.Obs/nanstd(std.Obs');
% stdPrd=std.Pred/nanstd(std.Obs');
% Taylor.std=[nanstd(stdObs') nanstd(stdPrd')];
% Taylor.rho(1)=1;Taylor.rmse(1)=0;
% for n=1:2
	% aux=nancorrcoef([stdObs' stdPrd(n,:)']);
	% Taylor.rho(1+n)=aux(1,2);
	% Taylor.rmse(n+1)=sqrt(nanmean(((stdPrd(n,:)'-nanmean(stdPrd(n,:)'))-(stdObs'-nanmean(stdObs'))).^2));
% end
% labels={'obs';'M1';'M2'};labelsColor={'k';'r';'b'};
% marker={'.';'o';'s'};color={'k';'r';'b'};colorEdge={'k';'r';'b'};
% figure;
% taylordiag(Taylor.std,Taylor.rmse,Taylor.rho,'labels',labels,'labelscolor',labelsColor,'markersize',10,'marker',marker,'frontsize',10,'markerfacecolor',color,'markeredgecolor',colorEdge)

function varargout = taylordiag(STDs,RMSs,CORs,varargin)

if nargin<3
	error('taylordiag.m : Wrong number of arguments')
end

%%
% if nargin == 0
    % disp_optionslist;
    % return
% else
    % narg = nargin - 3;
    % if mod(narg,2) ~=0
        % error('taylordiag.m : Wrong number of arguments')
    % end
% end
% STDs = varargin{1};
% RMSs = varargin{2};
% CORs = varargin{3};

%% CHECK THE INPUT FIELDS:
apro = 100;
di   = fix(RMSs*apro)/apro - fix(sqrt(STDs.^2 + STDs(1)^2 - 2*STDs*STDs(1).*CORs)*apro)/apro;
if find(di~=0)
    %	help taylordiag.m
    ii = find(di~=0);
    if length(ii) == length(di)
        warning(sprintf('taylordiag.m : Something''s wrong with ALL the datas\nYou must have:\nRMSs - sqrt(STDs.^2 + STDs(1)^2 - 2*STDs*STDs(1).*CORs) = 0 !'))
    else
        warning(sprintf('taylordiag.m : Something''s wrong with data indice(s): [%i]\nYou must have:\nRMSs - sqrt(STDs.^2 + STDs(1)^2 - 2*STDs*STDs(1).*CORs) = 0 !\n and\nRMSs - sqrt(STDs.^2 + STDs(1)^2 - 2*STDs*STDs(1).*CORs) = %s',ii,num2str(di)))
    end
end

%% IN POLAR COORDINATES:
rho   = STDs;
theta = real(acos(CORs));
dx    = rho(1);	% Observed STD
%%
%% BEGIN THE PLOT HERE TO GET AXIS VALUES:
hold off
cax = gca;
tc = get(cax,'xcolor');
%ls = get(cax,'gridlinestyle');
ls = '-'; % DEFINE HERE THE GRID STYLE
next = lower(get(cax,'NextPlot'));
labels=cell(1,length(STDs));
%% LOAD CUSTOM OPTION OF AXE LIMIT:
%default setting
color=repmat({'r'},length(STDs),1);
marker=repmat({'.'},length(STDs),1);
colorEdge=repmat({'r'},length(STDs),1);
labelsColor=repmat({'k'},length(STDs),1);
foundrmax = 0;
for iopt =1:2:length(varargin)
    optvalue = varargin{iopt+1};
    switch lower(varargin{iopt}), 
		case 'limstd',
			rmax=optvalue;
			foundrmax=1;
		case 'labels',labels=optvalue;
		case 'labelscolor',labelsColor=optvalue;
        case {'markerfacecolor','color'},color=optvalue;    
        case 'markeredgecolor',colorEdge=optvalue;    
        case 'marker',marker=optvalue; 
	end
end

if length(marker)~=length(color) || length(marker)~=length(colorEdge)
	error('Marker and Color arguments must have the same dimensions')
end
if length(labels)~=length(labelsColor)
	error('Labels and LabelsColor arguments must have the same dimensions')
end
% make a radial grid
hold(cax,'on');
if foundrmax==0
    maxrho = max(abs(rho(:)));
else
    maxrho = rmax;
end
hhh = line([-maxrho -maxrho maxrho maxrho],[-maxrho maxrho maxrho -maxrho],'parent',cax);
set(cax,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
v = [get(cax,'xlim') get(cax,'ylim')];
ticks = sum(get(cax,'ytick')>=0);
delete(hhh);

% check radial limits and ticks
rmin = 0;
if foundrmax == 0;
    rmax = v(4);
end
rticks = max(ticks-1,2);
if rticks > 5   % see if we can reduce the number
    if rem(rticks,2) == 0
        rticks = rticks/2;
    elseif rem(rticks,3) == 0
        rticks = rticks/3;
    end
end
rinc  = (rmax-rmin)/rticks;
tick  = (rmin+rinc):rinc:rmax;

%% LOAD DEFAULT PARAMETERS:
if find(CORs<0)
    Npan = 2; % double panel
else
    Npan = 1;
end
tickRMSangle  = 135;
showlabelsRMS = 1;showlabelsSTD = 1;showlabelsCOR = 1;
colSTD = [0 0 0];colRMS = [0 .6 0];colCOR = [0 0 1];
tickCOR(1).val = [1 .99 .95 .9:-.1:0];
tickCOR(2).val = [1 .99 .95 .9:-.1:0 -.1:-.1:-.9 -.95 -.99 -1];
widthCOR = .8;widthRMS = .8;widthSTD = .8;
styleCOR = '-.';styleRMS = '--';styleSTD = ':';
titleRMS = 1;titleCOR = 1;titleSTD = 1;
tickRMS = tick; rincRMS = rinc;
tickSTD = tick; rincSTD = rinc;
markersize=repmat(20,length(marker),1);fontsize=12;
%% LOAD CUSTOM OPTIONS:
for iopt =1:2:length(varargin)
    optname  = varargin{iopt};optvalue = varargin{iopt+1};
    switch lower(optname)
        case 'tickrms'
            tickRMS = sort(optvalue);
            rincRMS = (max(tickRMS)-min(tickRMS))/length(tickRMS);
        case 'showlabelsrms',showlabelsRMS = optvalue;
        case 'tickrmsangle',tickRMSangle = optvalue;
        case 'colrms',colRMS = optvalue;
        case 'widthrms',widthRMS = optvalue;
        case 'stylerms',styleRMS = optvalue;
        case 'titlerms',titleRMS = optvalue;
        case 'tickstd'
            tickSTD = sort(optvalue);
            rincSTD = (max(tickSTD)-min(tickSTD))/length(tickSTD);
        case 'showlabelsstd',showlabelsSTD = optvalue;
        case 'colstd',colstd = optvalue;
        case 'widthstd',widthSTD = optvalue;
        case 'stylestd',styleSTD = optvalue;
        case 'titlestd',titleSTD = optvalue;
        case 'npan',Npan = optvalue;
        case 'tickcor',tickCOR(Npan).val = optvalue;
        case 'colcor',colCOR = optvalue;
        case 'widthcor',widthCOR = optvalue;
        case 'stylecor',styleCOR = optvalue;
        case 'titlecor',titleCOR = optvalue;
        case 'showlabelscor',showlabelsCOR = optvalue;
        case 'fontsize',foontsize=optvalue;
        case 'markersize',markersize=optvalue;
    end
end
if length(markersize)==1
	markersize=markersize*ones(length(marker),1);
end

%% CONTINUE THE PLOT WITH UPDATED OPTIONS:

% define a circle
th = 0:pi/150:2*pi;
xunit = cos(th);
yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
inds = 1:(length(th)-1)/4:length(th);
xunit(inds(2:2:4)) = zeros(2,1);
yunit(inds(1:2:5)) = zeros(3,1);
% plot background if necessary
if ~ischar(get(cax,'color')),
    ig = 1:length(th);
    patch('xdata',xunit(ig)*rmax,'ydata',yunit(ig)*rmax, ...
        'edgecolor',tc,'facecolor',get(cax,'color'),...
        'handlevisibility','off','parent',cax);
end

% DRAW RMS CIRCLES:
% ANGLE OF THE TICK LABELS
c82 = cos(tickRMSangle*pi/180);
s82 = sin(tickRMSangle*pi/180);
for ic = 1 : length(tickRMS)
    i = tickRMS(ic);
    iphic = find( sqrt(dx^2+rmax^2-2*dx*rmax*xunit) >= i ,1);
    ig = find(i*cos(th)+dx <= rmax*cos(th(iphic)));
    hhh = line(xunit(ig)*i+dx,yunit(ig)*i,'linestyle',styleRMS,'color',colRMS,'linewidth',widthRMS,...
        'handlevisibility','off','parent',cax);
    if showlabelsRMS
        text((i+rincRMS/20)*c82+dx,(i+rincRMS/20)*s82, ...
            ['  ' num2str(i)],'verticalalignment','bottom',...
            'handlevisibility','off','parent',cax,'color',colRMS,'rotation',tickRMSangle-90)
    end
end

% DRAW DIFFERENTLY THE CIRCLE CORRESPONDING TO THE OBSERVED VALUE
%      hhh = line((cos(th)*dx),sin(th)*dx,'linestyle','--','color',colSTD,'linewidth',1,...
%                   'handlevisibility','off','parent',cax);

% DRAW STD CIRCLES:
% draw radial circles
for ic = 1 : length(tickSTD)
    i = tickSTD(ic);
    hhh = line(xunit*i,yunit*i,'linestyle',styleSTD,'color',colSTD,'linewidth',widthSTD,...
        'handlevisibility','off','parent',cax);
    if showlabelsSTD
        if Npan == 2
            if length(find(tickSTD==0)) == 0
                text(0,-rinc/20,'0','verticalalignment','top','horizontalAlignment','center',...
                    'handlevisibility','off','parent',cax,'color',colSTD);
            end
            text(i,-rinc/20, ...
                num2str(i),'verticalalignment','top','horizontalAlignment','center',...
                'handlevisibility','off','parent',cax,'color',colSTD)
        else
            if length(find(tickSTD==0)) == 0
                text(-rinc/20,rinc/20,'0','verticalalignment','middle','horizontalAlignment','right',...
                    'handlevisibility','off','parent',cax,'color',colSTD);
            end
            text(-rinc/20,i, ...
                num2str(i),'verticalalignment','middle','horizontalAlignment','right',...
                'handlevisibility','off','parent',cax,'color',colSTD)
        end
    end
end
set(hhh,'linestyle','-') % Make outer circle solid

% DRAW CORRELATIONS LINES EMANATING FROM THE ORIGIN:
corr = tickCOR(Npan).val;
th  = acos(corr);
cst = cos(th); snt = sin(th);
cs = [-cst; cst];
sn = [-snt; snt];
line(rmax*cs,rmax*sn,'linestyle',styleCOR,'color',colCOR,'linewidth',widthCOR,...
    'handlevisibility','off','parent',cax)

% annotate them in correlation coef
if showlabelsCOR
    rt = 1.05*rmax;
    for i = 1:length(corr)
        text(rt*cst(i),rt*snt(i),num2str(corr(i)),...
            'horizontalalignment','center',...
            'handlevisibility','off','parent',cax,'color',colCOR);
        if i == length(corr)
            loc = int2str(0);
            loc = '1';
        else
            loc = int2str(180+i*30);
            loc = '-1';
        end
    end
end

% AXIS TITLES
axlabweight = 'bold';
ix = 0;
if Npan == 1
    if titleSTD
        ix = ix + 1;
        ax(ix).handle = ylabel('Standard deviation','color',colSTD,'fontweight',axlabweight);
    end
    if titleCOR
        ix = ix + 1;
        clear ttt
        pos1 = 45;	DA = 15;
        lab = 'Correlation Coefficient';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.1*rmax;	ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',colCOR,'horizontalalignment','center',...
                'verticalalignment','bottom','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
    if titleRMS
        ix = ix + 1;
        clear ttt
        pos1 = tickRMSangle+(180-tickRMSangle)/2; DA = 15; pos1 = 160;
        lab = 'RMSD';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.05*tickRMS(1);
        dd = .95*tickRMS(2);
        ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dx+dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',colRMS,'horizontalalignment','center',...
                'verticalalignment','top','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
else
    if titleSTD
        ix = ix + 1;
        ax(ix).handle =xlabel('Standard deviation','fontweight',axlabweight,'color',colSTD);
    end
    if titleCOR
        ix = ix + 1;
        clear ttt
        pos1 = 90;	DA = 15;
        lab = 'Correlation Coefficient';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.1*rmax;	ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',colCOR,'horizontalalignment','center',...
                'verticalalignment','bottom','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
    if titleRMS
        ix = ix + 1;
        clear ttt
        pos1 = 160; DA = 10;
        lab = 'RMSD';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.05*tickRMS(1); ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dx+dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',colRMS,'horizontalalignment','center',...
                'verticalalignment','bottom','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
end

% VARIOUS ADJUSTMENTS TO THE PLOT:
set(cax,'dataaspectratio',[1 1 1]), axis(cax,'off'); set(cax,'NextPlot',next);
set(get(cax,'xlabel'),'visible','on')
set(get(cax,'ylabel'),'visible','on')
% set view to 2-D
view(cax,2);
% set axis limits
if Npan == 2
    axis(cax,rmax*[-1.15 1.15 0 1.15]);
    line([-rmax rmax],[0 0],'color',tc,'linewidth',1.2);
    line([0 0],[0 rmax],'color',tc);
else
    axis(cax,rmax*[0 1.15 0 1.15]);
    line([0 rmax],[0 0],'color',tc,'linewidth',1.2);
    line([0 0],[0 rmax],'color',tc,'linewidth',2);
end

% FINALY PLOT THE POINTS:
hold on
ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
for ii = 1 : length(STDs)
    pp(ii)=plot(rho(ii)*cos(theta(ii)),rho(ii)*sin(theta(ii)));
    set(pp(ii),'marker',marker{ii},'markersize',markersize(ii),'MarkerFaceColor',color{ii},'MarkerEdgeColor','k');
    if isempty(labels{ii})
        if mod(ii,length(ALPHABET))==0
            tt(ii)=text(rho(ii)*cos(theta(ii)),rho(ii)*sin(theta(ii)),lower([ALPHABET(div(ii,length(ALPHABET))+1) ALPHABET(length(ALPHABET))]),'color',labelsColor{ii});
        else
            tt(ii)=text(rho(ii)*cos(theta(ii)),rho(ii)*sin(theta(ii)),lower([ALPHABET(div(ii,length(ALPHABET))+1) ALPHABET(mod(ii,length(ALPHABET)))]),'color',labelsColor{ii});
        end
    else
        tt(ii)=text(rho(ii)*cos(theta(ii)),rho(ii)*sin(theta(ii)),labels(ii),'color',labelsColor{ii});
    end
end
set(tt,'verticalalignment','bottom','horizontalalignment','right')
set(tt,'fontsize',fontsize)

%%% OUTPUT
switch nargout
    case 1
        varargout(1) = {pp};
    case 2
        varargout(1) = {pp};
        varargout(2) = {tt};
    case 3
        varargout(1) = {pp};
        varargout(2) = {tt};
        varargout(3) = {ax};
end


end%function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = disp_optionslist(varargin)

disp('General options:')
dispopt('''Npan''',sprintf('1 or 2: Panels to display (1 for positive correlations, 2 for positive and negative correlations).\n\t\tDefault value depends on CORs'));

disp('RMS axis options:')
dispopt('''tickRMS''','RMS values to plot gridding circles from observation point');
dispopt('''colRMS''','RMS grid and tick labels color. Default: green');
dispopt('''showlabelsRMS''','0 / 1 (default): Show or not the RMS tick labels');
dispopt('''tickRMSangle''','Angle for RMS tick lables with the observation point. Default: 135 deg.');
dispopt('''styleRMS''','Linestyle of the RMS grid');
dispopt('''widthRMS''','Line width of the RMS grid');
dispopt('''titleRMS''','0 / 1 (default): Show RMSD axis title');

disp('STD axis options:')
dispopt('''tickSTD''','STD values to plot gridding circles from origin');
dispopt('''colSTD''','STD grid and tick labels color. Default: black');
dispopt('''showlabelsSTD''','0 / 1 (default): Show or not the STD tick labels');
dispopt('''styleSTD''','Linestyle of the STD grid');
dispopt('''widthSTD''','Line width of the STD grid');
dispopt('''titleSTD''','0 / 1 (default): Show STD axis title');
dispopt('''limSTD''','Max of the STD axis (radius of the largest circle)');

disp('CORRELATION axis options:')
dispopt('''tickCOR''','CORRELATON grid values');
dispopt('''colCOR''','CORRELATION grid color. Default: blue');
dispopt('''showlabelsCOR''','0 / 1 (default): Show or not the CORRELATION tick labels');
dispopt('''styleCOR''','Linestyle of the COR grid');
dispopt('''widthCOR''','Line width of the COR grid');
dispopt('''titleCOR''','0 / 1 (default): Show CORRELATION axis title');

end%function

function [] = dispopt(optname,optval)
disp(sprintf('\t%s',optname));
disp(sprintf('\t\t%s',optval));
end