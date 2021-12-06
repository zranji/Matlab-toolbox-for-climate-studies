function [CPs,EOFs]=ACPsvd(donnees,nb_comp)

t=cputime;

% centrage reduction
donneescr = pstd(donnees);

% matrice de variance
S=cov(donneescr);

% decomposition en valeurs singulieres
[EOFs,D]=svds(S,nb_comp);

% composantes principales des individus
CPs=donneescr*EOFs

'temps de calcul'
cputime-t