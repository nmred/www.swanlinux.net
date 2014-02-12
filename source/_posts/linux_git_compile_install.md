title: git编译安装
date: 2014-02-12 18:13:16
tags: GIT
categories: linux
---

###下载git源码：

	$wget http://down1.chinaunix.net/distfiles/git-1.7.9.7.tar.gz

###安装依赖的软件包：

	$yum -y install curl-devel expat-devel gettext-devel  openssl-devel zlib-devel

###配置编译安装:
	
	$./configure –prefix=/usr/local
	$make && make install

