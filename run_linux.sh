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
losetup /dev/loop0 /tmp/loop

pvcreate /dev/loop0
vgcreate vg1 /dev/loop0
lvcreate --size 90M --name lv1 vg1
mkfs.xfs /dev/vg1/lv1

#docker run \
#  --rm -it \
#  --mount='type=volume,dst=/opt,volume-driver=local,volume-opt=type=xfs,volume-opt=device=/dev/vg1/lv1' \
#  jiteshprm/nxp-riotboard-image-builder:lastest