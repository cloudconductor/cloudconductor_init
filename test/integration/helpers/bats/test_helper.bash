#!/usr/bin/env bash

setup() {
  LANG=en_US.UTF-8
}

assert_equal() {
  if [ "$1" != "$2" ] ; then
    echo "expected: $1"
    echo "actual:   $2"
    return 1
  fi
}

assert_output() {
  assert_equal "$1" "$output"
}

assert_success() {
  if [ $status -ne 0 ] ; then
    echo "command failed with exit status $status"
    echo ${output}
    return 1
  elif [ "$#" -gt 0 ] ; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ $status -eq 0 ] ; then
    echo "expected failed exit status"
    echo ${output}
    return 1
  elif [ "$#" -gt 0 ] ; then
    assert_output "$1"
  fi
}

assert_file_exists() {
  if [ ! -f $1 ] ; then
    echo "file not exists: ${1}"
    return 1
  fi
}

assert_directory_exists() {
  if [ ! -d $1 ] ; then
    echo "directory is not exists: ${1}"
    return 1
  fi
}
