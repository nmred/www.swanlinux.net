title: Linux权限控制sudo/acl
date: 2013-02-12 18:13:16
tags: sudo acl 
categories: linux
---

###利用sudo控制执行权限

1.确认sudo软件的安装

2.通过sudo授权用户可以修改配置文件和管理服务脚本：

	[root@nmred ~]# visudo
	
	helen localhost=/bin/vi /etc/httpd/conf/http.conf,/etc/rc.d/init.d/httpd start,/etc/rc.d/init.d/httpd reload,/etc/rc.d/init.d/httpd configtest,/etc/rc.d/init.d/httpd status

以上为授权用户helen可以修改apache配置文件，可以启动apache、修改apache配置文件后加载生效、以及检测apache配置文件语法错误和查看apache状态。

也可以通过chown helen /etc/http/conf/httpd.conf授权用户Helen可以更改配置文件。

	chown -R helen /var/www/html

修改网页存放目录/var/www/html让helen有全部控制权限，可以更新网页

###ACL权限设置

1.确认acl软件的安装

2.ACL权限设置

a.设置文件的ACL权限

setfacl -m <rules> <files>

参数说明：

>-m:设定
>-x:移除特定用户或组的权限
>-b:移除所有的权限

b.查看文件的acl权限

getfacl <files>

3.应用案例

>使用ACL授权helen对系统目录/var具有读写权限，david具有读写执行权限

	[root@nmred ~]# setfacl -m user:helen:rw /var
	[root@nmred ~]# setfacl -m user:david:rwx /var 
	[root@nmred ~]# getfacl /var

![acl][linux-acl-001-009]

[linux-acl-001-009]: /image/linux/linux-acl-001-009.png

