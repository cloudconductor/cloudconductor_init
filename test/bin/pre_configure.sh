#! /bin/sh
echo ROLE=${ROLE} >> /opt/cloudconductor/config

source /opt/cloudconductor/lib/common.sh

source ${CHEF_ENV_FILE}

service consul start

sleep 5

/opt/cloudconductor/bin/configure.sh
