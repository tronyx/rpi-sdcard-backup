#!/usr/bin/env bash
#
# Script to backup your RaspberryPi SDCard as a disk image directly onto a backup location, IE: NAS.
# This is based on the following guide:
# https://www.tomshardware.com/how-to/back-up-raspberry-pi-as-disk-image

# Prerequisites
# You will need to check the mount point of the SD Card as well just in case it is not the same as what I have listed below.
# You can check this by running: sudo lsblk
# Mine looks like this:
# pi@raspberrypi:~ $ sudo lsblk
# NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# mmcblk0     179:0    0 29.8G  0 disk 
# ├─mmcblk0p1 179:1    0 43.2M  0 part /boot
# └─mmcblk0p2 179:2    0 29.8G  0 part /
#
# So my SD Card is /dev/mmcblk0 for the creation of the image. I attempt to get this information automatically with variables,
# but you should check that it is correct before running the script.

# Define some variables
sdCardDisk=$(sudo lsblk | grep disk | awk '{print $1}')
sdCardMountPoint="/dev/${sdCardDisk}"
backupDirectory='/mnt/pihole_backup' # This is a share on my Netgear ReadyNAS that I mounted on my RaspberryPi
today=$(date +%Y-%m-%d)
days=$(( ( $(date '+%s') - $(date -d '5 weeks ago' '+%s') ) / 86400 ))
# Colors
readonly red='\e[31m'
readonly endColor='\e[0m'

# Script Information
get_scriptname() {
    local source
    local dir
    source="${BASH_SOURCE[0]}"
    while [[ -L ${source} ]]; do
        dir="$(cd -P "$(dirname "${source}")" > /dev/null && pwd)"
        source="$(readlink "${source}")"
        [[ ${source} != /* ]] && source="${dir}/${source}"
    done
    echo "${source}"
}

readonly scriptname="$(get_scriptname)"

# Check whether or not user is root or used sudo
root_check() {
    if [[ ${EUID} -ne 0 ]]; then
        echo -e "${red}You didn't run the script as root!${endColor}"
        echo -e "${red}Doing it for you now...${endColor}"
        echo ''
        sudo bash "${scriptname:-}" "${args[@]:-}"
        exit
    fi
}

# Function to get PiShrink if it does not exist
get_pishrink() {
    piShrinkExists=$(find /usr/local/bin/ -name "*pishrink*" -type f | wc -l)
    if [[ ${piShrinkExists} == '1' ]]; then
        :
    else
        echo 'Grabbing the PiShrink script...'
        sudo wget -O /usr/local/bin/pishrink https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
        sudo chmod a+x /usr/local/bin/pishrink
    fi
}

# Function to create disk image
create_image() {
    echo 'Creating image file. This can take some time...'
    sudo dd if="${sdCardMountPoint}" of="${backupDirectory}"/raspberrypi-"${today}".img bs=1M
}

# Function to check, repair, and shrink disk image
# This shrinks my image from ~30GB to ~2.5GB so it is worth doing
shrink_image() {
    echo 'Shrinking image file. This can take some time...'
    cd "${backupDirectory}" || echo 'Cannot cd to the backup directory! Does it exist?' exit 1
    sudo pishrink.sh -z raspberrypi-"${today}".img
}

# Function to cleanup old images from the backup directory based on the days variable specified at the top of the script
cleanup() {
    echo 'Removing old image files...'
    sudo find "${backupDirectory}" -name "*.gz" -mtime +"${days}" -type f -delete
}

# Main function to run all other functions
main() {
    root_check
    get_pishrink
    create_image
    shrink_image
    cleanup
}

main