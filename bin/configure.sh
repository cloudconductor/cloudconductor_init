#!/bin/sh

CONDUCTOR_DIR="/opt/cloudconductor"
BIN_DIR="${CONDUCTOR_DIR}/bin"
CONFIG_DIR="${CONDUCTOR_DIR}/etc"
TMP_DIR="${CONDUCTOR_DIR}/tmp"
LOG_DIR="${TMP_DIR}/logs"
FILE_CACHE_DIR="${TMP_DIR}/cache"

mkdir -p ${TMP_DIR}
mkdir -p ${LOG_DIR}
mkdir -p ${FILE_CACHE_DIR}

#TODO: register eventlo

#TODO: register services

ruby ${BIN_DIR}/configure.rb

cd ${CONDUCTOR_DIR}
chef-solo -j ${CONFIG_DIR}/node_configure.json -c ${CONFIG_DIR}/solo.rb

#TODO: register eventlog
