#!/bin/sh

source /opt/cloudconductor/lib/common.sh

ERROR=`grep -r "ERROR: finished abnormally. action_runner has failed. SERF_TAG_ROLE\[.*\], SERF_EVENT\[user\], SERF_USER_EVENT\[spec\]" $LOG_DIR | wc -l`
if [ $ERROR -gt 0 ]; then
  echo '{ "status": "ERROR" }'
  exit 1
fi

SUCCESS=`grep -r "INFO: finished successfully. SERF_TAG_ROLE\[.*\], SERF_EVENT\[user\], SERF_USER_EVENT\[spec\]" $LOG_DIR | wc -l`
if [ $SUCCESS -gt 0 ]; then
  echo '{ "status": "SUCCESS" }'
else
  echo '{ "status": "PENDING" }'
fi
