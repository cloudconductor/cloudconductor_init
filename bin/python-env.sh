#!/bin/bash -x

#script_dir=$(cd $(dirname $0) && pwd)
#root_dir=$(cd $(dirname $0)/..;pwd)
root_dir=$(pwd)

if ! which python ; then
  yum install -y python
fi

if ! which pip ; then
  curl -kL https://bootstrap.pypa.io/get-pip.py | python
fi

if ! which virtualenv ; then
  pip install virtualenv
fi

if [ ! -f ${root_dir}/.vent/bin/activate ] ; then
  cd ${root_dir}
  virtualenv --no-site-packages .venv
fi

source .venv/bin/activate

pip install -r bootstrap/packages.txt
