function [loc,Maes,id,nam,alt,prv,typ]=loadMaster(name,varargin)

MATFILE=0;
if(nargin>1)
   if(strcmpi(varargin{1},'mat'))
      MATFILE=1;
   end
end
%Cargamos los datos
loc=[];fptnd=[];
Maes=[];

if(MATFILE)
   eval(['load ' name]);   
else
   [Maes,Maeslength]=getLines(name);
   iMaes=find(Maeslength~=171);
   if ~isempty(iMaes)
      warning(sprintf('Some entry in %s don''t have a correct form.',name));  
      iMaes=find(Maeslength==171);
      Maes=Maes(iMaes,:);
   end
end

dum1=Maes(:,140:146);
dum1(find(dum1==' '))='0';
loc(:,1)=(str2num(dum1(:,1:2))+str2num(dum1(:,3:4))/60+...
   str2num(dum1(:,5:6))/3600).*((-1).^(str2num(dum1(:,7))+1));
dum1=Maes(:,147:152);
dum1(find(dum1==' '))='0';
loc(:,2)=(str2num(dum1(:,1:2))+str2num(dum1(:,3:4))/60+...
   str2num(dum1(:,5:6))/3600);

if nargout>2
   dum1=Maes(:,153:156);
	dum1(find(dum1==' '))='0';
   alt(:,1)=str2num(dum1);
	prv=Maes(:,86:97);
   dum1=Maes(:,118:126);
   tipos={'P','T','C','E','S','R','Y','H','A'};
   for t=1:length(tipos)
      typ(:,t)=sum(dum1==tipos{t},2);
   end
   nam=Maes(:,6:55);
   id=Maes(:,1:5);
end

iMaes=find(sum(loc,2)==0);
if ~isempty(iMaes)
   warning(sprintf('Some entry in %s don''t have location coordinate.',name));  
   iMaes=find(sum(loc,2)~=0);
   Maes=Maes(iMaes,:);
   loc=loc(iMaes,:);
   id=id(iMaes,:);
   if nargout>2
   	alt=alt(iMaes,:);   
   	prv=prv(iMaes,:);   
   	typ=typ(iMaes,:);   
   	nam=nam(iMaes,:);   
   end
end


