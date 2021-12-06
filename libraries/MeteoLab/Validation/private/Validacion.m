disp('Validacion...');
%Prediccion Climatologica
ParamClmt.NumA=inf;
ParamClmt.NEx=10;
ParamClmt.N=45;
ParamClmt.Ind=indObj';

ParamClmt.Umb=ptndLims{1};
Clmt{1,1}=prediccionClmtProb(Ptnd{1}(:,lista),ParamClmt);

%Observacion
dta=Ptnd{1}(indObj',lista);
%dta=Ptnd{1}(indObj(find(indObj<=size(Ptnd{1}(:,lista),2)))',lista);
Obsr{1,1}=rellenaProb(ptndLims{1},dta,~isnan(dta));

%[BSS{1},HIR{1},FAR{1}]=validaCuant(Obsr{1,1},Prdc{1,1},Clmt{1,1}); %
%BSSP{1}=validaProb(Obsr{1,1},Prdc{1,1},Clmt{1,1});
%BSSD{1}=validaCuantDaily(Obsr{1,1},Prdc{1,1},Clmt{1,1});
if LEARN_WITH_ATM
   DiscardNodes=[]; %17 41
   O=Obsr{1,1};Pin=Prdc{1,1};Pbn=Prdc{1,2};C=Clmt{1,1};
   if ~isempty(DiscardNodes)
      Pin(:,DiscardNodes,:)=NaN;
      Pbn(:,DiscardNodes,:)=NaN;
   end
   %[BSS{1},HIR{1},FAR{1}]=validaCuant(O,Pbn,C);
	%BSSP{1}=validaProb(O,P,C);
   %BSSD{1}=validaCuantDaily(O,Pbn,C);
   
   [BSS{1},HIR{1},FAR{1}]=validaCuant(O,Pbn,C);
   BSSD{1}=validaCuantDaily(O,Pbn,C);
else
   O=Obsr{1,1};P=Prdc{1,2};C=Clmt{1,1};
   DiscardNodes=NodEv;
   if ~isempty(DiscardNodes)
      P(:,DiscardNodes,:)=NaN;
   end
   [BSS{1},HIR{1},FAR{1}]=validaCuant(O,P,C); %
	BSSP{1}=validaProb(O,P,C);
  
	BSSD{1}=validaCuantDaily(O,P,C);
end

   

VP.BSSD=BSSD{1};
VP.BSS=BSS{1};
VP.HIR=HIR{1};
VP.FAR=FAR{1};
Loc.loc=loc{1};
%Loc.NodEv=NodEv;
Loc.colorMap=gray(20);  
  

drawValProb(VP,Loc,ptndLims{1},Labels{1});       

Data.Obsr=Obsr{1,1};Data.Prdc=Prdc{1,1};
drawPrdcObsr(Data,Loc,ptndLims{1},Labels{1});       


