#! /bin/sh

test_root=$(cd $(dirname $0)/.. ; pwd)

source /opt/cloudconductor/lib/common.sh

if ! which ruby ; then
  if [ -f /etc/profile.d/chef.sh ] ; then
    source /etc/profile.d/chef.sh
  fi
fi

CONSUL_SECRET_KEY_ENCODED=$(ruby -e "require 'cgi'; puts CGI::escape('${CONSUL_SECRET_KEY}')")

json_file=${test_root}/data/attributes.json

json=$(cat ${json_file} | jq '.' -c)

service consul start

sleep 5

curl --noproxy localhost -XPUT -d "$json" http://localhost:8500/v1/kv/cloudconductor/parameters?token=${CONSUL_SECRET_KEY_ENCODED}
