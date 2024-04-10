#!/bin/bash
#########################
# @desc   string util
# @author monap
# @since  2024/03/28
#########################

# 去掉字符串前后空格
# @param String 待处理字符串
# @return String 处理后字符串
function trim(){
  local param=$*
  if [[ ${#param} -eq 0 ]];then
    param=$(timeout 0.1 cat <&0)
  fi
  echo -e "${param}" | grep -o "[^ ]\+\( \+[^ ]\+\)*"
}

# ""  -> 0
# " " -> 1
# "1" -> 1
#  1  -> 1
# @param String 待判断字符串
# @return Boolean 是否为空
function isEmpty(){
  local param=$1
  # if[[ -z ${value} ]] 中 -z 代表判断字符串的长度是否为0
  [[ -z "${param}" ]]
}

# ""  -> 1
# " " -> 0
# "1" -> 0
#  1  -> 0
# @param String 待判断字符串
# @return Boolean 是否不为空
function isNotEmpty(){
  local param=$1
  [[ -n "${param}" ]]
}

# ""  -> 0
# " " -> 0
# "1" -> 1
#  1  -> 1
# @param String 待判断字符串
# @return Boolean 是否为空
function isBlank(){
  local param=$1
  param=$(echo "$1" | tr -d " ")
  [[ -z "${param}" ]]
}

# ""  -> 1
# " " -> 1
# "1" -> 0
#  1  -> 0
# @param String 待判断字符串
# @return Boolean 是否不为空
function isNotBlank(){
  local param=$1
  param=$(echo "$1" | tr -d " ")
  [[ -n "${param}" ]]
}