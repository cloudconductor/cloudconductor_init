#!/bin/sh

run() {
  output="$("$@" 2>&1)"
  status="$?"
  oldIFS=$IFS
  IFS=$'\n' lines=($output)
  IFS=$oldIFS
}

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
