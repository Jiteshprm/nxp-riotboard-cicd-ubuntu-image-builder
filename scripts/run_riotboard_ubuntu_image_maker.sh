#!/bin/bash

. common.env

#Log which shell we are in
echo "Shell is: ${SHELL}"
echo "Processes: $(ps ax)"

UBUNTU_IMAGE_DIR="${DATA_DIR}/image"

UBUNTU_RASPBPI_MOUNT_DIR="${UBUNTU_IMAGE_DIR}/raspb"
UBUNTU_RIOTBOARD_MOUNT_DIR="${UBUNTU_IMAGE_DIR}/riotboard"

#Add loop device modules in image
sudo modprobe loop

if [[ -d "${UBUNTU_IMAGE_DIR}" ]]
then
    echo "[OK] - Image Folder ${UBUNTU_IMAGE_DIR} exists on your filesystem"
else
    echo "[Creating...] - Image Folder ${UBUNTU_IMAGE_DIR}"
    mkdir -p "${UBUNTU_IMAGE_DIR}"
fi

if [[ -d "${UBUNTU_RASPBPI_MOUNT_DIR}" ]]
then
    echo "[OK] - Mount Folder ${UBUNTU_RASPBPI_MOUNT_DIR} exists on your filesystem."
else
    echo "[Creating...] - Mount Folder ${UBUNTU_RASPBPI_MOUNT_DIR}"
    mkdir -p "${UBUNTU_RASPBPI_MOUNT_DIR}"
fi

if [[ -d "${UBUNTU_RIOTBOARD_MOUNT_DIR}" ]]
then
    echo "[OK] - Mount Folder ${UBUNTU_RIOTBOARD_MOUNT_DIR} exists on your filesystem."
else
    echo "[Creating...] - Mount Folder ${UBUNTU_RIOTBOARD_MOUNT_DIR}"
    mkdir -p "${UBUNTU_RIOTBOARD_MOUNT_DIR}"
fi

echo "We are at path: $(pwd)"

cd ${UBUNTU_IMAGE_DIR}

#List BAD constructed images from folder
#ls -lart "*-BAD.img"

#Remove BAD constructed images from folder
#rm -rf "*-BAD.img"

echo "We are at path: $(pwd)"

if [[ -f "${UBUNTU_RASPBPI_IMAGE_FILENAME}" ]]
then
  echo "[EXISTS] - File ${UBUNTU_RASPBPI_IMAGE_FILENAME} already exists on your filesystem."
else
  echo "[Downloading..] - File ${UBUNTU_RASPBPI_IMAGE_FILENAME} does not exists on your filesystem."
  wget -nv ${UBUNTU_RASPBPI_IMAGE_URL}
  xz -d ${UBUNTU_RASPBPI_IMAGE_FILENAME_COMPRESSED}
fi

file ${UBUNTU_RASPBPI_IMAGE_FILENAME}

#2nd partition 526336*512=269484032
sudo mount -v -o offset=269484032 -t ext4  ${UBUNTU_RASPBPI_IMAGE_FILENAME} ${UBUNTU_RASPBPI_MOUNT_DIR}

UBUNTU_RIOTBOARD_IMAGE_FILENAME="${UBUNTU_RIOTBOARD_IMAGE_FILENAME_PREFIX}$(date '+%Y%m%d-%H%M%S')-BAD.img"

echo "UBUNTU_RIOTBOARD_IMAGE_FILENAME: ${UBUNTU_RIOTBOARD_IMAGE_FILENAME}"

# Create a file to hold the disk image
qemu-img create ${UBUNTU_RIOTBOARD_IMAGE_FILENAME} ${UBUNTU_RIOTBOARD_IMAGE_INIT_SIZE}
# Partition the disk image leaving some room (10mb) for u-boot in front of the first partition.
sfdisk --force ${UBUNTU_RIOTBOARD_IMAGE_FILENAME} << EOF
10M,,83
EOF
# create devices from the disk image
sudo kpartx -av ${UBUNTU_RIOTBOARD_IMAGE_FILENAME}
#Get loop device nname
UBUNTU_RIOTBOARD_IMAGE_LOOP_DEVICE=$(losetup --list | grep "${UBUNTU_RIOTBOARD_IMAGE_FILENAME}" | cut -d ' ' -f1)
echo "UBUNTU_RIOTBOARD_IMAGE_LOOP_DEVICE: ${UBUNTU_RIOTBOARD_IMAGE_LOOP_DEVICE}"
UBUNTU_RIOTBOARD_IMAGE_MAPPER_DEVICE=${UBUNTU_RIOTBOARD_IMAGE_LOOP_DEVICE/dev/dev/mapper}p1
echo "UBUNTU_RIOTBOARD_IMAGE_MAPPER_DEVICE: ${UBUNTU_RIOTBOARD_IMAGE_MAPPER_DEVICE}"
# format the partition. Make sure to use the correct device from the previous command.
sudo mkfs.ext4 -j ${UBUNTU_RIOTBOARD_IMAGE_MAPPER_DEVICE}
# Mount the partition we formatted.
sudo mount -t ext4 ${UBUNTU_RIOTBOARD_IMAGE_MAPPER_DEVICE} ${UBUNTU_RIOTBOARD_MOUNT_DIR}
# Unpack the root fs and kernel
sudo rsync -ap ${UBUNTU_RASPBPI_MOUNT_DIR}/* ${UBUNTU_RIOTBOARD_MOUNT_DIR}/
# Copy the boot script to the top level
#sudo cp boot.scr /mnt/sdcard/boot.scr
# Unmount and clean up devices
sudo umount ${UBUNTU_RIOTBOARD_MOUNT_DIR}
sudo kpartx -dv ${UBUNTU_RIOTBOARD_IMAGE_FILENAME}
sudo umount ${UBUNTU_RASPBPI_MOUNT_DIR}
# put u-boot 2 blocks into the disk image.  Don't leave out the notrunc option.
#dd if=u-boot.imx of=sdcard.img bs=512 seek=2 conv=notrunc

mv ${UBUNTU_RIOTBOARD_IMAGE_FILENAME} ${UBUNTU_RIOTBOARD_IMAGE_FILENAME/BAD/OK}

STATUS=$?

#Exit from container
if [ ${STATUS} -eq 0 ]; then
   echo "[SUCCESS] - Image Build returned status: ${STATUS}"
else
   echo "[FAIL] - Image Build returned status: ${STATUS}"
fi

exit ${STATUS}
