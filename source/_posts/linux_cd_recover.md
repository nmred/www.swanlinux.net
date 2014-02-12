title: Linux 系统光盘修复
date: 2013-02-12 18:13:16
tags: 光盘修复
categories: linux
---

###光盘修复备份过的文件

案例背景：系统中/etc原来已经备份到/backup一份，但是在操作中误删除了/etc/inittab或把grub.conf文件的title行删除掉了，重新启动Linux后系统无法引导，从/backup目录下恢复文件。(没有备份修复的方法下面介绍)

1.设置BIOS启动为光盘

2.启动系统后如图输入linux rescue

![linux rescue][linux-rescue-001-008]

3.后面两部按默认的就可以了

4.到了询问是否启动网络服务选择NO

![linux rescue][linux-rescue-002-008]

5.选择continue

![linux rescue][linux-rescue-003-008]

6.进入shell界面

![linux rescue][linux-rescue-004-008]

注意：在光盘修复模式下默认的/mnt/sysimage相当于正常系统的根目录

然后执行exit重启完成系统修复 

###完全用光盘修复系统 

案例背景：/etc/inittab误删除也没有备份 

进入光盘修复模式

boot: linux rescue

1、改变回原硬盘Linux的目录结构

	[root@nmred ~]# chroot /mnt/sysimage

2、查询文件隶属软件包

	[root@nmred ~]# rpm -qf /etc/inittab initscripts-8.45.30-2.el5.centos

3、挂载光盘

	[root@nmred ~]# mount /dev/hdc /mnt/cdrom

 \* 光盘修复模式不支持软链接,/dev/cdrom是/dev/hdc的软链接，不一定每个系统安装后光驱设备都为hdc，可以通过输入/dev/hd后Tab键自动补全

4、查看是否存在initscript安装包

	[root@nmred ~]# ls /mnt/cdrom/CentOS/ |grep initscript initscripts-8.45.30-2.el5.centos.i386.rpm
	
5.进一步确认initscript安装包是否包含inittab文件

	[root@nmred ~]# rpm -qlp /mnt/cdrom/CentOS/initscripts-8.45.30-2.el5.centos.i386.rpm |grep inittab /etc/inittab

6.提取恢复inittab文件：

	[root@nmred ~]# cd / 
	[root@nmred ~]# rpm2cpio /mnt/cdrom/CentOS/initscripts-8.45.30-2.el5.centos.i386.rpm |cpio -id ./etc/inittab

7.退出重启系统(第一个exit是退出chroot环境，第二个exit是退出修复模式) exit 

[linux-rescue-001-008]: /image/linux/linux-rescue-001-008.png
[linux-rescue-002-008]: /image/linux/linux-rescue-002-008.png
[linux-rescue-003-008]: /image/linux/linux-rescue-003-008.png
[linux-rescue-004-008]: /image/linux/linux-rescue-004-008.png
