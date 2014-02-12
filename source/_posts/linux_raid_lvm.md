title: Linux系统中的RAID和LVM
date: 2013-02-12 18:13:16
tags: raid lvm 
categories: linux
---

###软raid的使用

1.RAID定义

RAID是英文Redundant Array of Independent Disks的缩写，翻译成中文意思是“独立磁盘冗余阵列”，有时也简称磁盘阵列(Disk Array)。

简单的说，RAID是一种把多块独立的硬盘(物理硬盘)按不同的方式组合起来形成一个硬盘组(逻辑硬盘)，从而提供比单个硬盘更高的存储性能和提供数据备份技术。组成磁盘阵列的不同方式成为RAID级别(RAID Levels)。 

2.Raid主要种类

>raid0           扩展卷
>
>raid1           镜像卷
>
>raid5           扩展卷
>
>raid10         raid0+raid1 

1)raid0

raid 0又称为Stripe或Striping，所有RAID级别中最高的存储性能。RAID 0提高存储性能的原理是把连续的数据分散到多个磁盘上存取，这样，系统有数据请求就可以被多个磁盘并行的执行 。

![linux-raid-lvm-001-016][linux-raid-lvm-001-016]

2)raid1

RAID  1又称为Mirror或Mirroring，它的宗旨是最大限度的保证用户数据的可用性和可修复性。 RAID 1的操作方式是把用户写入硬盘的数据百分之百地自动复制到另外一个硬盘上。

![linux-raid-lvm-002-016][linux-raid-lvm-002-016]

3)raid5

RAID 5 是一种存储性能、数据安全和存储成本兼顾的存储解决方案。 以四个硬盘组成的RAID 5为例，其数据存储方式如下图所示:

![linux-raid-lvm-003-016][linux-raid-lvm-003-016]

4)RAID 0+1（别名：镜像阵列条带）

RAID 0+1:是RAID 0和RAID 1的组合形式，也称为RAID 10。

由于RAID 0+1也通过数据的100%备份提供数据安全保障，因此RAID 0+1的磁盘空间利用率与RAID 1相同，存储成本高。

![linux-raid-lvm-004-016][linux-raid-lvm-004-016]

3.RAID创建

1)为新添加的硬盘分区

注意：一定要指定分区类型为fd（文件系统类型的代号） Linux raid auto，而不是ext3

在新添加硬盘分区后可能要执行一下：partprobe命令，以免报错！ 

2)创建raid硬盘阵列

	#mdadm -C /dev/md0 -ayes -l0 -n2  /dev/sd[a,b]1

其中:

>-C             :表示创建RAID
>
>/dev/md0       :表示创建生成的RAID分区
>
>-ayes          :表示创建过程中并且激活该RAID分区
>
>-ln            :表示创建级别为n的RAID
>
>-nn            :表示创建RAID所参与的硬盘设备个数
>
>/dev/sd[a,b]1  :表示参与的硬盘设备

例如：创建raid1用/dev/sdb1 /dev/sdb2

	mdadm -C /dev/md1 -ayes -l1 -n2 /dev/sdb{1..2}

注意：创建raid0至少所需硬盘为1块，raid1为2块(一块为普通数据，另一块为镜像数据)，raid5为至少3块

cat /proc/mdstat命令查看创建进度，到100%时就好了 

3)创建文件系统

	mkfs.ext3 /dev/md0

4)挂载分区：
	
	mount /dev/md0 /mnt
	
	自动挂载,可以修改一下/etc/fstab文件,添加一行!
	
	/dev/md0           /raid5disk           ext3 defaults        0 0 

4.删除一个阵列

执行以下3条命令：

>umount [挂载目录]
>
>mdadm -S [RAID设备]
>
>mdadm –zero-superblock [生成RAID的硬盘设备]

例如：

	umount /raid5
	mdadm -S /dev/md0
	mdadm –zero-superblock /dev/sda{3..5}

5.查看RAID
	
	mdadm -D /dev/md0或cat /proc/mdstat

###Lvm的使用

1.lvm定义

LVM 是逻辑盘卷管理（Logical Volume Manager）的简称，它是 Linux 环境下对磁盘分区进行管理的一种机制，LVM 是建立在硬盘和分区之上的一个逻辑层，来为文件系统屏蔽下层磁盘分区布局，从而提高磁盘分区管理的灵活性。通过 LVM 系统管理员可以轻松管理磁盘分区.

1)物理卷 (physical volume, PV)

a.物理卷在 LVM 系统中处于最底层

b.物理卷可以是整个硬盘、硬盘上的分区或从逻辑上与磁盘分区具有同样功能的设备（如：RAID）

c.物理卷是 LVM 的基本存储逻辑块，但和基本的物理存储介质（如分区、磁盘等）比较，却包含有与 LVM 相关的管理参数

2)卷组 (Volume Group, VG)

a.卷组建立在物理卷之上，它由一个或多个物理卷组成卷组

b.创建之后，可以动态添加物理卷到卷组中，在卷组上可以创建一个或多个“LVM 分区”（逻辑卷）

c.一个 LVM 系统中可以只有一个卷组，也可以包含多个卷组LVM 的卷组类似于非 LVM 系统中的物理硬盘

3)逻辑卷 (Logical Volume, LV)

a.逻辑卷建立在卷组之上，它是从卷组中“切出”的一块空间

b.逻辑卷创建之后，其大小可以伸缩

c.LVM 的逻辑卷类似于非 LVM 系统中的硬盘分区，在逻辑卷之上可以建立文件系统

4)Lvm结构 

![linux-raid-lvm-005-016][linux-raid-lvm-005-016]

2.LVM使用过程

1)创建物理卷

a.创建 LVM 类型的分区

    fdisk /dev/sda

b.创建物理卷

    pvcreate /dev/sdb1

2)使用物理卷创建卷组VG

    vgcreate <卷组名> <物理卷设备名> [<物理卷设备名> ...]

    vgcreate VG0 /dev/sda1 /dev/sdb1

3)创建逻辑卷

    lvcreate –n data –L +500M vg0    ：在vg0逻辑卷中创建一个名为data大小为500M的逻辑卷(-n表示创建逻辑卷的名称，-L是以MB为单位，-l是以PE为单位1PE=4MB)
    lvcreate –n data –l 127 vg0
    lvdisplay /dev/vg0/data
    mkfs.ext3 /dev/vg0/data
    mount /dev/vg0/data /mnt
    vi /etc/fstab

3.扩容

1)逻辑卷扩容

	lvextend  –L +200M /dev/vg0/data    添加200M的
	e2fsck –f /dev/vg0/data            下面2条是在线扩容(不用停止掉挂载目录)
	resize2fs /dev/vg0/data

2)扩展卷组

a.创建一个物理卷：pvcreate /dev/sdc1

b.扩展逻辑卷组：vgextend vg0 /dev/sdc1

c.查看逻辑卷组：vgdisplay

4.删除逻辑卷

    lvremove /dev/vg0/data

5.休眠和激活卷组

    vgchange –an /dev/vg0   休眠
    vgchange –ay /dev/vg0   激活 

###RAID和LVM综合 

>应用案例：创建RAID5并在其上建LVM

	mdadm –C /dev/md0 –l5 –n3 /dev/sd[a,b,c]1
	pvcreate /dev/md0
	vgcreate vg0 /dev/md0
	lvcreate –n var –L 1G vg0
	lvcreate –n home –L 500M vg0
	mkfs.ext3 /dev/vg0/var 

[linux-raid-lvm-001-016]: /image/linux/linux-raid-lvm-001-016.png
[linux-raid-lvm-002-016]: /image/linux/linux-raid-lvm-002-016.png
[linux-raid-lvm-003-016]: /image/linux/linux-raid-lvm-003-016.png
[linux-raid-lvm-004-016]: /image/linux/linux-raid-lvm-004-016.png
[linux-raid-lvm-005-016]: /image/linux/linux-raid-lvm-005-016.png
