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
% 	Model statistics saved in a matfile in statistics directory  
%   Error matrix plot of different reanalysis datasets

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
            % extract the quality indices
            C = eval(strcat('allstats_modified(tts.',var{k},'_obstbl,tts.',var{k},'_reanltbl)'));
            statm(j,i,:) = abs(C(:,2)-C(:,1));
        end       
    end
    statm=squeeze(mean(statm,1));
    %% model rank
    T=table(statm(:,1),statm(:,2),statm(:,3),statm(:,4),statm(:,5),statm(:,6),statm(:,7));
    T.Properties.VariableNames ={'Mean','SD','RMSD','CC','Rsquared','RMSE','Bias'};
    T.name = reanl';
    cd statistics/
    save('statistics.mat','T');
    meanst(:,7)=abs(statm(:,7)); %remove negative value of bias for a meaningful average over stations
    % call model rank function to plot error matrix
    modelrank(meanst,k,var{k},reanl)
    cd ..
end