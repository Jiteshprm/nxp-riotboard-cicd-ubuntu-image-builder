#!/bin/bash

#Log which shell we are in
echo "Shell is: ${SHELL}"
echo "Processes: $(ps ax)"

STATUS=2

#Exit from container
if [ ${STATUS} -eq 0 ]; then
   echo "[SUCCESS] - Image Build returned status: ${STATUS}"
else
   echo "[FAIL] - Image Build returned status: ${STATUS}"
fi

exit ${STATUS}