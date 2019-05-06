import os
import re
import urllib,urllib2
import cookielib

def Notify(title,message):
        xbmc.executebuiltin("XBMC.Notification("+title+","+message+")")
        
def check_login(source,username):
    
    #the string you will use to check if the login is successful.
    #you may want to set it to:    username     (no quotes)
    logged_in_string = 'abmelden' 

    #search for the string in the html, without caring about upper or lower case
    if re.search(logged_in_string,source,re.IGNORECASE):
        return True
    else:
        return False

def check_premium(source,username):
    
    #the string you will use to check if the user has Premium Membership.
    logged_in_string = 'Premium' 

    #search for the string in the html, without caring about upper or lower case
    if re.search(logged_in_string,source,re.IGNORECASE):
        return True
    else:
        return False

def doLogin(cookiepath, username, password):

    #check if user has supplied only a folder path, or a full path
    if not os.path.isfile(cookiepath):
        #if the user supplied only a folder path, append on to the end of the path a filename.
        cookiepath = os.path.join(cookiepath,'cookies.lwp')
        
    #delete any old version of the cookie file
    try:
        os.remove(cookiepath)
    except:
        pass

    if username and password:
        wp_admin = 'https://takealug.de/wordpress/wp-admin/'
        #the url you will request to.
        login_url = 'https://takealug.de/wordpress/wp-login.php'

        #the header used to pretend you are a browser
        header_string = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0'

	#build the form data necessary for the login
        login_data = urllib.urlencode({'log':username, 'pwd':password, 'testcookie':'1', 'wp-submit':'Log In', 'rememberme':'forever' })

        #build the request we will make
        req = urllib2.Request(login_url, login_data)
        req.add_header('User-Agent',header_string)

        #initiate the cookielib class
        cj = cookielib.LWPCookieJar()

        #install cookielib into the url opener, so that cookies are handled
        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))

        #do the login and get the response
        response = opener.open(req)
        source = response.read()
        response.close()

        #check the received html for a string that will tell us if the user is logged in
        #pass the username, which can be used to do this.
        login = check_login(source,username)

        #if login suceeded, save the cookiejar to disk
        if login == True:
            cj.save(cookiepath, ignore_discard=True,)

        #return whether we are logged in or not
        return login
    
    else:
        return False
    
def doLoginPremium(cookiepath, username, password):

    #check if user has supplied only a folder path, or a full path
    if not os.path.isfile(cookiepath):
        #if the user supplied only a folder path, append on to the end of the path a filename.
        cookiepath = os.path.join(cookiepath,'cookies.lwp')
        
    #delete any old version of the cookie file
    try:
        os.remove(cookiepath)
    except:
        pass

    if username and password:
        wp_admin = 'https://takealug.de/wordpress/wp-admin/'
        #the url you will request to.
        login_url = 'https://takealug.de/wordpress/wp-login.php'

        #the header used to pretend you are a browser
        header_string = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0'

	#build the form data necessary for the login
        login_data = urllib.urlencode({'log':username, 'pwd':password, 'testcookie':'1', 'wp-submit':'Log In', 'rememberme':'forever' })

        #build the request we will make
        req = urllib2.Request(login_url, login_data)
        req.add_header('User-Agent',header_string)

        #initiate the cookielib class
        cj = cookielib.LWPCookieJar()

        #install cookielib into the url opener, so that cookies are handled
        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))

        #do the login and get the response
        response = opener.open(req)
        source = response.read()
        response.close()

        #check the received html for a string that will tell us if the user is logged in
        #pass the username, which can be used to do this.
        loginpremium = check_premium(source,username)

        #if login suceeded, save the cookiejar to disk
        if loginpremium == True:
            cj.save(cookiepath, ignore_discard=True,)

        #return whether we are logged in or not
        return loginpremium
    
    else:
        return False
