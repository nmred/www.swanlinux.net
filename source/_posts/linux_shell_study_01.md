title: Linux 系统 Shell 编程一
date: 2013-02-12 18:13:16
tags: shell 
categories: linux
---

###Shell 变量

用户自定义变量：由用户自己定义、修改和使用

- 环境变量：由系统维护，用于设置用户的Shell工作环境，只有极少数的变量用户可以修改
- 预定义变量：Bash预定义的特殊变量，不能直接修改
- 位置变量：通过命令行给程序传递执行参数


**变量的赋值与引用**

a.定义新的变量

变量名要以英文字母或下划线开头，区分大小写

格式：变量名=变量值

b.查看变量的值

格式：echo $变量名

	[root@swan ~]# DAY="SunDay"
	[root@swan ~]# echo DAY
	DAY
	[root@swan ~]#

c.从键盘输入内容为变量赋值

格式： read [-p "信息"] 变量名

d.结合不同的引号为变量赋值

双引号 “ ” ：允许通过$符号引用其他变量值

单引号 ‘ ’ ：禁止引用其他变量值，$视为普通字符

反撇号 \` \` ：将命令执行的结果输出给变量

	#!/bin/bash

	read -p "Please input a username:" USERNAME

	echo $USERNAME

	echo "------------------"

	echo "$USERNAME"

	echo '$USERNAME'

	echo `pwd`

运行结果：

	[root@swan ~]# ./var1.sh
	Please input a username:nmred
	nmred
	------------------
	nmred
	$username
	/root
	[root@swan ~]#

e.设置变量的作用范围

格式：export 变量名…

export 变量名=变量值 [...变量名n=变量值n]

f.清除用户定义的变量

格式：unset 变量名

	[root@swan ~]# set | grep str1
	[root@swan ~]# str1="nmredtest"
	[root@swan ~]# set | grep str1
	str1=nmredtest
	[root@swan ~]# echo $str1
	nmredtest
	[root@swan ~]# export str1
	[root@swan ~]# env |grep str1
	str1=nmredtest
	[root@swan ~]# unset str1
	[root@swan ~]# echo $str1

	[root@swan ~]#

g.数值变量的运算

格式：expr 变量1 运算符 变量2 …[运算符 变量n]

expr的常用运算符

加法运算：+

减法运算： -

乘法运算： \*

除法运算： /

求模（取余）运算： %

	[root@swan ~]# expr 2 + 4
	6
	[root@swan ~]# expr 2 - 4
	-2
	[root@swan ~]# expr 2 \* 4
	8
	[root@swan ~]# expr 2 / 4
	0
	[root@swan ~]# expr 2 % 4
	2
	[root@swan ~]#

**环境变量**

a.环境变量配置文件

>全局配置文件：/etc/profile

>用户配置文件：~/.bash_profile

b.查看环境变量

>set命令可以查看所有的Shell变量，其中包括环境变量

c.常见的环境变量：

>$USER 、$LOGNAME

> $UID 、 $SHELL 、$HOME

>$PWD、 $PATH

>$PS1、$PS2

其中PS1是[\u@\h \W]\$设置这个变量可以调整命令行前缀

	[root@swan ~]# echo $USER
	root
	[root@swan ~]# echo $PATH
	/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
	[root@swan ~]# echo $PS1
	[\u@\h \W]\$
	[root@swan ~]# PS1="[\\W]\\$"
	[~]#
	[~]#
	[~]#PS1="[\u@\h \W]\$"
	[root@swan ~]$

**位置变量**

表示为 $n，n为1~9之间的数字

	[root@swan ~]$./exam01 one two three four five six

**预定义变量**

表示形式如下

>$#：命令行中位置参数的个数
>
>$*：所有位置参数的内容
>
>$?：上一条命令执行后返回的状态，当返回状态值为0时表示执行正常，非0值表示执行异常或出错
>
>$$：当前所在进程的进程号
>
>$!：后台运行的最后一个进程号
>
>$0：当前执行的进程/程序名


###Shell编程

1、编写可执行的Shell脚本

a.建立包含执行语句的脚本文件

脚本文件中包括的内容

>运行环境设置：#!/bin/bash
>
>注释信息：以#开始的说明性文字
>
>可执行的Linux命令行

b.为脚本文件添加可执行权限

	[root@localhost ~]# vi repboot.sh
	#!/bin/bash
	# To show usage of /boot directory and mode of kernel file.
	echo “Useage of /boot: ”
	du -sh /boot
	echo “The mode of kernel file:”
	ls -lh /boot/vmlinuz-*
	[root@localhost ~]# chmod a+x repboot.sh

c.运行Shell脚本程序

1).直接执行具有“x”权限的脚本文件

例如：./repboot.sh

2).使用指定的解释器程序执行脚本内容

例如：bash repboot.sh、sh repboot.sh

3).通过source命令（或 . ）读取脚本内容执行

例如：souce repboot.sh 或 . hello.sh

###Shell编程实例

1.每周五17:30清理FTP服务器的公共共享目录检查 /var/ftp/pub/ 目录，将其中所有子目录及文件的详细列表、当时的时间信息追加保存到 /var/log/pubdir.log 日志文件中，然后清空该目录

	[root@localhost ~]# vi /opt/ftpclean.sh
	#!/bin/bash
	date >> /var/log/pubdir.log
	ls -lhR /var/ftp/pub >> /var/log/pubdir.log
	rm -rf /var/ftp/pub/*
	[root@localhost ~]# crontab -e
	30 17 * * 5 /opt/ftpclean.sh

2.每隔3天对数据库目录做一次完整备份

> 统计 /var/lib/mysql 目录占用的空间大小、查看当前的日期，并记录到临时文件 /tmp/dbinfo.txt 中
>
> 将 /tmp/dbinfo.txt 文件、/var/lib/mysql 目录进行压缩归档，备份到/opt/dbbak/目录中
>
> 备份后的包文件名中要包含当天的日期信息
>
> 最后删除临时文件/tmp/dbinfo.txt

	[root@localhost ~]# vi /opt/dbbak.sh

	#!/bin/bash

	DAY=`date +%Y%m%d`
	SIZE=`du -sh /var/lib/mysql`
	echo “Date: $DAY” >>\> tmp/dbinfo.txt
	echo “Data Size: $SIZE” >> /tmp/dbinfo.txt
	cd /opt/dbbak
	tar zcvf mysqlbak-${DAY}.tar.gz /var/lib/mysql /tmp/dbinfo.txt
	rm -f /tmp/dbinfo.txt

	root@localhost ~]# crontab -e
	55 23 */3 * * /opt/dbbak.sh

