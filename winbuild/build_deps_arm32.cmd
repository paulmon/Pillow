setlocal
set MSBUILD="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
set CMAKE="cmake.exe"
set INCLIB=%~dp0\depends
set BUILD=%~dp0\build
set ZLIB=%BUILD%\zlib-1.2.11
set JPEG=%BUILD%\jpeg-9c
set TIFF=%BUILD%\tiff-4.0.9
set FREETYPE=%BUILD%\freetype-2.9.1
set LCMS=%BUILD%\lcms2-2.7
set TCL-8.5=%BUILD%\tcl8.5.19
set TK-8.5=%BUILD%\tk8.5.19
set TCL-8.6=%BUILD%\tcl8.6.8
set TK-8.6=%BUILD%\tk8.6.8
set WEBP=%BUILD%\libwebp-1.0.0
set OPENJPEG=%BUILD%\openjpeg-2.3.0

mkdir %INCLIB%\tcl85\include\X11
copy /Y /B %BUILD%\tcl8.5.19\generic\*.h %INCLIB%\tcl85\include\
copy /Y /B %BUILD%\tk8.5.19\generic\*.h %INCLIB%\tcl85\include\
copy /Y /B %BUILD%\tk8.5.19\xlib\X11\* %INCLIB%\tcl85\include\X11\

mkdir %INCLIB%\tcl86\include\X11
copy /Y /B %BUILD%\tcl8.6.8\generic\*.h %INCLIB%\tcl86\include\
copy /Y /B %BUILD%\tk8.6.8\generic\*.h %INCLIB%\tcl86\include\
copy /Y /B %BUILD%\tk8.6.8\xlib\X11\* %INCLIB%\tcl86\include\X11\

setlocal EnableDelayedExpansion
call "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsamd64_arm.bat"
set INCLUDE=%INCLUDE%;C:\Program Files\Microsoft SDKs\Windows\v7.1\Include
set INCLIB=%INCLIB%\msvcr90-arm
set CVARS=-D_MD -MD
set CPU=ARM

rem Build libjpeg
setlocal
cd /D %JPEG%
nmake -f makefile.vc setup-v15
nmake -f makefile.vc clean
nmake -f makefile.vc libjpeg.lib
copy /Y /B *.dll %INCLIB%
copy /Y /B *.lib %INCLIB%
copy /Y /B j*.h %INCLIB%
endlocal

rem Build zlib
setlocal
cd /D %ZLIB%
nmake -f win32\Makefile.msc clean
nmake -f win32\Makefile.msc zlib.lib
copy /Y /B *.dll %INCLIB%
copy /Y /B *.lib %INCLIB%
copy /Y /B zlib.lib %INCLIB%\z.lib
copy /Y /B zlib.h %INCLIB%
copy /Y /B zconf.h %INCLIB%
endlocal

rem Build webp
setlocal
cd /D %WEBP%
rd /S /Q %WEBP%\output\release-static
nmake -f Makefile.vc CFG=release-static RTLIBCFG=static OBJDIR=output all
copy /Y /B output\release-static\x86\lib\* %INCLIB%
mkdir %INCLIB%\webp
copy /Y /B src\webp\*.h %INCLIB%\\webp
endlocal

rem Build libtiff
setlocal
rem do after building jpeg and zlib
copy %~dp0\nmake.opt %TIFF%

cd /D %TIFF%
nmake -f makefile.vc clean
nmake -f makefile.vc lib
copy /Y /B libtiff\*.dll %INCLIB%
copy /Y /B libtiff\*.lib %INCLIB%
copy /Y /B libtiff\tiff*.h %INCLIB%
endlocal




rem Build freetype
setlocal
rd /S /Q %FREETYPE%\objs
%MSBUILD% %FREETYPE%\builds\windows\vc2010\freetype.sln /t:Clean;Build /p:Configuration="Release" /p:Platform=ARM /m
xcopy /Y /E /Q %FREETYPE%\include %INCLIB%
copy /Y /B %FREETYPE%\objs\vc2010\arm\*.lib %INCLIB%\freetype.lib
endlocal


rem Build lcms2
setlocal
rd /S /Q %LCMS%\Lib
rd /S /Q %LCMS%\Projects\VS2013\Release
%MSBUILD% %LCMS%\Projects\VS2013\lcms2.sln  /t:Clean /p:Configuration="Release" /p:Platform=Win32 /m
%MSBUILD% %LCMS%\Projects\VS2013\lcms2.sln  /t:lcms2_static /p:Configuration="Release" /p:Platform=Win32 /m
xcopy /Y /E /Q %LCMS%\include %INCLIB%
copy /Y /B %LCMS%\Lib\MS\*.lib %INCLIB%
endlocal


endlocal
