title: Linux 系统网络设置及常用命令
date: 2013-02-12 18:13:16
tags: network 
categories: linux
---

###设置网络

1.设置ip/netmask

1)临时设置：

	[root@nmred ~]# ifconfig eth0 192.168.216.2

2)永久设置

2.设置DNS

文件中最多可以有3个“nameserver”配置记录

系统会优先使用文件中前面的“nameserver”配置记录

当前面的DNS服务器无效时系统会自动使用后面的DNS服务器进行域名解析

3.设置网关gateway

1)临时设置：

	[root@nmred ~]# route add defalut gw 192.168.216.10

2)永久设置（配置文件和IP的一样）

4.主机名修改

1)临时设置：

	[root@nmred ~]# hostname localhostnmred

2)永久设置
