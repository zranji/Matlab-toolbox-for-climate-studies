% monthly_analysis Plot a monthly summary of wind direction
%
% INPUTS:
%	directory: input excel files diretory
%	excels should include Time and the rest of variables with the name defined in the header 
%   An excel sample is provided
% OUTPUTS:
% 	Plots of monthly means
function [] = monthly_analysis(directory)
currdir=pwd;
cd(directory)

% The varible name is defined here
var='theta'; %%{'tas','hurs','u','psl'}

% choose the proper type of months in datetime format.
month=categorical({'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'});
%month=categorical({'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12'});

tbl=dir('*tbl.xlsx');
z=size(tbl,1);

% duration of analysis
startyear=1980;
endyear=2021;

for j=1:z
    if j==1
       tos=readtable(tbl(j).name);
       tosyr=retime(table2timetable(tos),[datetime(startyear,1,1):calmonths(1):datetime(endyear,1,1)]');
       tosyr=eval(strcat('timetable(tosyr.Time,tosyr.',var,')'));
       tss=tosyr;
    else
       %synchronize different datsets
       tos=readtable(tbl(j).name);
       tosyr=retime(table2timetable(tos),[datetime(startyear,1,1):calmonths(1):datetime(endyear,1,1)]');
       tosyr=eval(strcat('timetable(tosyr.Time,tosyr.',var,')'));
       tss=synchronize(tss,tosyr);
    end
end
tss=tss(1:end-1,:);
tom=struct();
hi=zeros(size(tss,2),12);

% monthly average
for i=1:size(tss,2)
    tmo=tss(:,i);
    for tm2=1:12
        if contains(var,'theta')
            tom.(char(month(tm2)))=(tmo(contains(datestr(tmo.Time),char(month(tm2))),1));
            array=tom.(char(month(tm2))){:,1:end};
            arr=array(~isnan(array));
            ang=(radtodeg(circ_mean(deg2rad(arr))));%,1,'omitnan'
            tommean(tm2)=ang+(ang<0)*360;
        else
            tom.(char(month(tm2)))=(tmo(contains(datestr(tmo.Time),char(month(tm2))),1));
            tommean(tm2)=mean(tom.(char(month(tm2))){:,1:end},1,'omitnan');
        end
    end
    hi(i,:)=tommean;
end

% bar plot
b=bar(hi','BarWidth',1);
st=size(hi,1);
cmap=parula(st);
set(b,'EdgeColor','k');
for k = 1:st
    b(k).FaceColor= cmap(k,:);
end
set(gca,'xticklabel',char(month))
for ii = 1 : st
    a=split(tbl(ii).name,'.xlsx');
    s{ii}=a{1,1};
end
xlim([0.5 12.5])
title(var)
legend(s)
cd(currdir)
end