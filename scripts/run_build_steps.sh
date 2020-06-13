#!/bin/bash

# Set up Verbose bash mode for logging
set -x

#Log which shell we are in
echo "Shell is: ${SHELL}"
echo "Processes: $(ps ax)"

#Setup Paths
DATA_DIR="${HOME}/data"
LOG_DIR="${DATA_DIR}/logs"

echo "Run Status: BUILD_NXP_BSP=${BUILD_NXP_BSP} BUILD_NXP_IMAGE=${BUILD_NXP_IMAGE}"
if [ ${BUILD_NXP_BSP} -eq 1 ]; then
    echo "[BUILD_NXP_BSP] - Building NXP BSP Core Package"
    /bin/bash -c ${HOME}/run_nxp_bsp_build.sh
    STATUS=$?
fi

if [ ${BUILD_NXP_IMAGE} -eq 1 ]; then
    echo "[BUILD_NXP_IMAGE] - Building RiotBoard Ubuntu Image..."
    /bin/bash -c ${HOME}/run_riotboard_ubuntu_image_maker.sh
    STATUS=$?
fi


#Exit from container
if [ ${STATUS} -eq 0 ]; then
   echo "[SUCCESS] - Build returned status: ${STATUS}"
else
   echo "[FAIL] - Build returned status: ${STATUS}"
fi

exit ${STATUS}