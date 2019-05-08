@echo off
@break off
@title EPGLoader Installer 
@color 0a
:begin
cls
echo ###########################################################################################
echo ###                      EPGloader Installer Fuer Windows                               ###
echo ###                    --Takealug.de feat. easyEPG Project--                            ###
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
echo Your Username on Takealug ist          "%user%"
echo Your Password ist                      "%password%"
echo Your desired Storage Path is           "%location%"
echo ###########################################################################################
echo ###########################################################################################
echo.
echo.
echo [1] Yes, go on!
echo [2] No!
echo.

set asw=0
set /p asw="Are this Settings Correct ?"
if %asw%==1 goto check
if %asw%==2 goto begin

:check
cls
echo ###########################################################################################
echo ###########################################################################################
echo Checking Username an Password...                                                                                   
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
"%cd%\curl\bin\curl.exe" --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0" --location --dump-header  tmp1 --cookie tmp1 --cookie-jar tmp1 --form log="%user%" --form pwd="%password%" --form testcookie="1" --form wp-submit="Log In" --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php" >tmp2

"%cd%\coreutils\cat.exe" tmp2 |"%cd%\coreutils\grep.exe" -o -m1 Abmelden > uc
"%cd%\coreutils\cat.exe" tmp2 |"%cd%\coreutils\grep.exe" -o -m1 Premium > pc
set /p ul= < uc
set /p pl= < pc

IF  "%pl%"=="Premium" goto welcomepremium
IF  "%ul%"=="Abmelden" goto welcomeuser
IF  "%ul%"=="" goto wronguser
cls

:welcomeuser
cls
echo ###########################################################################################
echo ###########################################################################################
echo Welcome back %user% Takealug say hello                                                                                   
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
del "%cd%\pc" 
del "%cd%\uc" 
del "%cd%\tmp1"
del "%cd%\tmp2"
goto createdirectory

:welcomepremium
cls
echo ###########################################################################################
echo ###########################################################################################
echo Welcome back %user% Takealug say hello, thank you for Donating !!                                                                           
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
del "%cd%\pc" 
del "%cd%\uc" 
del "%cd%\tmp1"
del "%cd%\tmp2"
goto createdirectory

:wronguser
cls
echo ###########################################################################################
echo ###########################################################################################
echo Ups, wrong Username or Password, please check your Settings.                                                                          
echo ###########################################################################################
echo ###########################################################################################
ping -n 5 127.0.0.1 > nul
del "%cd%\pc" 
del "%cd%\uc" 
del "%cd%\tmp1"
del "%cd%\tmp2"
goto begin

:createdirectory
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
echo Create configuration in %location%\settings\config.cmd
echo ###########################################################################################
echo ###########################################################################################
ping -n 2 127.0.0.1 > nul
mkdir "%location%"\settings > nul
(echo SET user=%user%)> "%location%\settings\config.cmd"
(echo SET password=%password%)>> "%location%\settings\config.cmd"
(echo SET location=%location%)>> "%location%\settings\config.cmd"
(echo SET curl="%location%\curl\bin\curl.exe")>> "%location%\settings\config.cmd"
(echo SET 7z="%location%\7z\bin\7z.exe")>> "%location%\settings\config.cmd"
(echo SET cat="%location%\coreutils\cat.exe")>> "%location%\settings\config.cmd"

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
(echo cd "%%location%%\settings\")>> "%location%\change-epg.bat"
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
(echo SET filename=\guide.gz)>> "%location%\epgloader-win.bat"
(echo SET agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0")>> "%location%\epgloader-win.bat"
(echo echo ## neu downloaden ##)>> "%location%\epgloader-win.bat"
(echo %%curl%% --user-agent %%agent%% --location --dump-header  "%%location%%%%temp%%" --cookie "%%location%%%%temp%%" --cookie-jar "%%location%%%%temp%%" --form log="%user%" --form pwd="%password%" --form testcookie="1" --form wp-submit="Log In" --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php")>> "%location%\epgloader-win.bat"
(echo %%curl%% -L -o "%%location%%%%filename%%" --cookie "%%location%%%%temp%%" "https://takealug.de/wordpress/download/%%EPG%%/")>> "%location%\epgloader-win.bat"
(echo "%%location%%\7z\bin\7z.exe" x -y "%%location%%\guide.gz")>> "%location%\epgloader-win.bat"
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
mkdir "%location%"\coreutils > nul
copy "%cd%"\curl\bin\curl.exe "%location%\curl\bin\curl.exe"
copy "%cd%"\curl\bin\ca-bundle.crt "%location%\curl\bin\ca-bundle.crt"
copy "%cd%"\7z\bin\7z.exe "%location%\7z\bin\7z.exe"
copy "%cd%"\7z\bin\7z.dll "%location%\7z\bin\7z.dll"
copy "%cd%"\coreutils\*.* "%location%\coreutils\"
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
