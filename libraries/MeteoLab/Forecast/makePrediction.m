function P=makePrediction(indAng,distAng,Ptnd,Prdc)
if(strcmpi(Prdc.Type,'Prb'))
   Umb=Prdc.Umb;
   Prdc.Umb=[];
   Prdc.Umb(1,:)=Umb(1:end-1);
	Prdc.Umb(2,:)=Umb(2:end);
   if(strcmpi(Prdc.Method,'Fq')) 
      P=prediccionProb(indAng,ones(size(indAng)),Ptnd,Prdc);
      P=1-cumsum(P(:,:,1:end-1),3);
   elseif(strcmpi(Prdc.Method,'Wg')) 
      P=prediccionProb(indAng,1./distAng,Ptnd,Prdc);
      P=1-cumsum(P(:,:,1:end-1),3);
   elseif(strcmpi(Prdc.Method,'Lg')) 
      P=prediccionLogistica(indAng,distAng,Ptnd,Prdc.RE,Prdc.REp,Prdc);
      %P=1-cumsum(P(:,:,1:end-1),3);
   elseif(strcmpi(Prdc.Method,'Lin')) 
      P=prediccionLin(indAng,distAng,Ptnd,Prdc.RE,Prdc.REp,Prdc);
      %P=1-cumsum(P(:,:,1:end-1),3);
   elseif(strcmpi(Prdc.Method,'NNLg')) 
      P=prediccionNNLog(indAng,distAng,Ptnd,Prdc.RE,Prdc.REp,Prdc);
      %P=1-cumsum(P(:,:,1:end-1),3);
   else
	   error(['Unknown Method of Prediction for ' Prdc.Type ' :' Prdc.Method]);   
   end
elseif(strcmpi(Prdc.Type,'Det'))
   if(strcmpi(Prdc.Method,'Rg'))
      P=prediccionDetRg(indAng,distAng,Ptnd,Prdc.RE,Prdc.REp,Prdc);
   elseif(strcmpi(Prdc.Method,'Lin'))
      P=prediccionDetLin(indAng,distAng,Ptnd,Prdc.RE,Prdc.REp,Prdc);
   elseif(strcmpi(Prdc.Method,'NN'))
      P=prediccionDetNN(indAng,distAng,Ptnd,Prdc.RE,Prdc.REp,Prdc);
   elseif(strcmpi(Prdc.Method,'Wm'))
      P=prediccionDetWm(indAng,1./distAng,Ptnd,Prdc);
   elseif(strcmpi(Prdc.Method,'Wm2'))
      P=prediccionDetWm2(indAng,1./distAng,Ptnd,Prdc);
   elseif (strcmpi(Prdc.Method,'Pr'))
      Prdc.Umb=Prdc.Prc;
      P=prediccionDetPercentile(indAng,distAng,Ptnd,Prdc);
   else
	   error(['Unknown Method of Prediction for ' Prdc.Type ' :' Prdc.Method]);   
   end
else
	   error(['Unknown Type of Prediction for ' Prdc.Type]);   
end


