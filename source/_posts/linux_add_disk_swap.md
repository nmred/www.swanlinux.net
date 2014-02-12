title: Linux 系统添加数据分区和 swap 分区
date: 2013-02-12 18:13:16
tags: swap fdisk
categories: linux
---

###添加硬盘分区的步骤 

1.固件检测识别(一般可以省略操作)

2.内核驱动demag(一般可以省略操作)

3.划分分区fdisk

4.创建文件系统mkfs

5.尝试挂载mount(一般可以省略操作)

6.写入配置文件(/etc/fstab) 

###添加硬盘分区

1、分区 fdisk

查看硬盘分区：fdisk -l 硬盘设备名

fdisk -l /dev/sda 

![linux-fdisk-001-011][linux-fdisk-001-011]

![linux-fdisk-002-011][linux-fdisk-002-011]

![linux-fdisk-003-011][linux-fdisk-003-011]

分区：fdisk 硬盘设备名

>-m帮助menu
>
>-p查看分区表print
>
>-n添加新分区new
>
>-d删除分区delete
>
>-t设置分区文件系统type   82-swap  83-ext
>
>-w保存退出write
>
>-q不保存退出quit 

扩展知识

--------

主分区primary partition

扩展分区extended

逻辑分区

1、主分区和扩展分区只能有四个

分多个分区：分三个主分区，一个扩展分区（剩余所有空间）

2、扩展分区存放逻辑分区

分区大小：+sizeM   +5120M 

---------

![linux-fdisk-004-011][linux-fdisk-004-011]

2、格式化（创建文件系统）

1)数据分区

>mkfs.ext3 分区名
>
>mkfs -t ext3 分区名

2)swap分区

>mkswap 分区名 

![linux-fdisk-005-011][linux-fdisk-005-011]

3、写入配置文件/etc/fstab     file system table

	卷标(设备名)  挂载点  文件系统  设置  是否启动检测(01)  检测顺序(012)
	e2label                 /dev/sda1 
	/dev/sdb1               /blog                   ext3    defaults        1 2
	/dev/sdb2               /backup                 ext3    defaults        1 2
	/dev/sdb3               swap                    swap    defaults        0 0

4.当swap分区不够用在现有的硬盘上添加

1)生成空数据文件：
	
   	dd if=/dev/zero of=/root/test.swap bs=1M count=512

2)生成swap文件 

	mkswap /root/test.swap

![linux-fdisk-006-011][linux-fdisk-006-011]

3)启用swap文件 
	
	swapon  /root/test.swap 

![linux-fdisk-007-011][linux-fdisk-007-011]

扩展知识：

1)查看内存信息free -m

2)dd命令

dd if=/dev/sda of=/dev/sdc(用于整盘备份，和cp相比可以拷贝运行中的文件)

dd if=/dev/zero of=输出文件 bs=1024 count=512000 block size 数据块大小

/dev/zero 往输出中写零

/dev/null 黑洞，一般用于计划任务和shell脚本 

[linux-fdisk-001-011]: /image/linux/linux-fdisk-001-011.png
[linux-fdisk-002-011]: /image/linux/linux-fdisk-002-011.png
[linux-fdisk-003-011]: /image/linux/linux-fdisk-003-011.png
[linux-fdisk-004-011]: /image/linux/linux-fdisk-004-011.png
[linux-fdisk-005-011]: /image/linux/linux-fdisk-005-011.png
[linux-fdisk-006-011]: /image/linux/linux-fdisk-006-011.png
[linux-fdisk-007-011]: /image/linux/linux-fdisk-007-011.png

