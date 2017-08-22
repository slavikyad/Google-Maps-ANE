@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"
SET AIR_PATH="D:\dev\sdks\AIR\AIRSDK_26\bin\"

SET projectName=GoogleMapsANE

copy %pathtome%..\bin\%projectName%.swc %pathtome%

REM contents of SWC.
copy /Y %pathtome%%projectName%.swc %pathtome%%projectName%Extract.swc
ren %pathtome%%projectName%Extract.swc %projectName%Extract.zip
call %SZIP% e %pathtome%%projectName%Extract.zip -o%pathtome%
del %pathtome%%projectName%Extract.zip

REM Copy library.swf to folders.
echo Copying library.swf into place.
copy %pathtome%library.swf %pathtome%platforms\android

echo copy the aar into place
copy /Y %pathtome%..\..\native_library\android\%projectName%\app\build\outputs\aar\app-release.aar %pathtome%platforms\android\app-release.aar


echo "GETTING ANDROID JAR"
call %SZIP% x %pathtome%platforms\android\app-release.aar -o%pathtome%platforms\android\ classes.jar


echo "GENERATING ANE"
call %AIR_PATH%adt.bat -package -target ane %pathtome%%projectName%.ane extension_mobile.xml ^
-swc %projectName%.swc ^
-platform Android-ARM ^
-C platforms/android library.swf classes.jar ^
com.tuarua.%projectName%-res/. ^
-platformoptions platforms/android/platform.xml


REM res/.


del %pathtome%platforms\\android\\classes.jar
del %pathtome%platforms\\android\\app-release.aar
del %pathtome%platforms\\android\\library.swf

call DEL /F /Q /A %pathtome%library.swf
call DEL /F /Q /A %pathtome%catalog.xml
call DEL /F /Q /A %pathtome%%projectName%.swc

echo "DONE!"

REM res/values/styles.xml ^
REM res/layout/activity_maps.xml ^
REM play-services-maps.jar ^
REM play-services-base.jar ^
REM play-services-basement.jar