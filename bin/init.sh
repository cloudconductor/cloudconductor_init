#!/bin/sh

CONDUCTOR_DIR="/opt/cloudconductor"
CONFIG_DIR="${CONDUCTOR_DIR}/etc"
TMP_DIR="${CONDUCTOR_DIR}/tmp"
LOG_DIR="${TMP_DIR}/logs"
FILE_CACHE_DIR="${TMP_DIR}/cache"

mkdir -p ${TMP_DIR}
mkdir -p ${LOG_DIR}
mkdir -p ${FILE_CACHE_DIR}

cd ${CONFIG_DIR}
berks vendor ${TMP_DIR}/cookbooks
cd ${CONDUCTOR_DIR}
chef-solo -j ${CONFIG_DIR}/node_setup.json -c ${CONFIG_DIR}/solo.rb
