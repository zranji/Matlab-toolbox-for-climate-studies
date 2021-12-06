function M=loadMtx(cam,name);
%M=loadMtx(cam,name)
%   Devuelve en M la variable NAME, que se encuentra en PC.mat,
%   y si no en un archivo NAME.mat,  dentro del directorio CAM.
cfgdir=dir(cam); 
[dcfg{1:size(cfgdir,1)}]=deal(cfgdir.name);
if any(strcmpi(dcfg,'PC.mat'))
   vars=who('-file',[cam 'PC.mat']);
   if any(strcmpi(vars,name)) 
      gvar='PC.mat';
   elseif any(strcmpi(dcfg,[name '.mat']))
      gvar=[name '.mat'];
   else
      error([cam ': ' name ' variable or file not found']);   
   end
   DATA=load([cam gvar],name);
   M=eval(['DATA.' name]);
elseif any(strcmpi(dcfg,'CP.mat'))
   vars=who('-file',[cam 'CP.mat']);
   if any(strcmpi(vars,name)) 
      gvar='CP.mat';
   elseif any(strcmpi(dcfg,[name '.mat']))
      gvar=[name '.mat'];
   else
      error([cam ': ' name ' variable or file not found']);   
   end
   DATA=load([cam gvar],name);
   M=eval(['DATA.' name]);
else
	error([cam 'PC.mat: not found']);   
end