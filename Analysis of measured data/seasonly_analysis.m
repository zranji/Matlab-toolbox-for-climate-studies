% monthly_analysis Plot a monthly summary of wind direction
%
% INPUTS:
%	directory: input excel files diretory
%	excels should include Time and the rest of variables with the name defined in the header 
%   An excel sample is provided
% OUTPUTS:
% 	Plots of monthly means
function [] = seasonly_analysis(directory)
currdir=pwd;
cd(directory)

% The varible name is defined here
param={'tas','psl','hurs','u','theta'};
for p=1:size(param,2)
    var=char(param(p));
    tbl=dir('*tbl.xlsx');
    z=size(tbl,1);
    for j=1:z
        if j==1
           tos=readtable(tbl(j).name);
           tosyr=retime(table2timetable(tos),[datetime(1980,1,1):calmonths(1):datetime(2021,1,1)]');
           tosyr=eval(strcat('timetable(tosyr.Time,tosyr.',var,')'));
           tss=tosyr;
        else
           %% Synchronize
           tos=readtable(tbl(j).name);
           tosyr=retime(table2timetable(tos),[datetime(1980,1,1):calmonths(1):datetime(2021,1,1)]');
           tosyr=eval(strcat('timetable(tosyr.Time,tosyr.',var,')'));
           tss=synchronize(tss,tosyr);
        end
    end
    tss=tss(1:end-1,:);
    month=categorical({'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'});
    %month=categorical({'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12'});
    season=categorical({'Spring','Summer','Autumn','Winter'});
    tom=struct();
    hi=zeros(size(tss,2),12);
    if contains(var,'theta')
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
    else
        for i=1:size(tss,2)
            %% Synchronize
            tmo=tss(:,i);
            for tm2=1:12
                tom.(char(month(tm2)))=(tmo(contains(datestr(tmo.Time),char(month(tm2))),1));
                tommean(tm2)=mean(tom.(char(month(tm2))){:,1:end},1,'omitnan');
            end
            hi(i,:)=tommean;
        end
    end
    kk=0;
    for modeln=1:size(hi)
        for tseason=1:3:12
            kk=kk+1;
            hii(modeln,kk)=mean(hi(modeln,tseason:tseason+2));
            if mod(kk,4)==0
                kk=0;
            end
        end
    end
    subplot(3,2,p)
    b=bar(hii','BarWidth',1);
    st=size(hii,1);
    clr=parula(st);
    cmap = clr;
    for k = 1:st
        b(k).FaceColor= cmap(k,:);
    end
    set(gca,'xticklabel',char(season))
    for ii = 1 : j
        a=split(tbl(ii).name,'tbl.xlsx');
        ss{ii}=a{1,1};
        str=lower(ss{ii});
        aa=char(str);
        aa(1)=upper(aa(1));
        strr{ii}=aa;
    end
    title(var) 
end
legend(strr)
cd(currdir)
end