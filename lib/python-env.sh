#!/bin/sh
# Copyright 2014-2015 TIS Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source /opt/cloudconductor/lib/run-base.sh

python_exec() {
  work_dir=$(pwd)

  run which python
  if [ $status -ne 0 ] ; then
    run yum install -y python
    if [ $status -ne 0 ] ; then
      echo $output >&2
      return 1
    fi
  fi

  run which pip
  if [ $status -ne 0 ] ; then
    run bash -c "curl -kL https://bootstrap.pypa.io/get-pip.py | python"
    if [ $status -ne 0 ] ; then
      echo $output >&2
      return 1
    fi
  fi

  run which virtualenv
  if [ $status -ne 0 ] ; then
    run pip install virtualenv
    if [ $status -ne 0 ] ; then
      echo $output >&2
      return 1
    fi
  fi

  if [ ! -f ${work_dir}/.vent/bin/activate ] ; then
    run bash -c "cd ${work_dir} && virtualenv --no-site-packages .venv"
    if [ $status -ne 0 ] ; then
      echo $output >&2
      return 1
    fi
  fi

  source .venv/bin/activate

  run pip install -r /opt/cloudconductor/python-packages.txt
  if [ $status -ne 0 ] ; then
    echo $output >&2
    deactivate
    return 1
  fi

  run python $@
  if [ $status -ne 0 ] ; then
    deactivate
    return 1
  fi
  echo $output

  deactivate
}
