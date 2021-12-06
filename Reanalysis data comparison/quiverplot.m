function [ ] = quiverplot(tts,i,tstart,tend,reanl,clr)
tt=mod((tts.theta_obstbl-270),360);
tt=deg2rad(tt);
[uo,vo]=pol2cart(tt,tts.u_obstbl);
to=timetable(tts.Time,uo,vo,'VariableNames',{'uo','vo'});

ttt=mod((tts.theta_reanltbl-270),360);
ttt=deg2rad(ttt);

[um,vm]=pol2cart(ttt,tts.u_reanltbl);
tm=timetable(tts.Time,um,vm,'VariableNames',{'um','vm'});

subplot(2,2,i)
XX=1:1:size(tm.um,1);
quiver(XX',XX'.*0,tm.um,tm.vm,0,'MaxHeadSize',0,'color',clr);
hold on
quiver(XX',XX'.*0,to.uo,to.vo,0,'MaxHeadSize',0,'color','k');
set(gca,'XTick',[],'XTickLabel',[])
set(gca,'XTick',0:12:size(tm.Time,1))
set(gca,'XTickLabel',year(tstart):1:year(tend))
xlim([0,size(to.Time,1)-1])    
title(reanl)
legend('Measured','Reanalysis')
hold on
end