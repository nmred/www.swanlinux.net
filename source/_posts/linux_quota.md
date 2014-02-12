title: Linux 系统磁盘配额
date: 2013-02-12 18:13:16
tags: quota
categories: linux
---

应用案例：

>设置用户zhangsan和lisi在/quota分区中，只有使用50MB的磁盘空间

###开启分区配额功能

编辑/etc/fstab文件，修改/quota行设置 

![linux-quota-001-012][linux-quota-001-012]

用户配额usrquota
用户组配额grpquota

###生成配额数据库

用户配额aquota.user 
用户组配额aquota.group

quotacheck -cvu 分区挂载点

>-c 创建
>-v 详细信息
>-u 用户配额
>-g 用户组配额
>-f 强行检测生成（/分区）
>-m 强行检测生成（新添加的硬盘分区）

注意：
\* /分区quotacheck需要增加-m选项强制检测
\* 其他新添加硬盘分区quotacheck需要增加-f选项强制检测

![linux-quota-002-012][linux-quota-002-012]
 
###启动配额功能

quotaon 分区名  

![linux-quota-003-012][linux-quota-003-012]

关闭配额功能
quotaoff

###编辑用户配额

edquota 用户名
        -g 用户组名
blocks 空间大小(kb)
inodes 文件多少

soft 软限制

hard 硬限制

blocks-hard *

edquota zhangsan 

![linux-quota-004-012][linux-quota-004-012]

[linux-quota-001-012]: /image/linux/linux-quota-001-012.png
[linux-quota-002-012]: /image/linux/linux-quota-002-012.png
[linux-quota-003-012]: /image/linux/linux-quota-003-012.png
[linux-quota-004-012]: /image/linux/linux-quota-004-012.png
