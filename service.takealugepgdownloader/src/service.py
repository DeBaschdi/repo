import xbmcgui
import sys
import os
import subprocess
import xbmc
import xbmcaddon
import requests
import random
import xbmcvfs
import gzip
import shutil
import tarfile
from resources.lib import weblogin
from cookielib import LWPCookieJar
import threading
import time

usrsettings = xbmcaddon.Addon(id="service.takealugepgdownloader")
script_file = os.path.realpath(__file__).decode('utf-8')
addondir = os.path.dirname(script_file).decode('utf-8')
speicherort = usrsettings.getSetting("path").decode('utf-8')
server1 = 'https://takealug.de/wordpress'
username = usrsettings.getSetting('username')
uc = username[0].upper() + username[1:]
password = usrsettings.getSetting('password')
choose_epg = usrsettings.getSetting('choose_epg')
auto_download = usrsettings.getSetting('auto_download')
timeswitch = usrsettings.getSetting('timeswitch')
__datapath__ = xbmc.translatePath("special://userdata/addon_data/service.takealugepgdownloader/")
cookie = xbmc.translatePath("special://userdata/addon_data/service.takealugepgdownloader/cookies.lwp")
hidesuccess = usrsettings.getSetting('hide-successful-login-messages')
use_account = usrsettings.getSetting('use-account')

def Notify(title,message):
        xbmc.executebuiltin("XBMC.Notification("+title+","+message+")")

def LOGIN(username,password,hidesuccess):
        uc = username[0].upper() + username[1:]
        lc = username.lower()
        
        logged_inpremium = weblogin.doLoginPremium(__datapath__,username,password)
        
        if logged_inpremium == True:
            if hidesuccess == 'false':
                Notify('Welcome back '+uc,'Thank you for donating!')
                
        elif logged_inpremium == False:
            logged_in = weblogin.doLogin(__datapath__,username,password)
        
            if logged_in == True:
                if hidesuccess == 'false':
                    Notify('Welcome back '+uc,'Takealug say hello')
                
            elif logged_in == False:
                Notify('Login Failure',uc+' could not login')
    
logged_inpremium = weblogin.doLoginPremium(__datapath__,username,password)
    
                
def STARTUP_ROUTINES():
        #deal with bug that happens if the datapath doesn't exist
        if not os.path.exists(__datapath__):
          os.makedirs(__datapath__)
        
        if not os.path.exists(__datapath__+'/temp'):
          os.makedirs(__datapath__+'/temp')
        
        #check if user has enabled use-login setting
        use_account = usrsettings.getSetting('use-account')

        if use_account == 'true':
             #get username and password and do login with them
             #also get whether to hid successful login notification
             LOGIN(username,password,hidesuccess) 


STARTUP_ROUTINES()


def takealug_download():
    if choose_epg == 'Premium DE AT CH 12-14Day':
        de_at_ch_premium()
    else:
        pass
    if choose_epg == 'Premium easyEPG 12-14Day':
        easy_epg_premium()
    else:
        pass
    if choose_epg == 'Premium Zattoo DE 12-14Day':
        zattoo_de_premium()
    else:
        pass
    if choose_epg == 'Premium Zattoo CH 12-14Day':
        zattoo_ch_premium()
    else:
        pass
    if choose_epg == 'Free DE AT CH 3-5Day':
        de_at_ch_free()
    else:
        pass
    if choose_epg == 'Free easyEPG 3-5Day':
        easy_epg_free()
    else:
        pass
    if choose_epg == 'Free Zattoo DE 3-5Day':
        zattoo_de_free()
    else:
        pass
    if choose_epg == 'Free Zattoo CH 3-5Day':
        zattoo_ch_free()
    else:
        pass          
        
def de_at_ch_premium():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/879/'
        if logged_inpremium == False:
            if hidesuccess == 'false':
                Notify('Sorry '+uc,'You need Premium Membership for this File')
        elif logged_inpremium == True: 
            r = s.get(url)
            with open(__datapath__+'temp/guide.gz', 'wb') as f:
                f.write(r.content)            
            with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
                with open(speicherort+'guide.xml', 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
                Notify('Guide Stored', speicherort) 

def easy_epg_premium():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/1122/'
        if logged_inpremium == False:
            if hidesuccess == 'false':
                Notify('Sorry '+uc,'You need Premium Membership for this File')
        elif logged_inpremium == True: 
            r = s.get(url)
            with open(__datapath__+'temp/guide.gz', 'wb') as f:
                f.write(r.content)            
            with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
                with open(speicherort+'guide.xml', 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
                Notify('Guide Stored', speicherort)

def zattoo_de_premium():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/1123/'
        if logged_inpremium == False:
            if hidesuccess == 'false':
                Notify('Sorry '+uc,'You need Premium Membership for this File')
        elif logged_inpremium == True: 
            r = s.get(url)
            with open(__datapath__+'temp/guide.gz', 'wb') as f:
                f.write(r.content)            
            with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
                with open(speicherort+'guide.xml', 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            Notify('Guide Stored', speicherort)

def zattoo_ch_premium():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/1124/'
        if logged_inpremium == False:
            if hidesuccess == 'false':
                Notify('Sorry '+uc,'You need Premium Membership for this File')
        elif logged_inpremium == True: 
            r = s.get(url)
            with open(__datapath__+'temp/guide.gz', 'wb') as f:
                f.write(r.content)            
            with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
                with open(speicherort+'guide.xml', 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            Notify('Guide Stored', speicherort)
        
def de_at_ch_free():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/1271/'
        r = s.get(url)
        with open(__datapath__+'temp/guide.gz', 'wb') as f:
            f.write(r.content)            
        with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
            with open(speicherort+'guide.xml', 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        Notify('Guide Stored', speicherort)

def easy_epg_free():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/1125/'
        r = s.get(url)
        with open(__datapath__+'temp/guide.gz', 'wb') as f:
            f.write(r.content)            
        with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
            with open(speicherort+'guide.xml', 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        Notify('Guide Stored', speicherort)

def zattoo_de_free():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/1126/'
        r = s.get(url)
        with open(__datapath__+'temp/guide.gz', 'wb') as f:
            f.write(r.content)            
        with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
            with open(speicherort+'guide.xml', 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        Notify('Guide Stored', speicherort)

def zattoo_ch_free():
    with requests.Session() as s:
        s.cookies = LWPCookieJar(cookie)
        s.cookies.load(ignore_discard=True)
        url = server1+'/download/1127/'
        r = s.get(url)
        with open(__datapath__+'temp/guide.gz', 'wb') as f:
            f.write(r.content)            
        with gzip.open(__datapath__+'temp/guide.gz', 'rb') as f_in:
            with open(speicherort+'guide.xml', 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        Notify('Guide Stored', speicherort)                

#Download Files
def AUTO():
    logged_in = weblogin.doLogin(__datapath__,username,password)
    if logged_in == True:
        if speicherort == 'choose': 
            Notify('Sorry '+uc,'You need to choose your Downloadlocation first')                    
        else:
            if choose_epg == 'None':
                Notify('Sorry '+uc,'You need to choose your EPG first')
            else:
                if use_account == 'true':
                    if auto_download == 'true':        
                        Notify('Auto-Download', choose_epg)
                        takealug_download()

if auto_download == 'true':
    AUTO()

def manual_download():
    manual_download = False
    try:
        if sys.argv[1:][0] == 'manual_download':
            manual_download = True
    except:
        pass
    return manual_download

if manual_download() == True:
    logged_in = weblogin.doLogin(__datapath__,username,password)
    if logged_in == True:
        if speicherort == 'choose': 
            Notify('Sorry '+uc,'You need to choose your Downloadlocation first')                    
        else:
            if choose_epg == 'None':
                Notify('Sorry '+uc,'You need to choose your EPG first')
            else:
                dialog = xbmcgui.Dialog()
                ret = dialog.yesno('Takealug EPG Downloader', 'Start Manual Download')
                if ret:
                    manual = True
                    Notify('Manual-Download', choose_epg)
                    takealug_download()          

def worker():
  time.sleep(86400)
  Notify('Daily Download', choose_epg)
  takealug_download()
  worker()

if timeswitch == 'true':
    logged_in = weblogin.doLogin(__datapath__,username,password)    
    if logged_in == True:
        if speicherort == 'choose': 
            Notify('Sorry '+uc,'You need to choose your Downloadlocation first')                    
        else:
            if choose_epg == 'None':
                Notify('Sorry '+uc,'You need to choose your EPG first')
            else:
                worker()    