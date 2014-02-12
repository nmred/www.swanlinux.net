title: Linux系统中配置代理服务器Squid
date: 2013-02-12 18:13:16
tags: squid 
categories: linux
---

###squid简介

1.代理服务的应用原理

代理服务器工作在TCP/IP的应用层 

![linux-squid-001-019][linux-squid-001-019]

2.squid服务器的功能

1)提供对HTTP和FTP协议的代理服务

2)缓存代理的内容，提高客户端访问网站的速度，并能够节约出口网络流量

3)对客户端地址进行访问控制，限制允许访问squid服务器的客户机

4)对目标地址进行访问控制，限制客户端允许访问的网站

5)根据时间进行访问控制，限定客户端可以使用代理服务的时间

3.squid缓存代理

缓存代理作用

1)通过缓存的方式为用户提供Web访问加速

2)对用户的Web访问进行过滤控制 

![linux-squid-002-019][linux-squid-002-019]

4.squid普通和透明代理

1)普通代理服务

a.即标准的、传统的代理服务

b.需要客户机在浏览器中指定代理服务器的地址、端口

2)透明代理服务

a.适用于企业的网关主机

b.客户机不需要指定代理服务器地址、端口等信息

c.通过iptables将客户机的Web访问数据转交给代理服务程序处理

5.squid反向代理

为Internet用户访问企业Web站点提供缓存加速 

![linux-squid-003-019][linux-squid-003-019]

6.Squid安装和配置

1)安装squid软件包

yum -y install squid*

2)squid配置文件

/etc/squid/squid.conf

3)启动squid服务

service squid start/restart

4)停止squid服务

service  squid stop

5)重新加载配置文件

squid -k reconfig

7.配置文件squid.conf

常用配置项

>http_port 192.168.10.1:3128
>
>cache_mem 64 MB
>
>maximum_object_size 4096 KB
>
>reply_body_max_size 10480000 allow all
>
>access_log /var/log/squid/access.log
>
>visible_hostname 192.168.10.1
>
>cache_dir ufs /var/spool/squid 100 16 256

8.ACL访问控制

1)ACL（Access Control List，访问控制列表）

可以从客户机的IP地址、请求访问的URL/域名/文件类型、访问时间、并发请求数等各方面进行控制

2)应用访问控制的方式

a.定义acl列表

acl 列表名称 列表类型 列表内容

b.针对acl列表进行限制

http_access allow或deny 列表名

3)最基本acl列表控制

最基本的ACL访问控制示例

禁止任何客户机使用代理服务 

![linux-squid-004-019][linux-squid-004-019]

4)acl列表类型

常用的acl列表类型

![linux-squid-005-019][linux-squid-005-019]

5)ACL列表定义示例

	acl LAN1 src 192.168.1.0/24
	acl PC1 src 192.168.1.66/32
	acl Blk_Domain dstdomain .qq.com .kaixin001.com
	acl Work_Hours time MTWHF 08:30-17:30
	acl Max20_Conn maxconn 20
	acl Blk_URL url_regex -i ^rtsp:// ^mms://
	acl Blk_Words urlpath_regex -i sex adult
	acl RealFile urlpath_regex -i \.rmvb$ \.rm$
	
6)允许或拒绝acl列表

根据已经定义的部分ACL列表进行访问控制

	http_access deny LAN1 Blk_URL
	http_access deny LAN1 Blk_Words
	http_access deny PC1 RealFile
	http_access deny PC1 Max20_Conn
	http_access allow LAN1 Work_Hours

###配置Squid

1.普通squid代理服务器

1)配置环境说明 

![linux-squid-006-019][linux-squid-006-019]

2)修改配置文件如下：

3)重新加载配置文件

	#squid -k reconfig

4)在客户机上测试

a.首先在客户机浏览器中设置代理IP：192.168.129.1  端口：3128

![linux-squid-007-019][linux-squid-007-019]

![linux-squid-008-019][linux-squid-008-019]

b.访问http://192.168.128.2

![linux-squid-009-019][linux-squid-009-019]

2.配置squid透明代理

1)配置环境说明

基本环境和配置普通代理服务器一样，唯一区别就是客户机需要加上网关：192.168.129.1

2)修改配置文件如下：

3)重新加载配置文件

	#squid -k reconfig

4)设置防火墙将80端口请求转化为3128 

![linux-squid-010-019][linux-squid-010-019]

5)在客户机上测试

a.这个就不用设置代理IP和端口了

b.访问http://192.168.128.2

3.配置squid反向代理

1)配置环境说明

注意该环境下默认将129网段的模拟为公网 

![linux-squid-011-019][linux-squid-011-019]

2)修改配置文件如下：

3)重新加载配置文件

	#squid -k reconfig

4)在客户机上测试

a.这个就不用设置代理IP和端口了

b.访问http://192.168.129.1

![linux-squid-012-019][linux-squid-012-019]

4.为虚拟主机配置squid反向代理

1)配置环境说明

注意该环境下默认将129网段的模拟为公网

![linux-squid-013-019][linux-squid-013-019]

2)修改配置文件如下：

3)将WEB服务器配置成虚拟主机(配置虚拟主机的部分，一定要注意目录权限问题)

4)重新加载配置文件

	#squid -k reconfig

5)在客户机上测试

a.用DNS解析www.baidu.com和www.sina.com到192.168.129.1

b.分别访问www.baidu.com和www.sina.com

5.cache_peer的特殊用法

1)具有lvs负载均衡的特性(轮循负载)

	cache_peer 192.168.10.2 parent 80 0 originserver weight=1 round-robin
	cache_peer 192.168.10.3 parent 80 0 originserver weight=1 round-robin

2)具有自动检测后台web服务器,检测其心跳的作用,当后台10.2坏掉后,外部访问会自动去访问10.3这台服务器,具有ha集群心跳作用

	cache_peer 192.168.10.2 parent 80 0 originserver
	cache_peer 192.168.10.3 parent 80 0 originserver

注:

>a.当用负载时,数据可能无法通过squid缓存,而冗余这种比较好，而且有squid缓存.
>
>b.用squid做负载均衡时必须是用同一存储的方式才会有缓存效果

[linux-squid-001-019]: /image/linux/linux-squid-001-019.png
[linux-squid-002-019]: /image/linux/linux-squid-002-019.png
[linux-squid-003-019]: /image/linux/linux-squid-003-019.png
[linux-squid-004-019]: /image/linux/linux-squid-004-019.png
[linux-squid-005-019]: /image/linux/linux-squid-005-019.png
[linux-squid-006-019]: /image/linux/linux-squid-006-019.png
[linux-squid-007-019]: /image/linux/linux-squid-007-019.png
[linux-squid-008-019]: /image/linux/linux-squid-008-019.png
[linux-squid-009-019]: /image/linux/linux-squid-009-019.png
[linux-squid-010-019]: /image/linux/linux-squid-010-019.png
[linux-squid-011-019]: /image/linux/linux-squid-011-019.png
[linux-squid-012-019]: /image/linux/linux-squid-012-019.png
[linux-squid-013-019]: /image/linux/linux-squid-013-019.png
