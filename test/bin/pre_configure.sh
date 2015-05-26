#! /bin/sh
echo ROLE=${ROLE} >> /opt/cloudconductor/config

source /opt/cloudconductor/lib/common.sh

source ${CHEF_ENV_FILE}

service consul start

sleep 10

output="$(bash -x /opt/cloudconductor/bin/configure.sh)"
status=$?

if [ $status -ne 0 ] ; then
  echo $output
  exit $status
fi
