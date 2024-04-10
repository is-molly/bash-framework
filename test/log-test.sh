#!/bin/bash

# shellcheck disable=SC2016
readonly logSuccess='lsb log success $0 ${BASH_LINENO} ${FUNCNAME}'
readonly logError='lsb log error $0 ${BASH_LINENO} ${FUNCNAME}'

function logTest() {
  echo "log success before"
  eval "$logSuccess \"I'm success log\""
  echo "log success after"
  echo "log error before"
  eval "$logError \"I'm error log\""
  echo "log error after"
}

logTest