function [C,EOFs]=ACPeig(donnees,nb_comp)

t=cputime;

% centrage du tableau X de donnees
%[n,p]=size(Y);
%X=Y-ones(n,1)*mean(Y,1);  

% centrage reduction
donneescr = pstd(donnees);

% matrice de variance
S=cov(donneescr);

% valeurs propres et vecteurs propres
[VECTp,VALp]=eig(S);

% on reordonne par ordre de decroissance
[VALp,permut]=sort(-diag(VALp));
VALp=-diag(VALp);
VECTpOrd=VECTp(:,permut);
EOFs=VECTpOrd(:,1:nb_comp);
% composantes principales des individus
C=donneescr*VECTpOrd(:,1:nb_comp);

% affichage des resultats
%'matrice des EOF'
%VECTpOrd

%'CPs (composantes des individus sur les EOF)'
%C

'pourcentage d inertie expliquee'
vectVALp=diag(VALp);
somme = 0;
for i=1,nb_comp;
somme = somme + vectVALp(i);
end
sommeTOT=somme;
for i=nb_comp,size(vectVALp);
    sommeTOT=sommeTOT+vectVALp(i);
end
somme*100/sommeTOT

'temps de calcul'
cputime-t