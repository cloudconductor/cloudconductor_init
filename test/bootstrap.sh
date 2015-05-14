#!/bin/sh

LANG=en_US.UTF-8

rm -r -f /opt/cloudconductor/patterns/**/

export PATTERN_NAME="tomcat_cluster_pattern"
export PATTERN_URL="https://github.com/cloudconductor-patterns/${PATTERN_NAME}.git"
export PATTERN_REVISION="develop"
export ROLE="web,ap"
export CONSUL_SECRET_KEY="MXGqE1yFQnwdZvyteIGCAg=="
/bin/sh /opt/cloudconductor/bin/init.sh

rm /opt/cloudconductor/config

echo "ROLE=${ROLE}" >> /opt/cloudconductor/config
if [ "${CONSUL_SECRET_KEY}" != "" ] ; then
  echo "CONSUL_SECRET_KEY=${CONSUL_SECRET_KEY}" >> /opt/cloudconductor/config 
fi

service consul start

sleep 5

/shared/setup_scripts/cloudconductor/attributes.sh

/bin/sh /opt/cloudconductor/bin/configure.sh
