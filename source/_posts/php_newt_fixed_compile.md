title: 编译PHP中newt扩展库
date: 2013-09-14 18:13:16
tags: newt 
categories: php
---

最近做个类似于linux下setup命令出来的纯文本界面，想到了用newt扩展库，但是这个库网上的资料仅仅是PHP: Newt – Manual，在编译过程中遇到了一些问题，现在把整个编译过程叙述一下：

1.将源码放到php的ext目录下，执行phpize命令

2.进行配置：

a、newt扩展库需要ncurses和slang这个两个库，并且依赖red hat 的C语言newt、newt-devel在配置前必须注意这四个库的存在。

b、newt安装前configuer

```
	[root@nmred ~]# ./configure –with-curses-dir=/usr/lib/libncurses.so –with-slang-dir=/usr/lib/libslang.so.2 –enable-newt=shared
	[root@nmred ~]# make && make install
```

具体newt开发可以参考一些C中的newt资料：

http://people.redhat.com/~rjones/ocaml-newt/html/Newt_int.html#TYPEnewtFlagsSense

[NEWT 程序设计指南][Newt-C] 

以后随着开发的进行将会更新详细的newt用法

[NEWT-c]: http://www.ibm.com/developerworks/cn/linux/guitoolkit/newt/
