#!/bin/sh

source /opt/cloudconductor/lib/common.sh

ERROR_NUM=`grep -r "^\[[0-9T:-]\{19\}[0-9\+:]\{6\}\?\] ERROR:" $LOG_DIR | wc -l`
if [ $ERROR_NUM -eq 0 ]; then
  echo '{ "status": "SUCCESS" }'
else
  echo '{ "status": "ERROR" }'
fi
