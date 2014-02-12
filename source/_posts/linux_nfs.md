title: Linux 系统中文件共享之 NFS
date: 2013-02-12 18:13:16
tags: nfs
categories: linux
---

###NFS 网络共享的一般用法

在NFS服务器主机中进行设置

>1）安装NFS服务器软件包
>
>2） 启动NFS服务器程序
>
>3）设置NFS共享目录输出

在NFS客户机中进行设置

>1）使用mount命令挂载NFS服务器中的NFS共享目录到文件系统中
>
>2） 通过NFS文件系统的挂载点目录访问NFS服务器中的共享内容

###NFS 服务器的安装与配置

1、NFS服务器的安装

portmap软件包

提供了运行portmap服务所需的文件，portmap服务为NFS等服务器程序提供RPC服务的支持

nfs-utils软件包

提供了NFS服务器的启动脚本和管理维护工具

软件包安装

“nfs-utils”和“portmap”两个软件包在系统中是默认安装的

	[root@nmred ~]# yum install -y nfs*

2、NFS服务器的配置

“/etc/exports”文件用于配置NFS服务器中输出的共享目录

	# vi /etc/exports
	/home/share    *(sync,ro)

![exports][linux-nfs-001-003]

1)exports文件中“客户端主机地址”字段可以使用多种形式表示主机地址

![exports-ip][linux-nfs-002-003]

2)exports文件中的“配置选项”字段放置在括号对中 ，多个选项间用逗号分隔

>sync：设置NFS服务器同步写磁盘，这样不会轻易丢失数据，建议所有的NFS共享目录都使用该选项
>
>ro：设置输出的共享目录只读，与rw不能共同使用
>
>rw：设置输出的共享目录可读写，与ro不能共同使用

3)exports文件配置实例

配置NFS服务器输出的共享目录

输出“/home/share”目录，对所有主机可读，对地址为192.168.1.19的主机可读可写

输出“/home/pub”目录，对192.168.152.0子网内的所有主机可读

	#vi /etc/exports

	/home/share *(sync,ro) 192.168.1.19(sync,rw)

	/home/pub 192.168.152.0/24(sync,ro)

3、NFS服务器的启动与停止

查询服务器的状态

为了保证NFS服务器能够正常工作，系统中需要运行portmap和nfs两个服务程序

	# service portmap status

	# service nfs status

启动服务器

	# service portmap start

	# service nfs start

停止服务器运行

	# service nfs stop

![service-stop-start][linux-nfs-003-003]

4、NFS的常用命令

showmount命令

>1）showmount -e显示NFS服务器的输出目录列表
>
>2)showmount -d 显示当前主机NFS服务器中已经被NFS客户机挂载使用的共享目录
>
>3)showmount –a 显示当前主机中NFS服务器的客户机信息
>
>4)showmount –a   [主机] 显示指定主机中NFS服务器的客户机信息

exportfs命令

>1)exportfs -rv 使nfs服务器重新读取exports文件中的设置
>
>2)exportfs -auv 停止当前主机中NFS服务器的所有目录输出

![exportfs命令][linux-nfs-004-003]

###NFS 客户端操作

1）挂载共享目录

	[root@nmred ~]# mount 192.168.216.128:/home /mnt

![挂载共享目录][linux-nfs-005-003]

2）卸载NFS共享

	[root@nmred ~]# umount  /mnt

3)系统启动时自动挂载NFS文件系统

将NFS的共享目录挂载信息写入“/etc/fstab”文件，可实现对NFS共享目录的自动挂载

	# vi /etc/fstab

	192.168.216.128:/home/pub /mnt nfs defaults 0 0 

[linux-nfs-001-003]: /image/linux/linux-nfs-001-003.png
[linux-nfs-002-003]: /image/linux/linux-nfs-002-003.png
[linux-nfs-003-003]: /image/linux/linux-nfs-003-003.png
[linux-nfs-004-003]: /image/linux/linux-nfs-004-003.png
[linux-nfs-005-003]: /image/linux/linux-nfs-005-003.png
