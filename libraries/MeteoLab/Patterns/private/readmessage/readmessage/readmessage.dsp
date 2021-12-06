# Microsoft Developer Studio Project File - Name="readmessage" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=readmessage - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "readmessage.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "readmessage.mak" CFG="readmessage - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "readmessage - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "readmessage - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=xicl6.exe
F90=df.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "readmessage - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\Release"
# PROP BASE Intermediate_Dir ".\Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Release"
# PROP Intermediate_Dir ".\Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD F90 /browser
# SUBTRACT F90 /fast
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "c:\matlabr11\extern\include" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "MATLAB_MEX_FILE" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc0a /d "NDEBUG"
# ADD RSC /l 0xc0a /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo /o".\Release/buildIndex.bsc"
LINK32=xilink6.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mymeximports.lib /nologo /subsystem:windows /dll /debug /machine:I386 /out:".\..\..\readmessage2.dll"
# SUBTRACT LINK32 /profile /incremental:yes /map

!ELSEIF  "$(CFG)" == "readmessage - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\readmess"
# PROP BASE Intermediate_Dir ".\readmess"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\readmess"
# PROP Intermediate_Dir ".\readmess"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "c:\matlabr11\extern\include" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "MATLAB_MEX_FILE" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc0a /d "_DEBUG"
# ADD RSC /l 0xc0a /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=xilink6.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mymeximports.lib /nologo /subsystem:windows /dll /debug /machine:I386 /out:".\debug\readmessage.dll"
# SUBTRACT LINK32 /profile

!ENDIF 

# Begin Target

# Name "readmessage - Win32 Release"
# Name "readmessage - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat;for;f90"
# Begin Source File

SOURCE=..\gribsimp\apply_bitmap.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\apply_bitmap_DOUBLE.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gbyte.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\grib_seek_b.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gribdec.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gribdec_DOUBLE.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gribgetbds.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gribgetbds_DOUBLE.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gribgetbms.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gribgetgds.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\gribgetpds.c
# End Source File
# Begin Source File

SOURCE=..\gribtomatlab.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\hdr_print.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\init_struct.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\printer.c
# End Source File
# Begin Source File

SOURCE=..\gribsimp\prt_err.c
# End Source File
# Begin Source File

SOURCE=..\readgrib_b.c
# End Source File
# Begin Source File

SOURCE=.\readmessage.def
# End Source File
# Begin Source File

SOURCE=..\readmessage_mex.c
# End Source File
# End Group
# End Target
# End Project
