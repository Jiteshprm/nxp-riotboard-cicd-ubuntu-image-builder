#!/bin/bash

. common.env

#Log which shell we are in
echo "Shell is: ${SHELL}"
echo "Processes: $(ps ax)"

REPO_DIR="${HOME}/bin"
REPO_FILE="${REPO_DIR}/repo"

#Get Repo tool if needed
if [[ -f "${REPO_FILE}" ]]
then
  echo "[EXISTS] - File ~/bin/repo already exists on your filesystem."
  PATH=${PATH}:${REPO_DIR}
else
  echo "[Downloading..] - File ~/bin/repo does not exists on your filesystem."
  rm -rf ${REPO_DIR}
  mkdir -p ${REPO_DIR}
  if [[ $? -ne 0 ]] ; then
    exit 20
  fi
  curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ${REPO_FILE}
  chmod a+x ${REPO_FILE}
  PATH=${PATH}:${REPO_DIR}
fi

#Check if BSP folder exists
cd ${DATA_DIR}
echo "We are at path: $(pwd)"

echo "Using BSP_DIR_NAME=${BSP_DIR_NAME}"
if [[ -d "${BSP_DIR_NAME}" ]]
then
    echo "[OK] - BSP Folder ${BSP_DIR_NAME} exists on your filesystem."
else
    echo "[Creating...] - BSP Folder ${BSP_DIR_NAME}"
    mkdir -p "${BSP_DIR_NAME}"
    if [[ $? -ne 0 ]] ; then
      exit 21
    fi
fi

#Download BSP from Git
cd ${BSP_DIR_NAME}
echo "We are at path: $(pwd)"
repo init -u ${BUILD_NXP_GIT_URL} -b ${BUILD_NXP_BSP_BRANCH}
repo sync

#COpy custom local config
mkdir -p build/conf
cp ${HOME}/local.conf build/conf

#Setup BitBake Environment
source ./setup-environment build
# Remove Verbose bash mode for logging for BB
set +x
#Build BitBake
bitbake core-image-minimal
# Re Enable Verbose bash mode for logging
set -x
STATUS=$?

#Exit from container
if [ ${STATUS} -eq 0 ]; then
   echo "[SUCCESS] - BitBake returned status: ${STATUS}"
else
   echo "[FAIL] - BitBake returned status: ${STATUS}"
fi

exit ${STATUS}