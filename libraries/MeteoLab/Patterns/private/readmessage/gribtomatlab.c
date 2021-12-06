#include "./readmessage.h"
mxArray *AssignMessToMatlab(MessageStruct Mess){
	mxArray *MessMatlab;
	int nDimsMess,nFieldsMess;
	int dimsMess[2];
	const char *FieldNamesMess[]={
		"PDS","GDS","BMS","BDS"
	};
	nFieldsMess=4;
	nDimsMess=2;
	dimsMess[0]=1;
	dimsMess[1]=1;
	MessMatlab=mxCreateStructArray(nDimsMess,dimsMess,nFieldsMess,FieldNamesMess);
	mxSetFieldByNumber(MessMatlab,0,0,AssignPDSToMatlab(Mess.pds));
	mxSetFieldByNumber(MessMatlab,0,1,AssignGDSToMatlab(Mess.gds));
	mxSetFieldByNumber(MessMatlab,0,2,AssignBMSToMatlab(Mess.bms));
	mxSetFieldByNumber(MessMatlab,0,3,AssignBDSToMatlab(Mess.bdsHead));
	
	return MessMatlab;
}
mxArray *AssignPDSToMatlab(PDS_INPUT PDS){
	mxArray *PDSMatlab;
	int nDimsPDS,nFieldsPDS;
	int dimsPDS[2];
	const char *FieldNamesPDS[]={
		"GRIBEdition","Length","ParameterTable","Center","Process",
		"GridId","GDSBMSFlag","Parameter","TypeLevel","Height1","Height2",
		"Year","Month","Day","Hour","Minute","ForecastUnit","PeriodTime","TimeInterval",
		"TimeRange","TimeRangeMiss","TimeRangeIncl","Century","ScaleFactor",
		"SubTableCenter","Seconds","TrackId","SubTableParemeter","SubTableVersion",
		"Class","Type","Stream","Version","Number","EnsembleSize","SystemNumber","MethodNumber","TotalSize"
	};
	nFieldsPDS=38;
	nDimsPDS=2;
	dimsPDS[0]=1;
	dimsPDS[1]=1;
	PDSMatlab=mxCreateStructArray(nDimsPDS,dimsPDS,nFieldsPDS,FieldNamesPDS);
	mxSetFieldByNumber(PDSMatlab,0,0,ushortTomxArray(PDS.usEd_num));
	mxSetFieldByNumber(PDSMatlab,0,1,ushortTomxArray(PDS.uslength));
	mxSetFieldByNumber(PDSMatlab,0,2,ushortTomxArray(PDS.usParm_tbl));
	mxSetFieldByNumber(PDSMatlab,0,3,ushortTomxArray(PDS.usCenter_id));
	mxSetFieldByNumber(PDSMatlab,0,4,ushortTomxArray(PDS.usProc_id));
	mxSetFieldByNumber(PDSMatlab,0,5,ushortTomxArray(PDS.usGrid_id));
	mxSetFieldByNumber(PDSMatlab,0,6,ushortTomxArray(PDS.usGds_bms_id));
	mxSetFieldByNumber(PDSMatlab,0,7,ushortTomxArray(PDS.usParm_id));
	mxSetFieldByNumber(PDSMatlab,0,8,ushortTomxArray(PDS.usLevel_id));
	mxSetFieldByNumber(PDSMatlab,0,9,ushortTomxArray(PDS.usHeight1));
	mxSetFieldByNumber(PDSMatlab,0,10,ushortTomxArray(PDS.usHeight2));
	mxSetFieldByNumber(PDSMatlab,0,11,ushortTomxArray(PDS.usYear));
	mxSetFieldByNumber(PDSMatlab,0,12,ushortTomxArray(PDS.usMonth));
	mxSetFieldByNumber(PDSMatlab,0,13,ushortTomxArray(PDS.usDay));
	mxSetFieldByNumber(PDSMatlab,0,14,ushortTomxArray(PDS.usHour));
	mxSetFieldByNumber(PDSMatlab,0,15,ushortTomxArray(PDS.usMinute));
	mxSetFieldByNumber(PDSMatlab,0,16,ushortTomxArray(PDS.usFcst_unit_id));
	mxSetFieldByNumber(PDSMatlab,0,17,ushortTomxArray(PDS.usP1));
	mxSetFieldByNumber(PDSMatlab,0,18,ushortTomxArray(PDS.usP2));
	mxSetFieldByNumber(PDSMatlab,0,19,ushortTomxArray(PDS.usTime_range));
	mxSetFieldByNumber(PDSMatlab,0,20,ushortTomxArray(PDS.usTime_range_avg));
	mxSetFieldByNumber(PDSMatlab,0,21,ushortTomxArray(PDS.usTime_range_mis));
	mxSetFieldByNumber(PDSMatlab,0,22,ushortTomxArray(PDS.usCentury));
	mxSetFieldByNumber(PDSMatlab,0,23,shortTomxArray(PDS.sDec_sc_fctr));
	mxSetFieldByNumber(PDSMatlab,0,24,ushortTomxArray(PDS.usCenter_sub));
	mxSetFieldByNumber(PDSMatlab,0,25,ushortTomxArray(PDS.usSecond));
	mxSetFieldByNumber(PDSMatlab,0,26,ushortTomxArray(PDS.usTrack_num));
	mxSetFieldByNumber(PDSMatlab,0,27,ushortTomxArray(PDS.usParm_sub));
	mxSetFieldByNumber(PDSMatlab,0,28,ushortTomxArray(PDS.usSub_tbl));
	mxSetFieldByNumber(PDSMatlab,0,29,ushortTomxArray(PDS.ecClass));
	mxSetFieldByNumber(PDSMatlab,0,30,ushortTomxArray(PDS.ecType));
	mxSetFieldByNumber(PDSMatlab,0,31,ushortTomxArray(PDS.ecStream));
	mxSetFieldByNumber(PDSMatlab,0,32,mxCreateString(PDS.ecVersion));
	mxSetFieldByNumber(PDSMatlab,0,33,ushortTomxArray(PDS.ecNumber));
	mxSetFieldByNumber(PDSMatlab,0,34,ushortTomxArray(PDS.ecEnsembleSize));
	mxSetFieldByNumber(PDSMatlab,0,35,ushortTomxArray(PDS.ecSystemNumber));
	mxSetFieldByNumber(PDSMatlab,0,36,ushortTomxArray(PDS.ecMethodNumber));
	mxSetFieldByNumber(PDSMatlab,0,37,ulongTomxArray(PDS.ulMess_Size));
	
	return PDSMatlab; 
}
mxArray *AssignBMSToMatlab(BMS_INPUT BMS){
	mxArray *BMSMatlab;
	int nDimsBMS,nFieldsBMS;
	int dimsBMS[2];
	const char *FieldNamesBMS[]={
		"Length","UnusedBits","BMSId","BitsPresent","Bitmap"
	};
	nFieldsBMS=5;
	nDimsBMS=2;
	dimsBMS[0]=1;
	dimsBMS[1]=1;
	BMSMatlab=mxCreateStructArray(nDimsBMS,dimsBMS,nFieldsBMS,FieldNamesBMS);
	mxSetFieldByNumber(BMSMatlab,0,0,ushortTomxArray(BMS.uslength));
	mxSetFieldByNumber(BMSMatlab,0,1,ushortTomxArray(BMS.usUnused_bits));
	mxSetFieldByNumber(BMSMatlab,0,2,ushortTomxArray(BMS.usBMS_id));
	mxSetFieldByNumber(BMSMatlab,0,3,ulongTomxArray(BMS.ulbits_set));
	return BMSMatlab; 
}
mxArray *AssignBDSToMatlab(BDS_HEAD_INPUT BDS){
	mxArray *BDSMatlab;
	int nDimsBDS,nFieldsBDS;
	int dimsBDS[2];
	const char *FieldNamesBDS[]={
		"Length","BDSFlag","BinaryScaleFactor","MinimunValue","BitPackNum",
		"GridSize","PackNull"
	};
	nFieldsBDS=7;
	nDimsBDS=2;
	dimsBDS[0]=1;
	dimsBDS[1]=1;
	BDSMatlab=mxCreateStructArray(nDimsBDS,dimsBDS,nFieldsBDS,FieldNamesBDS);
	mxSetFieldByNumber(BDSMatlab,0,0,ulongTomxArray(BDS.length));
	mxSetFieldByNumber(BDSMatlab,0,1,ushortTomxArray(BDS.usBDS_flag));
	mxSetFieldByNumber(BDSMatlab,0,2,intTomxArray(BDS.Bin_sc_fctr));
	mxSetFieldByNumber(BDSMatlab,0,3,floatTomxArray(BDS.fReference));
	mxSetFieldByNumber(BDSMatlab,0,4,ushortTomxArray(BDS.usBit_pack_num));
	mxSetFieldByNumber(BDSMatlab,0,5,ulongTomxArray(BDS.ulGrid_size));
	mxSetFieldByNumber(BDSMatlab,0,6,floatTomxArray(BDS.fPack_null));
	
	return BDSMatlab; 
}

mxArray *AssignGDSToMatlab(grid_desc_sec GDS){
	mxArray *GDSMatlab;
	int nDimsGDS,nFieldsGDS;
	int dimsGDS[2];
	const char *FieldNamesGDS[]={
		"Head","LatLon","Lambert","Polar","Mercator","SpaceView"	
	};
	nFieldsGDS=6;
	nDimsGDS=2;
	dimsGDS[0]=1;
	dimsGDS[1]=1;
	GDSMatlab=mxCreateStructArray(nDimsGDS,dimsGDS,nFieldsGDS,FieldNamesGDS);
	mxSetFieldByNumber(GDSMatlab,0,0,AssignGDSHeadToMatlab(GDS.head));
	mxSetFieldByNumber(GDSMatlab,0,1,AssignGDSLatLonToMatlab(GDS.llg));
	mxSetFieldByNumber(GDSMatlab,0,2,AssignGDSLambertToMatlab(GDS.lam));
	mxSetFieldByNumber(GDSMatlab,0,3,AssignGDSPolarToMatlab(GDS.pol));
	mxSetFieldByNumber(GDSMatlab,0,4,AssignGDSMercatorToMatlab(GDS.merc));
	mxSetFieldByNumber(GDSMatlab,0,5,AssignGDSSpaceViewToMatlab(GDS.svw));
	return GDSMatlab;
}
mxArray *AssignGDSHeadToMatlab(GDS_HEAD_INPUT GDSHead){
	mxArray *GDSHeadMatlab;
	int nDimsGDSHead,nFieldsGDSHead;
	int dimsGDSHead[2];
	const char *FieldNamesGDSHead[]={
		"NumberVertical","PVPLLocation","DataType","Length"
	};
	nFieldsGDSHead=4;
	nDimsGDSHead=2;
	dimsGDSHead[0]=1;
	dimsGDSHead[1]=1;
	GDSHeadMatlab=mxCreateStructArray(nDimsGDSHead,dimsGDSHead,nFieldsGDSHead,FieldNamesGDSHead);
	mxSetFieldByNumber(GDSHeadMatlab,0,0,ushortTomxArray(GDSHead.usNum_v));
	mxSetFieldByNumber(GDSHeadMatlab,0,1,ushortTomxArray(GDSHead.usPl_Pv));
	mxSetFieldByNumber(GDSHeadMatlab,0,2,ushortTomxArray(GDSHead.usData_type));
	mxSetFieldByNumber(GDSHeadMatlab,0,3,ushortTomxArray(GDSHead.uslength));
	return GDSHeadMatlab;
}
mxArray *AssignGDSLatLonToMatlab(GDS_LATLON_INPUT GDSLatLon){
	mxArray *GDSLatLonMatlab;
	int nDimsGDSLatLon,nFieldsGDSLatLon;
	int dimsGDSLatLon[2];
	const char *FieldNamesGDSLatLon[]={
		"DataType","Ni","Nj","Lat1","Lon1","ResolutionFlag","Lat2","Lon2",
		"Di","Dj","ScanMode","LatSouthPole","LonSouthPole","Rotated",
		"LatPoleStretch","LonPoleStretch","StretchFactor",
	};
	nFieldsGDSLatLon=17;
	nDimsGDSLatLon=2;
	dimsGDSLatLon[0]=1;
	dimsGDSLatLon[1]=1;
	GDSLatLonMatlab=mxCreateStructArray(nDimsGDSLatLon,dimsGDSLatLon,nFieldsGDSLatLon,FieldNamesGDSLatLon);
	mxSetFieldByNumber(GDSLatLonMatlab,0,0,ushortTomxArray(GDSLatLon.usData_type));
	mxSetFieldByNumber(GDSLatLonMatlab,0,1,intTomxArray(GDSLatLon.usNi));
	mxSetFieldByNumber(GDSLatLonMatlab,0,2,intTomxArray(GDSLatLon.usNj));
	mxSetFieldByNumber(GDSLatLonMatlab,0,3,longTomxArray(GDSLatLon.lLat1));
	mxSetFieldByNumber(GDSLatLonMatlab,0,4,longTomxArray(GDSLatLon.lLon1));
	mxSetFieldByNumber(GDSLatLonMatlab,0,5,ushortTomxArray(GDSLatLon.usRes_flag));
	mxSetFieldByNumber(GDSLatLonMatlab,0,6,longTomxArray(GDSLatLon.lLat2));
	mxSetFieldByNumber(GDSLatLonMatlab,0,7,longTomxArray(GDSLatLon.lLon2));
	mxSetFieldByNumber(GDSLatLonMatlab,0,8,intTomxArray(GDSLatLon.iDi));
	mxSetFieldByNumber(GDSLatLonMatlab,0,9,intTomxArray(GDSLatLon.iDj));
	mxSetFieldByNumber(GDSLatLonMatlab,0,10,ushortTomxArray(GDSLatLon.usScan_mode));
	mxSetFieldByNumber(GDSLatLonMatlab,0,11,longTomxArray(GDSLatLon.lLat_southpole));
	mxSetFieldByNumber(GDSLatLonMatlab,0,12,longTomxArray(GDSLatLon.lLon_southpole));
	mxSetFieldByNumber(GDSLatLonMatlab,0,13,longTomxArray(GDSLatLon.lRotate));
	mxSetFieldByNumber(GDSLatLonMatlab,0,14,longTomxArray(GDSLatLon.lPole_lat));
	mxSetFieldByNumber(GDSLatLonMatlab,0,15,longTomxArray(GDSLatLon.lPole_lon));
	mxSetFieldByNumber(GDSLatLonMatlab,0,16,longTomxArray(GDSLatLon.lStretch));
	
	return GDSLatLonMatlab;
}
mxArray *AssignGDSLambertToMatlab(GDS_LAM_INPUT GDSLambert){
	mxArray *GDSLambertMatlab;
	int nDimsGDSLambert,nFieldsGDSLambert;
	int dimsGDSLambert[2];
	const char *FieldNamesGDSLambert[]={
		"DataType","Nx","Ny","Lat1","Lon1","ResolutionFlag","LongOriented",
		"Dx","Dy","ProjectionCenterFlag","ScanMode","LatCut1","LatCut2",
		"LatSouthPole","LonSouthPole"
	};
	nFieldsGDSLambert=15;
	nDimsGDSLambert=2;
	dimsGDSLambert[0]=1;
	dimsGDSLambert[1]=1;
	GDSLambertMatlab=mxCreateStructArray(nDimsGDSLambert,dimsGDSLambert,nFieldsGDSLambert,FieldNamesGDSLambert);
	return GDSLambertMatlab;
}
mxArray *AssignGDSPolarToMatlab(GDS_PS_INPUT GDSPolar){
	mxArray *GDSPolarMatlab;
	int nDimsGDSPolar,nFieldsGDSPolar;
	int dimsGDSPolar[2];
	const char *FieldNamesGDSPolar[]={
		"DataType","Nx","Ny","Lat1","Lon1","ResolutionFlag","LongOriented",
		"Dx","Dy","ProjectionCenterFlag","ScanMode"
		
	};
	nFieldsGDSPolar=11;
	nDimsGDSPolar=2;
	dimsGDSPolar[0]=1;
	dimsGDSPolar[1]=1;
	GDSPolarMatlab=mxCreateStructArray(nDimsGDSPolar,dimsGDSPolar,nFieldsGDSPolar,FieldNamesGDSPolar);
	return GDSPolarMatlab;
}
mxArray *AssignGDSMercatorToMatlab(mercator GDSMercator){
	mxArray *GDSMercatorMatlab;
	int nDimsGDSMercator,nFieldsGDSMercator;
	int dimsGDSMercator[2];
	const char *FieldNamesGDSMercator[]={
		"Ni","Nj","Lat1","Lon1","ResolutionFlag","Lat2","Lon2",
		"LatIntersection","Di","Dj","ScanMode"
	};
	nFieldsGDSMercator=11;
	nDimsGDSMercator=2;
	dimsGDSMercator[0]=1;
	dimsGDSMercator[1]=1;
	GDSMercatorMatlab=mxCreateStructArray(nDimsGDSMercator,dimsGDSMercator,nFieldsGDSMercator,FieldNamesGDSMercator);
	return GDSMercatorMatlab;

}
mxArray *AssignGDSSpaceViewToMatlab(space_view GDSSpaceView){
	mxArray *GDSSpaceViewMatlab;
	int nDimsGDSSpaceView,nFieldsGDSSpaceView;
	int dimsGDSSpaceView[2];
	const char *FieldNamesGDSSpaceView[]={
		"Ni","Nj","Lat1","Lon1","ResolutionFlag","DiameterX","DiameterY",
		"XSubSatP","YSubSatP","Orientation","Altitude","iXo","iYo"
	};
	nFieldsGDSSpaceView=13;
	nDimsGDSSpaceView=2;
	dimsGDSSpaceView[0]=1;
	dimsGDSSpaceView[1]=1;
	GDSSpaceViewMatlab=mxCreateStructArray(nDimsGDSSpaceView,dimsGDSSpaceView,nFieldsGDSSpaceView,FieldNamesGDSSpaceView);
	return GDSSpaceViewMatlab;
}
mxArray *ushortTomxArray(unsigned short in){
	mxArray *out;
	double *dum;
	int d=1;
	out=mxCreateNumericArray(1,&d,mxDOUBLE_CLASS,mxREAL);
	dum=mxGetPr(out);
	dum[0]=(double)in;
	return out;
}
mxArray *uintTomxArray(unsigned int in){
	mxArray *out;
	double *dum;
	int d=1;
	out=mxCreateNumericArray(1,&d,mxDOUBLE_CLASS,mxREAL);
	dum=mxGetPr(out);
	dum[0]=(double)in;
	return out;
}
mxArray *ulongTomxArray(unsigned long in){
	mxArray *out;
	double *dum;
	int d=1;
	out=mxCreateNumericArray(1,&d,mxDOUBLE_CLASS,mxREAL);
	dum=mxGetPr(out);
	dum[0]=(double)in;
	return out;
}
mxArray *shortTomxArray(short in){
	mxArray *out;
	double *dum;
	int d=1;
	out=mxCreateNumericArray(1,&d,mxDOUBLE_CLASS,mxREAL);
	dum=mxGetPr(out);
	dum[0]=(double)in;
	return out;
}
mxArray *intTomxArray(int in){
	mxArray *out;
	double *dum;
	int d=1;
	out=mxCreateNumericArray(1,&d,mxDOUBLE_CLASS,mxREAL);
	dum=mxGetPr(out);
	dum[0]=(double)in;
	return out;
}
mxArray *longTomxArray(long in){
	mxArray *out;
	double *dum;
	int d=1;
	out=mxCreateNumericArray(1,&d,mxDOUBLE_CLASS,mxREAL);
	dum=mxGetPr(out);
	dum[0]=(double)in;
	return out;
}
mxArray *floatTomxArray(float in){
	mxArray *out;
	double *dum;
	int d=1;
	out=mxCreateNumericArray(1,&d,mxDOUBLE_CLASS,mxREAL);
	dum=mxGetPr(out);
	dum[0]=(double)in;
	return out;
}
