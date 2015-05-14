#!/bin/bash -x

source /opt/cloudconductor/lib/common.sh

script_dir=$(cd $(dirname $0) && pwd)

if ! which ruby ; then
  source ${script_dir}/chef-env.sh

  path=$([ -L $(which chef-solo) ] && readlink $(which chef-solo) || which chef-solo)
  chef_home=$(cd ${path%/*}/.. && pwd)

  ruby_home=${chef_home}/embedded/bin
  echo "export PATH=\$PATH:/opt/chefdk/embedded/bin" > ${CHEF_ENV_FILE}
  export PATH=${ruby_home}:${PATH}
fi
