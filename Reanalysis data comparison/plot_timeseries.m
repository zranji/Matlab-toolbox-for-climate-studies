function [ ] = plot_timeseries(obstbl,reanltbl,j,param,tstart,tend,reanl,clr)
subplot(2,2,j)
eval(strcat('plot(obstbl.Time,obstbl.',param,',''linewidth'',','1.5',',''color''',',''k''',')'))
hold on
eval(strcat('plot(reanltbl.Time,reanltbl.',param,',''linestyle'',''none'',''Marker'',''.'',''Markersize'',','10',',''color'',','clr)'))
xlim([tstart,tend])
title(reanl)
legend('Measured','Reanalysis')
xlabel('Date')
if contains(param,'tas')
    ylabel('Surface Temperature ({\circ}C)')
elseif contains(param,'psl')
    ylabel('Sea Level Pressure (mbar)')
elseif contains(param,'hurs')
    ylabel('Relative Humidity (%)')
elseif contains(param,'u')
    ylabel('Wind Speed (m/s)')
elseif contains(param,'theta')
    ylabel('Wind Direction ({\circ})')
end
end

