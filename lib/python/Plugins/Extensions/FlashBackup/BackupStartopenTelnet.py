from Screens.Screen import Screen
from Screens.MessageBox import MessageBox
from Screens.Console import Console
from Components.Console import Console as eConsole
from Components.ActionMap import ActionMap
from Components.Sources.StaticText import StaticText
from Components.config import ConfigSubsection, ConfigText, ConfigLocations, getConfigListEntry, configfile
from Components.config import config
from Components.ScrollLabel import ScrollLabel
from enigma import getDesktop
from Tools.Directories import *
from time import gmtime, strftime, localtime, time
from datetime import date
from time import time
from os import path, stat, rename, remove, makedirs
from os import environ
import os
import gettext
from Components.Language import language

def localeInit():
	lang = language.getLanguage()
	environ["LANGUAGE"] = lang[:2]
	gettext.bindtextdomain("enigma2", resolveFilename(SCOPE_LANGUAGE))
	gettext.textdomain("enigma2")
	gettext.bindtextdomain("FlashBackup", "%s%s" % (resolveFilename(SCOPE_PLUGINS), "Extensions/FlashBackup/locale/"))

def _(txt):
	t = gettext.dgettext("FlashBackup", txt)
	if t == txt:
		t = gettext.gettext(txt)
	return t

localeInit()
language.addCallback(localeInit)

def getBackupPath():
    backuppath = config.plugins.FlashBackup.backuplocation.value 
    if backuppath.endswith('/'):
        return backuppath + 'backup'
    else:
        return backuppath + '/backup'

class makeFlashBackupTelnet(Screen):
    try:
        sz_w = getDesktop(0).size().width()
    except:
        sz_w = 720
    if sz_w == 1280:
        skin = """
        <screen name="makeFlashBackupTelnet" position="center,center" size="1280,720" title="Backup is running" flags="wfNoBorder">
        <widget name="text" position="80,80" size="1020,560" zPosition="10" font="Console;22" />
        </screen>"""

    elif sz_w == 1024:
        skin = """
        <screen name="makeFlashBackupTelnet" position="center,center" size="1024,576" title="Backup is running">
        <widget name="text" position="80,80" size="550,400" font="Console;14" />
        </screen>"""

    elif sz_w == 1920:
        skin = """
        <screen name="makeFlashBackupTelnet" position="center,center" size="1920,1080" title="Backup is running" flags="wfNoBorder">
        <widget name="text" position="105,65" size="1720,960" zPosition="10" font="Console; 35" />
        </screen>"""

    else:
        skin = """
        <screen position="135,144" size="350,310" title="Backup is running" >
        <widget name="text" position="0,0" size="550,400" font="Console;14" />
        </screen>"""

    def __init__(self, session, runBackup = False):
        Screen.__init__(self, session)
        self.session = session
        self.startTime = None
        self.runBackup = runBackup
        self["text"] = ScrollLabel("")
        self["actions"] = ActionMap(["WizardActions", "DirectionActions"],
        {
            "ok": self.cancel,
            "back": self.cancel,
            "up": self["text"].pageUp,
            "down": self["text"].pageDown
        }, -1)
        self.finished_createFolder = None
        self.backuppath = getBackupPath()
        self.onLayoutFinish.append(self.layoutFinished)
        if self.runBackup:
            self.onShown.append(self.doBackup)

    def layoutFinished(self):
        self.setWindowTitle()

    def setWindowTitle(self):
        self.setTitle(_("Backup in Debug modus is running..."))

    def doBackup(self):
        if environ["LANGUAGE"] == "de":
            self.flaschCom = "sh -x /usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/build-nfi-image_de.sh"
        else:
            if environ["LANGUAGE"] == "de_DE":
                self.flaschCom = "sh -x /usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/build-nfi-image_de.sh"
            else:
                self.flaschCom = "sh -x /usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/build-nfi-image_en.sh"

        self.flaschCom += ' ' + config.plugins.FlashBackup.backuplocation.value

        if config.plugins.FlashBackup.swap.value == "auto":
            self.flaschCom += ' ' + config.plugins.FlashBackup.swapsize.value
        else:
            self.flaschCom += ' ' + config.plugins.FlashBackup.swap.value

        self.flaschCom += ' ' + config.plugins.FlashBackup.debug.value

        self.flaschCom += ' ' + config.plugins.FlashBackup.log.value

        self.prompt(self.flaschCom)

    def prompt(self, com):
        configfile.save()
        self.startTime = time()
        try:
            if (path.exists(self.backuppath) == False):
                    makedirs(self.backuppath)
            if self.finished_createFolder:
                self.session.openWithCallback(self.finished_createFolder, Console, title = _("Backup in Debug modus is running..."), cmdlist = ["%s" % com],finishedCallback = self.backupFinished, closeOnSuccess = False)
            else:
                self.session.open(Console, title = _("Backup in Debug modus is running..."), cmdlist = ["%s" % com],finishedCallback = self.backupFinished, closeOnSuccess = False)

        except OSError:
            if self.finished_createFolder:
                    self.session.openWithCallback(self.finished_createFolder, MessageBox, _("Sorry your backup destination is not writeable.\nPlease choose an other one."), MessageBox.TYPE_ERROR, timeout = 10 )
            else:
                    self.session.openWithCallback(self.backupError, MessageBox, _("Sorry your backup destination is not writeable.\nPlease choose an other one."), MessageBox.TYPE_ERROR, timeout = 10 )

    def backupFinished(self):
            seconds = int(time() - self.startTime)
            minutes = 0
            while seconds > 60:
                seconds -= 60
                minutes += 1
            if minutes > 1:
                self.session.open(MessageBox, "\n%s%s:%d"%(_("FlashBackup successfully done.\nFlashBackup Debug-Log createt in /tmp/ as file FlashBackupLog.\nBackupduration (in minutes): "),minutes, seconds), MessageBox.TYPE_INFO )
                self.close()
            else:
                self.session.open(MessageBox, _("FlashBackup failed.\nFlashBackup Debug-Log createt in /tmp/ as file FlashBackupLog."), MessageBox.TYPE_ERROR )
                self.close()

    def cancel(self):
        self.close()