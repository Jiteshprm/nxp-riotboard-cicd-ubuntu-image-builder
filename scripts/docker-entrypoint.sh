#!/bin/bash

. common.env

if [[ ${1} == *"run_build_steps"* ]]; then
  DATA_DIR="${HOME}/data"
  LOG_DIR="${DATA_DIR}/logs"

  #Start HTTP file server in node in order to see the logs in browser
  http-server -a ${HTTP_HOSTNAME_INTERNAL} -p ${HTTP_FILE_PORT_INTERNAL} ${HOME} &

  if [[ -d "$DATA_DIR" ]]
  then
      echo "[OK] - Folder $DATA_DIR exists on your filesystem."
  else
      echo "[ERROR] - Folder $DATA_DIR does not exists on your filesystem."
      exit 1
  fi

  if [[ -d "$LOG_DIR" ]]
  then
      echo "[OK] - Log Folder $LOG_DIR exists on your filesystem."
  else
      echo "[Creating...] - Log Folder $LOG_DIR"
      mkdir -p "${LOG_DIR}"
  fi

  # redirect stdout and stderr to files
  #exec >${LOG_DIR}/stdout.log
  #exec 2>${LOG_DIR}/stderr.log
  LOG_FILENAME=${BUILD_LOG}$(date '+%Y%m%d_%H%M%S').log
  LOG_FILE=${LOG_DIR}/${LOG_FILENAME}
  echo "Logging into file: ${LOG_FILE}"
  echo "Log URL is: http://${HTTP_HOSTNAME_EXTERNAL}:${HTTP_FILE_PORT_EXTERNAL}/data/logs/${LOG_FILENAME}"
  exec >${LOG_FILE} 2>&1
else
  echo "Running Custom exec command, disabling logs"
fi


echo "[OK] - Starting container jobs..."

# now run the requested CMD without forking a subprocess
#exec "$@"
echo "[Running...] - /bin/bash -c $@"
exec /bin/bash -c "$@"
STATUS=$?
echo "[WARN] - Script should not have reached here!"

if [ ${STATUS} -eq 0 ]; then
   echo "[SUCCESS] - Script returned status: ${STATUS}"
else
   echo "[FAIL] - Script returned status: ${STATUS}"
fi

exit ${STATUS}