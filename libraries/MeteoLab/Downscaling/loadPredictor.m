function [EOF,X,MN,DV] = loadPredictor(dmn,BASE_PATH,EOF_PATH,type)

[EOF,PC,MN,DV]=getEOF(dmn,'path',[BASE_PATH EOF_PATH '/']);
FIELDS = [];
if ~strcmp(type,'PC')
  if isempty(dir([BASE_PATH EOF_PATH '/FIELDS.mat']))
    % old version
    FIELDS = PC*EOF';
  else
    FIELDS = load([BASE_PATH EOF_PATH '/FIELDS.mat']);
    FIELDS = FIELDS.FIELDS;
  end
  FIELDS = pstd(FIELDS);
end
if strcmp(type,'FIELDS')
  PC = [];
end
X = [PC FIELDS];
