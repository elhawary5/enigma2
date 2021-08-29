from Screens.Screen import Screen
from Screens.MessageBox import MessageBox
from Screens.InputBox import InputBox
from Screens.HelpMenu import HelpableScreen
from Components.Sources.StaticText import StaticText
from Tools.Directories import *
from Components.config import ConfigSubsection, ConfigText, ConfigLocations, getConfigListEntry, configfile
from Components.config import config
import os
from Components.ActionMap import NumberActionMap, HelpableActionMap
from Components.Label import Label
from Components.Pixmap import Pixmap
from Components.Button import Button
from Components.FileList import FileList
from Components.MenuList import MenuList
from enigma import getDesktop
from os import environ
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

class FlashBackupBackupLocation(Screen, HelpableScreen):
    try:
        sz_w = getDesktop(0).size().width()
    except:
        sz_w = 720
    if sz_w == 1280:
        skin = """ 
    <screen name="FlashBackupBackupLocation" position="center,center" title=" " size="1280,720" flags="wfNoBorder">
            <widget source="Title" render="Label" position="80,80" size="750,30" zPosition="3" font="Regular;26" transparent="1"/>
            <widget source="session.VideoPicture" render="Pig"  position="80,120" size="380,215" zPosition="3" backgroundColor="#ff000000"/>
            <widget source="text" render="Label" position="80,470" size="260,25" font="Regular;22" transparent="1" zPosition="1" foregroundColor="#ffffff" />
            <ePixmap position="500,596" size="35,25" pixmap="%s" transparent="1" alphatest="blend" />
            <widget source="oktext" render="Label" position="540,596" size="660,25" font="Regular;22" transparent="1" zPosition="1" halign="left" valign="center" />
            <widget name="target" position="80,500" size="540,22" valign="left" font="Regular;22" transparent="1" />
            <widget name="filelist" position="550,120" size="610,503" zPosition="1" scrollbarMode="showOnDemand" selectionDisabled="1" transparent="1" />
            <widget name="red" position="80,600" zPosition="1" size="15,16" pixmap="skin_default/buttons/button_red.png" transparent="1" alphatest="on" />
            <widget name="green" position="290,600" zPosition="1" size="15,16" pixmap="skin_default/buttons/button_green.png" transparent="1" alphatest="on" />
            <widget name="key_red" position="100,596" zPosition="2" size="140,25" halign="left" font="Regular;22" transparent="1" />               
            <widget name="key_green" position="310,596" zPosition="2" size="140,25" halign="left" font="Regular;22" transparent="1" />
        </screen>""" % ( resolveFilename(SCOPE_PLUGINS, "Extensions/FlashBackup/key_ok.png" ))
        
    elif sz_w == 1024:
        skin = """
    <screen name="FlashBackupBackupLocation" position="center,center" title=" " size="1024,576" flags="wfNoBorder">
            <widget source="Title" render="Label" position="80,80" size="750,30" zPosition="3" font="Regular;26" transparent="1"/>
            <widget source="session.VideoPicture" render="Pig"  position="80,120" size="380,215" zPosition="3" backgroundColor="#ff000000"/>
            <ePixmap position="500,496" size="35,25" pixmap="%s" transparent="1" alphatest="blend" />
            <widget source="oktext" render="Label" position="540,496" size="500,25" font="Regular;22" transparent="1" zPosition="1" halign="left" valign="center" />
            <widget source="text" render="Label" position="80,360" size="260,25" font="Regular;22" transparent="1" zPosition="1" foregroundColor="#ffffff" />
            <widget name="target" position="80,390" size="540,22" valign="left" font="Regular;22" transparent="1" />
            <widget name="filelist" position="550,120" size="394,380" zPosition="1" scrollbarMode="showOnDemand" selectionDisabled="1" transparent="1" />
            <widget name="red" position="80,500" zPosition="1" size="15,16" pixmap="skin_default/buttons/button_red.png" transparent="1" alphatest="on" />
            <widget name="green" position="290,500" zPosition="1" size="15,16" pixmap="skin_default/buttons/button_green.png" transparent="1" alphatest="on" />
            <widget name="key_red" position="100,496" zPosition="2" size="140,25" halign="left" font="Regular;22" transparent="1" />               
            <widget name="key_green" position="310,496" zPosition="2" size="140,25" halign="left" font="Regular;22" transparent="1" />
        </screen>""" % ( resolveFilename(SCOPE_PLUGINS, "Extensions/FlashBackup/key_ok.png" ))
        
    elif sz_w == 1920:
        skin = """
    <screen name="FlashBackupBackupLocation" position="center,center" title=" " size="1920,1080" flags="wfNoBorder">
            <widget source="Title" render="Label" position="80,25" size="1760,80" zPosition="3" font="Regular; 40" transparent="1" halign="center" />
            <widget source="session.VideoPicture" render="Pig" position="80,120" size="880,615" zPosition="3" backgroundColor="#ff000000" />
            <widget source="text" render="Label" position="80,775" size="880,50" font="Regular;22" transparent="1" zPosition="1" foregroundColor="#ffffff" />
            <ePixmap position="755,955" size="80,80" pixmap="%s" transparent="1" alphatest="blend" />
            <widget source="oktext" render="Label" position="845,973" size="1050,40" font="Regular; 35" transparent="1" zPosition="1" halign="left" valign="center" />
            <widget name="target" position="80,835" size="880,50" valign="left" font="Regular; 35" transparent="1" />
            <widget name="filelist" position="980,120" size="860,830" zPosition="1" scrollbarMode="showOnDemand" selectionDisabled="1" transparent="1" />
            <widget name="red" position="80,985" zPosition="1" size="15,16" pixmap="skin_default/buttons/button_red.png" transparent="1" alphatest="on" />
            <widget name="green" position="410,985" zPosition="1" size="15,16" pixmap="skin_default/buttons/button_green.png" transparent="1" alphatest="on" />
            <widget name="key_red" position="105,973" zPosition="2" size="300,40" halign="left" font="Regular; 35" transparent="1" />               
            <widget name="key_green" position="435,973" zPosition="2" size="300,40" halign="left" font="Regular; 35" transparent="1" />
        </screen>""" % ( resolveFilename(SCOPE_PLUGINS, "Extensions/FlashBackup/key_ok2.png" ))
        
    else:
        skin = """
    <screen name="FlashBackupBackupLocation" position="center,center" title="Choose backup location" size="540,460" >
            <widget source="text" render="Label" position="0,23" size="540,25" font="Regular;22" transparent="1" zPosition="1" foregroundColor="#ffffff" />
            <widget name="target" position="0,50" size="540,25" valign="center" font="Regular;22" />
            <widget name="filelist" position="0,80" zPosition="1" size="540,210" scrollbarMode="showOnDemand" selectionDisabled="1" />
            <ePixmap position="300,415" size="35,25" pixmap="%s" transparent="1" alphatest="blend" />
            <widget name="red" position="0,415" zPosition="1" size="135,40" pixmap="skin_default/buttons/red.png" transparent="1" alphatest="on" />
            <widget name="key_red" position="0,415" zPosition="2" size="135,40" halign="center" valign="center" font="Regular;22" transparent="1" shadowColor="black" shadowOffset="-1,-1" />   
            <widget name="green" position="135,415" zPosition="1" size="135,40" pixmap="skin_default/buttons/green.png" transparent="1" alphatest="on" />
            <widget name="key_green" position="135,415" zPosition="2" size="135,40" halign="center" valign="center" font="Regular;22" transparent="1" shadowColor="black" shadowOffset="-1,-1" />
        </screen>""" % ( resolveFilename(SCOPE_PLUGINS, "Extensions/FlashBackup/key_ok.png" ))
        

    def __init__(self, session, text = "", filename = "", currDir = None, location = None, userMode = False, windowTitle = _("Choose backup location"), minFree = None, autoAdd = False, editDir = False, inhibitDirs = [], inhibitMounts = []):
        Screen.__init__(self, session)
        HelpableScreen.__init__(self)

        self["text"] = StaticText(_("Selected memory place:"))
        self["oktext"] = StaticText(_("for select sublist!"))
        self.text = text
        self.filename = filename
        self.minFree = minFree
        self.reallocation = location
        self.location = location and location.value[:] or []
        self.userMode = userMode
        self.autoAdd = autoAdd
        self.editDir = editDir
        self.inhibitDirs = inhibitDirs
        self.inhibitMounts = inhibitMounts
        inhibitDirs = ["/bin", "/boot", "/dev", "/lib", "/proc", "/sbin", "/sys", "/mnt", "/var", "/home", "/tmp", "/srv", "/etc", "/share", "/usr", "/ba", "/MB_Images"]
        inhibitMounts = ["/mnt", "/ba", "/MB_Images"]
        self["filelist"] = FileList(currDir, showDirectories = True, showFiles = False, inhibitMounts = inhibitMounts, inhibitDirs = inhibitDirs)

        self["key_green"] = Button(_("Save"))
        self["key_red"] = Button(_("Close"))

        self["green"] = Pixmap()
        self["red"] = Pixmap()

        self["target"] = Label()

        if self.userMode:
            self.usermodeOn()

        class BackupLocationActionMap(HelpableActionMap):
            def __init__(self, parent, context, actions = { }, prio=0):
                HelpableActionMap.__init__(self, parent, context, actions, prio)

        self["WizardActions"] = BackupLocationActionMap(self, "WizardActions",
            {
                "left": self.left,
                "right": self.right,
                "up": self.up,
                "down": self.down,
                "ok": (self.ok, _("Select")),
                "back": (self.cancel, _("Cancel")),
            }, -2)

        self["ColorActions"] = BackupLocationActionMap(self, "ColorActions",
            {
                "red": self.cancel,
                "green": self.select,
            }, -2)
        self.setWindowTitle()
        self.onLayoutFinish.append(self.switchToFileListOnStart)

    def setWindowTitle(self):
        self.setTitle(_("Choose backup location"))

    def switchToFileListOnStart(self):
        if self.reallocation and self.reallocation.value:
            self.currList = "filelist"
            currDir = self["filelist"].current_directory
            if currDir in self.location:
                self["filelist"].moveToIndex(self.location.index(currDir))
        else:
            self.switchToFileList()

    def switchToFileList(self):
        if not self.userMode:
            self.currList = "filelist"
            self["filelist"].selectionEnabled(1)
            self.updateTarget()

    def up(self):
        self[self.currList].up()
        self.updateTarget()

    def down(self):
        self[self.currList].down()
        self.updateTarget()

    def left(self):
        self[self.currList].pageUp()
        self.updateTarget()

    def right(self):
        self[self.currList].pageDown()
        self.updateTarget()

    def ok(self):
        if self.currList == "filelist":
            if self["filelist"].canDescent():
                self["filelist"].descent()
                self.updateTarget()

    def updateTarget(self):
        currFolder = self.getPreferredFolder()
        if currFolder is not None:
            self["target"].setText(''.join((currFolder, self.filename)))
        else:
            self["target"].setText(_("Invalid Location"))
 
    def cancel(self):
        self.close(None)

    def getPreferredFolder(self):
        if self.currList == "filelist":
            return self["filelist"].getSelection()[0]

    def saveSelection(self, ret):
        if ret:
            ret = ''.join((self.getPreferredFolder(), self.filename))
        config.plugins.FlashBackup.backuplocation.value = ret
        config.plugins.FlashBackup.backuplocation.save()
        config.plugins.FlashBackup.save()
        config.save()
        self.close(None)

    def select(self):
        currentFolder = self.getPreferredFolder()
        if currentFolder is not None:
            if self.minFree is not None:
                try:
                    s = os.statvfs(currentFolder)
                    if (s.f_bavail * s.f_bsize) / 314572800 > self.minFree:
                        return self.saveSelection(True)
                except OSError:
                    pass

                self.session.openWithCallback(self.saveSelection, MessageBox, _("There might not be enough Space on the selected Partition.\nDo you really want to continue?"), type = MessageBox.TYPE_YESNO )
            else:
                self.saveSelection(True)