@echo off
@break off
@title EPGLoader Installer 
@color 0a
cls
echo ###########################################################################################
echo ###                      EPGloader Installer Fuer Windows                               ###
echo ###                    --Takealug.de feat. easyEPG Preject--                            ###
echo ###                                Revision 1                                           ###
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
echo Your Username on Takealug ist          %user%
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
  mkdir "%location%"\settings 
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
echo Create configuration in %location%\settings\config.cmd
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
(echo SET user=%user%)> "%location%\settings\config.cmd"
(echo SET password=%password%)>> "%location%\settings\config.cmd"
(echo SET location=%location%)>> "%location%\settings\config.cmd"
(echo SET curl="%location%\curl\bin\curl.exe")>> "%location%\settings\config.cmd"
(echo SET 7z="%location%\7z\bin\7z.exe")>> "%location%\settings\config.cmd"

:epgchanger
cls
echo ###########################################################################################
echo ###########################################################################################
echo Create EPG-Changer in %location%\change-epg.bat
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
(echo call "%%cd%%\settings\config.cmd")> "%location%\change-epg.bat"
(echo SET curl="%location%\curl\bin\curl.exe")>> "%location%\change-epg.bat"
(echo SET git="%location%\settings\git.bat")>> "%location%\change-epg.bat"
(echo %%curl%% -L -o %%git%% "https://github.com/DeBaschdi/repo/raw/master/epgloader/windows/git.bat")>> "%location%\change-epg.bat"
(echo %%git%% )>> "%location%\change-epg.bat"
(echo exit)>> "%location%\change-epg.bat"

:grabber
cls
echo ###########################################################################################
echo ###########################################################################################
echo Create epgloader-win.bat in %location%\epgloader-win.bat
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
(echo call "%%cd%%\settings\config.cmd")> "%location%\epgloader-win.bat"
(echo call "%%cd%%\settings\source.cmd")>> "%location%\epgloader-win.bat"
(echo SET temp=\settings\cookie.txt)>> "%location%\epgloader-win.bat"
(echo SET filename=\guide.tar.gz)>> "%location%\epgloader-win.bat"
(echo SET agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0")>> "%location%\epgloader-win.bat"
(echo echo ## neu downloaden ##)>> "%location%\epgloader-win.bat"
(echo %%curl%% -D "%%location%%%%temp%%" "https://takealug.de/wordpress/wp-login.php")>> "%location%\epgloader-win.bat"
(echo %%curl%% -A %%agent%% -L -D "%%location%%%%temp%%" -b "%%location%%%%temp%%" -d "log=%%user%%&pwd=%%password%%&testcookie=1&rememberme=forever" "https://takealug.de/wordpress/wp-login.php")>> "%location%\epgloader-win.bat"
(echo %%curl%% -L -o "%%location%%%%filename%%" --cookie "%%location%%%%temp%%" "https://takealug.de/wordpress/download/%%EPG%%/")>> "%location%\epgloader-win.bat"
(echo "%%location%%\7z\bin\7z.exe" x -y "%%location%%\guide.tar.gz")>> "%location%\epgloader-win.bat"
(echo "%%location%%\7z\bin\7z.exe" x -y "%%location%%\guide.tar")>> "%location%\epgloader-win.bat"
(echo del "%%location%%\guide.tar.gz")>> "%location%\epgloader-win.bat"
(echo del "%%location%%\guide.tar")>> "%location%\epgloader-win.bat"
(echo exit)>> "%location%\epgloader-win.bat" 

:curl
cls
echo ###########################################################################################
echo ###########################################################################################
echo installing curl in %location%\curl\bin\curl.exe
echo installing 7z in %location%\7z\bin\7z.exe
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
mkdir "%location%"\curl > nul
mkdir "%location%"\curl\bin > nul
mkdir "%location%"\7z > nul
mkdir "%location%"\7z\bin > nul
copy "%cd%"\curl\bin\curl.exe "%location%\curl\bin\curl.exe"
copy "%cd%"\curl\bin\ca-bundle.crt "%location%\curl\bin\ca-bundle.crt"
copy "%cd%"\7z\bin\7z.exe "%location%\7z\bin\7z.exe"
copy "%cd%"\7z\bin\7z.dll "%location%\7z\bin\7z.dll"
ping -n 3 127.0.0.1 > nul
cls
echo ###########################################################################################
echo ###########################################################################################
echo Setup is almost done, run %location%\epgloader-win.bat to download your EPG
echo If you want to choose an other EPG Source, run %location%\change-epg.bat
echo ###########################################################################################
echo ###########################################################################################
pause
cls
echo ###########################################################################################
echo ###########################################################################################
echo starting EPG Selection....
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
"%location%\change-epg.bat"
exit