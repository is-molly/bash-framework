#!/bin/bash
#########################
# @desc   日志记录
# @author monap
# @since  2024/03/28
#########################

function __logDeclare() {
  SYS_LOG_LOG_DIR=$(lsb config LOG LOG_DIR)
  SYS_LOG_LOG_LEVEL=$(lsb config LOG LOG_LEVEL)
  SYS_LOG_TRIM="lsb string trim"
  SYS_LOG_NOW_TIME_STR="date -d today +'%Y-%m-%d %H:%M:%S'"
  SYS_LOG_A_NOTBLACK="lsb annotation A_NotBlank"
  [[ ! -d ${SYS_LOG_LOG_DIR} ]] && mkdir -p "${SYS_LOG_LOG_DIR:?}"
  # ERROR < WARN < INFO < DEBUG
  case ${SYS_LOG_LOG_LEVEL} in
    "ERROR" ) SYS_LOG_LOG_LEVEL=0 ;;
    "WARN"  ) SYS_LOG_LOG_LEVEL=1 ;;
    "INFO"  ) SYS_LOG_LOG_LEVEL=2 ;;
    "DEBUG" ) SYS_LOG_LOG_LEVEL=3 ;;
    "SYSTEM") SYS_LOG_LOG_LEVEL=4 ;;
    "*") SYS_LOG_LOG_LEVEL=2 ;;
  esac
}

# debug级别的日志
# 默认关闭,debug级别的日志会忽略
# @param $1 执行脚本
# @param $2 行号
# @param $3 所在方法
# @parma $4~ 日志内容
function debug(){
  __logDeclare
  eval "$SYS_LOG_A_NOTBLACK \"$1\""
  eval "$SYS_LOG_A_NOTBLACK \"$2\""
  eval "$SYS_LOG_A_NOTBLACK \"$3\""
  eval "$SYS_LOG_A_NOTBLACK \"$4\""
  local LOG_HEADER
  LOG_HEADER="[$(eval "$SYS_LOG_NOW_TIME_STR")][ERROR][<$1 $2> $3()]"
  shift 3
  if [[ ${SYS_LOG_LOG_LEVEL} -ge 3 ]];then
    echo -e "${LOG_HEADER}:   $*"|$SYS_LOG_TRIM 1>&2
    echo -e "${LOG_HEADER}:   $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).debug.log" 2>&1
    echo -e "${LOG_HEADER}:   $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).log" 2>&1
    exit 0
  fi
}

# info级别的日志
# @param $1 执行脚本
# @param $2 行号
# @param $3 所在方法
# @parma $4~ 日志内容
function info(){
  __logDeclare
  eval "$SYS_LOG_A_NOTBLACK \"$1\""
  eval "$SYS_LOG_A_NOTBLACK \"$2\""
  eval "$SYS_LOG_A_NOTBLACK \"$3\""
  eval "$SYS_LOG_A_NOTBLACK \"$4\""
  if [[ ${SYS_LOG_LOG_LEVEL} -ge 2 ]];then
    local LOG_HEADER
    LOG_HEADER="[$(eval "$SYS_LOG_NOW_TIME_STR")][ERROR][<$1 $2> $3()]"
    shift 3
    echo -e "\\033[37m${LOG_HEADER}:    $*\\033[0m"|$SYS_LOG_TRIM 1>&2
    echo -e "${LOG_HEADER}:    $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).info.log"  2>&1
    echo -e "${LOG_HEADER}:    $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).log"  2>&1
    exit 0
  fi
}

# warn级别的日志
# @param $1 执行脚本
# @param $2 行号
# @param $3 所在方法
# @parma $4~ 日志内容
function warn(){
  __logDeclare
  eval "$SYS_LOG_A_NOTBLACK \"$1\""
  eval "$SYS_LOG_A_NOTBLACK \"$2\""
  eval "$SYS_LOG_A_NOTBLACK \"$3\""
  eval "$SYS_LOG_A_NOTBLACK \"$4\""
  if [[ ${SYS_LOG_LOG_LEVEL} -ge 2 ]];then
    local LOG_HEADER
    LOG_HEADER="[$(eval "$SYS_LOG_NOW_TIME_STR")][ERROR][<$1 $2> $3()]"
    shift 3
    echo -e "\033[33m${LOG_HEADER}:    $*\033[0m"|$SYS_LOG_TRIM 1>&2
    echo -e "${LOG_HEADER}:    $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).info.log" 2>&1
    echo -e "${LOG_HEADER}:    $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).log" 2>&1
    exit 0
  fi
}

# error级别的日志,会使父进程退出
# @param $1 执行脚本
# @param $2 行号
# @param $3 所在方法
# @parma $4~ 日志内容
function error(){
  __logDeclare
  eval "$SYS_LOG_A_NOTBLACK \"$1\""
  eval "$SYS_LOG_A_NOTBLACK \"$2\""
  eval "$SYS_LOG_A_NOTBLACK \"$3\""
  eval "$SYS_LOG_A_NOTBLACK \"$4\""
  if [[ ${SYS_LOG_LOG_LEVEL} -ge 0 ]];then
    local LOG_HEADER
    LOG_HEADER="[$(eval "$SYS_LOG_NOW_TIME_STR")][ERROR][<$1 $2> $3()]"
    shift 3
    echo -e "\\033[31m${LOG_HEADER}:   $*\\033[0m"|$SYS_LOG_TRIM 1>&2
    echo -e "${LOG_HEADER}:   $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).error.log" 2>&1
    echo -e "${LOG_HEADER}:   $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).log" 2>&1
    kill -15 $PPID
  fi
}

# 用来标识成功状态的,用绿色
# @param $1 执行脚本
# @param $2 行号
# @param $3 所在方法
# @parma $4~ 日志内容
function success(){
  __logDeclare
  eval "$SYS_LOG_A_NOTBLACK \"$1\""
  eval "$SYS_LOG_A_NOTBLACK \"$2\""
  eval "$SYS_LOG_A_NOTBLACK \"$3\""
  eval "$SYS_LOG_A_NOTBLACK \"$4\""
  if [[ ${SYS_LOG_LOG_LEVEL} -ge 2 ]];then
    local LOG_HEADER
    LOG_HEADER="[$(eval "$SYS_LOG_NOW_TIME_STR")][SUCCESS][<$1 $2> $3()]"
    shift 3
    echo -e "\\033[32m${LOG_HEADER}: $*\\033[0m"|$SYS_LOG_TRIM 1>&2
    echo -e "${LOG_HEADER}: $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).info.log" 2>&1
    echo -e "${LOG_HEADER}: $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).log" 2>&1
    exit 0
  fi
}

# bash-framework内部系统级别的日志
# @param $1 执行脚本
# @param $2 行号
# @param $3 所在方法
# @parma $4~ 日志内容
function system(){
  __logDeclare
  eval "$SYS_LOG_A_NOTBLACK \"$1\""
  eval "$SYS_LOG_A_NOTBLACK \"$2\""
  eval "$SYS_LOG_A_NOTBLACK \"$3\""
  eval "$SYS_LOG_A_NOTBLACK \"$4\""
  if [[ ${SYS_LOG_LOG_LEVEL} -ge 4 ]];then
    local LOG_HEADER
    LOG_HEADER="[$(eval "$SYS_LOG_NOW_TIME_STR")][SYSTEM][<$1 $2> $3()]"
    shift 3
    echo -e "${LOG_HEADER}:    $*"|$SYS_LOG_TRIM 1>&2
    echo -e "${LOG_HEADER}:    $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).info.log" 2>&1
    echo -e "${LOG_HEADER}:    $*"|$SYS_LOG_TRIM >> "${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d).log" 2>&1
    exit 0
  fi
}

# 用来标识追踪日志
# 日志只会输出到日志文件中,不会输出在控制台上,默认开启
# @param $1 执行脚本
# @param $2 行号
# @param $3 所在方法
# @parma $4~ 日志内容
function trace(){
  __logDeclare
  eval "$SYS_LOG_A_NOTBLACK \"$1\""
  eval "$SYS_LOG_A_NOTBLACK \"$2\""
  eval "$SYS_LOG_A_NOTBLACK \"$3\""
  eval "$SYS_LOG_A_NOTBLACK \"$4\""
  local LOG_HEADER
  LOG_HEADER="[$(eval "$SYS_LOG_NOW_TIME_STR")][TRACE][<$1 $2> $3()]"
  shift 3
  echo -e "${LOG_HEADER}:   $*"|$SYS_LOG_TRIM >>"${SYS_LOG_LOG_DIR}/$(date +%Y-%m-%d)".trace.log 2>&1
  exit 0
}