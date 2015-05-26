#!/bin/sh

script_root=$(cd $(dirname $0) && pwd)

root_dir=$(cd $(dirname $0)/..;pwd)

lib_dir=${root_dir}/lib

source ${lib_dir}/common.sh
source ${lib_dir}/consul_config.sh
source /opt/cloudconductor/lib/python-env.sh

# checkout optional patterns, and setup consul services information of optional patterns

opt_patterns=($(python_exec ${lib_dir}/patterns.py | jq -r '.[] | .name +"|"+ .url +"|"+ .revision'))

for ptn in ${opt_patterns[@]}
do
  ptn_prm=(`echo ${ptn} | tr -s '|' ' '`)
  ptn_name=${ptn_prm[0]}
  ptn_url=${ptn_prm[1]}
  ptn_revision=${ptn_prm[2]}
  git_checkout ${ptn_url} /opt/cloudconductor/patterns/${ptn_name} ${ptn_revision} || exit $?

  link /opt/cloudconductor/patterns/${ptn_name}/logs /opt/cloudconductor/logs/${ptn_name}

  # install services
  if ls /opt/cloudconductor/patterns/${ptn_name}/services/all/*.json ; then
    cp /opt/cloudconductor/patterns/${ptn_name}/services/all/*.json ${consul_config_dir}/
  fi
done
