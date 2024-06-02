# Bash Framework

**bash-framework** 是一个可以帮助你更好更快的进行 Bash Shell 编程而诞生的一个 Shell 框架，同时它也是一个简单易上手的、拿来即用的Shell函数工具库。

# 目标

bash-framework的目标是最大化的减少业务代码重复量，将一切可抽取的代码都封装为函数库。如日志、字符处理、集合工具、并发执行、日期时间转换、JSON解析、SSH远程代码执行、文件上传与下载等一系类操作。

# 优点

## 无侵入性

当你执行`bash -x youScript.sh` 进行业务代码debug时，没有任何的框架脚本执行信息妨碍你排查错误。

## 易用性

一键打包所有框架脚本为一个入口可执行程序 `lsb` ，无需在各种脚本间寻找你所需要的工具函数。只需要对照 API 文档，执行如`lsb log success "I'm a success log!"` 的命令即可得到运行结果。

## 灵活性

本框架全局配置信息采用`config.ini`文件形式存储，可随时修改，随时生效，如日志级别、日志存放目录等。

## 友好性

打包所有框架脚本为可执行程序 `lsb`有两种选项即`proxy | full`

- proxy：代理模式，可执行程序 `lsb`只是一个代理程序，具体的框架脚本仍在自定义的配置目录中存放，方便线上debug排查问题。
- full：整体打包模式，所有框架脚本被打包进 `lsb`中，可对该 `lsb`脚本程序进行加密或扰乱编码处理，使之成为一个真正的二进制程序，更加安全可靠！使用于给客户机器部署使用的场景。

> 注意：
> bash-framework的proxy打包模式无法使用sshLogin函数！该函数需要终端保持，代理模式的代理脚本执行完成后会结束！

# 使用说明

## 前置依赖

- expect
- bc

## 构建与使用

```shell
# clone代码到目标Linux机器任意目录如/root
git clone https://github.com/is-molly/bash-framework.git
# 执行初始化
cd /root/bash-framework
bash init.sh [proxy|full]
# 执行初始化命令后，默认将产生一个/usr/bin/lsb可执行程序

# 参考下面手册，在你的业务脚本中自由的探索这个强大的`lsb` 命令吧！
```

# API手册

| 模块名 | 方法名 | 参数                                                         | 使用范例                                                     |
| ------ | ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| log    | debug  | `$1：`当前脚本名<br />`$2：`当前行<br />`$3：`当前方法名<br />`$4：`日志信息 | lsb log debug $0 ${BASH_LINENO} ${FUNCNAME} "I'm a debug log" |
| log    | info   | `$1：`当前脚本名<br />`$2：`当前行<br />`$3：`当前方法名<br />`$4：`日志信息 | lsb log info $0 ${BASH_LINENO} ${FUNCNAME} "I'm a info log"  |
| log    | warn   | `$1：`当前脚本名<br />`$2：`当前行<br />`$3：`当前方法名<br />`$4：`日志信息 | lsb log warn $0 ${BASH_LINENO} ${FUNCNAME} "I'm a warn log"  |
| log    | error  | `$1：`当前脚本名<br />`$2：`当前行<br />`$3：`当前方法名<br />`$4：`日志信息 | lsb log warn $0 ${BASH_LINENO} ${FUNCNAME} "I'm a error log" |

