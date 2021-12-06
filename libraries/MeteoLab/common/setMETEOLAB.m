function setMETEOLAB(METEOLAB)

fid=fopen([prefdir(1) filesep 'METEOLAB.cfg'],'wb');
nom = fieldnames(METEOLAB);
for i=1:length(nom);
    fprintf(fid,'%s=%s\n',nom{i},getfield(METEOLAB,nom{i}));
end
fclose(fid);
