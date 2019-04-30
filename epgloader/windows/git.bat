@echo off
@break off
@title EPG Changer
@color 0a
cls
call config.cmd

"%location%\curl\bin\curl.exe" --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0" --location --dump-header  "%location%\settings\tmp1" --cookie "%location%\settings\tmp1" --cookie-jar "%location%\settings\tmp1" --form log="%user%" --form pwd="%password%" --form testcookie="1" --form wp-submit="Log In" --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php" >"%location%\settings\tmp2"

"%location%\coreutils\cat.exe" "%location%\settings\tmp2" |"%location%\coreutils\grep.exe" -o -m1 Premium > "%location%\settings\pc"
set /p pl= < "%location%\settings\pc"

:begin
cls
echo ###########################################################################################
echo ###                          EPGchooser for Windows                                     ###
echo ###                    --Takealug.de feat. easyEPG Project--                            ###
echo ###                                Revision 1                                           ###
echo ###########################################################################################


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
IF  "%pl%"=="Premium" (echo SET EPG=879)> "%location%\settings\source.cmd" else goto nopremium
cls
goto done

:2
IF  "%pl%"=="Premium" (echo SET EPG=1122)> "%location%\settings\source.cmd" else goto nopremium
cls
goto done

:3
IF  "%pl%"=="Premium" (echo SET EPG=1123)> "%location%\settings\source.cmd" else goto nopremium
cls
goto done

:4
IF  "%pl%"=="Premium" (echo SET EPG=1124)> "%location%\settings\source.cmd" else goto nopremium
cls
goto done

:5
(echo SET EPG=1271)> "%location%\settings\source.cmd"
cls
goto done

:6
(echo SET EPG=1125)> "%location%\settings\source.cmd"
cls
goto done

:7
(echo SET EPG=1126)> "%location%\settings\source.cmd"
cls
goto done

:8
(echo SET EPG=1127)> "%location%\settings\source.cmd"
cls
goto done

:nopremium
cls
echo ###########################################################################################
echo ###########################################################################################
echo ##                  Sorry, you need Premium Membership for this File                     ##
echo ###########################################################################################
echo ###########################################################################################
pause
del "%location%\settings\tmp1" 
del "%location%\settings\tmp2" 
del "%location%\settings\pc"
goto begin

:done
echo ###########################################################################################
echo ###########################################################################################
echo ##                                     DONE                                              ##
echo ###########################################################################################
echo ###########################################################################################
pause
goto END

:END
del "%location%\settings\tmp1" 
del "%location%\settings\tmp2" 
del "%location%\settings\pc"
exit
