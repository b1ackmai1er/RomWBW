#!/bin/bash

# fail on any error
set -e

CPMCP=../../Tools/`uname`/cpmcp
CPMCH=../../Tools/`uname`/cpmchattr

timestamp=$(date +%Y-%m-%d)
#timestamp="2020-02-24"

if [ $1 == '-d' ] ; then
	shift
	diffdir=$1
	shift
	if [ -f $diffdir/build.inc ] ; then
		timestamp=$(grep TIMESTAMP $diffdir/build.inc | awk '{print $3}' | tr -d '\015"')
		echo diff build using $timestamp
	fi
fi

# positional arguments
platform=$1
config=$2
romsize=$3
romname=$4

export platform

# prompt if no match
platforms=($(find Config -name \*.asm -print | \
	sed -e 's,Config/,,' -e 's/_.*$//' | sort -u))

while ! echo ${platforms[@]} | grep -q -w -s "$platform" ; do
	echo -n "Enter platform [" ${platforms[@]} "] :"
	read platform
done

configs=$(find Config -name ${platform}_\* -print | \
	sed -e 's,Config/,,' -e "s/${platform}_//" -e "s/.asm//")
while ! echo ${configs[@]} | grep -s -w -q "$config" ; do
	echo -n "Enter config for $platform [" ${configs[@]} "] :"
	read config
done
configfile=Config/${platform}_${config}.asm

while [ ! '(' "$romsize" = 1024 -o "$romsize" = 512 -o "$romsize" = 256 -o "$romsize" = 128 ')' ] ; do
	echo -n "Romsize :"
	read romsize
done

if [ -z "$romname" ] ; then
	romname=${platform}_${config}
fi
echo Building for $romname for $platform $config $romsize

if [ $platform == UNA ] ; then
	BIOS=una
else
	BIOS=wbw
fi

Apps=(assign mode rtc syscopy xm)
if [ $romsize -gt 256 ] ; then
	Apps+=(fdu format survey sysgen talk timer inttest)
fi

blankfile=Blank${romsize}KB.dat
romdiskfile=RomDisk.tmp
romfmt=wbw_rom${romsize}
outdir=../../Binary

echo "creating empty rom disk of size $romsize in $blankfile"
#LANG=en_US.US-ASCII tr '\000' '\345' </dev/zero | dd of=$blankfile bs=1024 count=`expr $romsize - 128` 2>/dev/null
#LC_CTYPE=en_US.US-ASCII tr '\000' '\345' </dev/zero | dd of=$blankfile bs=1024 count=`expr $romsize - 128` 2>/dev/null
LC_ALL=en_US.US-ASCII tr '\000' '\345' </dev/zero | dd of=$blankfile bs=1024 count=`expr $romsize - 128`
hexdump $blankfile

cat <<- EOF > build.inc
; RomWBW Configured for $platform $config $timestamp
;
#DEFINE	TIMESTAMP	"$timestamp"
;
ROMSIZE		.EQU	$romsize
;
#INCLUDE "$configfile"
;
EOF

echo "checking prerequisites"
for need in ../CPM22/cpm_$BIOS.bin ../ZSDOS/zsys_$BIOS.bin \
	../Forth/camel80.bin font8x11c.asm font8x11u.asm font8x16c.asm \
	font8x16u.asm font8x8c.asm font8x8u.asm ; do
	if [ ! -f $need ] ; then
		echo $need missing
		exit 2
	fi
done

cp ../Forth/camel80.bin .

make dbgmon.bin romldr.bin eastaegg.bin imgpad2.bin

if [ $platform != UNA ] ; then
	make nascom.bin tastybasic.bin game.bin usrrom.bin imgpad2.bin
	make hbios_rom.bin hbios_app.bin hbios_img.bin
fi

echo "Building $romname output files..."

cat romldr.bin dbgmon.bin ../CPM22/cpm_$BIOS.bin ../ZSDOS/zsys_$BIOS.bin >osimg.bin
cat romldr.bin dbgmon.bin ../ZSDOS/zsys_$BIOS.bin >osimg_small.bin

if [ $platform != UNA ] ; then
	cat camel80.bin nascom.bin tastybasic.bin game.bin eastaegg.bin usrrom.bin >osimg1.bin
	cat netboot.mod imgpad2.bin >osimg2.bin
fi

echo "Building ${romsize}KB $romname ROM disk data file..."

cp $blankfile $romdiskfile
	
if [ $romsize -gt 128 ] ; then

	echo placing files into $romdiskfile
	
	for file in $(ls -1 ../RomDsk/ROM_${romsize}KB/* | sort -V) ; do
		echo " " $file
		$CPMCP -f $romfmt $romdiskfile $file 0:
	done
	
	if [ -d ../RomDsk/$platform ] ; then
		for file in ../RomDsk/$platform/* ; do
			echo " " $file
			$CPMCP -f $romfmt $romdiskfile $file 0:
		done
	fi
	
	echo "adding apps to $romdiskfile"
	for i in ${Apps[@]} ; do
		set +e
		f=$(../../Tools/unix/casefn.sh ../../Binary/Apps/$i.com)
		set -e
		if [ -z "$f" ] ; then
			echo " " $i "not found"
		else
			echo " " $f
			$CPMCP -f $romfmt $romdiskfile $f 0:
		fi
	done
	
	echo "copying systems to $romdiskfile"
	$CPMCP -f $romfmt $romdiskfile ../CPM22/cpm_$BIOS.sys 0:cpm.sys
	$CPMCP -f $romfmt $romdiskfile ../ZSDOS/zsys_$BIOS.sys 0:zsys.sys
	
	echo "setting files in the ROM disk image to read only"
	$CPMCH -f $romfmt $romdiskfile  r 0:*.*
fi

if [ $platform = UNA ] ; then
	cp osimg.bin $outdir/UNA_WBW_SYS.bin
	cp $romdiskfile $outdir/UNA_WBW_ROM$romsize.bin
	cat ../UBIOS/UNA-BIOS.BIN osimg.bin ../UBIOS/FSFAT.BIN $romdiskfile >$romname.rom
else
	cat hbios_rom.bin osimg.bin osimg1.bin osimg2.bin $romdiskfile >$romname.rom
	cat hbios_rom.bin osimg.bin osimg1.bin osimg2.bin >$romname.upd
	cat hbios_app.bin osimg_small.bin > $romname.com
	# cat hbios_img.bin osimg_small.bin > $romname.img
fi

#rm $romdiskfile
