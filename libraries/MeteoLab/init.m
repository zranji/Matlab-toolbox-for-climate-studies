function init
v = version;
%  addpath(MyGenpath(pwd,0))
  addpath(MyGenpath(pwd))

METEOLAB.home=pwd;

METEOLAB.networksFiles1=which('Networks.txt');
METEOLAB.zonesFiles1=which('Zones.txt');


d=[pwd filesep '..' filesep 'config' filesep 'Networks.txt'];
if(~isempty(dir(d)))
    METEOLAB.networksFiles2=d;
end


d=[pwd filesep '..' filesep 'config' filesep 'Zones.txt'];
if(~isempty(dir(d)))
    METEOLAB.zonesFiles2=d;
end

setMETEOLAB(METEOLAB);

%%Using toolsui
javaaddpath( [pwd '/Patterns/private/netcdf-java/netcdfAll-4.3.jar']);
% javaaddpath( [pwd '/Patterns/private/netcdf-java/netcdfAll.jar']);
if ~ispref('SNCTOOLS', 'USE_JAVA')
	setpref ( 'SNCTOOLS', 'USE_JAVA', true ); % this requires SNCTOOLS 2.4.8 or better
else 
    %disp('pref already set')	
end

%we need to overwrite the old ucar units
CHANGECLASSPATH=0;
cp=which('classpath.txt');
p=textread('classpath.txt','%[^\n]');
for i=1:length(p),
    ind=findstr(p{i},'mwucarunits.jar');
    if(~isempty(ind) & p{i}~='#')
        CHANGECLASSPATH=i;
        p{i}=['#' p{i}];
    end
end

if(CHANGECLASSPATH>0)
   r=input(sprintf(['\n#####\nWARNING!!!!\nThe classpath file (%s) contains an old UCAR''s units library.\n'...
       ' The script it''s going to comment the line number %d (%s).\n'...
       ' You should make a backup of the file.\n'...
       ' To proceed please type ''yes'': '],strrep(cp,'\','\\'),CHANGECLASSPATH,p{CHANGECLASSPATH}(2:end)),'s');
   if(strcmp(lower(r),'yes'))
       disp('Commenting the line...')
       fid=fopen(cp,'wb');
       for i=1:length(p)
           fprintf(fid,'%s\n',p{i});
       end
       fclose(fid);
   else
       disp('Skipping.')
   end
end

disp('To save the configuration, remember to save the path');

function p = MyGenpath(d)

p = '';

files = dir(d);
if isempty(files)
  return
end

%
% Add d to the path if it contains any non-directories
%
isdir = logical(cat(1,files.isdir));
% if ~all(isdir)
  p = [p d pathsep];
% end

%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
  methodsep = '@';

dirs = files(isdir);
for i=1:length(dirs)
   dirname = dirs(i).name;
  if ~strcmp( dirname,'.')         &...
     ~strcmp( dirname,'..')        &...
     ~strncmp(dirname,methodsep,1) &...
     ~strcmp( dirname,'private')   &...
     ~strcmp( dirname,'.exp')   &...
     ~strcmp( dirname,'.svn')   
   p = [p MyGenpath(fullfile(d,dirname))];
  end
end
