@echo off
@break off
@title EPGLoader Installer 
@color 0a
cls
echo ###########################################################################################
echo ###                      EPGloader Installer Fuer Windows                               ###
echo ###                    --Takealug.de feat. easyEPG Preject--                            ###
echo ###                                Revision 3                                           ###
echo ###########################################################################################
pause
cls

echo Please, enter your Username for Takealug.de   
set /p user=
echo and now, enter your Password   
set /p password=
:location
echo Choose your desired Storage Path   (like %UserProfile%\Documents\epgloader)
echo.
set /p location=
echo.
cls

echo ###########################################################################################
echo ###########################################################################################
echo Your Username on Tkealug ist            %user%
echo Your Password ist                      %password%
echo Your desired Storage Path is           %location%
echo ###########################################################################################
echo ###########################################################################################
echo .
echo Are this Settings Correct ? (If no, please cancel and restart)
echo .

pause
cls
echo Create Directory %location%
setlocal EnableDelayedExpansion
if not exist "%location%" (
  mkdir "%location%"
  if "!errorlevel!" EQU "0" (
    echo ###########################################################################################
    echo Directory successfully created
    echo ###########################################################################################
    goto configurationfile
    ) else (
    echo ###########################################################################################    
    echo Error creating the directory 
    echo ###########################################################################################
    goto location
  )
) else (
  echo ###########################################################################################
  echo Directory Exists already, overwrites existing configuration
  echo ###########################################################################################
  goto configurationfile
)

:configurationfile
cls
echo ###########################################################################################
echo ###########################################################################################
echo Create configuration in %location%\config.cmd
echo ###########################################################################################
echo ###########################################################################################
pause
(echo SET user=%user%)> "%location%\config.cmd"
(echo SET password=%password%)>> "%location%\config.cmd"
(echo SET location=%location%)>> "%location%\config.cmd"
(echo SET curl="%location%\curl\bin\curl.exe")>> "%location%\config.cmd"
(echo SET 7z="%location%\7z\bin\7z.exe")>> "%location%\config.cmd"

:epgchanger
cls
echo ###########################################################################################
echo ###########################################################################################
echo Create EPG-Changer in %location%\change-epg.bat
echo ###########################################################################################
echo ###########################################################################################
pause
(echo call "%%cd%%\config.cmd")> "%location%\change-epg.bat"
(echo call "%%cd%%\source.cmd")>> "%location%\change-epg.bat"
(echo SET curl="%location%\curl\bin\curl.exe")>> "%location%\change-epg.bat"
(echo %%curl%% -D "%%location%%%%temp%%" "https://github.com/DeBaschdi/repo/raw/master/repository.takealug-1.0.0.zip")>> "%location%\change-epg.bat"
(echo exit)>> "%location%\change-epg.bat"

:grabber
cls
echo ###########################################################################################
echo ###########################################################################################
echo Create epgloader-win.bat in %location%\epgloader-win.bat
echo ###########################################################################################
echo ###########################################################################################
pause
(echo call "%%cd%%\config.cmd")> "%location%\epgloader-win.bat"
(echo call "%%cd%%\source.cmd")>> "%location%\epgloader-win.bat"
(echo SET temp=\cookie.txt)>> "%location%\epgloader-win.bat"
(echo SET filename=\guide-mapped.xml)>> "%location%\epgloader-win.bat"
(echo SET agent="Mozilla/5.0 ^(Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6^) Gecko/20070725 Firefox/2.0.0.6")>> "%location%\epgloader-win.bat"
(echo echo ##aufraumen ##)>> "%location%\epgloader-win.bat"
(echo del "%%location%%%%filename%%")>> "%location%\epgloader-win.bat"
(echo echo ## neu downloaden ##)>> "%location%\epgloader-win.bat"
(echo %%curl%% -D "%%location%%%%temp%%" "https://takealug.de/wordpress/wp-login.php")>> "%location%\epgloader-win.bat"
(echo %%curl%% -A %%agent%% -L -D "%%location%%%%temp%%" -b "%%location%%%%temp%%" -d "log=%%user%%&pwd=%%password%%&testcookie=1&rememberme=forever" "https://takealug.de/wordpress/wp-login.php")>> "%location%\epgloader-win.bat"
(echo %%curl%% -L -o "%%location%%%%filename%%" --cookie "%%location%%%%temp%%" "https://takealug.de/wordpress/download/%%EPG%%/")>> "%location%\epgloader-win.bat"
(echo exit)>> "%location%\epgloader-win.bat"
:curl
cls
echo ###########################################################################################
echo ###########################################################################################
echo installiere curl in %location%\curl\bin\curl.exe
echo installiere 7z in %location%\7z\bin\7z.exe
echo ###########################################################################################
echo ###########################################################################################
pause
mkdir "%location%"\curl
mkdir "%location%"\curl\bin
mkdir "%location%"\7z
mkdir "%location%"\7z\bin
copy "%cd%"\curl\bin\curl.exe "%location%\curl\bin\curl.exe"
copy "%cd%"\curl\bin\ca-bundle.crt "%location%\curl\bin\ca-bundle.crt"
copy "%cd%"\7z\bin\7z.exe "%location%\7z\bin\7z.exe"
copy "%cd%"\7z\bin\7z.dll "%location%\7z\bin\7z.dll"
pause
cls
echo ###########################################################################################
echo ###########################################################################################
echo Installation ist fertig gestellt, starte %location%\epgloader-win.bat um dein EPG Downzuloaden
echo Um deine EPG Quelle auszuwählen, oder zu ändern, starte %location%\change-epg.bat
echo ###########################################################################################
echo ###########################################################################################
pause
exit
