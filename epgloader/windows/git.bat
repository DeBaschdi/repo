@echo off
@break off
@title EPGLoader Installer 
@color 0a
cls
echo ###########################################################################################
echo ###                          EPGchooser for Windows                                     ###
echo ###                    --Takealug.de feat. easyEPG Preject--                            ###
echo ###                                Revision 1                                           ###
echo ###########################################################################################

call "%cd%\config.cmd"
echo.
echo .
echo ===========
echo.
echo [1]Premium DE AT CH 12-14Day
echo [2]Premium easyEPG 12-14Day
echo [3]Premium Zattoo DE 12-14Day
echo [4]Premium Zattoo CH 12-14Day
echo [5]Free DE AT CH 3-5Day
echo [6]Free easyEPG 3-5Day
echo [7]Free Zattoo DE 3-5Day
echo [8]Free Zattoo CH 3-5Day
echo.

set asw=0
set /p asw="Choose your EPG Source: "

if %asw%==1 goto 1
if %asw%==2 goto 2
if %asw%==3 goto 3
if %asw%==4 goto 4
if %asw%==5 goto 5
if %asw%==6 goto 6
if %asw%==7 goto 7
if %asw%==8 goto 8
cls
:1
(echo SET EPG=879)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:2
(echo SET EPG=1122)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:3
(echo SET EPG=1123)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:4
(echo SET EPG=1124)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:5
(echo SET EPG=569)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:6
(echo SET EPG=1125)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:7
(echo SET EPG=1126)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:8
(echo SET EPG=1127)> "%location%\settings\source.cmd"
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:END
exit
