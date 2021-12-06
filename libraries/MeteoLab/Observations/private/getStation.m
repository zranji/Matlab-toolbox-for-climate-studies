function [DATA,file_exist]=getStation(PATH,FILES,varargin);


listFormats={'BINFILE','ASCFILE'};
BINFILE=1;
ASCFILE=2;
FILEFORMAT=BINFILE;
yesOptions={'YES','TRUE','1','SI'};
noOptions={'NO','FALSE','0','none'};
ZIPFILE=0;
CHECKEXISTENCE=0;
%%ARGUMENTS={'FILEFORMAT','ZIPFILE'}
for i=1:2:length(varargin)
   switch(upper(varargin{i}))
   case 'FILEFORMAT'
      ind=strmatch(upper(varargin{i+1}),listFormats);
      if(length(ind)~=1)
         error(['No matches or multiples matches for argument: ' 'FILEFORMAT'])    
      end
      FILEFORMAT=ind;
   case 'ZIPFILE'
      if(~isempty(strmatch(upper(varargin{i+1}),yesOptions)))
         ZIPFILE=1;    
      elseif(~isempty(strmatch(upper(varargin{i+1}),noOptions)))
         ZIPFILE=0;
      else
         error('Unknown option for argument: ZIPFILE');
      end
   case 'CHECKEXISTENCE'
      if(~isempty(strmatch(upper(varargin{i+1}),yesOptions)))
         CHECKEXISTENCE=1;    
      elseif(~isempty(strmatch(upper(varargin{i+1}),noOptions)))
         CHECKEXISTENCE=0;
      else
         error('Unknown option for argument: CHECKEXISTENCE');
      end
   otherwise
      error(['Unknown argument' varargin{i}])
   end
end



%Pasing to cell
if(~iscell(FILES))
   FILES=cellstr(FILES);
end
%Initializing DATA structure with empty fields
empCell=cell(size(FILES));
%empCell={};
DATA=struct(...
   'startDate',empCell,'endDate',empCell,'period',empCell,'step',empCell,'ndata',empCell,...
   'type',empCell, 'unit',empCell, 'var',empCell, 'source',empCell,'data',empCell,'snht',empCell);
%Passing the PATH to UNIX format (is more general)
PATH=strrep(PATH,'\','/');
%If PATH doesn't end with path separator, put it.

if(PATH(end)~='/' & ~ZIPFILE)
   PATH=[PATH '/'];
end

%Reading for each one
d=[];
file_exist=zeros(size(FILES));
for iFILES=1:length(FILES)
    if CHECKEXISTENCE
        [s1,s2]=getData(PATH,FILES{iFILES},FILEFORMAT,ZIPFILE);
    else
        [s1,s2,d]=getData(PATH,FILES{iFILES},FILEFORMAT,ZIPFILE);
    end
    DATA(iFILES)=par2struct(DATA(iFILES),[char(s1) ',' char(s2)],',',{'ndata'});
    numdias=DATA(iFILES).ndata;
   if((isempty(d) | numdias~=length(d)) & ~CHECKEXISTENCE)
      if(~isempty(d))
         disp(sprintf('Unmatched data length in Station %s (expected=%d,read=%d)',[PATH FILES{iFILES}],numdias,length(d)));
      end
   else
       DATA(iFILES).data=d;
       file_exist(iFILES)=1;
   end
   if(mod(iFILES,100)==0)
       disp(num2str(iFILES))
   end
end




function [s1,s2,d]=getData(PATH,FILE,FILEFORMAT,ZIPFILE)


BINFILE=1;
ASCFILE=2;

%%Checking in which format is asking to us
s1='';s2='';d=[];
if(~ZIPFILE)
   fid=fopen([PATH FILE],'rb','ieee-be');  
   %If there is any error opening file, left this one empty and continue
   if(fid<0)
      return
   end
   %Read the 2 first headerlines and pass it to a structure
   s1=fgetl(fid);
   s2=fgetl(fid);
   switch FILEFORMAT
   case BINFILE
      d=fread(fid,Inf,'single');
   case ASCFILE
      d=textread([PATH FILE],'%f','headerlines',2);
   otherwise
      error('Ops!!! Which is the format of the FILE?');
   end
   fclose(fid);
else
   %From ZIP
   s1='';s2='';d=[];
   switch FILEFORMAT
   case BINFILE
      switch nargout
          case 1
            s1=zipgetStationData(PATH,FILE);
          case 2
            [s1,s2]=zipgetStationData(PATH,FILE);
          case 3
            [s1,s2,d]=zipgetStationData(PATH,FILE);
          otherwise
              error('Ops!!! Which is the format of the FILE?');
      end
      
              
   case ASCFILE
      return
      error('Ops!!! ASCFILE and ZIPPED not yet supported');    
   otherwise
      error('Ops!!! Which is the format of the FILE?');
   end
   if(isempty(s1) | isempty(s2))
      s1='';s2='';d=[];
      return
   end
end

%from MAT-file (Not finished)
%s=load([PATH FILES{iFILES}]);
