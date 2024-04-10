#!/bin/bash
#########################
# @desc   ssh util
# @author monap
# @since  2024/04/09
#########################

# shellcheck disable=SC2016
function __sshDeclare() {
  SYS_SSH_LOG_ERROR='lsb log error $0 ${BASH_LINENO} ${FUNCNAME}'
  SYS_SSH_LOG_SUCCESS='lsb log success $0 ${BASH_LINENO} ${FUNCNAME}'
  SYS_SSH_A_NOTBLACK="lsb annotation A_NotBlank"
  SYS_SSH_SSH_TIME_OUT="30"
  # check expect
  ! expect -v &>/dev/null && eval "$SYS_SSH_LOG_ERROR \"please install expect first!\""
}

# 检查机器登陆状态
# @param ip   登陆ip地址
# @param port 登陆端口号
# @param user 登陆账号
# @param pass 登陆密码
function sshCheckLogin() {
  __sshDeclare
  eval "$SYS_SSH_A_NOTBLACK \"$1\" 'ip can not be null'"
  eval "$SYS_SSH_A_NOTBLACK \"$2\" 'port can not be null'"
  eval "$SYS_SSH_A_NOTBLACK \"$3\" 'user can not be null'"
  eval "$SYS_SSH_A_NOTBLACK \"$4\" 'pass can not be null'"
  local ip=$1
  local port=$2
  local user=$3
  local pass=$4
  local msg
  msg=$(expect -c "
    set timeout $SYS_SSH_SSH_TIME_OUT
    spawn ssh -p ${port} ${user}@${ip} 'pwd'
    expect {
      \"*yes/no*\"   { send \"yes\r\"; exp_continue }
      \"*assword*\" { send \"${pass}\r\";exp_continue }
      \"*${user}*\" { exit 0 }
      timeout { exit 1 }
      eof { exit 1 }
    }
  ")
  local status=$?
  msg=$(echo "$msg" | tail -n2 | tr '\r' ';' | tr -d '\n')
  if [ $status -ne 0 ]; then
    eval "$SYS_SSH_LOG_ERROR \"login fail: $msg\""
  else
    eval "$SYS_SSH_LOG_SUCCESS \"login success: $msg\""
  fi
}
