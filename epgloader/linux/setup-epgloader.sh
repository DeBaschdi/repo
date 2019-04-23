#!/bin/bash

curl=$(command -v curl)  #Edit this Line to the correct path to curl if Autodetect dont work. normaly in /usr/bin/curl or /opt/bin/curl or /usr/opt/bin/curl
wget=$(command -v wget)  #Edit this Line to the correct path to wget if Autodetect dont work.

tput clear
echo "###########################################################################################"
echo "###                        EPGloader Installer for Linux                                ###"
echo "###                    --Takealug.de feat. easyEPG Project--                            ###"
echo "###                                Revision 1                                           ###"
echo "###########################################################################################"
echo
echo "Please, enter your Username for Takealug.de"   
read username
echo
echo "and now, enter your Password" 
read password
echo
echo 'Choose your desired Storage Path (like /home/'$USER'/epgloader)'
read location
echo
echo 'Choose your Download Engine'
echo "[1] Curl (preferred)"
echo "[2] Wget"  
read n
case $n in
    1) engine=curl;;
    2) engine=wget;;
    *) invalid option;;
esac

tput clear
echo "###########################################################################################"
echo "###########################################################################################"
echo "Your Username on Takealug ist          $username                                           "
echo "Your Password ist                      $password                                           "
echo "Your desired Storage Path is           $location                                           "
echo "Your chosen Download engine is         $engine                                             "
echo "###########################################################################################"
echo "###########################################################################################"
echo 
echo "Are this Settings Correct ?"
echo "[1] Yes, go on!"
echo "[2] No!"  
read n
case $n in
    1) echo "Ok" ;;
    2) exit;;
    *) invalid option;;
esac

##check login
if [ "$engine" == "curl" ];
then
    echo "###########################################################################################"
    echo "###########################################################################################"
    echo "Checking Username an Password...                                                              "                     
    echo "###########################################################################################"
    echo "###########################################################################################"
    sleep 3
    $curl --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0" --location \
        --dump-header  tmpfile \
        --cookie tmpfile --cookie-jar tmpfile\
        --form log="$username" \
        --form pwd="$password" --form testcookie="1" \
        --form wp-submit="Log In" \
        --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php" >tmpfile2
    pc=$(cat tmpfile2 |grep -o Premium -m1)
    uc=$(cat tmpfile2 |grep -o Abmelden -m1)
    ug=$(if [[ $uc =~ ^.*Abmelden.*$ ]] ; then echo "Welcome back $username Takealug say hello"; fi)
    pg=$(if [[ $pc =~ ^.*Premium.*$ ]] ; then echo " ,thank you for Donating !!"; fi)
    if [[ $ug = "" ]] ; then tput clear && echo "Ups, wrong Username or Password, please check your Settings and run Setup again" && rm tmpfile && rm tmpfile2 && exit; fi
    rm tmpfile && rm tmpfile2
    tput clear
    echo "###########################################################################################"
    echo "###########################################################################################"
    echo "$ug $pg"                                                                                   
    echo "###########################################################################################"
    echo "###########################################################################################"
    sleep 4
    tput clear
fi

if [ "$engine" == "wget" ];
then
    echo "###########################################################################################"
    echo "###########################################################################################"
    echo "Checking Username an Password...                                                              "                     
    echo "###########################################################################################"
    echo "###########################################################################################"
    sleep 3
    $wget \
        --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0" \
        --save-cookies tmpfile \
        --keep-session-cookies \
        --post-data="log="$username"&pwd="$password"&testcookie="1"&wp-submit="Log In"&redirect_to="https://takealug.de/wordpress/wp-admin"&submit="login"&rememberme="forever"" \
        "https://takealug.de/wordpress/wp-login.php" \
        -O tmpfile2
    pc=$(cat tmpfile2 |grep -o Premium -m1)
    uc=$(cat tmpfile2 |grep -o Abmelden -m1)
    ug=$(if [[ $uc =~ ^.*Abmelden.*$ ]] ; then echo "Welcome back $username Takealug say hello"; fi)
    pg=$(if [[ $pc =~ ^.*Premium.*$ ]] ; then echo " ,thank you for Donating !!"; fi)
    if [[ $ug = "" ]] ; then tput clear && echo "Ups, wrong Username or Password, please check your Settings and run Setup again" && rm tmpfile && rm tmpfile2 && exit; fi
    rm tmpfile && rm tmpfile2
    tput clear
    echo "###########################################################################################"
    echo "###########################################################################################"
    echo "$ug $pg"                                                                                   
    echo "###########################################################################################"
    echo "###########################################################################################"
    sleep 5
    tput clear
fi

abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
}

trap 'abort' 0

set -e

    if [ -d "$location" ];then
        tput clear
        echo " !!WARNING!! $location already exist, do you want to delete $location and all Subdirectorys?"
        echo ""
        echo "[1] Yes, delete $location and all Subdirectorys"
        echo "[2] No! Please no!"
        echo ""  
        read n
        case $n in
            1) rm -rf "$location" && mkdir "$location" &&  mkdir "$location/settings" ;;
            2) exit;;
            *) invalid option;;
        esac
    fi
    if ! [ -d "$location" ];then
        mkdir "$location";
        mkdir "$location/settings";
    fi 
 
tput clear
echo "###########################################################################################"
echo "###########################################################################################"
echo "Create configuration in $location/settings/settings.ini                                    "
echo "###########################################################################################"
echo "###########################################################################################"
sleep 1
echo "username=$username"> "$location"/settings/settings.ini
echo "password=$password">> "$location"/settings/settings.ini
echo "location=$location">> "$location"/settings/settings.ini
echo "engine=$engine">> "$location"/settings/settings.ini
echo "curl=$curl">> "$location"/settings/settings.ini
echo "wget=$wget">> "$location"/settings/settings.ini
sleep 1
tput clear

echo "###########################################################################################"
echo "###########################################################################################"
echo "Create EPG-Changer in $location/change-epg.sh                                              "
echo "###########################################################################################"
echo "###########################################################################################"
sleep 1
echo '#!/bin/bash'> "$location"/change-epg.sh
echo '. '$location'/settings/settings.ini'>> "$location"/change-epg.sh
echo 'git=$location/settings/git.sh'>> "$location"/change-epg.sh
echo 'curl -L -o $git "https://github.com/DeBaschdi/repo/raw/master/epgloader/linux/git.sh"'>> "$location"/change-epg.sh
echo 'cd $location/settings/'>> "$location"/change-epg.sh
echo 'chmod a+x $git'>> "$location"/change-epg.sh
echo '$git'>> "$location"/change-epg.sh
sleep 1
tput clear

if [ "$engine" == "curl" ];
then
    echo "###########################################################################################"
    echo "###########################################################################################"
    echo "Create epgloader-linux.sh in "$location"/epgloader-linux.sh                                   "
    echo "###########################################################################################"
    echo "###########################################################################################"
    sleep 1
    echo '#!/bin/bash'> "$location"/epgloader-linux.sh
    echo '. '$location'/settings/settings.ini'>> "$location"/epgloader-linux.sh
    echo '. '$location'/settings/source.ini'>> "$location"/epgloader-linux.sh
    echo 'filename=$location/guide.tar.gz'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'curl="$curl" '>> "$location"/epgloader-linux.sh
    echo 'gzip="$(command -v gzip)" ## Path to Gzip, if autodetect dont work, modify for your self'>> "$location"/epgloader-linux.sh
    echo 'agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0"'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'cd "$location/"'>> "$location"/epgloader-linux.sh
    echo 'rm guide*'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '## authenticate and save cookies'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '$curl --user-agent "$agent" --location \'>> "$location"/epgloader-linux.sh
    echo '      --dump-header  "$location"/settings/cookie1.txt \'>> "$location"/epgloader-linux.sh
    echo '      --cookie "$location"/settings/cookie1.txt --cookie-jar "$location"/settings/cookie1.txt \'>> "$location"/epgloader-linux.sh
    echo '      --form log="$username" \'>> "$location"/epgloader-linux.sh
    echo '      --form pwd="$password" --form testcookie="1" \'>> "$location"/epgloader-linux.sh
    echo '      --form wp-submit="Log In" \'>> "$location"/epgloader-linux.sh
    echo '      --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php" >$location/settings/log.txt'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '## access home page with authenticated cookies and download compressed guide'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '$curl -L -o "$filename" --cookie "$location"/settings/cookie1.txt https://takealug.de/wordpress/download/"$EPG"/'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '##extract guide'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '$gzip -d $filename -c >$location/guide.xml'>> "$location"/epgloader-linux.sh
    echo 'rm $filename'>> "$location"/epgloader-linux.sh
    echo 'rm "$location"/settings/cookie1.txt'>> "$location"/epgloader-linux.sh
    echo 'exit'>> "$location"/epgloader-linux.sh
    sleep 1
    tput clear
fi

if [ "$engine" == "wget" ];
then
    echo "###########################################################################################"
    echo "###########################################################################################"
    echo "Create epgloader-linux.sh in "$location"/epgloader-linux.sh                                   "
    echo "###########################################################################################"
    echo "###########################################################################################"
    sleep 1
    echo '#!/bin/bash'> "$location"/epgloader-linux.sh
    echo '. '$location'/settings/settings.ini'>> "$location"/epgloader-linux.sh
    echo '. '$location'/settings/source.ini'>> "$location"/epgloader-linux.sh
    echo 'filename=$location/guide.tar.gz'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'wget="$wget" '>> "$location"/epgloader-linux.sh
    echo 'gzip="$(command -v gzip)" ## Path to Gzip, if autodetect dont work, modify for your self'>> "$location"/epgloader-linux.sh
    echo 'agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0"'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'cd "$location/"'>> "$location"/epgloader-linux.sh
    echo 'rm guide*'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '## authenticate and save cookies'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '"$wget" \'>> "$location"/epgloader-linux.sh
    echo '  --user-agent="$agent" \'>> "$location"/epgloader-linux.sh
    echo '  --save-cookies "$location"/settings/cookie1.txt \'>> "$location"/epgloader-linux.sh
    echo '  --keep-session-cookies \'>> "$location"/epgloader-linux.sh
    echo '  --post-data="log="$username"&pwd="$password"&testcookie="1"&wp-submit="Log In"&redirect_to="https://takealug.de/wordpress/wp-admin"&submit="login"&rememberme="forever"" \'>> "$location"/epgloader-linux.sh
    echo '  "https://takealug.de/wordpress/wp-login.php" \'>> "$location"/epgloader-linux.sh
    echo '  -O $location/settings/log.txt'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '## access home page with authenticated cookies and download compressed guide'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '$wget \'>> "$location"/epgloader-linux.sh
    echo '  --user-agent="$agent" \'>> "$location"/epgloader-linux.sh
    echo '  --load-cookies "$location"/settings/cookie1.txt \'>> "$location"/epgloader-linux.sh
    echo '  "https://takealug.de/wordpress/download/"$EPG"/" \'>> "$location"/epgloader-linux.sh
    echo '  --quiet \'>> "$location"/epgloader-linux.sh
    echo '  -O $filename'>> "$location"/epgloader-linux.sh
    echo '##extract guide'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'gzip -d $filename -c >$location/guide.xml'>> "$location"/epgloader-linux.sh
    echo 'rm $filename'>> "$location"/epgloader-linux.sh
    echo 'rm "$location"/settings/cookie1.txt'>> "$location"/epgloader-linux.sh
    echo 'exit'>> "$location"/epgloader-linux.sh
    sleep 1
    tput clear
fi


chmod a+x $location/epgloader-linux.sh
chmod a+x $location/change-epg.sh
echo "###########################################################################################"
echo "###########################################################################################"
echo "Setup is almost done, run $location/epgloader-linux.sh to download your EPG                "
echo "If you want to choose an other EPG Source, run $location/change-epg.sh                     "
echo "###########################################################################################"
echo "###########################################################################################"
sleep 6
echo "                       Starting change-epg.sh in 3 Seconds                                 "
echo "###########################################################################################"
echo "###########################################################################################"
sleep 3
tput clear

trap : 0

echo >&2 '
************
*** DONE *** 
************
'

$location/change-epg.sh
exit