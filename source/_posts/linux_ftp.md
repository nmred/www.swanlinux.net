title: Linux 系统中文件共享之 FTP
date: 2013-02-12 18:13:16
tags: ftp 
categories: linux
---

###FTP 的安装

安装文件名称是vsftpd-2.0.1-5.i386.rpm 

	[root@nmred ~]# yum install vsftpd*

###FTP 配置

1.配置文件简介

1）vsftpd.conf配置文件

vsftpd.conf是vsftpd服务器的主配置文件

/etc/vsftpd/vsftpd.conf

>配置文件中所有的配置项都有相同的格式
>
>anonymous_enable=YES
>
>配置文件中的注释行以“#”开始
>
>配置文件的详细帮助信息可查询手册页
>
>\# man vsftpd.conf

2）vsftpd.ftpusers文件

vsftpd.ftpusers用于保存不允许进行FTP登录的本地用户帐号 ，vsftpd.ftpusers文件中可禁止高权限本地用户登录FTP服务器，提高了系统的安全性 。

3）vsftpd.user_list文件

vsftpd.user\_list文件具有对vsftpd服务器更灵活的用户访问控制 ，使用vsftpd.user_list文件需要在主配置文件中进行设置 。

>设置禁止vsftpd.user_list文件中的用户登录
>
>userlist_enable=YES
>
>userlist_deny=YES
>
>设置只允许vsftpd.user_list文件中的用户登录
>
>userlist_enable=YES
>
>userlist_deny=NO

2.FTP配置

匿名用户拥有下载，上传,创建文件夹，修改名字，删除文件的权限

    vi /etc/vsftpd/vsftpd.conf
    anonymous_enable=yes
    anonymous_upload_enable=yes
    anonymous_mkdir_write_enable=yes
    anonymous_other_write_enable=yes

注意：用户虽然ftp服务拥有了读写权限，但是共享目录的权限其他用户是没用权限需要给定权限。

具体的方法：1.chmod 757  -R  /var/ftp/pub

2.使用ACL分配权限

3.FTP本地用户帐号的问题

使用FTP本地用户帐号存在安全性问题

>本地用户登录FTP目录后可从宿主目录转换到其他目录，不是很安全
>
>可以设置将本地用户禁锢在宿主目录中

将FTP本地用户禁锢在宿主目录中

>在vsftpd.conf文件中添加设置项
>
>chroot_local_user=YES
>
>重新启动vsftpd服务
>
>\# service vsftpd restart
>
>使用ftp客户端验证
>
>本地用户登录FTP服务器后，宿主目录将作为根目录

4.匿名用户登录

匿名用户使用的登录用户名

anonymous

ftp
