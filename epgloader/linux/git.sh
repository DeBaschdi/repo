#!/bin/bash

. settings.ini

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
    1) EPG=879;;
    2) EPG=1122;;
    3) EPG=1123;;
    4) EPG=1124;;
    5) EPG=569;;
    6) EPG=1125;;
    7) EPG=1126;;
    8) EPG=1127;;
    *) invalid option;;
esac

echo "EPG=$EPG" >"$location"/settings/source.ini
