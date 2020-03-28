# -*- coding: utf-8 -*-

import xbmcplugin
import sys
from urllib import urlencode
from urlparse import parse_qsl, urlparse
import os
import platform
import subprocess
from subprocess import Popen
import re
import xbmc
import xbmcaddon
import xbmcgui
import json
import requests
import xbmcvfs
from zipfile import ZipFile
import shlex

ADDON = xbmcaddon.Addon(id="plugin.video.telerising-cloudcontrol")
addon_name = ADDON.getAddonInfo('name')
addon_version = ADDON.getAddonInfo('version')
datapath = xbmc.translatePath(ADDON.getAddonInfo('profile'))
addonpath = xbmc.translatePath(ADDON.getAddonInfo('path'))
temppath = os.path.join(datapath, "temp")
mute_notify = ADDON.getSetting('hide-osd-messages')

## Read Cloud Settings
enable_cloud = True if ADDON.getSetting('enable_cloud').upper() == 'TRUE' else False
recording_address = ADDON.getSetting('recording_address')
recording_port = ADDON.getSetting('recording_port')
connection_type_cloud = True if ADDON.getSetting('connection_type_cloud').upper() == 'TRUE' else False
enable_protection_pin_cloud = True if ADDON.getSetting('enable_protection_pin_cloud').upper() == 'TRUE' else False
protection_pin_cloud = ADDON.getSetting('protection_pin_cloud')

## Read Vod Settings
enable_vod = True if ADDON.getSetting('enable_vod').upper() == 'TRUE' else False
vod_address = ADDON.getSetting('vod_address')
vod_port = ADDON.getSetting('vod_port')
connection_type_vod = True if ADDON.getSetting('connection_type_vod').upper() == 'TRUE' else False
enable_protection_pin_vod = True if ADDON.getSetting('enable_protection_pin_vod').upper() == 'TRUE' else False
protection_pin_vod = ADDON.getSetting('protection_pin_vod')


##Read Global Settings
storage_path = ADDON.getSetting('storage_path').decode('utf-8')
quality = ADDON.getSetting('quality')
audio_profile = ADDON.getSetting('audio_profile')
showtime_in_title = True if ADDON.getSetting('showtime_in_title').upper() == 'TRUE' else False


machine = platform.machine()

# return connection type

def setServer(server, port, secure=True):
    if secure: return 'https://{}'.format(server)
    return 'http://{}:{}'.format(server, port)


# Translate Video Settings to Bandwidth

bandwidth = dict({'432p25': '1500',
                  '576p50': '2999',
                  '720p25': '3000',
                  '720p50': '5000',
                  '1080p25': '4999',
                  '1080p50': '8000'})


# Make OSD Notify Messages

OSD = xbmcgui.Dialog()


def notify(title, message, icon=xbmcgui.NOTIFICATION_INFO):
    OSD.notification(title, message, icon)


# Make a debug logger

def log(message, loglevel=xbmc.LOGDEBUG):
    xbmc.log('[{} {}] {}'.format(addon_name, addon_version, message), loglevel)


class SystemEnvironment(object):
    def __init__(self):
        self.base_git_url = 'https://github.com/DeBaschdi/packages/raw/master'

        # structure of dict: machine: [OS, URL ffprobe packed, URL ffmpeg packed, ffprobe unpacked, ffmpeg unpacked]

        self.mtypes = dict({'x86_64': ['Linux', 'ffprobe_x86_64.zip', 'ffmpeg_x86_64.zip', 'ffprobe', 'ffmpeg'],
                            'AMD64': ['Windows', 'ffprobe_amd64.zip', 'ffmpeg_amd64.zip', 'ffprobe.exe', 'ffmpeg.exe'],
                            'OSX64': ['OSX', 'ffprobe_osx64.zip', 'ffmpeg_osx64.zip', 'ffprobe', 'ffmpeg'],
                            'armv7l': ['Linux', 'ffprobe_arm32.zip', 'ffmpeg_arm32.zip', 'ffprobe', 'ffmpeg'],
                            'armv8l': ['Linux', 'ffprobe_arm64.zip', 'ffmpeg_arm64.zip' 'ffprobe', 'ffmpeg'],
                            'aarch64': ['Android', None, None, None, None]})

        self.machine = None
        self.isSupported = False
        self.isInstalled = False

        self.run = None
        self.temp = None

    def prepare(self):
        if machine != '' and machine in self.mtypes.keys() and self.mtypes[machine][1] is not None and self.mtypes[machine][2] is not None:

            self.isSupported = True
            self.machine = machine

            self.run = os.path.join(datapath, 'bin')
            self.temp = os.path.join(datapath, 'temp')

            if not os.path.exists(self.run): os.makedirs(self.run, mode=509)
            if not os.path.exists(self.temp): os.makedirs(self.temp)

            self.ffprobe_url = '{}/{}'.format(self.base_git_url, self.mtypes[machine][1])
            self.ffmpeg_url = '{}/{}'.format(self.base_git_url, self.mtypes[machine][2])
            self.ffprobe_executable = os.path.join(self.run, self.mtypes[machine][3])
            self.ffmpeg_executable = os.path.join(self.run, self.mtypes[machine][4])

            log('Machine is {}'.format(self.machine), xbmc.LOGNOTICE)


        else:
            if self.machine == '' or None:
                log('Machine ' + machine + 'is currently not supported', xbmc.LOGERROR)
                notify(addon_name, 'Machine ' + machine + 'is currently not supported', icon=xbmcgui.NOTIFICATION_ERROR)

    def check(self):
        if self.isSupported == True:
            if os.path.exists(self.run) and os.path.isfile(self.ffprobe_executable) and os.path.isfile(self.ffmpeg_executable):
                self.isInstalled = True
                log('{} and {} are installed'.format(os.path.basename(self.ffprobe_executable),os.path.basename(self.ffmpeg_executable)), xbmc.LOGNOTICE)

                ## Make Binarys Executable (Octal Premission Python 2 +3 Compatible)
                os.chmod(self.ffprobe_executable, 509)
                os.chmod(self.ffmpeg_executable, 509)
        else:
            log('Machine is ' + machine + ' and currently only support Playback / Delete', xbmc.LOGNOTICE)

    def download(self, response, message):
        with open(os.path.join(self.run, 'download.zip'), 'wb') as f:
            total = response.headers.get('content-length')
            if total is None:
                log('Could not determine download size', xbmc.LOGNOTICE)
                f.write(response.content)
            else:
                bgDialog = xbmcgui.DialogProgress()
                bgDialog.create(addon_name, message)

                partial = 0
                total = int(total)
                completed = True
                for data in response.iter_content(chunk_size=4096):
                    partial += len(data)
                    f.write(data)
                    bgDialog.update(int(100 * partial / total), addon_name, message)
                    if bgDialog.iscanceled():
                        completed = False
                        break
                bgDialog.close()
        f.close()

        if completed:
            with ZipFile(os.path.join(self.run, 'download.zip'), 'r') as zip:
                zip.extractall(self.run)
        os.remove(os.path.join(self.run, 'download.zip'))
        return completed

    def install_tools(self):
        if self.isInstalled: return

        yn = OSD.yesno(addon_name, "You are about to install the required environment tools. This may take some time. Do you want to continue?")
        if yn:
            try:
                log('Download and install FFProbe', xbmc.LOGNOTICE)
                req = requests.get(self.ffprobe_url, stream=True)
                req.raise_for_status()

                if self.download(req, 'Download FFProbe'):
                    log('Download and install FFMpeg', xbmc.LOGNOTICE)
                    req = requests.get(self.ffmpeg_url, stream=True)
                    req.raise_for_status()

                    if self.download(req, 'Download FFMpeg'):
                        OSD.ok('{} - Addon Environment'.format(addon_name), 'Setup Complete.')
                        self.isInstalled = True

                if not self.isInstalled:
                    OSD.ok('{} - Addon Environment'.format(addon_name), 'Setup aborted by User.')

            except requests.exceptions.RequestException as e:
                log('Could not download/install ffmpeg/ffprobe: {}'.format(e), xbmc.LOGERROR)


def request_m3u(list_type, address, port, secure, params):
    try:
        req = requests.get(setServer(address, port, secure),params=params)
        req.raise_for_status()
        encoding = 'utf-8' if req.encoding is None else req.encoding
        response = req.text.encode(encoding=encoding)
        m3u = response.splitlines()
        m3u.pop(0)
        return m3u
    except requests.exceptions.RequestException as e:
        notify(addon_name, 'Could not download {} m3u: {}'.format(list_type, e), icon=xbmcgui.NOTIFICATION_ERROR)
        log('Could not download {} m3u: {}'.format(list_type, e), xbmc.LOGERROR)
    except AttributeError as e:
        log('Error while processing items in {} list: {}'.format(list_type, e), xbmc.LOGERROR)
    return []


def parse_m3u_items(line_0, line_1, list_type):
    m3u_items = line_0.split(', ')
    (extinf, tvgid, grouptitle, tvglogo) = shlex.split(m3u_items[0])
    showtime = ''
    channel = ''

    if list_type.lower() == 'cloud':
        (showtime, title, channel) = m3u_items[1].split(' | ')

    elif list_type.lower() == 'vod':
        title = m3u_items[1]

    videourl = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', line_1)

    stream_params = urlparse(videourl[0]).query
    ffmpeg_params = line_1.split(videourl[0] + '"')[1].split('pipe:1')[0]
    IsPlayable = 'true'

    if title[0:9] == '[PLANNED]':
        collection = 'Timer'
        title = title[10:]
        IsPlayable = 'false'
    #elif list_type.lower() == 'vod':
        #collection = 'Video on Demand (VoD)'
    else:
        collection = grouptitle.split('=')[1]

    return (collection,
            title.replace(' _', ':'),
            tvglogo.split('=')[1],
            videourl[0],
            grouptitle.split('=')[1],
            showtime,
            channel,
            ffmpeg_params,
            dict(parse_qsl(stream_params)),
            IsPlayable)


def create_videodict(list_types):

    videodict = dict()

    for list_type in list_types:
        log('Getting M3U from {}'.format(list_type))
        try:
            if list_type.lower() == 'cloud':
                    m3u = request_m3u(list_type,
                                  recording_address,
                                  recording_port,
                                  connection_type_cloud,
                                  params={'file': 'recordings.m3u', 'bw': bandwidth[quality], 'platform': 'hls5', 'ffmpeg': 'true', 'profile': audio_profile, 'code': protection_pin_cloud})

            elif list_type.lower() == 'vod':
                m3u = request_m3u(list_type,
                                  vod_address,
                                  vod_port,
                                  connection_type_vod,
                                  params={'file': 'ondemand.m3u', 'bw': bandwidth[quality],'platform': 'hls5', 'ffmpeg': 'true', 'profile': audio_profile, 'code': protection_pin_vod})

            else:
                m3u = []

            for i in range(0, len(m3u), 2):
                (collection, name, thumb, video_url, group, showtime,
                 channel, ffmpeg_params, streamparams, IsPlayable) = parse_m3u_items(m3u[i], m3u[i + 1], list_type)

                if collection not in videodict.keys(): videodict.update({collection: list()})
                videodict[collection].append(dict({'name': name,
                                                   'thumb': thumb,
                                                   'group': group,
                                                   'video': video_url,
                                                   'showtime': showtime,
                                                   'channel': channel,
                                                   'list_type': list_type,
                                                   'ffmpeg_params': ffmpeg_params,
                                                   'streamparams': streamparams,
                                                   'isplayable': IsPlayable}))

        except (TypeError, AttributeError) as e:
            log('Error while processing items in recording list: {}'.format(e), xbmc.LOGERROR)
            return False

    # log('Retrieved Content {}: '.format(videodict))
    return videodict

def get_url(**kwargs):
    """
    Create a URL for calling the plugin recursively from the given set of keyword arguments.
    :param kwargs: "argument=value" pairs
    :type kwargs: dict
    :return: plugin call URL
    :rtype: str
    """
    return '{0}?{1}'.format(_url, urlencode(kwargs))


def get_categories():
    """
    Get the list of video categories.
    Here you can insert some parsing code that retrieves
    the list of video categories (e.g. 'Movies', 'TV-shows', 'Documentaries' etc.)
    from some site or server.
    .. note:: Consider using `generator functions <https://wiki.python.org/moin/Generators>`_
        instead of returning lists.
    :return: The list of video categories
    :rtype: types.GeneratorType
    """
    return tr_videos.iterkeys()


def get_videos(category):
    """
    Get the list of videofiles/streams.
    Here you can insert some parsing code that retrieves
    the list of video streams in the given category from some site or server.
    .. note:: Consider using `generators functions <https://wiki.python.org/moin/Generators>`_
        instead of returning lists.
    :param category: Category name
    :type category: str
    :return: the list of videos in the category
    :rtype: list
    """
    return tr_videos[category]

def create_context_url(mode, **kwargs):
    """
    Create a context menu URL for downloading and deleting video from server
    :param params: dict of video params
    :param mode: router parameter (play, delete, download....)
    :return: URL
    """
    return 'RunPlugin({})'.format(get_url(action=mode, **kwargs))


def list_categories():
    """
    Create the list of video categories in the Kodi interface.
    """
    xbmcplugin.setPluginCategory(_handle, 'My Video Collection')
    xbmcplugin.setContent(_handle, 'videos')

    categories = get_categories()

    for category in categories:
        liz = xbmcgui.ListItem(label=category)
        liz.setArt({'thumb': tr_videos[category][0]['thumb'],
                    'icon': tr_videos[category][0]['thumb'],
                    'fanart': tr_videos[category][0]['thumb']})

        liz.setInfo('video', {'title': category,
                              'genre': category,
                              'mediatype': 'video'})

        # Create a URL for a plugin recursive call.
        # Example: plugin://plugin.video.example/?action=listing&category=Animals
        url = get_url(action='listing', category=category)
        is_folder = True
        xbmcplugin.addDirectoryItem(_handle, url, liz, is_folder)

    # Add a sort method for the virtual folder items (alphabetically, ignore articles)
    xbmcplugin.addSortMethod(_handle, xbmcplugin.SORT_METHOD_LABEL_IGNORE_THE)
    xbmcplugin.endOfDirectory(_handle)


def list_videos(category):
    """
    Create the list of playable videos in the Kodi interface.
    :param category: Category name
    :type category: str
    """
    xbmcplugin.setPluginCategory(_handle, category)
    xbmcplugin.setContent(_handle, 'videos')
    videos = get_videos(category)
    for video in videos:
        liz = xbmcgui.ListItem(label=video['name'])
        liz.setArt({'thumb': video['thumb'],
                    'icon': video['thumb'],
                    'fanart': video['thumb']})

        liz.setInfo('video', {'plot': video['channel'] + '\n' + video['showtime'],
                              'genre': video['group'],
                              'mediatype': 'video'})

        if showtime_in_title == True:
            liz.setInfo('video', {'title': video['showtime'] + ' ' + video['name']})
        else:
            liz.setInfo('video', {'title': video['name']})

        # Set 'IsPlayable' property to 'true'.
        # This is mandatory for playable items!
        liz.setProperty('IsPlayable', video['isplayable'])

        # Context Menu
        context_items = list()

        if video['isplayable'] == 'true':
            if SysEnv.isSupported:
                context_items.append(('Download', create_context_url('download', video=video['video'], title=video['name'], ffmpeg_params=video['ffmpeg_params'], list_type=video['list_type'])))

        # Create a URL for a plugin call from within context menu
        # Example: plugin://script.telerising-cloudcontrol/?action=download&recording=12345678

        if video['list_type'] == 'Cloud':
            context_items.append(('Delete', create_context_url('delete', video=video['video'])))
        liz.addContextMenuItems(context_items)

        # Create a URL for a plugin recursive call.
        # Example: plugin://plugin.video.example/?action=play&video=http://www.vidsplay.com/wp-content/uploads/2017/04/crab.mp4

        url = get_url(action='play', video=video['video'])
        is_folder = False
        xbmcplugin.addDirectoryItem(_handle, url, liz, is_folder)

    # Add a sort method for the virtual folder items (alphabetically, ignore articles)
    xbmcplugin.addSortMethod(_handle, xbmcplugin.SORT_METHOD_LABEL_IGNORE_THE)
    xbmcplugin.endOfDirectory(_handle, cacheToDisc=False)


def play_video(path):
    """
    Play a video by the provided path.
    :param path: Fully-qualified video URL
    :type path: str
    """
    play_item = xbmcgui.ListItem(path=path)
    xbmcplugin.setResolvedUrl(_handle, True, listitem=play_item)

def delete_video(video):
    """
    Remove a file aka Recording from the server.
    :param download_id: unique Recording ID
    :return: True, if deleting was success else False
    """
    params = dict(parse_qsl(urlparse(video).query))
    try:
        req = requests.get(setServer(recording_address, recording_port, secure=connection_type_cloud) + '/index.m3u',params={'recording': params['recording'], 'remove': 'true', 'code': protection_pin_cloud})
        req.raise_for_status()

        if 'SUCCESS' in req.text:
            return True

    except requests.exceptions.RequestException as e:
        log('Could not delete video with id {}: {}'.format(params['recording'], e), xbmc.LOGERROR)
        return False

    log('Unexpected response from server while deleting a file: {}'.format(req.text), xbmc.LOGERROR)
    return False


def download_video(url, title, ffmpeg_params, list_type):
    title = title.decode('utf-8').replace('/','-').replace('\\','-')
    params = dict(parse_qsl(urlparse(url).query))
    if list_type.lower() == 'vod':
        download_id = params['vod']
    elif list_type.lower() == 'cloud':
        download_id = params['recording']

    print 'download_id is' + download_id

    #print setRecordingServer(recording_address, recording_port, secure=connection_type) + '/index.m3u8?recording=' + download_id + '&bw=' + bw + '&platform=hls5&profile=' + profile

    ffmpeg_bin = '"' + SysEnv.ffmpeg_executable + '"'
    ffprobe_bin = '"' + SysEnv.ffprobe_executable + '"'

    src_json = xbmc.makeLegalFilename(os.path.join(SysEnv.temp, download_id + '_src.json'))
    dest_json = xbmc.makeLegalFilename(os.path.join(SysEnv.temp, download_id + '_dest.json'))
    src_movie = xbmc.makeLegalFilename(os.path.join(SysEnv.temp, download_id + '.ts'))
    dest_movie = xbmc.makeLegalFilename(os.path.join(storage_path, title + '.ts').encode('utf-8'))

    log("Selectet ID for Download = " + list_type.lower() + ' ' + download_id, xbmc.LOGNOTICE)
    percent = 100
    pDialog = xbmcgui.DialogProgressBG()
    pDialog.create('Downloading {} {}'.format(title.encode('utf-8'), quality), '{} Prozent verbleibend'.format(percent))
    probe_duration_src = ffprobe_bin + ' -v quiet -print_format json -show_format ' + '"' + url + '"' + ' >' + ' "' + src_json + '"'
    print probe_duration_src
    subprocess.Popen(probe_duration_src, shell=True)
    xbmc.sleep(10000)
    retries = 10
    while retries > 0:
        try:
            with open(src_json, 'r') as f_src:
                xbmc.sleep(3000)
                src_status = json.load(f_src)
                src_duration = src_status["format"].get("duration")
            break
        except (IOError, KeyError, AttributeError) as e:
            xbmc.sleep(1000)
            retries -= 1
    if retries == 0:
        notify(addon_name, "Could not open Json SRC File", icon=xbmcgui.NOTIFICATION_ERROR)
        log("Could not open Json SRC File", xbmc.LOGERROR)
        pDialog.close()
    command = ffmpeg_bin + ' -y -i "' + url + '" ' + ffmpeg_params + '"' + src_movie + '"'
    print command
    log('Started Downloading ' + download_id, xbmc.LOGNOTICE)
    running_ffmpeg = [Popen(command, shell=True)]
    xbmc.sleep(10000)
    while running_ffmpeg:
        for proc in running_ffmpeg:
            retcode = proc.poll()
            if retcode is not None:  # Process finished.
                running_ffmpeg.remove(proc)
                percent = 0
                pDialog.update(100 - percent, 'Downloading ' + title.encode('utf-8') + ' ' + quality, '{} Prozent verbleibend'.format(percent))
                xbmc.sleep(1000)
                pDialog.close()
                log('finished Downloading ' + download_id, xbmc.LOGNOTICE)
                xbmc.sleep(3000)
                pDialog.close()

                ## Copy Downloaded Files to Destination
                if xbmcvfs.exists(src_movie):

                    cDialog = xbmcgui.DialogProgressBG()
                    cDialog.create('Copy ' + title.encode('utf-8') + ' to Destination', "Status is currently not supportet, please wait until finish")
                    xbmc.sleep(2000)
                    log('copy ' + src_movie + ' to Destination', xbmc.LOGNOTICE)
                    done = xbmcvfs.copy(src_movie, dest_movie)
                    cDialog.close()

                    ## Delete all old Files if the copyrprocess was successful
                    if done == True:
                        log(download_id + ' has been copied', xbmc.LOGNOTICE)
                        notify(addon_name, title.encode('utf-8') + ' has been copied', icon=xbmcgui.NOTIFICATION_INFO)
                        f_dest.close()
                        f_src.close()
                        xbmcvfs.delete(os.path.join(SysEnv.temp, download_id + '_src.json'))
                        xbmcvfs.delete(os.path.join(SysEnv.temp, download_id + '_dest.json'))
                        xbmcvfs.delete(os.path.join(SysEnv.temp, download_id + '.ts'))
                    else:
                        log(download_id + ' cannot be copied', xbmc.LOGERROR)
                        notify(addon_name, download_id + ' cannot be copied', icon=xbmcgui.NOTIFICATION_ERROR)
                        cDialog.close()
                        f_dest.close()
                        f_src.close()
                        for file in os.listdir(SysEnv.temp): xbmcvfs.delete(os.path.join(SysEnv.temp, file))
                else:
                    notify(addon_name, "Could not open " + src_movie, icon=xbmcgui.NOTIFICATION_ERROR)
                    log("Could not open " + src_movie, xbmc.LOGERROR)
                    pDialog.close()

            else:  # # Still Running
                probe_duration_dest = ffprobe_bin + ' -v quiet -print_format json -show_format ' + '"' + src_movie + '"' + ' >' + ' "' + dest_json + '"'
                subprocess.Popen(probe_duration_dest, shell=True)
                xbmc.sleep(7000)
                retries = 10
                while retries > 0:
                    try:
                        xbmc.sleep(3000)
                        with open(dest_json, 'r') as f_dest:
                            dest_status = json.load(f_dest)
                            dest_duration = dest_status["format"].get("duration")
                        break
                    except (IOError, KeyError, AttributeError) as e:
                        xbmc.sleep(7000)
                        retries -= 1
                if retries == 0:
                    notify(addon_name, "Could not open Json Dest File", icon=xbmcgui.NOTIFICATION_ERROR)
                    log("Could not open Json Dest File", xbmc.LOGERROR)
                percent = int(100) - int(dest_duration.replace('.', '')) * int(100) / int(src_duration.replace('.', ''))
                pDialog.update(100 - percent, 'Downloading ' + title.encode('utf-8') + ' ' + quality, '{} Prozent verbleibend'.format(percent))
                continue

def router(paramstring):
    """
    Router function that calls other functions
    depending on the provided paramstring
    :param paramstring: URL encoded plugin paramstring
    :type paramstring: str
    """
    log('Provided params: {}'.format(paramstring), xbmc.LOGDEBUG)
    # Parse a URL-encoded paramstring to the dictionary of
    # {<parameter>: <value>} elements
    params = dict(parse_qsl(paramstring))
    # Check the parameters passed to the plugin
    if params:
        if params['action'] == 'check':
            SysEnv.prepare()
            SysEnv.check()
            if not SysEnv.isInstalled:
                SysEnv.install_tools()
            else:
                notify(addon_name, 'Environment Tools already installed')
            if not SysEnv.isInstalled:
                log('Could not install System Environment', xbmc.LOGERROR)
                notify(addon_name, 'Could not install System Environment', icon=xbmcgui.NOTIFICATION_ERROR)
            quit()

        if params['action'] == 'listing':
            # Display the list of videos in a provided category.
            list_videos(params['category'])

        elif params['action'] == 'play':
            # Play a video from a provided URL.
            play_video(params['video'])

        elif params['action'] == 'delete':
            # Delete a video from server
            if delete_video(params['video']):
                xbmc.executebuiltin('Container.Update({})'.format(get_url()))

        elif params['action'] == 'download':
            # Download a video from server to a defined destination
            download_video(params['video'], params['title'], params['ffmpeg_params'], params['list_type'])

        else:
            # If the provided paramstring does not contain a supported action
            # we raise an exception. This helps to catch coding errors,
            # e.g. typos in action names.
            raise ValueError('Invalid paramstring: {0}!'.format(paramstring))
    else:
        # If the plugin is called from Kodi UI without any parameters,
        # display the list of video categories
        list_categories()


### START MAIN PROGRAM ###

SysEnv = SystemEnvironment()

if recording_address == '0.0.0.0':
    log('You need to setup Telerising Server first, check IP/Port', xbmc.LOGERROR)
    notify(addon_name, 'Please setup Telerising Server first', icon=xbmcgui.NOTIFICATION_ERROR)
    quit()

if enable_vod == True and vod_address  == '0.0.0.0' :
    log('You need to setup VOD Server first, check IP/Port', xbmc.LOGERROR)
    notify(addon_name, 'Please setup VOD Server first', icon=xbmcgui.NOTIFICATION_ERROR)
    quit()

_url = sys.argv[0]
_handle = int(sys.argv[1])

if __name__ == '__main__':

    SysEnv.prepare()
    SysEnv.check()

    if SysEnv.isSupported and not SysEnv.isInstalled:
        if sys.argv[2][1:] == 'action=check':
            router(sys.argv[2][1:])
        OSD.ok('{} - Missing Environment'.format(addon_name), 'You have to install some missing Tools first before using this Plugin.')
        xbmc.executebuiltin('RunPlugin("plugin://plugin.video.telerising-cloudcontrol/?action=check")')
        quit()
    else:
        if enable_vod and not enable_cloud:
            servers = ['VOD']
            servers.append('VOD')
        elif enable_cloud and not enable_vod:
            servers = ['Cloud']
            servers.append('Cloud')
        elif enable_vod and enable_cloud:
            servers = ['Cloud']
            servers.append('VOD')
        tr_videos = create_videodict(servers)
        router(sys.argv[2][1:])