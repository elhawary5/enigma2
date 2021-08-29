#!/bin/sh
#Modified By RAED
#07.05.2013 for OE1.6 & OE2.0
#Updated 05.05.2015 Fixed Some Bugs 
##############?nderbare Variablen############
VSNDMAN=$4 #manuelle SecondStageLoader Version, wird hier ein Wert eingegeben, dann wird dieser Wert immer benutzt! Unabh?ngig der Ermittlungen über ipkg-list oder IHAD
#############################################
DIRECTORY=`echo "$1" | sed -e "s/\/*$/\1/"`
#################Exit cleanup################

for sig in 0 1 2 3 6 14 15; do
	trap "cleanup $sig" $sig
done

#echo "$1 $2 $3 $4"
cleanup() {
	EXIT_CODE=$?
	if [ $EXIT_CODE = 130 ] ; then
		echo "**************************"
		echo "*     Aborted by User    *"
		echo "**************************"	  
	fi
	
	umount $MOUNTPOINT/bi/boot  2> /dev/null
	umount $MOUNTPOINT/bi/root  2> /dev/null 
	
	if [ -f /boot/autoexec.bat ]; then
       touch /boot/dummy 2> /dev/null
    fi
	#External Flash
    if [ -f /boot/dummpy ]; then
	if [ -f /media/ba/ba.sh ]; then
	if [ -f /sbin/bainit ]; then
	    rm -rf /sbin/init  2> /dev/null
        ln -sfn /media/ba /ba  2> /dev/null
        ln -sfn /media/ba/MB_Images /MB_Images  2> /dev/null
        ln -sfn /media/ba/BarryAllen /usr/lib/enigma2/python/Plugins/Extensions/BarryAllen  2> /dev/null
        ln -sfn /media/ba/ba.sh /home/root/ba.sh  2> /dev/null
        ln -sfn /media/ba/ba.sh /usr/sbin/ba.sh  2> /dev/null
        ln -sfn /sbin/bainit /sbin/init  2> /dev/null
        mv $MOUNTPOINT/bi/bainfo /.bainfo  2> /dev/null
        mv $MOUNTPOINT/bi/bainfo.tmp /.bainfo.tmp  2> /dev/null
     fi
	 fi
	 fi
	 #Internal Flash
	 if [ ! -f /boot/dummpy ]; then
	 if [ ! -f /media/ba/ba.sh ]; then
         echo ""
     elif [ -f /media/ba/ba.sh ]; then
	 if [ -f /sbin/bainit ]; then
	    rm -rf /sbin/init  2> /dev/null
        ln -sfn /media/ba /ba  2> /dev/null
        ln -sfn /media/ba/MB_Images /MB_Images  2> /dev/null
        ln -sfn /media/ba/BarryAllen /usr/lib/enigma2/python/Plugins/Extensions/BarryAllen  2> /dev/null
        ln -sfn /media/ba/ba.sh /home/root/ba.sh  2> /dev/null
        ln -sfn /media/ba/ba.sh /usr/sbin/ba.sh  2> /dev/null
        ln -sfn /sbin/bainit /sbin/init  2> /dev/null
        mv $MOUNTPOINT/bi/bainfo /.bainfo  2> /dev/null
        mv $MOUNTPOINT/bi/bainfo.tmp /.bainfo.tmp  2> /dev/null
     fi
	 fi
	 fi
	 rm -rf /boot/dummpy 2> /dev/null

	 if [ -s "$SWAPDIR"/swapfile_backup ] ; then
		swapoff $SWAPDIR/swapfile_backup 2> /dev/null
		rm -rf $SWAPDIR/swapfile_backup
		echo " "
		echo "----------------------------------------"
		echo "deactivating an deleting swapfile"
		echo "----------------------------------------"
     fi
	 
	if [ -e /etc/init.d/openvpn ]; then
       /etc/init.d/openvpn start >> $RAEDTMP 2>&1
       echo "Start openvpn" >> $RAEDTMP 2>&1 
    fi
	 
    rm -rf $DIRECTORY/boot.img > /dev/null 2>&1
    rm -rf $DIRECTORY/boot.ubi > /dev/null 2>&1
    rm -rf $DIRECTORY/root.img > /dev/null 2>&1
    rm -rf $DIRECTORY/root.ubi > /dev/null 2>&1	

	echo " "
	echo "exit "$EXIT_CODE
	trap - 0
	exit $EXIT_CODE
}

if [ -e /dev/mtdblock2 ]; then
	MTDBOOT=/dev/mtdblock2
	MTDROOT=/dev/mtdblock3
elif [ -e /dev/mtdblock/2 ]; then
	MTDBOOT=/dev/mtdblock/2
	MTDROOT=/dev/mtdblock/3
else
	echo "No mtdblocks found"
	exit 1
fi
SWAPDIR=$DIRECTORY
SWAPSIZE=$2
if [ "$SWAPSIZE" -lt 1 ]; then
SWAPSIZE=128
fi

if [ -e /dev/mtd/1 ]; then
   $Nanddump --noecc --omitoob --bb=skipbad --truncate --file /dev/null /dev/mtd/1 > /tmp/.raedtmp 2>&1
else
   $Nanddump --noecc --omitoob --bb=skipbad --truncate --file /dev/null /dev/mtd1 > /tmp/.raedtmp 2>&1
fi
RAEDTMP=/tmp/.raedtmp
HEADER=`head -n 1 $RAEDTMP`
BLOCKSIZE=`echo $HEADER | cut -d"," -f 2 | cut -d" " -f 4`

OPTIONS=" -e 0x4000 -n -l"
UBIOPTIONS="-m 512 -e 15KiB -c 3735 -F"
UBINIZE_OPTIONS="-m 512 -p 16KiB -s 512"
UBINIZECFG="/tmp/ubinize.cfg"
UBICOMPRESSION="zlib"
if grep -qs dm500hd /proc/stb/info/model ; then
   BOXTYPE=dm500hd
   BUILDOPTIONS=" --brcmnand -a dm500hd -e 0x4000 -f 0x4000000 -s 512 -b 0x40000:$DIRECTORY/secondstage.bin -d 0x3C0000:$DIRECTORY/boot.img -d 0x3C00000:$DIRECTORY/root.img"
fi
if grep -qs dm500hdv2 /proc/stb/info/model ; then
   BOXTYPE=dm500hdv2
   BUILDOPTIONS="-a dm500hdv2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
   UBIBUILDOPTIONS="-a dm500hdv2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
   OPTIONS=" -e 0x20000 -n -l"
   UBIOPTIONS="-m 2048 -e 124KiB -c 3320 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 2048"
   UBINIZE_VOLSIZE="402MiB"
   UBINIZE_DATAVOLSIZE="569MiB"
   UBICOMPRESSION="favor_lzo"
   CACHED="-c"
fi
if grep -qs dm800 /proc/stb/info/model ; then
   BOXTYPE=dm800
   BUILDOPTIONS=" --brcmnand -a dm800 -e 0x4000 -f 0x4000000 -s 512 -b 0x40000:$DIRECTORY/secondstage.bin -d 0x3C0000:$DIRECTORY/boot.img -d 0x3C00000:$DIRECTORY/root.img"
fi
if grep -qs dm800se /proc/stb/info/model ; then
   BOXTYPE=dm800se
   BUILDOPTIONS=" --brcmnand -a dm800se -e 0x4000 -f 0x4000000 -s 512 -b 0x40000:$DIRECTORY/secondstage.bin -d 0x3C0000:$DIRECTORY/boot.img -d 0x3C00000:$DIRECTORY/root.img"
fi
if grep -qs dm800sev2 /proc/stb/info/model ; then
   BOXTYPE=dm800sev2
   BUILDOPTIONS="-a dm800sev2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
   UBIBUILDOPTIONS="-a dm800sev2 --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
   OPTIONS=" -e 0x20000 -n -l"
   UBIOPTIONS="-m 2048 -e 124KiB -c 3320 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 2048"
   UBINIZE_VOLSIZE="402MiB"
   UBINIZE_DATAVOLSIZE="569MiB"
   UBICOMPRESSION="favor_lzo"
   CACHED="-c"
fi
if grep -qs dm8000 /proc/stb/info/model ; then
   BOXTYPE=dm8000
   BUILDOPTIONS="-a dm8000 -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
   OPTIONS=" -e 0x20000 -n -l"
   UBIOPTIONS="-m 2048 -e 126KiB -c 1961 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 512"
   UBICOMPRESSION="favor_lzo"
fi
if [ -e /proc/stb/info/vumodel -o -e /proc/stb/info/boxtype ]; then
   BOXTYPE=guest
   UBIOPTIONS="-m 2048 -e 124KiB -c 4096 -F"
   UBINIZE_OPTIONS="-m 2048 -p 128KiB"
   CACHED="-c"
fi
UBIBUILDOPTIONS=$BUILDOPTIONS
if grep -qs dm7020hd /proc/stb/info/model ; then
   BOXTYPE=dm7020hd
   if [ $BLOCKSIZE -eq 4096 ]; then
      BUILDOPTIONS="-a dm7020hd --brcmnand -e 0x40000 -f 0x10000000 -s 4096 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
      UBIBUILDOPTIONS="-a dm7020hd --brcmnand -e 0x40000 -f 0x10000000 -s 4096 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
      OPTIONS=" -e 0x40000 -n -l"
      UBIOPTIONS="-m 4096 -e 248KiB -c 1640 -F"
      UBINIZE_OPTIONS="-m 4096 -p 256KiB -s 4096"
      UBINIZE_VOLSIZE="397MiB"
      UBINIZE_DATAVOLSIZE="574MiB"
   else
      BUILDOPTIONS="-a dm7020hd --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0xF800000:$DIRECTORY/root.img"
      UBIBUILDOPTIONS="-a dm7020hd --brcmnand -e 0x20000 -f 0x10000000 -s 2048 -b 0x100000:$DIRECTORY/secondstage.bin -d 0x700000:$DIRECTORY/boot.img -d 0x3F800000:$DIRECTORY/root.img"
      OPTIONS=" -e 0x20000 -n -l"
      UBIOPTIONS="-m 2048 -e 124KiB -c 3320 -F"
      UBINIZE_OPTIONS="-m 2048 -p 128KiB -s 2048"
      UBINIZE_VOLSIZE="402MiB"
      UBINIZE_DATAVOLSIZE="569MiB"
   fi
   UBICOMPRESSION="favor_lzo"
   CACHED="-c"
fi

echo " "
echo "***********************"
echo "* "$BOXTYPE " FOUND *"
echo "***********************"
echo " "

echo "---------------------------------------------------------------"
#listdummy=ls "$DIRECTORY"/blabla 2> /dev/null
#FREESIZE=`df -m "$DIRECTORY" | tr -s " " | tail -n1 | cut -d' ' -f4 | sed "s/Available/0/`
#if ! [ "$FREESIZE" -gt "128" ]; then
#	echo ""$DIRECTORY" can't be used for FlashBackup because there is too less space left on the device!"
#	echo "trying to find an alternative medium"
#echo "---------------------------------------------------------------"
#	DEVICE=`df -m | grep / | awk '{print $4 " " $1}' | sort -n | cut -d ' ' -f2 | tail -n1`
#	DIRECTORY=`mount | grep $DEVICE | sort -n | cut -d ' ' -f3`
#	FREESIZE=`df -m | grep / | awk '{print $4 " " $1}' | sort -n | cut -d ' ' -f1 | tail -n1`
#	if [ "$FREESIZE" -lt "128" ]; then
#		echo "No laternative medium could be found"
#		echo "probably no correct medium is mounted"
#		echo "---------------------------------------------------------------"
#		exit 1
#	else
#		echo "Alternative medium=$DIRECTORY"
#echo "---------------------------------------------------------------"
#	fi
#fi

############# Check Swap ###############
#echo "check if 128MB are free in $DIRECTORY"
#if [ "$FREESIZE" -lt "128" ]; then
#		echo "Free memory space="$FREESIZE"MB,aborting FlashBackup"
#		echo "---------------------------------------------------------------"
#		exit 1
#	else
#		echo "Free memory space="$FREESIZE"MB=OK"
#	if [ $DEBUG = "debugon" ] 2> /dev/null ; then
#		SWAPDIR=$DIRECTORY
#	else
#		SWAPDIR=$DIRECTORY
#	fi
#	echo "---------------------------------------------------------------"
#fi

############ Name of Flash-Image ###########
if [ $BOXTYPE = "dm8000" -o $BOXTYPE = "dm800se" -o $BOXTYPE = "dm800sev2" -o $BOXTYPE = "dm800" -o $BOXTYPE = "dm7020hd" -o $BOXTYPE = "dm500hd" -o $BOXTYPE = "dm500hdv2" ] ;then
	echo "Trying to identify flash-image"

if grep -qs "comment=iCVS Image" /etc/image-version ; then
		IMAGEINFO=iCVS
		LINK="Link: http://www.ihad.tv"
		echo "$IMAGEINFO found"
	elif grep -qs "\<oe@dreamboxupdate.com\>" /etc/image-version ; then
		IMAGEINFO=CVS
		LINK="Link: http://www.dreamboxupdate.com"
		echo "$IMAGEINFO found"
	elif grep -qs "url=http:\/\/www.i-have-a-dreambox.com" /etc/image-version ; then
#		IMAGEINFO=Gemini-`cat /etc/image-version | grep version | cut -d'2' -f1 | sed 's/.*\(.\{3\}\)$/\1/' | cut -b 1`.`cat /etc/image-version | grep version | cut -d'2' -f1 | sed 's/.*\(.\{2\}\)$/\1/'`
		IMAGEINFO=Gemini-`cat /etc/issue | cut -d " " -f2 | cut -d "." -f1-2 | head -n 1` #sed 's/.*\(.\{2\}\)$/\1/'` # sed Befehl schnappt sich die letzten 3 Zeichen
		LINK="Link: http://www.ihad.tv"
		echo "$IMAGEINFO found"
	elif grep -qs "OoZooN" /etc/image-version ; then
		IMAGEINFO=OoZooN
		LINK="Link: http://www.oozoon.de/progs/images/$BOXTYPE"
		echo "$IMAGEINFO found"
	elif grep -qs "newnigma2" /etc/image-version ; then
		IMAGEINFO=Newnigma-`cat /etc/image-version | grep catalog | sed 's/.*\(.\{3\}\)$/\1/'`
		echo "$IMAGEINFO found"
		LINK="Link: http://www.newnigma2.to/"
		#if [ `cat /etc/image-version | grep version | sed 's/.*\(.\{8\}\)$/\1/'` -gt "20100426" ] ; then
		#	echo "Since version 2.8 20100427 it's not wanted by the Newnigma2 Team to create a backup anymore"
		#	echo "Hasta la vista, baby"
		#	exit 1
		#fi
	elif grep -qs "LT" /etc/image-version ; then
		IMAGEINFO=LT-Team
		LINK="Link: http://www.lt-forums.org/"
		echo "$IMAGEINFO found"
	elif grep -qs "OpenBlackhole" /etc/image-version ; then
		IMAGEINFO=OpenBlackhole
		LINK="Link: http://http://www.openblackhole.com/"
		echo "$IMAGEINFO found"
	elif grep -qs "MerlinDownloadBrowser" /usr/lib/enigma2/python/Plugins/Extensions/AddOnManager/plugin.py ; then
		IMAGEINFO=Merlin3
		LINK="Link: http://www.dreambox-tools.info/"
		echo "$IMAGEINFO found"
	elif grep -qs "openpli" /etc/issue ; then
		IMAGEINFO=OpenPLI
		LINK="Link: http://www.pli-images.org/"
		echo "$IMAGEINFO found"
	elif grep -qs "BlackHole" /etc/issue ; then
		IMAGEINFO=BlackHole
		LINK="Link: http://www.vuplus.com/"
		echo "$IMAGEINFO found"
	elif grep -qs "TSimage" /etc/image-version ; then
		IMAGEINFO=TSimage
		LINK="Link: http://www.tunisia-sat.com/"
		echo "$IMAGEINFO found"
	elif grep -qs "openATV" /etc/image-version ; then
		IMAGEINFO=OpenATV
		LINK="Link: http://www.opena.tv/"
		echo "$IMAGEINFO found"
	elif grep -qs "Persian Empire" /etc/image-version ; then
		IMAGEINFO=PE-Persian Empire
		LINK="Link: http://e2pe.com"
		echo "$IMAGEINFO found"
	elif grep -qs "dreamelite" /etc/image-version ; then
		IMAGEINFO=Dream Elite
		LINK="http://www.dream-elite.net"
		echo "$IMAGEINFO found"
	elif grep -qs "ItalySat" /etc/image-version ; then
		IMAGEINFO=ItalySat
		LINK="http://www.italysat.it/"
		echo "$IMAGEINFO found"
	elif grep -qs "SIFTeam" /etc/image-version ; then
		IMAGEINFO=SIFTeam
		LINK="http://forum.sifteam.eu"
		echo "$IMAGEINFO found"
	else
		IMAGEINFO=FlashBackup
		LINK="Link: http://sources.dreamboxupdate.com/opendreambox/1.6/$BOXTYPE/experimental"
		echo "Couldn't identify flash-image, using FlashBackup as backupname"
	fi
else
	IMAGEINFO=FlashBackup
	echo "Couldn't identify flash-image, using FlashBackup as backupname"
fi
	if [ -e /usr/lib/enigma2/python/Plugins/Bp/geminimain ]; then
#		IMAGEINFO=Gemini-`cat /etc/image-version | grep version | cut -d'2' -f1 | sed 's/.*\(.\{3\}\)$/\1/' | cut -b 1`.`cat /etc/image-version | grep version | cut -d'2' -f1 | sed 's/.*\(.\{2\}\)$/\1/'` # sed Befehl schnappt sich die letzten 3 Zeichen
		GP3="GP3."`cat /usr/lib/enigma2/python/Plugins/Bp/geminimain/gVersion.py | sed -e "s/^.*'\(.*\)'.*$/\1/"`"-"
		LINK="Link: http://www.ihad.tv"
		echo "$GP3 found"
fi
	echo "---------------------------------------------------------------"

DEBUG=$3
MOUNTPOINT=/tmp
BAINFO=/.bainfo
VSND=$BOXTYPE
DATE=`date +%Y-%m-%d@%H.%M.%S`
SND=$DIRECTORY/secondstage.bin
PLUGINPATH=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup
Nanddump=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/bin/nanddump
MKFS=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/bin/mkfs.jffs2
UBIFS=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/bin/mkfs.ubifs
UBINIZE=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/bin/ubinize
SUMTOOL=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/bin/sumtool
BUILDIMAGE=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/bin/buildimage
BUILDIMAGE2=/usr/lib/enigma2/python/Plugins/Extensions/FlashBackup/bin/oe2.0/buildimage
BACKUPIMAGE=$DIRECTORY/$IMAGEINFO-$DATE-SSL-$VSND.nfi

if [ ! -f $DIRECTORY/secondstage.bin ] ; then
if [ -e /dev/mtd/1 ]; then
    $Nanddump --noecc --omitoob --bb=skipbad --truncate --file $DIRECTORY/secondstage.bin /dev/mtd/1 
  else
    $Nanddump --noecc --omitoob --bb=skipbad --truncate --file $DIRECTORY/secondstage.bin /dev/mtd1 
fi
fi

case "$DIRECTORY" in
	/media/net* )
		echo "Skipping SWAP-creation because the backup will be done to a network device"
	;;
	* )
#		echo "Checking free memory, about "$SWAPSIZE"MB will bee needed"
#let MEMFREE=`free | grep Total | tr -s " " | cut -d " " -f 4 `/1024
#  if [ "$MEMFREE" -lt $SWAPSIZE ]; then
#  echo "Memory is smaller than "$SWAPSIZE"MB, FlashBackup has to create a swapfile"
echo "---------------------------------------------------------------"
  echo "Creating swapfile on $SWAPDIR with "$SWAPSIZE"MB"
  dd if=/dev/zero of=$SWAPDIR/swapfile_backup bs=1024k count=$SWAPSIZE
  mkswap $SWAPDIR/swapfile_backup
  swapon $SWAPDIR/swapfile_backup
echo "---------------------------------------------------------------"
  echo "Swapfile activated"
echo "---------------------------------------------------------------"
#else
#  echo "memory="$MEMFREE"MB=OK"
#fi
	;;
esac

echo "***********************************************"
starttime="$(date +%s)"
echo "* FlashBackup started at: `date +%H:%M:%S`          *"
echo "***********************************************"

if [ -f /boot/autoexec.bat ]; then
touch /boot/dummy 2> /dev/null
fi

### External ###
if [ -f /boot/dummy ]; then
rm -rf /boot/dummy 2> /dev/null
    umount $MOUNTPOINT/bi/boot  2> /dev/null
	umount $MOUNTPOINT/bi/root  2> /dev/null  
	
	rm -rf $DIRECTORY/boot.img > /dev/null 2>&1
    rm -rf $DIRECTORY/boot.ubi > /dev/null 2>&1
    rm -rf $DIRECTORY/root.img > /dev/null 2>&1
    rm -rf $DIRECTORY/root.ubi > /dev/null 2>&1
	
    if [ ! -f /boot/autoexec.bat  ]; then
    if [ -f $MOUNTPOINT/bi/boot/autoexec.bat ] ; then	
       rm -r /boot   2> /dev/null            
       mv $MOUNTPOINT/bi/boot /boot  2> /dev/null
	fi
	fi
	
if [ -f $MOUNTPOINT/bi/root/usr/bin/enigma2 ] ; then
echo "******************************************************************"
echo "* (ROOT NOT UNMOUNT) Make reboot first then try to backup again  *" 
echo "******************************************************************"
exit 1
fi

rm -rf $MOUNTPOINT/bi/root > /dev/null 2>&1
mkdir -p $MOUNTPOINT/bi/root > /dev/null 2>&1

		
echo "Removed MultiBoot Links"
sleep 3
rm -rf $DIRECTORY/bainfo > /dev/null 2>&1
rm -rf /ba  2> /dev/null 
rm -rf /MB_Images  2> /dev/null
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/BarryAllen  2> /dev/null
rm -rf /sbin/ba.sh  2> /dev/null
rm -rf /home/root/ba.sh  2> /dev/null
rm -rf /usr/sbin/ba.sh  2> /dev/null
rm -rf /sbin/init  2> /dev/null
mv -f /.bainfo $MOUNTPOINT/bi/bainfo  2> /dev/null
mv -f /.bainfo.tmp $MOUNTPOINT/bi/bainfo.tmp  2> /dev/null
rm -rf /.ba* > /dev/null 2>&1 
rm -rf /.meo* 2> /dev/null 
rm -rf /sbin/meoinit 2> /dev/null 
if [ -f /sbin/RAEDinit ] ; then
ln -sfn /sbin/RAEDinit /sbin/init  >> $RAEDTMP 2>&1
else
ln -sfn /sbin/init.sysvinit /sbin/init  >> $RAEDTMP 2>&1
fi
 
if [ -e /etc/init.d/openvpn ]; then
   /etc/init.d/openvpn stop >> $RAEDTMP 2>&1
   echo "Stop openvpn" >> $RAEDTMP 2>&1  
fi
 
if grep -qs dm800sev2 /proc/stb/info/model ; then
mv /boot $MOUNTPOINT/bi/boot; cd $MOUNTPOINT/bi/boot; ln -sfn vmlinux-3.2-dm800sev2.gz vmlinux
ln -sfn /usr/share/bootlogo.mvi bootlogo.mvi; ln -sfn bootlog.mvi backdrop.mvi; ln -sfn bootlogo.mvi bootlogo_wait.mvi; cd /
sed -ie s!"root=/dev/mtdblock3 rootfstype=jffs2"!"ubi.mtd=root root=ubi0:rootfs rootfstype=ubifs"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"console=null"!"console=ttyS0,115200"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"quiet"!""!g $MOUNTPOINT/bi/boot/autoexec*.bat
else
mv /boot $MOUNTPOINT/bi/boot  > /dev/null 2>&1
fi
mkdir -p /boot  > /dev/null 2>&1            
mount -o bind / $MOUNTPOINT/bi/root > /dev/null 2>&1
if [ -e $MOUNTPOINT/bi/root/dev/usbdev1.1_ep00 ] ; then
   echo "Removing /dev/usbdev* (they will be back again after reboot)"
   rm -rf $MOUNTPOINT/bi/root/dev/usbdev* > /dev/null 2>&1
fi
	         echo "create boot.img"
		     $MKFS --root=$MOUNTPOINT/bi/boot --faketime --output=$DIRECTORY/boot.img $OPTIONS
			 SZboot=`ls -al $DIRECTORY/boot.img | awk '{print $5}'`
	         UBI=0
			 dd if=/dev/mtdblock3 of=$RAEDTMP bs=3 count=1 > /dev/null 2>&1
             if [ `grep UBI $RAEDTMP | wc -l` -gt 0 ]; then
             echo  "UBIFS Filesystem ..." 
			 UBI=1
             echo \[root\] > $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo image=$DIRECTORY/root.ubi >> $UBINIZECFG
             echo vol_id=0 >> $UBINIZECFG
             echo vol_name=rootfs >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             if [ $BOXTYPE != "dm7020hd" ]; then   
             echo vol_flags=autoresize >> $UBINIZECFG
             else 
             echo vol_size=$UBINIZE_VOLSIZE >> $UBINIZECFG
             echo \[data\] >> $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo vol_id=1 >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             echo vol_name=data >> $UBINIZECFG
             echo vol_size=$UBINIZE_DATAVOLSIZE >> $UBINIZECFG
             echo vol_flags=autoresize >> $UBINIZECFG
             fi
             else
             echo  "jffs2 Filesystem ..." 
             fi
			 if [ $UBI -eq 1 ]; then
			   echo "create root.ubi"
			   echo "Relax 5 or 6 minutes until finishing"
			   echo "---------------------"
			   mkdir -p $MOUNTPOINT/bi/root 2> /dev/null
               $UBIFS $UBIOPTIONS -x $UBICOMPRESSION -r $MOUNTPOINT/bi/root -o $DIRECTORY/root.ubi
               $UBINIZE -o $DIRECTORY/root.img $UBINIZE_OPTIONS $UBINIZECFG
             else
			   echo "create root.img"
			   echo "Relax 5 or 6 minutes until finishing"
			   echo "---------------------"
			   mkdir -p $MOUNTPOINT/bi/root 2> /dev/null
               $MKFS --root=$MOUNTPOINT/bi/root --faketime --output=$DIRECTORY/root.img $OPTIONS 
             fi
	         SZroot=`ls -al $DIRECTORY/root.img | awk '{print $5}'`
	         SZssl=`ls -al $DIRECTORY/secondstage.bin | awk '{print $5}'`
	         echo "Build" $BOXTYPE "IMAGE..."
	         if [ $BOXTYPE == "dm7020hd" -o $BOXTYPE == "dm8000" ]; then   
              if [ $UBI -eq 0 ]; then
                 $SUMTOOL --input=$DIRECTORY/boot.img --output=$DIRECTORY/boots.img $OPTIONS 
                 cp $DIRECTORY/boots.img $DIRECTORY/boot.img
                 rm $DIRECTORY/boots.img 
                 $SUMTOOL --input=$DIRECTORY/root.img --output=$DIRECTORY/roots.img $OPTIONS 
                 cp $DIRECTORY/roots.img $DIRECTORY/root.img
                 rm $DIRECTORY/roots.img 
              fi
              fi
		  if [ -d /usr/lib/python2.7 ] ; then
			  echo "Build" $BOXTYPE "IMAGE OE2.0..." >> $RAEDTMP 2>&1
              if [ -f /lib/ld-2.13.so ] ; then
              echo "2.13.so" >> $RAEDTMP 2>&1
			  if [ $BOXTYPE = "dm7020hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800se" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm8000" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 large > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800sev2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hdv2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	         fi
			 else
			  echo "2.xx.so" >> $RAEDTMP 2>&1
              if [ $UBI -eq 1 ]; then
                 $BUILDIMAGE2 $UBIBUILDOPTIONS > $BACKUPIMAGE
                 else
                 $BUILDIMAGE2 $BUILDOPTIONS > $BACKUPIMAGE
              fi
			  fi
		   fi
            if [ -d /usr/lib/python2.6 ] ; then
			if [ ! -d /usr/lib/python2.7 ] ; then
			  echo "Build" $BOXTYPE "IMAGE OE1.6..."
			  if [ $BOXTYPE = "dm7020hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800se" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm8000" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 large > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800sev2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hdv2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	         fi
			 fi
			 fi
             SZimage=`ls -al $BACKUPIMAGE | awk '{print $5}'`
             SZsum=`expr $SZboot "+" $SZroot "+" $SZssl`
             SZdiff=`expr $SZimage "-" $SZsum`
		     if [ "$SZsum" -lt $SZimage ]; then
		         echo "----------------------------------------------------------------------"
		         echo "FlashBackup created in:" $BACKUPIMAGE
		         echo "----------------------------------------------------------------------"
			     echo "Enigma2: Experimental " > $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo "Machine: Dreambox $BOXTYPE" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo "Date: "$DATE | cut -d '@' -f1 | sed -e "s/-//g" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo "Issuer: $IMAGEINFO" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo $LINK >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     md5NFO=`md5sum $BACKUPIMAGE | cut -d ' ' -f1`
			     echo "MD5: $md5NFO" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
		        else
			     echo "Download Error :("
			     rm -rf $SWAPDIR/$IMAGEINFO-$DATE-SSL-$VSND.nfi
				 umount $MOUNTPOINT/bi/root > /dev/null 2>&1		
                 rm -r /boot > /dev/null 2>&1             
                 mv $MOUNTPOINT/bi/boot /boot > /dev/null 2>&1
	             exit 1
		       fi
         stoptime="$(date +%s)"
         elapsed_seconds="$(expr $stoptime - $starttime)"
		 umount $MOUNTPOINT/bi/root	 > /dev/null 2>&1	
         rm -r /boot > /dev/null 2>&1
		 mv $MOUNTPOINT/bi/boot /boot > /dev/null 2>&1
         exit 1
	  fi
### Internal ###
if [ ! -f /boot/dummy ]; then
umount $MOUNTPOINT/bi/boot  2> /dev/null
umount $MOUNTPOINT/bi/root  2> /dev/null

if [ -f $MOUNTPOINT/bi/root/usr/bin/enigma2 ] ; then
echo "******************************************************************"
echo "* (ROOT NOT UNMOUNT) Make reboot first then try to backup again  *" 
echo "******************************************************************"
exit 1
fi

if [ -f $MOUNTPOINT/bi/boot/autoexec.bat ] ; then
echo "******************************************************************"
echo "* (BOOT NOT UNMOUNT) Make reboot first then try to backup again  *"
echo "******************************************************************"
exit 1
fi

rm -rf /ba > /dev/null 2>&1
rm -rf /MB_Images > /dev/null 2>&1
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/BarryAllen  > /dev/null 2>&1
rm -rf /sbin/ba.sh > /dev/null 2>&1
rm -rf /home/root/ba.sh > /dev/null 2>&1
rm -rf /usr/sbin/ba.sh > /dev/null 2>&1
rm -rf /sbin/init > /dev/null 2>&1
mv /.bainfo $MOUNTPOINT/bi/bainfo 2> /dev/null	
mv /.bainfo.tmp $MOUNTPOINT/bi/bainfo.tmp 2> /dev/null	
ln -sfn /sbin/init.sysvinit /sbin/init 2> /dev/null	
rm -rf /.ba* 2> /dev/null
rm -rf /.meo* 2> /dev/null 
rm -rf /sbin/meoinit 2> /dev/nul 

rm -rf $DIRECTORY/boot.img > /dev/null 2>&1
rm -rf $DIRECTORY/boot.ubi > /dev/null 2>&1
rm -rf $DIRECTORY/root.img > /dev/null 2>&1
rm -rf $DIRECTORY/root.ubi > /dev/null 2>&1

mkdir -p $MOUNTPOINT/bi/root > /dev/null 2>&1
mkdir -p $MOUNTPOINT/bi/boot > /dev/null 2>&1

if grep -qs dm800sev2 /proc/stb/info/model ; then
cp /boot/* $MOUNTPOINT/bi/boot; cd $MOUNTPOINT/bi/boot; ln -sfn vmlinux-3.2-dm800sev2.gz vmlinux
ln -sfn /usr/share/bootlogo.mvi bootlogo.mvi; ln -sfn bootlog.mvi backdrop.mvi; ln -sfn bootlogo.mvi bootlogo_wait.mvi; cd /
sed -ie s!"root=/dev/mtdblock3 rootfstype=jffs2"!"ubi.mtd=root root=ubi0:rootfs rootfstype=ubifs"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"console=null"!"console=ttyS0,115200"!g $MOUNTPOINT/bi/boot/autoexec*.bat
sed -ie s!"quiet"!""!g $MOUNTPOINT/bi/boot/autoexec*.bat
else
mount -t jffs2 $MTDBOOT $MOUNTPOINT/bi/boot
fi

	         echo "create boot.img From Flash"
		     $MKFS --root=$MOUNTPOINT/bi/boot --faketime --output=$DIRECTORY/boot.img $OPTIONS
			 SZboot=`ls -al $DIRECTORY/boot.img | awk '{print $5}'`
	         echo "create root.img..."
			 echo "---------------------"
			 UBI=0
			 dd if=/dev/mtdblock3 of=$RAEDTMP bs=3 count=1 > /dev/null 2>&1
             if [ `grep UBI $RAEDTMP | wc -l` -gt 0 ]; then
             echo  "UBIFS Filesystem ..." 
			 UBI=1
             echo \[root\] > $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo image=$DIRECTORY/root.ubi >> $UBINIZECFG
             echo vol_id=0 >> $UBINIZECFG
             echo vol_name=rootfs >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             if [ $BOXTYPE != "dm7020hd" ]; then   
             echo vol_flags=autoresize >> $UBINIZECFG
             else 
             echo vol_size=$UBINIZE_VOLSIZE >> $UBINIZECFG
             echo \[data\] >> $UBINIZECFG
             echo mode=ubi >> $UBINIZECFG
             echo vol_id=1 >> $UBINIZECFG
             echo vol_type=dynamic >> $UBINIZECFG
             echo vol_name=data >> $UBINIZECFG
             echo vol_size=$UBINIZE_DATAVOLSIZE >> $UBINIZECFG
             echo vol_flags=autoresize >> $UBINIZECFG
             fi
             else
             echo  "jffs2 Filesystem ..." 
             fi
             if [ $UBI -eq 1 ]; then
			   echo "create root.ubi From Flash"
			   echo "Relax 5 or 6 minutes until finishing"
			   echo "---------------------"
               mount -t ubifs /dev/ubi0_0 $MOUNTPOINT/bi/root
               $UBIFS $UBIOPTIONS -x $UBICOMPRESSION -r $MOUNTPOINT/bi/root -o $DIRECTORY/root.ubi 
               $UBINIZE -o $DIRECTORY/root.img $UBINIZE_OPTIONS $UBINIZECFG 
             else
			   echo "create root.img From Flash"
			   echo "Relax 5 or 6 minutes until finishing"
               mount -o bind / $MOUNTPOINT/bi/root > /dev/null 2>&1
			   if [ -e $MOUNTPOINT/bi/root/dev/usbdev1.1_ep00 ] ; then
               echo "Removing /dev/usbdev* (they will be back again after reboot)"
               rm -rf $MOUNTPOINT/bi/root/dev/usbdev* > /dev/null 2>&1
               fi
			   echo "---------------------"
               $MKFS --root=$MOUNTPOINT/bi/root --faketime --output=$DIRECTORY/root.img $OPTIONS 
             fi
			 echo "Build" $BOXTYPE "IMAGE OE2.0 From Flash..."
			 if [ $BOXTYPE == "dm7020hd" -o $BOXTYPE == "dm8000" ]; then   
              if [ $UBI -eq 0 ]; then
                 $SUMTOOL --input=$DIRECTORY/boot.img --output=$DIRECTORY/boots.img $OPTIONS 
                 cp $DIRECTORY/boots.img $DIRECTORY/boot.img 
                 rm $DIRECTORY/boots.img 
                 $SUMTOOL --input=$DIRECTORY/root.img --output=$DIRECTORY/roots.img $OPTIONS
                 cp $DIRECTORY/roots.img $DIRECTORY/root.img 
                 rm $DIRECTORY/roots.img 
              fi
              fi
           if [ -d /usr/lib/python2.7 ] ; then
			  echo "Build" $BOXTYPE "IMAGE OE2.0..." >> $RAEDTMP 2>&1
              if [ -f /lib/ld-2.13.so ] ; then
              echo "2.13.so" >> $RAEDTMP 2>&1
			  if [ $BOXTYPE = "dm7020hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800se" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm8000" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 large > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800sev2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hdv2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	         fi
			 else
			  echo "2.xx.so" >> $RAEDTMP 2>&1
              if [ $UBI -eq 1 ]; then
                 $BUILDIMAGE2 $UBIBUILDOPTIONS > $BACKUPIMAGE
                 else
                 $BUILDIMAGE2 $BUILDOPTIONS > $BACKUPIMAGE
              fi
			  fi
		   fi
            if [ -d /usr/lib/python2.6 ] ; then
			if [ ! -d /usr/lib/python2.7 ] ; then
			  echo "Build" $BOXTYPE "IMAGE OE1.6..."
			  if [ $BOXTYPE = "dm7020hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800se" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm8000" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 large > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm800sev2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hdv2" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	          elif [ $BOXTYPE = "dm500hd" ] ; then
		         $BUILDIMAGE $DIRECTORY/secondstage.bin $DIRECTORY/boot.img $DIRECTORY/root.img $BOXTYPE 64 > $BACKUPIMAGE
	         fi
			 fi
			 fi
			 SZroot=`ls -al $DIRECTORY/root.img | awk '{print $5}'`
	         SZssl=`ls -al $DIRECTORY/secondstage.bin | awk '{print $5}'`
             SZimage=`ls -al $BACKUPIMAGE | awk '{print $5}'`
             SZsum=`expr $SZboot "+" $SZroot "+" $SZssl`
             SZdiff=`expr $SZimage "-" $SZsum`
		     if [ "$SZsum" -lt $SZimage ]; then
		         echo "----------------------------------------------------------------------"
		         echo "FlashBackup created in:" $BACKUPIMAGE
		         echo "----------------------------------------------------------------------"
			     echo "Enigma2: Experimental " > $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo "Machine: Dreambox $BOXTYPE" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo "Date: "$DATE | cut -d '@' -f1 | sed -e "s/-//g" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo "Issuer: $IMAGEINFO" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     echo $LINK >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
			     md5NFO=`md5sum $BACKUPIMAGE | cut -d ' ' -f1`
			     echo "MD5: $md5NFO" >> $SWAPDIR/$IMAGEINFO-$BOXTYPE-$DATE-SSL-$VSND.nfo
		        else
			     echo "Download Error :("
			     rm -rf $SWAPDIR/$IMAGEINFO-$DATE-SSL-$VSND.nfi
			exit 1
    fi
    stoptime="$(date +%s)"
    elapsed_seconds="$(expr $stoptime - $starttime)"
fi
echo "***********************************************"
echo "* FlashBackup finished at: `date +%H:%M:%S`            *"
echo "* Duration of FlashBackup: $((elapsed_seconds / 60))minutes $((elapsed_seconds % 60))seconds *"
echo "***********************************************"
exit 0
