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
  SYS_SSH_SSH_TIME_OUT="5"
  # check expect
  ! expect -v &>/dev/null && eval "$SYS_SSH_LOG_ERROR \"please install expect first!\""
}

# 检查机器登陆状态
# @param ip   登陆ip地址
# @param port 登陆端口号
# @param user 登陆账号
# @param pass 登陆密码
function __sshCheckLogin() {
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
  msg=$(expect << EOF
    set timeout $SYS_SSH_SSH_TIME_OUT
    spawn ssh -p ${port} ${user}@${ip} 'pwd'
    expect {
      "*yes/no*"   { send "yes\r"; exp_continue }
      "*assword*" { send "${pass}\r";exp_continue }
      "*${user}*" { exit 0 }
      timeout { exit 1 }
      eof { exit 1 }
    }
EOF
)
  local status=$?
  msg=$(echo "$msg" | tail -n2 | tr '\r' ';' | tr -d '\n')
  if [ $status -ne 0 ]; then
    eval "$SYS_SSH_LOG_ERROR \"login fail: $msg\""
  fi
}

# @param ip   登陆ip地址
# @param port 登陆端口号
# @param port 登陆账号
# @param pass 登陆密码
# 登陆远程机器 []<-(ip:String,port:Int,pass:String)
# 注意：bash-framework的proxy打包模式无法使用该函数！该函数需要终端保持，代理模式的代理脚本执行完成后会结束！
function sshLogin() {
  __sshDeclare
  local ip=$1
  local port=$2
  local user=$3
  local pass=$4
  __sshCheckLogin "${ip}" "${port}" "${user}" "${pass}" || return
  expect -c "
    set timeout $SYS_SSH_SSH_TIME_OUT
    spawn ssh -p ${port} ${user}@${ip}
    expect {
      \"*yes/no*\"   { send \"yes\r\"; exp_continue }
      \"*password*\" { send \"${pass}\r\" }
      \"*Connection closed by remote host*\" { exit 1 }
      timeout {exit 2}
    }
    interact
  "
}

# @param ip   登陆ip地址
# @param port 登陆端口号
# @param port 登陆账号
# @param pass 登陆密码
# @param time_out 超时时间
# 执行远程命令 [String]<-(ip:String,port:Int,pass:String,time_out:int,cmd:String)
function sshExec() {
  __sshDeclare
  eval "$SYS_SSH_A_NOTBLACK \"$5\" 'timeout can not be null'"
  eval "$SYS_SSH_A_NOTBLACK \"$6\" 'cmd can not be null'"
  local ip=$1
  local port=$2
  local user=$3
  local pass=$4
  local time_out=$5
  local cmd=$6
  __sshCheckLogin "${ip}" "${port}" "${user}" "${pass}" || return
  expect << EOF
    log_user 0
    set timeout $time_out
    spawn ssh -p ${port} ${user}@${ip} ${cmd}
    expect {
      "*yes/no*"   { send "yes\r"; exp_continue }
      "*assword*" { send "${pass}\r"; exp_continue }
      "*Connection closed by remote host*" { exit 1 }
      timeout { exit 2 }
      eof {
        log_user 1
        puts \$expect_out(buffer)
        exit 0
      }
    };
    expect eof
    exit [lindex [wait] 3]
EOF
}

# @param ip   登陆ip地址
# @param port 登陆端口号
# @param pass 登陆密码
# @param time_out 超时时间
# @param dir  上传到远程服务器的目录
# @param files 待上传的文件,可写多个
# 执行远程命令 [String]<-(ip:String,port:Int,pass:String,time_out:int,dir:String,...files:String)
function sshUpload() {
  __sshDeclare
  eval "$SYS_SSH_A_NOTBLACK \"$5\" 'timeout can not be null'"
  eval "$SYS_SSH_A_NOTBLACK \"$6\" 'target dir can not be null'"
  eval "$SYS_SSH_A_NOTBLACK \"$7\" 'files can not be null'"
  local ip=$1
  local port=$2
  local user=$3
  local pass=$4
  local time_out=$5
  local dir=$6
  shift 6
  local files=$*
  __sshCheckLogin "${ip}" "${port}" "${user}" "${pass}" || return
  expect << EOF
    set timeout $SYS_SSH_SSH_TIME_OUT
    # 先判断目录存不存在,不存在则新建之
    spawn ssh -p ${port} ${user}@${ip}
    expect {
      "*yes/no*"   { send "yes\r"; exp_continue }
      "*assword*" { send "${pass}\r" }
      "*Connection closed by remote host*" {exit 1}
      timeout {exit 2}
    };
    expect *${user}@* { send "\[ -d ${dir} \] && echo exist || mkdir -p ${dir} ; exit \r"};
    # scp上传文件
    set timeout $time_out
    spawn scp -r -P ${port} ${files} ${user}@${ip}:${dir};
    expect {
      "*yes/no*"   { send "yes\r"; exp_continue }
      "*assword*" { send "${pass}\r"; exp_continue }
      timeout {exit 2}
      eof { exit 0 }
    };
    expect eof
    exit [lindex [wait] 3]
EOF
}
