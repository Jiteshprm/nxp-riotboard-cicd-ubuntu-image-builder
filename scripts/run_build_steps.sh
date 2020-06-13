#!/bin/bash

# Set up Verbose bash mode for logging
set -x

#Log which shell we are in
echo "Shell is: ${SHELL}"
echo "Processes: $(ps ax)"

#Setup Paths
DATA_DIR="${HOME}/data"
LOG_DIR="${DATA_DIR}/logs"

echo "Run STatus: BUILD_NXP_BSP=${BUILD_NXP_BSP} BUILD_NXP_IMAGE=${BUILD_NXP_IMAGE}"
if [ ${BUILD_NXP_BSP} -eq 1 ]; then
    echo "[BUILD_NXP_BSP] - Building NXP BSP Core Package"
    /home/dev/run_nxp_bsp_build.sh
    STATUS=$?
fi

if [ ${BUILD_NXP_IMAGE} -eq 1 ]; then
    echo "[BUILD_NXP_IMAGE] - Building RiotBoard Ubuntu Image..."
    STATUS=$?
fi


#Exit from container
if [ ${STATUS} -eq 0 ]; then
   echo "[SUCCESS] - BitBake returned status: ${STATUS}"
else
   echo "[FAIL] - BitBake returned status: ${STATUS}"
fi

exit ${STATUS}