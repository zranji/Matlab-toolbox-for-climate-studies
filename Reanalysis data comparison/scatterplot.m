function [ ] = scatterplot(tts,j,reanl,clr,param)
subplot(2,2,j)
eval(strcat('plot(tts.',param,'_obstbl,','tts.',param,'_reanltbl,','''linestyle'',''none'',''Marker'',''o'',''Markersize'',','3',',''color'',clr)'))
hold on
a=eval(strcat('min(tts.',param,'_obstbl)'));
b=eval(strcat('max(tts.',param,'_obstbl)'));
c=eval(strcat('min(tts.',param,'_reanltbl)'));
d=eval(strcat('max(tts.',param,'_reanltbl)'));
t = linspace(a,b,500); %arbitrary bounds and number of points
plot(t,t,'linewidth',2,'color','k');
title(reanl)
ylim([min(a,c) max(b,d)])
xlim([min(a,c) max(b,d)])
xlabel('Measured')
ylabel('Simulated')
end
    