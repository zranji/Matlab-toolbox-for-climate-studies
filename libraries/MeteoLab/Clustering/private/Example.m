cfg.cam='../areaPatterns/Spain/NacionalEuropa/';
cfg.fil='domain.cfg';
dmn=readDomain([cfg.cam cfg.fil]);
%drawAreaPattern(dmn)


%field=getFieldfromEOF(cfg.cam,dmn);

%figure
%for i=1:size(field.dat,1),
%   drawGrid(field.dat(i,:),dmn)
%   pause
%end

CP=loadMtx(cfg.cam,'CP');
SV=loadMtx(cfg.cam,'SV');
DV=loadMtx(cfg.cam,'DV');
MN=loadMtx(cfg.cam,'MN');

NCP=50;
nCenters=36;
[ind,Centers] = kmeans(CP(:,1:NCP),nCenters);

%datos=CP2Real(129,12,1000,dmn,Centers,1:NCP,SV,DV,MN);




