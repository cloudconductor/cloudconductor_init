#! /bin/sh
echo "$0 start."

echo ROLE=${ROLE} >> /opt/cloudconductor/config

source /opt/cloudconductor/lib/common.sh

if [ -f ${CHEF_ENV_FILE} ]; then
  source ${CHEF_ENV_FILE}
fi

service consul start

sleep 10

output="$(bash /opt/cloudconductor/bin/configure.sh)"
status=$?

if [ $status -ne 0 ] ; then
  echo $output
  exit $status
fi
