title: Linux 系统中文件共享之 Samba
date: 2013-02-12 18:13:16
tags: samba 
categories: linux
---

###Samba服务器的服务程序

Samba服务器包括两个服务程序

>smbd服务程序为客户机提供了服务器中共享资源的访问
>
>nmbd服务程序提供了NetBIOS主机名称的解析

###Samba安装与配置

1、安装Samba运用程序

	[root@nmred pub]# yum install -y samba* –skip-broken

注意：–skip-broken是跳过错误依赖包

2、配置Samba

smb.conf

Samba服务器的主配置文件是smb.conf，保存在目录“/etc/samba/”中

文件中注释行使用“#”开始，是对配置内容的说明文字

样例行使用“;”开始，是对配置内容的举例

查看smb.conf有效配置的命令 

![查看smb.conf有效配置的命令][linux-samba-001-005]

	# grep -v “^#” /etc/samba/smb.conf |grep -v “^;” 

应用实例：

共享目录需求

>在smb.conf中添加名为[public ]共享目录
>
>公共共享目录的路径是“/home/public”
>
>仅192.168.10.0/24网段的人可以访问
>
>仅staff组的人对这个目录具有写的权限 

3.smbpasswd命令（为用户添加samba密码）

	>smbpasswd命令用于维护Samba服务器的用户帐号
	
	>添加Samba用户帐号
	
	# smbpasswd -a sambauser
	
	>禁用Samba用户帐号
	
	# smbpasswd -d sambauser
	
	>启用Samba用户帐号
	
	# smbpasswd -e sambauser
	
	>删除Samba用户帐号
	
	# smbpasswd -x sambauser

![smbpasswd -a sambauser][linux-samba-002-005]

###Samba客户端应用

1.linux系统挂载smaba共享目录

	[root@nmred ~]# mount //192.168.216.128/web /mnt -o username=user1

![mount][linux-samba-003-005]

2.WINDOWS系统共享samba目录

1）通过网上邻居

![通过网上邻居-1][linux-samba-004-005]

![通过网上邻居-2][linux-samba-005-005]

2）通过网络驱动映射

a.点击 我的电脑->工具–>映射网络驱动器

![通过网络驱动映射-1][linux-samba-006-005]

b.输入映射地址   \\192.168.216.128\web

![通过网络驱动映射-2][linux-samba-007-005]

[linux-samba-001-005]: /image/linux/linux-samba-001-005.png
[linux-samba-002-005]: /image/linux/linux-samba-002-005.png
[linux-samba-003-005]: /image/linux/linux-samba-003-005.png
[linux-samba-004-005]: /image/linux/linux-samba-004-005.png
[linux-samba-005-005]: /image/linux/linux-samba-005-005.png
[linux-samba-006-005]: /image/linux/linux-samba-006-005.png
[linux-samba-007-005]: /image/linux/linux-samba-007-005.png
