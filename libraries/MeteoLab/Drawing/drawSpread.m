function h = drawSpread(data,varargin)

% Draws a spread function
% Output arguments
%    h:   Figure handle
% 
%  Input arguments ([]'s are optional): 
%    data:    (Matrix) NxM matrix where N is the time dimension 
%                      and  M the members dimension
%    [argID,  (String) See below
%     value]  (varies) 
%
% Here are the valid argument IDs and corresponding values:
%   'xvalues'   (Cell):   X axis values (N values)
%   'lines'     (String): Draw individual model values:
%                          'yes' (by default)
%                          'no'
%   'indexes'   (Matriz): Matrix (Lx1 values) with the indexes (relative to the 
%                          second dimension of data) for visble line members.
%                          By default, all members are visible
%   'colors'    (Matrix): Lx3 matrix corresponding to different members. By
%                          default, random colors are chosen. It is applied
%                          if lines is 'yes'
%   'styles'    (Cell):   Cell array (L values) specifing the line styles
%                          for individual members. It is applied
%                          if lines is 'yes'
%   'widths'    (Cell):   Matrix (Lx1 values) specifing the lines width
%   'legends'   (Cell):   Cell array (L values) specifing the legend
%                          for individual members. By default it's empty so
%                          legend is not visible
%   'shadows'   (String): Draw shadows:
%                          'yes' (by default)
%                          'no'
%   'indexesg'  (Cell):   Cell array (S values) with the indexes (relative to the 
%                          second dimension of data) for different shadows.
%                          By default there is just one group containing
%                          all individual members. If is empty no shadow is visible                          
%   'colorsg'   (Matrix): Sx3 matrix corresponding to different shadows. By
%                          default, random colors are chosen.
%   'alphasg'   (Matrix): Sx1 matrix width shadows opacity level (0.5)
%   'legendsg'  (Cell):   Cell array (S values) specifing the legend
%                          for shadows. By default it's empty so
%                          legend is not visible
%   'boundary'  (Cell):   Cell array (Sx2 values) specifing the lower and
%                          upper function employed for shadow limits. 
%                          By default min and max values are used. Possible
%                          values are:
%                           min, max and prcXX


[N,M] = size(data);

%% Default parameters
xv = [1:N]';
lines   = 'yes';
colors  = rand(M,3);
styles  = cellstr(repmat('-',M,1));
legends = {};
indexes = 1:M;
widths = ones(1,M);

shadows    = 'yes';
legendsg   = {};
colorsg    = rand(M,3);
indexesg{1} = 1:M;
indexesg{2} = 1:M;
colorsg    = rand(1,3);
alphasg    = 0.5;
for k=1:M
    boundary{k} = {'min','max'};
end

%% Read parameters
i=1;
while i<=length(varargin), 
  argok = 1;
  switch varargin{i},
     case 'xvalues',    i=i+1; xv = varargin{i}; 
     case 'lines',      i=i+1; lines = lower(varargin{i}); 
     case 'colors',     i=i+1; colors = varargin{i};
     case 'styles',     i=i+1; styles = varargin{i};
     case 'legends',    i=i+1; legends = varargin{i}; 
     case 'indexes',    i=i+1; indexes = varargin{i};
     case 'widths',     i=i+1; widths = varargin{i};
     case 'indexesg',   i=i+1; indexesg = varargin{i};
     case 'colorsg',    i=i+1; colorsg = varargin{i};
     case 'shadows',    i=i+1; shadows = lower(varargin{i});
     case 'alphasg',    i=i+1; alphasg = varargin{i};
     case 'legendsg',   i=i+1; legendsg = varargin{i};
     case 'boundary',   i=i+1; boundary = varargin{i};         
     otherwise argok=0;
  end
  if ~argok, 
    disp(['Ignoring invalid argument #' num2str(i+1)]); 
  end
  i = i+1; 
end

S = length(indexesg);
if length(indexesg)~=size(colorsg,1)
    colorsg=rand(S,3);
end
if length(indexesg)~=length(alphasg)
    alphasg=repmat(0.5,S,1);
end
if length(indexesg)~=size(boundary,1)
    for k=1:size(boundary,1)
        boundary{k} = {'min','max'};
    end
end

L = length(indexes);
if length(indexes)~=size(colors,1)
    colors=rand(L,3);
end
if length(indexes)~=size(styles,1)
    styles=cellstr(repmat('-',L,1));
end
if length(indexes)~=size(widths,1)
    widths  = ones(L,1);
end
% h = figure;hold on;

LEGS = {};
HAND = [];
i = 1;
if strcmp(shadows,'yes')
    for s=1:S
        BB = boundary{s};
        MN = getBoundary(data(:,indexesg{s}),BB{1});
        MX = getBoundary(data(:,indexesg{s}),BB{2});
        [rows,columns]=find(isnan(MX));
        MX(rows)=MX(rows-1);
        MN(rows)=MN(rows-1);
        p = patch([xv(27:end); flipud(xv(27:end))],[MX(27:end);flipud(MN(27:end))],colorsg(s,:));hold on;
        set(p,'EdgeAlpha',0);set(p,'FaceAlpha',alphasg(s));set(p,'EdgeColor',colorsg(s,:))
        if ~isempty(legendsg)
            LEGS{i} = legendsg{s};
            HAND(i) = p;
            i = i+1;
        end
    end
end

if strcmp(lines,'yes')
    for l=1:L
        p = plot(xv,data(:,indexes(l)),'LineStyle',styles{l},'color',colors(l,:),'LineWidth',widths(l));
        if ~isempty(legends)
            LEGS{i} = legends{l};
            HAND(i) = p;
            i = i+1;
        end
    end
end

if ~isempty(LEGS)
   legend(HAND,LEGS); 
end

function val = getBoundary(d,b)
if strcmp(b,'max')
    val = max(d,[],2);
elseif strcmp(b,'min')
    val = min(d,[],2);
elseif strcmp(b,'mean')
    val = mean(d,2);
elseif strmatch('prc',b)
    val = NaN*zeros(size(d,1));
    prct=str2num(b(4:end));
    for v=1:size(val,1)
        val(v) = prctile(d(v,:),prct);
    end
else
    error('Invalid boundary function');
end