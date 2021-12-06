% comparison_rank ranks the reanalysis datasets using the measured data
%
% INPUTS:
%	An excel file that includes station names and their longitude and
%	latitude (here station.xlsx)
%	
%   Measured data in an excel file with the same name used in station.xlsx
%   in xlsx directory
%
%   Reanalysis datasets in netcdf format in ncs directory (only available
%   for ECMWF CFSR and NCEP/NCAR data)
%   
% OUTPUTS:
% 	Comparison plot of reanalysis datasets against measured data in the
% 	format of timeseries/quiverplot/scatterplot

clc
clear
close all

var={'psl','tas','hurs','u','theta'};
st=readtable('station.xlsx');
x=st.x;
y=st.y;
name=st.name;

reanl={'ERA5','ERAI','NCEPNCAR','CFSR'};%
clr=jet(size(var,2));
cd xlsx
tss=dir('*.xlsx');
cd ..
for k=1:size(var,2)
    clear statm C
    for j=1:size(name,1)
        h=figure('Name',strcat(name{j},var{k}),'units','normalized','outerposition',[0 0 1 1]);
        set(gcf,'color','w')
        for i=1:size(reanl,2)
            cd xlsx
            % call obsread function to read measured data
            obstbl=obsread(name{j});
            %tstart and tend can be modified
            tstart=datetime(datestr(max(datenum(obstbl.Time(1)),datenum(1985,1,1))));
            tend=datetime(2006,1,1);
            cd ../ncs
            % call reanl_era/reanl_cfsr/reanl_ncep function to extract the
            % reanalysis data at the corresponding measured station 
            if contains(reanl{i},'ERA')
                reanltbl=reanl_era(reanl{i},x(j),y(j));
            elseif contains(reanl{i},'CFSR')
                reanltbl=reanl_cfsr(reanl{i},x(j),y(j));
            elseif contains(reanl{i},'NCEP')
                reanltbl=reanl_ncep(reanl{i},x(j),y(j));
            end
            cd ..
            % synchronize the measured and reanalysis data
            tts=synchronize(obstbl,reanltbl,tstart:tend,'linear');
            %% plot Uncomment the required plot
            plot_timeseries(obstbl,reanltbl,i,var{k},tstart,tend,reanl{i},clr(k,:))
%           quiverplot(tts,i,tstart,tend,reanl{i},clr(k,:))
%           scatterplot(tts,i,reanl{i},clr(k,:),var{k})
        end       
    end
end