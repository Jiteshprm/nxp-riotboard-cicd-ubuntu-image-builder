#!/bin/bash
# Set up Verbose bash mode for logging
set -x

#From: https://intoli.com/blog/exit-on-errors-in-bash-scripts/
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

mv linux.env .env
dd if=/dev/zero of=/tmp/loop bs=1M count=100
losetup /dev/loop100 /tmp/loop

sudo pvcreate /dev/loop100
sudo vgcreate vg1 /dev/loop100
sudo lvcreate --size 90M --name lv1 vg1
sudo mkfs.xfs /dev/vg1/lv1

#sudo apt install lvm2
#sudo apt install xfsprogs

#docker run \
#  --rm -it \
#  -v /home/birdofprey-nvidia/hdd/docker/data:/home/dev/data \
#  --mount='type=volume,dst=/opt,volume-driver=local,volume-opt=type=xfs,volume-opt=device=/dev/vg1/lv1' \
#  jiteshprm/nxp-riotboard-image-builder:latest ls


#docker run \
#--rm -it \
#-v /home/birdofprey-nvidia/hdd/docker/data:/home/dev/data \
#--mount='type=volume,dst=/opt,volume-driver=local,volume-opt=type=xfs,volume-opt=device=/dev/vg1/lv1' \
#jiteshprm/nxp-riotboard-image-builder:latest \
#"ls /home/dev"

docker run \
--rm -it \
--privileged \
-v /home/birdofprey-nvidia/hdd/docker/data:/home/dev/data \
jiteshprm/nxp-riotboard-image-builder:latest \
"cd /home/dev/data;file ubuntu-20.04-preinstalled-server-armhf+raspi.img;mkdir /home/dev/m;sudo mount -v -o offset=269484032 -t ext4 ubuntu-20.04-preinstalled-server-armhf+raspi.img /home/dev/m; ls -lart /home/dev/m; df -h"

