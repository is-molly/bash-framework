#!/bin/bash

function __readINI() {
  local INIFILE=$1;
  local SECTION=$2; 
  local ITEM=$3
  local _readIni
  _readIni=$(awk -F '=' '/['"$SECTION"']/{a=1}a==1&&$1~/'"$ITEM"'/{print $2;exit}' "$INIFILE")
  # trim
  echo "$_readIni" | grep -o "[^ ]\+\( \+[^ ]\+\)*"
}

BASE_DIR=$(__readINI conf/config.ini SYS BASE_DIR)
[ -e "${BASE_DIR}" ] && rm -rf "${BASE_DIR}"
mkdir -p "${BASE_DIR}"
mkdir -p "${BASE_DIR}"/conf

# 代理
# shellcheck disable=SC2038,SC2044
function proxy() {
  mkdir -p "${BASE_DIR}"/shell
  # init lsb sub shell
  find core/ -type f -name "*.sh" | xargs -I {} cp {} "${BASE_DIR}"/shell/
  for subShell in $(find "${BASE_DIR}"/shell/ -type f -name "*.sh");do
    echo -e "\n" >> "$subShell"
    cat >>"$subShell"<<EOF
type -t \$1 &>/dev/null
if [ \$? -ne 0 ] || [[ \$1 = "" ]];then
  param=\$(grep "^function" \$0 | grep -v 'function __' | cut -d ' ' -f 2 | cut -d '(' -f '1' | awk '{print "    " \$0}')
  echo -e "avaliable params \$1(function name): \n\$param"
  echo "[ERROR] function [\$1] not exist!" && exit 1 
fi
"\$@"
EOF
  done
  # init config
  cp -r conf/* "${BASE_DIR}"/conf/
  # init lsb
  addCommonPart
  cat >>lsb<<EOF
if [[ \$LSB_TYPE = "config" ]];then
  __readINI \${BASE_DIR}/conf/config.ini "\$@"
else
  bash \${BASE_DIR}/shell/\${LSB_TYPE}.sh "\$@"
  [ \$? -ne 0 ] && kill -15 \$PPID && exit 1  # 异常退出、继续向上抛出（kill）
fi
EOF
  chmod 777 lsb && mv lsb /usr/bin/
}

# 整合
# shellcheck disable=SC2001,SC2044
function full() {
  # init config
  cp -r conf/* "${BASE_DIR}"/conf/
  # init slb
  addCommonPart
  for sh in $(find core/ -type f -name "*.sh");do
    shContext=$(grep -v "#\!/bin/bash" < "$sh" )
    shCode=$(basename "$sh" | cut -d '.' -f 1)
    shFinalContext=$(echo "$shContext" | sed "s/\bfunction \([^__][a-zA-Z0-9_]*\)\b/function ${shCode}_\1/g")
    echo -e "\n" >> lsb
    cat >>lsb <<EOF
$shFinalContext
EOF
  done
  echo -e "\n" >> lsb
  cat >>lsb<<EOF
if [[ \$LSB_TYPE = "config" ]];then
  __readINI \${BASE_DIR}/conf/config.ini "\$@"
else
  funName=\${LSB_TYPE}_\$1
  type -t \$funName &>/dev/null
  if [ \$? -ne 0 ] || [[ \$funName = "" ]];then
    param=\$(grep "^function" \$lsbPath | grep -v 'function __' | grep "^function \${LSB_TYPE}_" | cut -d ' ' -f 2 | cut -d '(' -f '1' | awk -v pattern="\${LSB_TYPE}_" '{gsub("^" pattern,"",\$0);print}' | awk '{print "    " \$0}')
    [[ ! \$param == "" ]] && echo -e "avaliable params \$1(function name): \n\$param"
    echo "[ERROR] function [\$1] not exist!" && exit 1 
  fi
  shift
  \$funName "\$@"
fi
EOF
  chmod 777 lsb && mv lsb /usr/bin/
}

function addCommonPart() {
  cat >>lsb<<EOF
#!/bin/bash
readonly lsbPath=\$(whereis lsb | cut -d ' ' -f 2)
readonly BASE_DIR=${BASE_DIR}
readonly LSB_TYPE=\$1
shift

[ ! -e \$lsbPath ] && echo "[ERROR] Environment variables not set for lsb!" && exit 1

trap "kill -15 \$PPID;exit 1" 15  # 捕获异常，向上抛出（kill）

function __readINI() {
  local INIFILE=\$1;
  local SECTION=\$2; 
  local ITEM=\$3
  local _readIni=\$(awk -F '=' '/['\$SECTION']/{a=1}a==1&&\$1~/'\$ITEM'/{print \$2;exit}' \$INIFILE)
  # trim
  echo \$_readIni | grep -o "[^ ]\+\( \+[^ ]\+\)*"
}
EOF
  echo -e "\n" >> lsb
}

case "$1" in
proxy)
  proxy
  ;;
full)
  full
  ;;
*)
  echo "[ERROR] Plase usage: $0 {proxy|full}"  && exit 1
  ;;
esac
