% roseplot_seasonaly Plot seasonal windrose of input datasets
%
% INPUTS:
%	directory: input excel files diretory
%	excels should include Time and the wind speed (u) and direction (theta) variables with the name defined in the header 
%   An excel sample is provided
% OUTPUTS:
% 	Rose wind plot

function [] = roseplot_seasonaly(directory)
currdir=pwd;
cd(directory)

% duration of analysis
startyear=1980;
endyear=2021;

tbl=dir('*hourly.xlsx');
z=size(tbl,1);

% read theta variable of all inputs
var='theta'; 
for j=1:z
    if j==1 
       tos=readtable(tbl(j).name);
       tosyr=retime(table2timetable(tos),[datetime(startyear,1,1,0,0,0):hours(1):datetime(endyear,1,1,0,0,0)]');
       tosyr=eval(strcat('timetable(tosyr.Time,tosyr.',var,')'));
       tss=tosyr;
    else
       tos=readtable(tbl(j).name);
       tosyr=retime(table2timetable(tos),[datetime(startyear,1,1,0,0,0):hours(1):datetime(endyear,1,1,0,0,0)]');
       tosyr=eval(strcat('timetable(tosyr.Time,tosyr.',var,')'));
       tss=synchronize(tss,tosyr);
    end
end

% read u variable of all inputs
var='u'; 
for j=1:z
    if j==1 
       tos1=readtable(tbl(j).name);
       tosyr1=retime(table2timetable(tos1),[datetime(startyear,1,1,0,0,0):hours(1):datetime(endyear,1,1,0,0,0)]');
       tosyr1=eval(strcat('timetable(tosyr1.Time,tosyr1.',var,')'));
       tss1=tosyr1;
   else
       tos1=readtable(tbl(j).name);
       tosyr1=retime(table2timetable(tos1),[datetime(startyear,1,1,0,0,0):hours(1):datetime(endyear,1,1,0,0,0)]');
       tosyr1=eval(strcat('timetable(tosyr1.Time,tosyr1.',var,')'));
       tss1=synchronize(tss1,tosyr1);
   end
end
tss=tss(1:end-1,:);
tss1=tss1(1:end-1,:);
%% categorize in season
season={'Spring','Summer','Autumn','Winter'};
ind=contains(datestr(tss.Time),{'Apr','May','Jun'});
ts.spring=tss(ind,:);
ts1.spring=tss1(ind,:);        
    
ind=contains(datestr(tss.Time),{'Jul','Aug','Sep'});
ts.summer=tss(ind,:);
ts1.summer=tss1(ind,:);
    
ind=contains(datestr(tss.Time),{'Oct','Nov','Dec'});
ts.fall=tss(ind,:);
ts1.fall=tss1(ind,:);

ind=contains(datestr(tss.Time),{'Jan','Feb','Mar'});
ts.winter=tss(ind,:);
ts1.winter=tss1(ind,:);

for ii = 1 : z
    a=split(tbl(ii).name,'hourly.xlsx');
    ss{ii}=a{1,1};
    str=lower(ss{ii});
    aa=char(str);
    aa(1)=upper(aa(1));
    name{ii}=aa;
end
%% roseplot
for sz=1:4
    for i=1:size(name,2)
        Options2 = {'anglenorth',0,'angleeast',90,...
         'labels',{'N','E','S','W'},'freqlabelangle',45,...
         'legendtype',0,'vwinds',[2,4,6,8,10,12],...
         'radialgridstyle', ':', 'circulargridstyle', ':', ...
         'radialgridcolor',[0.5 0.5 0.5], 'circulargridcolor',[0.5 0.5 0.5],...
         'radialgridwidth', 1, 'circulargridwidth', 1, ...
         'radialgridalpha', 0.75, 'circulargridalpha', 0.75,'cMap', cmocean('delta'),...
         'textfontname','Time new roman','titlefontname', 'Time new roman',...
         'TitleString',''};
        if sz==1
            WindRose(ts.spring{:,i},ts1.spring{:,i},Options2)
        elseif sz==2
            WindRose(ts.summer{:,i},ts1.summer{:,i},Options2)
        elseif sz==3
            WindRose(ts.fall{:,i},ts1.fall{:,i},Options2)
        else
            WindRose(ts.winter{:,i},ts1.winter{:,i},Options2)
        end
        title(strcat(name{i},'-','',season{sz}),'fontsize',16,'fontweight','bold','Position', [1, 1.1, 1])
    end
end
cd(currdir)
end