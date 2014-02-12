title: rrdtool画图时提示字体找不到的错误解决方法
date: 2013-02-12 18:13:16
tags: rrdtool 
categories: linux
---

提示错误如下：

![linux-rrdtool-001-020][linux-rrdtool-001-020]

原文：

>Recently we did an upgrade to CentOS 5.3 and rrdtool stopped working, specifically, rrdgraph. The reason is that there is no font installed in the system (not sure why, you can check it via “fc-list”). To fix this, do an “yum install xorg-x11-fonts-Type1″ and make sure you see some fonts listed in “fc-list”. Also assume you already have fontconfig.

用YUM安装xorg-x11-fonts-Type1

[linux-rrdtool-001-020]: /image/linux/linux-rrdtool-001-020.png
