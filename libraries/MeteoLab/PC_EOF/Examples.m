%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTING AND STORING EOFS...
% The necessary data is not included in MeteoLab (this example will not work!!).
% The example just illustrates how to run computeEOF on you own data. 
% If you want to obtain this data, send a mail to: gutierjm@unican.es

%       dmn=readDomain('Nao');
%       ctl.cam=dmn.src;
%       ctl.fil='era40.ctl';
%       [fields,dmn]=getFieldfromGRIB(ctl,dmn);
%       [EOF,PC,MN,DV,PEV]=computeEOF(fields,'npc',50,'path',dmn.path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTING EOFs...
% ATTENTION: Don't store these EOFs or you will loose those included in the toolbox
% (generated with the 40 year reanalysis)
dmn=readDomain('\\oceano.macc.unican.es\gmeteo\METEOLAB\PatternsData\Spain\CuencaBaleares');
ctl.cam=dmn.src;
ctl.fil='era40.ctl';
dates={'01-Jan-1999','31-Dec-1999'};
[fields,dmn]=getFieldfromGRIB(ctl,dmn,'dates',dates);
[EOF,PC,MN,DV,PEV]=computeEOF(fields,'npc',50);

% COMPUTING AND STORING EOFS... (without standarizing the data)
dmn=readDomain('NorthernBasin');
ctl.cam=dmn.src;
ctl.fil='era40.ctl';
dates={'01-Jan-1999','31-Dec-1999'};
[fields,dmn]=getFieldfromGRIB(ctl,dmn,'dates',dates);
[EOF,PC,MN,DV,PEV]=computeEOF(fields,'npc',50,'path',dmn.path,'prest','no');

% LOADING STORED EOFS...
dmn=readDomain('Nao');
[EOF,PC,MN,DV,PEV]=getEOF(dmn,'npc',50,'dates',{'01-Jan-1958','31-Dec-2001'});

% Drawing EOFs (columns of matrix EOF)
drawGrid(EOF(:,1:4)',dmn,'iscontourf',1);%only square-matrices can be drawn: EOF(:,1:9)',EOF(:,1:16)'...
drawGrid(EOF(:,25)',dmn,'iscontourf',1);
drawGrid(EOF(:,50)',dmn,'iscontourf',1);

% Drawing PCs (columns of matrix PC)
figure
subplot(2,1,1); plot(PC(:,1));   %Coefficients of the first EOF
subplot(2,1,2); plot(PC(:,50));  %Coefficients of the 50th EOF

% Drawing mean field, standard deviation and cumulative percentage of explained variance
drawGrid(MN,dmn,'iscontourf',1);
drawGrid(DV,dmn,'iscontourf',1);
figure
plot(PEV)

% If the atmospheric pattern used to compute EOFs has more than one variable, level or time
% then you must use findVarPosition to draw each field of interest
dmn=readDomain('Iberia');
[EOF,PC,MN,DV,PEV]=getEOF(dmn,'npc',50);
drawGrid(EOF(findVarPosition('Z',12,500,dmn),1:4)',dmn,'iscontourf',1);
drawGrid(MN(:,findVarPosition('T',12,1000,dmn)),dmn)

% Computing and drawing power spectrum for PCs
figure
subplot(2,1,1) 
f=fft(PC(:,1)); loglog(abs(f(2:end/2,:)))
subplot(2,1,2)
f=fft(PC(:,50)); loglog(abs(f(2:end/2,:)))

% Averaging yearly values
figure
period=365;
a=aveknt(PC(:,5),period); 
plot(a(1,1:period:end))

% Comparing standarised fields with non-standarised fields
dmn=readDomain('Nao');
ctl.cam=dmn.src;
ctl.fil='era40.ctl';
dates={'01-Jan-1999','31-Dec-1999'};
[fields,dmn]=getFieldfromGRIB(ctl,dmn,'dates',dates);
[EOF,PC,MN,DV,PEV]=computeEOF(fields,'npc',50);
EOFSTD=EOF;
PEVSTD=PEV;
drawGrid(EOFSTD(:,1)',dmn,'iscontourf',1);
[EOF,PC,MN,DV,PEV]=computeEOF(fields,'npc',50,'prestd','no');
drawGrid(EOF(:,1)',dmn,'iscontourf',1);
[PEVSTD(1:10) PEV(1:10)]

%Comparing a reconstructed field with the original field
dmn=readDomain('Nao');
ctl.cam=dmn.src;
ctl.fil='era40.ctl';
dates={'01-Aug-1999','10-Aug-1999'};
[fields,dmn]=getFieldfromGRIB(ctl,dmn,'dates',dates);
[aproxfields,info]=getFieldfromEOF(dmn,'npc',50,...
       'var',151,'time',12,'level',0,'dates',dates);
drawGrid(fields(1,:),dmn)
drewGrid(aproxfields(1,:),dmn)

% Obtaining the reconstructed fields with 50 and 4 PCs
dmn=readDomain('Iberia');
dates={'01-Aug-1999','10-Aug-1999'};
[aproxpat50,info]=getFieldfromEOF(dmn,'npc',50,...
       'var',151,'time',12,'level',0,'dates',dates);
[aproxpat4,info]=getFieldfromEOF(dmn,'npc',4,...
       'var',151,'time',12,'level',0,'dates',dates);
drawGrid(aproxpat50(1:9,:),dmn)
drawGrid(aproxpat4(1:9,:),dmn)


% Reconstructed fields with 50 and 4 PCs (for only 1 variable,level and time)
days=size(PC,1);
pat=((PC*EOF').*repmat(DV,[days 1]))+repmat(MN,[days  1]);
patAprox=((PC(:,1:4)*EOF(:,1:4)').*repmat(DV,[days 1]))+repmat(MN,[days 1]);
drawGrid(pat(1:9,:),dmn);
drawGrid(patAprox(1:9,:),dmn);

