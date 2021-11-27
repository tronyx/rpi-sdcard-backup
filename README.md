# RaspberryPi SD Card Backup

[![CodeFactor](https://www.codefactor.io/repository/github/tronyx/tronitor/badge)](https://www.codefactor.io/repository/github/tronyx/tronitor) [![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/) [![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/tronyx/tronitor/blob/develop/LICENSE.md)

A Bash script to create an image file of the SD Card in a Raspberry Pi for backup purposes. The image file is stored on a mounted backup location, such as a NAS share, and then the script uses [PiShrink](https://github.com/Drewsif/PiShrink) to compress the image file to save space.

## Setting it up

Download the script, made it executable, update and make sure the variables work for your Raspberry Pi per the comments in the script, and then run it.

```bash
wget https://raw.githubusercontent.com/tronyx/rpi-sdcard-backup/master/rpi-sdcard-backup.sh
chmod a+x backup.sh
```

### Prerequisites
You will need to check the mount point of the SD Card as well just in case it is not the same as what I have listed below. You can check this by running:

`sudo lsblk`

Mine looks like this:

```bash
pi@raspberrypi:~ $ sudo lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk0     179:0    0 29.8G  0 disk 
├─mmcblk0p1 179:1    0 43.2M  0 part /boot
└─mmcblk0p2 179:2    0 29.8G  0 part /
```

So my SD Card is `/dev/mmcblk0` for the creation of the image. I attempt to get this information automatically with variables in the script, but you should check that it is correct before running it.

## Example Cronjob

Here is the cronjob that I use to run the script every Sunday morning at 5am:

```bash
## Run the rpi-sdcard-backup.sh script every Sunday at 5am
0 5 * * 0 /home/tronyx/scripts/rpi-sdcard-backup.sh > /var/log/rpi-sdcard-backup.log
```

The `> /var/log/rpi-sdcard-backup.log` at the end allows me to log the output of the script so I can check it if there was an issue while it ran overnight.