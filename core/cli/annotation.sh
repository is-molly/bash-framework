#!/bin/bash
#########################
# @desc   校验注解
# @author monap
# @since  2024/04/09
#########################

# shellcheck disable=SC2016
function __annotationDeclare() {
  SYS_ANNOTATION_TRIM="lsb string trim"
  SYS_ANNOTATION_LOG_ERROR='lsb log error $0 ${BASH_LINENO} ${FUNCNAME}'
  SYS_ANNOTATION_A_NOTBLACK="lsb annotation A_NotBlank"
}

# 判断传入参数是否为空
# @param $1 参数值
# @param $2 err_msg
function A_NotBlank() {
  __annotationDeclare
  local param
  local err_msg=$2
  param=$(echo "$1" | $SYS_ANNOTATION_TRIM)
  err_msg=${err_msg:-'parameter can not be null'}
  [[ -z "${param}" ]] && eval "$SYS_ANNOTATION_LOG_ERROR \"${err_msg}\"" || exit 0
}

# 判断传入参数是否为自然数
# @param $1:参数值
# @param $2 err_msg
function A_Natural() {
  __annotationDeclare
  local param=$1
  local err_msg=$2
  err_msg=${err_msg:-'parameter must be numeric'}
  ! grep -q '^[[:digit:]]*$' <<<"${param}" && eval "$SYS_ANNOTATION_LOG_ERROR \"${err_msg}\"" || exit 0
}

# 最大不得小于此最小值
# @param $1 最小值
# @param $2 参数值
# @param $3 err_msg
function A_Min() {
  __annotationDeclare
  eval "$SYS_ANNOTATION_A_NOTBLACK \"$1\""
  eval "$SYS_ANNOTATION_A_NOTBLACK \"$2\""
  local err_msg=$3
  err_msg=${err_msg:-"value can not be less than $1"}
  # $2:参数值 < $1:最小值
  # 注意bc计算器0代表假，1代表真
  [[ $(echo "$2 <= $1" | bc) -eq 1 ]] && eval "$SYS_ANNOTATION_LOG_ERROR \"${err_msg}\"" || exit 0
}

# 最大不得超过此最大值
# @param $1 最大值
# @param $2 参数值
# @param $3 err_msg
function A_Max() {
  __annotationDeclare
  eval "$SYS_ANNOTATION_A_NOTBLACK \"$1\""
  eval "$SYS_ANNOTATION_A_NOTBLACK \"$2\""
  local err_msg=$3
  err_msg=${err_msg:-"value can not be bigger than  $1"}
  # $2:参数值 > $1:最大值
  # 注意bc计算器0代表假，1代表真
  [[ $(echo "$2 >= $1" | bc) -eq 1 ]] && eval "$SYS_ANNOTATION_LOG_ERROR \"${err_msg}\"" || exit 0
}
