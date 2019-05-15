#!/bin/bash

# CHECK IF ALL APPLICATIONS ARE INSTALLED
command -v curl >/dev/null 2>&1 || { printf "\ncurl is required but it's not installed!" >&2; ERROR1="true"; }
command -v gzip >/dev/null 2>&1 || { printf "\ngzip is required but it's not installed!" >&2; ERROR1="true"; }
command -v clear >/dev/null 2>&1 || { printf "\nclear is required but it's not installed!" >&2; ERROR1="true"; }

if [ ! -z "$ERROR1" ]
then
	printf "\n\n[ FATAL ERROR ] Required applications are missing - Stop.\n"
	exit 1
fi

clear
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

curl=$(command -v curl)
engine=curl

clear
echo "###########################################################################################"
echo "###########################################################################################"
echo "Your Username on Takealug ist          $username                                           "
echo "Your Password ist                      $password                                           "
echo "Your desired Storage Path is           $location                                           "
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
    *) clear; echo invalid option;sleep 3; exit;;
esac
clear
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
        --form log=''$username'' \
        --form pwd=''$password'' --form testcookie="1" \
        --form wp-submit="Log In" \
        --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php" >tmpfile2
    pc=$(cat tmpfile2 |grep -o Premium -m1)
    uc=$(cat tmpfile2 |grep -o Abmelden -m1)
    ug=$(if [[ $uc =~ ^.*Abmelden.*$ ]] ; then echo "Welcome back $username Takealug say hello"; fi)
    pg=$(if [[ $pc =~ ^.*Premium.*$ ]] ; then echo " ,thank you for Donating !!"; fi)
    if [[ $ug = "" ]] ; then clear && echo "Ups, wrong Username or Password, please check your Settings and run Setup again" && rm tmpfile && rm tmpfile2 && exit; fi
    rm tmpfile && rm tmpfile2
    clear
    echo "###########################################################################################"
    echo "###########################################################################################"
    echo "$ug $pg"                                                                                   
    echo "###########################################################################################"
    echo "###########################################################################################"
    sleep 4
    clear
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
        clear
        echo " !!WARNING!! $location already exist, do you want to delete $location and all Subdirectorys?"
        echo ""
        echo "[1] Yes, delete $location and all Subdirectorys"
        echo "[2] No! Please no!"
        echo ""  
        read n
        case $n in
            1) rm -rf "$location" && mkdir "$location" &&  mkdir "$location/settings" ;;
            2) exit;;
            *) clear; echo invalid option;sleep 3; exit;;
        esac
    fi
    if ! [ -d "$location" ];then
        mkdir "$location";
        mkdir "$location/settings";
    fi 
 
clear
echo "###########################################################################################"
echo "###########################################################################################"
echo "Create configuration in $location/settings/settings.ini                                    "
echo "###########################################################################################"
echo "###########################################################################################"
sleep 1
echo "username='$username'"> "$location"/settings/settings.ini
echo "password='$password'">> "$location"/settings/settings.ini
echo "location=$location">> "$location"/settings/settings.ini
echo "engine=$engine">> "$location"/settings/settings.ini
echo "curl=$curl">> "$location"/settings/settings.ini
sleep 1
clear

echo "###########################################################################################"
echo "###########################################################################################"
echo "Create EPG-Changer in $location/change-epg.sh                                              "
echo "###########################################################################################"
echo "###########################################################################################"
sleep 1
echo '#!/bin/bash'> "$location"/change-epg.sh
echo '. '$location'/settings/settings.ini'>> "$location"/change-epg.sh
echo 'git=$location/settings/git.sh'>> "$location"/change-epg.sh
echo 'if [ "$engine" == "curl" ]; then $curl -L -o $git "https://github.com/DeBaschdi/repo/raw/master/epgloader/linux/git.sh"; fi'>> "$location"/change-epg.sh
echo 'cd $location/settings/'>> "$location"/change-epg.sh
echo 'chmod a+x $git'>> "$location"/change-epg.sh
echo '$git'>> "$location"/change-epg.sh
sleep 1
clear

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
    echo 'filename=$location/guide.gz'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'curl="$curl" '>> "$location"/epgloader-linux.sh
    echo 'gzip="$(command -v gzip)" ## Path to Gzip, if autodetect dont work, modify for your self'>> "$location"/epgloader-linux.sh
    echo 'agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0"'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'cd "$location/"'>> "$location"/epgloader-linux.sh
    echo 'rm guide* >/dev/null 2>&1'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '## authenticate and save cookies'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '$curl --user-agent "$agent" --location \'>> "$location"/epgloader-linux.sh
    echo '      --dump-header  "$location"/settings/cookie1.txt \'>> "$location"/epgloader-linux.sh
    echo '      --cookie "$location"/settings/cookie1.txt --cookie-jar "$location"/settings/cookie1.txt \'>> "$location"/epgloader-linux.sh
    echo '      --form log="''$username''" \'>> "$location"/epgloader-linux.sh
    echo '      --form pwd="''$password''" --form testcookie="1" \'>> "$location"/epgloader-linux.sh
    echo '      --form wp-submit="Log In" \'>> "$location"/epgloader-linux.sh
    echo '      --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php" >$location/settings/log.txt'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '## access home page with authenticated cookies and download compressed guide'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '$curl -L -o "$filename" --cookie "$location"/settings/cookie1.txt https://takealug.de/wordpress/download/"$EPG"/'>> "$location"/epgloader-linux.sh
    echo 'chmod 777 $filename'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '##extract guide'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo '$gzip -d $filename -c >"$location"/guide.xml'>> "$location"/epgloader-linux.sh
    echo 'chmod 777 "$location"/guide.xml'>> "$location"/epgloader-linux.sh
    echo ''>> "$location"/epgloader-linux.sh
    echo 'rm $filename'>> "$location"/epgloader-linux.sh
    echo 'rm "$location"/settings/cookie1.txt'>> "$location"/epgloader-linux.sh
    echo 'exit'>> "$location"/epgloader-linux.sh
    sleep 1
    clear
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
clear

trap : 0

echo >&2 '
************
*** DONE *** 
************
'

$location/change-epg.sh
exit