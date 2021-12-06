# Microsoft Developer Studio Generated NMAKE File, Format Version 4.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

!IF "$(CFG)" == ""
CFG=readmessage - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to readmessage - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "readmessage - Win32 Release" && "$(CFG)" !=\
 "readmessage - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "readmessage.mak" CFG="readmessage - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "readmessage - Win32 Release" (based on\
 "Win32 (x86) Dynamic-Link Library")
!MESSAGE "readmessage - Win32 Debug" (based on\
 "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "readmessage - Win32 Debug"
RSC=rc.exe
MTL=mktyplib.exe
CPP=cl.exe

!IF  "$(CFG)" == "readmessage - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\readmessage.dll"

CLEAN : 
	-@erase ".\Release\readmessage.dll"
	-@erase ".\Release\gribtomatlab.obj"
	-@erase ".\Release\gribgetpds.obj"
	-@erase ".\Release\grib_seek.obj"
	-@erase ".\Release\gribgetbms.obj"
	-@erase ".\Release\apply_bitmap.obj"
	-@erase ".\Release\gbyte.obj"
	-@erase ".\Release\gribgetgds.obj"
	-@erase ".\Release\gribdec.obj"
	-@erase ".\Release\readmessage.obj"
	-@erase ".\Release\hdr_print.obj"
	-@erase ".\Release\init_struct.obj"
	-@erase ".\Release\gribgetbds.obj"
	-@erase ".\Release\prt_err.obj"
	-@erase ".\Release\printer.obj"
	-@erase ".\Release\readmessage.lib"
	-@erase ".\Release\readmessage.exp"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "c:\matlabr11\extern\include" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "MATLAB_MEX_FILE" /YX /c
CPP_PROJ=/nologo /MT /W3 /GX /O2 /I "c:\matlabr11\extern\include" /D "NDEBUG"\
 /D "WIN32" /D "_WINDOWS" /D "MATLAB_MEX_FILE" /Fp"$(INTDIR)/readmessage.pch"\
 /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0xc0a /d "NDEBUG"
# ADD RSC /l 0xc0a /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/readmessage.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mymeximports.lib /nologo /subsystem:windows /dll /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib mymeximports.lib /nologo /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/readmessage.pdb" /machine:I386 /def:".\readmessage.def"\
 /out:"$(OUTDIR)/readmessage.dll" /implib:"$(OUTDIR)/readmessage.lib" 
DEF_FILE= \
	".\readmessage.def"
LINK32_OBJS= \
	"$(INTDIR)/gribtomatlab.obj" \
	"$(INTDIR)/gribgetpds.obj" \
	"$(INTDIR)/grib_seek.obj" \
	"$(INTDIR)/gribgetbms.obj" \
	"$(INTDIR)/apply_bitmap.obj" \
	"$(INTDIR)/gbyte.obj" \
	"$(INTDIR)/gribgetgds.obj" \
	"$(INTDIR)/gribdec.obj" \
	"$(INTDIR)/readmessage.obj" \
	"$(INTDIR)/hdr_print.obj" \
	"$(INTDIR)/init_struct.obj" \
	"$(INTDIR)/gribgetbds.obj" \
	"$(INTDIR)/prt_err.obj" \
	"$(INTDIR)/printer.obj"

"$(OUTDIR)\readmessage.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "readmessage - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "readmess"
# PROP BASE Intermediate_Dir "readmess"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "readmess"
# PROP Intermediate_Dir "readmess"
# PROP Target_Dir ""
OUTDIR=.\readmess
INTDIR=.\readmess

ALL : "$(OUTDIR)\readmessage.dll"

CLEAN : 
	-@erase ".\readmess\vc40.pdb"
	-@erase ".\readmess\vc40.idb"
	-@erase ".\debug\readmessage.dll"
	-@erase ".\readmess\apply_bitmap.obj"
	-@erase ".\readmess\gribgetbms.obj"
	-@erase ".\readmess\hdr_print.obj"
	-@erase ".\readmess\grib_seek.obj"
	-@erase ".\readmess\printer.obj"
	-@erase ".\readmess\gbyte.obj"
	-@erase ".\readmess\gribgetgds.obj"
	-@erase ".\readmess\gribtomatlab.obj"
	-@erase ".\readmess\gribgetpds.obj"
	-@erase ".\readmess\gribgetbds.obj"
	-@erase ".\readmess\prt_err.obj"
	-@erase ".\readmess\readmessage.obj"
	-@erase ".\readmess\init_struct.obj"
	-@erase ".\readmess\gribdec.obj"
	-@erase ".\debug\readmessage.ilk"
	-@erase ".\readmess\readmessage.lib"
	-@erase ".\readmess\readmessage.exp"
	-@erase ".\readmess\readmessage.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /I "c:\matlabr11\extern\include" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "MATLAB_MEX_FILE" /YX /c
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /Zi /Od /I "c:\matlabr11\extern\include" /D\
 "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "MATLAB_MEX_FILE"\
 /Fp"$(INTDIR)/readmessage.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\readmess/
CPP_SBRS=
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0xc0a /d "_DEBUG"
# ADD RSC /l 0xc0a /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/readmessage.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mymeximports.lib /nologo /subsystem:windows /dll /debug /machine:I386 /out:"debug/readmessage.dll"
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib mymeximports.lib /nologo /subsystem:windows /dll /incremental:yes\
 /pdb:"$(OUTDIR)/readmessage.pdb" /debug /machine:I386 /def:".\readmessage.def"\
 /out:"debug/readmessage.dll" /implib:"$(OUTDIR)/readmessage.lib" 
DEF_FILE= \
	".\readmessage.def"
LINK32_OBJS= \
	"$(INTDIR)/apply_bitmap.obj" \
	"$(INTDIR)/gribgetbms.obj" \
	"$(INTDIR)/hdr_print.obj" \
	"$(INTDIR)/grib_seek.obj" \
	"$(INTDIR)/printer.obj" \
	"$(INTDIR)/gbyte.obj" \
	"$(INTDIR)/gribgetgds.obj" \
	"$(INTDIR)/gribtomatlab.obj" \
	"$(INTDIR)/gribgetpds.obj" \
	"$(INTDIR)/gribgetbds.obj" \
	"$(INTDIR)/prt_err.obj" \
	"$(INTDIR)/readmessage.obj" \
	"$(INTDIR)/init_struct.obj" \
	"$(INTDIR)/gribdec.obj"

"$(OUTDIR)\readmessage.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "readmessage - Win32 Release"
# Name "readmessage - Win32 Debug"

!IF  "$(CFG)" == "readmessage - Win32 Release"

!ELSEIF  "$(CFG)" == "readmessage - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\readmessage.c
DEP_CPP_READM=\
	".\readmessage.h"\
	"c:\matlabr11\extern\include\mex.h"\
	".\gribsimp\grib.h"\
	".\gribsimp\tables.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_READM=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

!IF  "$(CFG)" == "readmessage - Win32 Release"


"$(INTDIR)\readmessage.obj" : $(SOURCE) $(DEP_CPP_READM) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "readmessage - Win32 Debug"


"$(INTDIR)\readmessage.obj" : $(SOURCE) $(DEP_CPP_READM) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\readmessage.def

!IF  "$(CFG)" == "readmessage - Win32 Release"

!ELSEIF  "$(CFG)" == "readmessage - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\prt_err.c
DEP_CPP_PRT_E=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_PRT_E=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\prt_err.obj" : $(SOURCE) $(DEP_CPP_PRT_E) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\gbyte.c
DEP_CPP_GBYTE=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GBYTE=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\gbyte.obj" : $(SOURCE) $(DEP_CPP_GBYTE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\grib_seek.c
DEP_CPP_GRIB_=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GRIB_=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\grib_seek.obj" : $(SOURCE) $(DEP_CPP_GRIB_) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\gribdec.c
DEP_CPP_GRIBD=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GRIBD=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\gribdec.obj" : $(SOURCE) $(DEP_CPP_GRIBD) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\gribgetbds.c
DEP_CPP_GRIBG=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GRIBG=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\gribgetbds.obj" : $(SOURCE) $(DEP_CPP_GRIBG) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\gribgetbms.c
DEP_CPP_GRIBGE=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GRIBGE=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\gribgetbms.obj" : $(SOURCE) $(DEP_CPP_GRIBGE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\gribgetgds.c
DEP_CPP_GRIBGET=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GRIBGET=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\gribgetgds.obj" : $(SOURCE) $(DEP_CPP_GRIBGET) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\gribgetpds.c
DEP_CPP_GRIBGETP=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GRIBGETP=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\gribgetpds.obj" : $(SOURCE) $(DEP_CPP_GRIBGETP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\hdr_print.c
DEP_CPP_HDR_P=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_HDR_P=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\hdr_print.obj" : $(SOURCE) $(DEP_CPP_HDR_P) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\init_struct.c
DEP_CPP_INIT_=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_INIT_=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\init_struct.obj" : $(SOURCE) $(DEP_CPP_INIT_) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\printer.c
DEP_CPP_PRINT=\
	".\gribsimp\grib.h"\
	".\gribsimp\tables.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_PRINT=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\printer.obj" : $(SOURCE) $(DEP_CPP_PRINT) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribsimp\apply_bitmap.c
DEP_CPP_APPLY=\
	".\gribsimp\grib.h"\
	"c:\matlabr11\extern\include\mex.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_APPLY=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\apply_bitmap.obj" : $(SOURCE) $(DEP_CPP_APPLY) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gribtomatlab.c
DEP_CPP_GRIBT=\
	".\readmessage.h"\
	"c:\matlabr11\extern\include\mex.h"\
	".\gribsimp\grib.h"\
	".\gribsimp\tables.h"\
	"c:\matlabr11\extern\include\matrix.h"\
	"c:\matlabr11\extern\include\mwdebug.h"\
	"c:\matlabr11\extern\include\tmwtypes.h"\
	"c:\matlabr11\extern\include\mat.h"\
	
NODEP_CPP_GRIBT=\
	"c:\matlabr11\extern\include\mexsun4.h"\
	

"$(INTDIR)\gribtomatlab.obj" : $(SOURCE) $(DEP_CPP_GRIBT) "$(INTDIR)"


# End Source File
# End Target
# End Project
################################################################################
