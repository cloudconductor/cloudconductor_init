#!/bin/sh

source /opt/cloudconductor/lib/common.sh
LOG_FILE=${LOG_DIR}/bootstrap_script.log

run() {
  output="$("$@" 2>&1)"
  status="$?"
  oldIFS=$IFS
  IFS=$'\n' lines=($output)
  IFS=$oldIFS
}

package() {
  action=$1
  name=$2
  options=$3

  case $action in
    install )
      run bash -c "yum list installed | grep '${name}\.'"
      info=${output}
      if [ $status -eq 0 ] ; then
        log_info "yum_package[${name}] installed ${name} at ${info[1]}. (skip)"
        return 0
      fi

      run yum install -y ${options} "$name"

      if [ $status -ne 0 ] ; then
        log_error "yum_package[${name}] install failed."
        log_error $output
        return $status
      fi
      log_info "yum_package[${name}] installed ${name} at ${info[1]}."
    ;;
    erase )
      yum list installed | grep "$name" && yum erase -y ${options} "$name"
      status=$?
      if [ $status -ne 0 ] ; then
        log_error "yum_package[${name}] erase failed."
        return $status
      fi
      log_info "yum_package[${name}] erased."
    ;;
  esac
}

directory() {
  path=$1
  owner=$2
  mode=$3

  mkdir -p $path || return $?
  log_info "directory[${path}] created."
  chown $owner $path || return $?
  chmod $mode $path || return $?
}

file_copy() {
  src_path=$1
  to_path=$2
  owner=$3
  mode=$4

  cp $src_path $to_path || return $?
  log_info "file_copy[${to_path}] copied from ${src_path}."
  chown $owner $to_path || return $?
  chmod $mode $to_path || return $?
}

link() {

  ln -s -f $1 $2
  status=$?
  if [ $status -ne 0 ] ; then
    log_error "link[${2}] create failed."
    return $status
  fi
  log_info "link[${2}] created."
}

remote_file() {
  remote_url=$1
  to_path=$2

  run which wget
  if [ $status -eq 0 ] ; then
    run wget -O ${to_path} ${remote_url}
  fi

  if [ $status -ne 0 ] ; then
    echo $output >&2
  fi

  return $status
}

git_checkout() {
  repository=$1
  path_to_dir=$2
  branch_start_point=$3

  log_info "git cloning repo ${repository} to ${path_to_dir}"

  if [ "${repository}" != "" ] ; then
    git clone ${repository} ${path_to_dir}
    cd ${path_to_dir}
    if [ $? -eq 0 ] ; then
      git checkout master
      git branch -a | grep deploy && git branch -d deploy

      if git branch -a | grep ${branch_start_point} ; then
        git checkout -f -b deploy origin/${branch_start_point}
        status=$?
        log_info "git [${path_to_dir}] checked out branch ${branch_start_point} onto deploy."
      else
        git checkout -f -b deploy ${branch_start_point}
        status=$?
        log_info "git [${path_to_dir}] checked out branch ${branch_start_point} onto deploy."
      fi

    fi
  fi
}

