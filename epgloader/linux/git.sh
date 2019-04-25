#!/bin/bash

. settings.ini

##check restrictions
if [ "$engine" == "curl" ];
then
    $curl --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0" --location \
        --dump-header  tmpfile \
        --cookie tmpfile --cookie-jar tmpfile\
        --form log="$username" \
        --form pwd="$password" --form testcookie="1" \
        --form wp-submit="Log In" \
        --form rememberme="forever" "https://takealug.de/wordpress/wp-login.php" >tmpfile2
fi

if [ "$engine" == "wget" ];
then
    $wget \
        --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0" \
        --save-cookies tmpfile \
        --keep-session-cookies \
        --post-data="log="$username"&pwd="$password"&testcookie='1'&wp-submit='Log In'&rememberme='forever'" \
        "https://takealug.de/wordpress/wp-login.php" \
        -O tmpfile2
fi

pc=$(cat tmpfile2 |grep -o Premium -m1)
uc=$(cat tmpfile2 |grep -o Abmelden -m1)
ug=$(if [[ $uc =~ ^.*Abmelden.*$ ]] ; then echo "Welcome back $username Takealug say hello"; fi)
pg=$(if [[ $pc =~ ^.*Premium.*$ ]] ; then echo " ,thank you for Donating !!"; fi)
if [[ $ug = "" ]] ; then echo "Ups, wrong Username or Password, please check your Settings and run Setup again";exit ; fi
restmsg=$(echo "Sorry, you need Premium Membership for this File")
tput clear

echo
echo "$ug $pg"
echo 
echo "###########################################################################################"
echo "###                           EPGchooser for Linux                                      ###"
echo "###                    --Takealug.de feat. easyEPG Project--                            ###"
echo "###                                Revision 1                                           ###"
echo "###########################################################################################"
echo
echo "                              --Choose your EPG--                                          "
echo
echo "[1] Premium DE AT CH 12-14Day"
echo "[2] Premium easyEPG 12-14Day"  
echo "[3] Premium Zattoo DE 12-14Day"
echo "[4] Premium Zattoo CH 12-14Day"
echo "[5] Free DE AT CH 3-5Day"
echo "[6] Free easyEPG 3-5Day"  
echo "[7] Free Zattoo DE 3-5Day"
echo "[8] Free Zattoo CH 3-5Day"
echo
read n
case $n in
    1) if [[ $pg = "" ]] ; then tput clear; echo "$restmsg"; sleep 3; $location/settings/git.sh; else echo EPG=879 >"$location"/settings/source.ini; fi ;;
    2) if [[ $pg = "" ]] ; then tput clear; echo "$restmsg"; sleep 3; $location/settings/git.sh; else echo EPG=1122 >"$location"/settings/source.ini; fi ;;
    3) if [[ $pg = "" ]] ; then tput clear; echo "$restmsg"; sleep 3; $location/settings/git.sh; else echo EPG=1123 >"$location"/settings/source.ini; fi ;;
    4) if [[ $pg = "" ]] ; then tput clear; echo "$restmsg"; sleep 3; $location/settings/git.sh; else echo EPG=1124 >"$location"/settings/source.ini; fi ;;
    5) echo EPG=569 >"$location"/settings/source.ini;;
    6) echo EPG=1125 >"$location"/settings/source.ini;;
    7) echo EPG=1126 >"$location"/settings/source.ini;;
    8) echo EPG=1127 >"$location"/settings/source.ini;;
    *) tput clear; echo invalid option;sleep 3; $location/settings/git.sh;;
esac
echo


rm tmpfile && rm tmpfile2
tput clear
echo "###########################################################################################"
echo "###########################################################################################"
echo "##                                     DONE                                              ##"
echo "###########################################################################################"
echo "###########################################################################################"
