title: Linux系统配置DNS主从及缓存服务器
date: 2013-02-12 18:13:16
tags: dns
categories: linux
---

###DNS系统概述

1.DNS系统的作用

正向解析：根据主机名称（域名）查找对应的IP地址

反向解析：根据IP地址查找对应的主机域名

![linux-dns-001-014][linux-dns-001-014]

2.DNS查询方式：

1)递归查询

大多数客户机向DNS服务器解析域名的方式

2)迭代查询

大多数DNS服务器向其他DNS服务器解析域名的方式

3.DNS服务的整体结构

1)DNS服务体系是一个庞大的分布式数据库

2)DNS服务采用树型层次结构

3)全世界的DNS服务器具有共同的根域（.）

4)对域名的查询是分层次进行的

5)例如：对域名www.sina.com.cn域名的解析需要依次经过 

>根（．）域的DNS服务器
>
>“cn.”域的DNS服务器
>
>“com.cn. ”域的DNS服务器
>
>“sina.com.cn.”域的DNS服务器 

![linux-dns-002-014][linux-dns-002-014]

4.DNS服务器的类型

1)缓存域名服务器

通过向其他域名服务器查询获得域名->IP地址记录将域名查询结果缓存到本地，提高重复查询时的速度

2)主域名服务器

特定DNS区域的官方服务器，具有唯一性负责维护该区域内所有域名->IP地址的映射记录

3)从域名服务器

也称为 辅助域名服务器,其维护的 域名->IP地址记录 来源于主域名服务器

5.DNS域名服务器软件安装

BIND（Berkeley Internet Name Daemon）相关软件包 

	bind-9.3.3-7.el5.i386.rpm
	bind-utils-9.3.3-7.el5.i386.rpm
	bind-chroot-9.3.3-7.el5.i386.rpm
	caching-nameserver-9.3.3-7.el5.i386.rpm(缓存DNS服务器软件) 

6.BIND域名服务基础

1)BIND服务器端程序

主要执行程序：/usr/sbin/named

服务脚本：/etc/init.d/named

默认监听端口：53

2)主配置文件：

/var/named/chroot/etc/

3)保存DNS解析记录的数据文件位于：

/var/named/chroot/var/named/ 

###DNS服务器配置文件相关解析

1.全局配置文件

全局配置部分

设置DNS服务器的全局参数

包括监听地址/端口、数据文件的默认位置等

使用 options { …… }; 的配置段 

![linux-dns-003-014][linux-dns-003-014]

>注意：在软件默认安装后，一般需求配置是将127.0.0.1和localhost全部替换成any即可

2.区域配置文件

区域配置部分

设置本服务器提供域名解析的特定DNS区域

包括域名、服务器角色、数据文件名等

使用 zone “区域名” IN { …… }; 的配置段

![linux-dns-004-014][linux-dns-004-014]

区域配置部分

倒序网络地址.in-addr.arpa 的形式表示反向区域

![linux-dns-005-014][linux-dns-005-014]

3.区域数据解析文件

全局TTL配置项及SOA记录

$TTL（Time To Live，生存时间）记录

SOA（Start Of Authority，授权信息开始）记录

分号“;”开始的部分表示注释信息 

![linux-dns-006-014][linux-dns-006-014]

域名解析记录

NS域名服务器（Name Server）记录

MX邮件交换（Mail Exchange）记录

A地址（Address）记录，只用在正向解析的区域数据文件中

CNAME别名（Canonical Name）记录 

![linux-dns-007-014][linux-dns-007-014]

域名解析记录

PTR指针（Point）记录，只用在反向解析的区域数据文件中配置反向解析记录时，只需要指定IP地址中的主机地址部分即可，网络地址部分不用写 

![linux-dns-008-014][linux-dns-008-014]

区域数据解析文件特殊用法

1)基于域名解析的负载均衡，同一域名对应到多个IP地址

2)泛域名解析,找不到精确对应的A记录时，使用“*”进行匹配

![linux-dns-009-014][linux-dns-009-014]

###配置DNS实例 

应用案例：解析一个域名ln128.net
   
其中：

>主机名www的IP为192.168.216.1
>
>主机名bbs的IP为192.168.216.2
>
>主机名mp3的IP为192.168.216.3
>
>主机名blog的IP为192.168.216.4
>
>主DNS服务器的IP为192.168.216.128
>
>从DNS服务器的IP为192.168.216.129
>
>要求有缓存服务器 


1.构建缓存域名服务器

>注意：在安装DNS服务器相关软件中caching-nameserver安装后默认就是一台缓存服务器，所以默认不用配置即可。

只需修改一下主配置文件即可：

将named.caching-nameserver.conf中127.0.0.1和localhost替换成any即可 

![linux-dns-010-014][linux-dns-010-014]

![linux-dns-011-014][linux-dns-011-014]

[扩展知识]

1)根区域设置

named.caching-nameserver.conf中的根区域设置

	zone “.” IN {
	        type hint;
	        file “named.ca”;
	};

a)type设置为hint表示该区域的类型是根区域

b)file用于设置区域文件，根区域文件的名称是“named.ca”

2)根区域文件

named.ca是根区域文件，位于“/var/named/chroot/var/named/ ”目录中

a)localhost正向解析

localhost区域的作用是对主机名称“localhost”和环回地址“127.0.0.1” 进行解析

	zone “localhost” IN {
	        type master;
	        file “localhost.zone”;
	};

type设置为master表示区域的类型为主服务器

b)localhost反向解析

	zone “0.0.127.in-addr.arpa” IN {
	        type master;
	        file “named.local”;
	}; 

2.构建主域名服务器

A、在named.rfc1912.zones文件中设置域

1)建立正向解析域

	zone “ln128.net” {
        type master;
        file “ln128.z”;
    };

2)建立反向解析域

	zone “216.168.192.in-addr.arpa” {
	    type master;
		file “ln128.f”;
	};


注意反向解析的IP是倒着写的，而且只需编写IP的前3位，只要网段即可.如：192.168.216.128 

![linux-dns-012-014][linux-dns-012-014]

B、建立正向数据区域解析文件

创建技巧：可以直接复制named.local文件直接在此基础上修改

/var/named/chroot/var/named/ln128.z

![linux-dns-013-014][linux-dns-013-014]

1)基本设置

	$TTL    86400
	@   IN SOA    ns1.lamp.com.   root.ln128.net. (
      42              ; serial (d. adams)
      3H              ; refresh
      15M             ; retry
      1W              ; expiry
      1D )            ; minimum 

2)添加域名服务器记录

域名服务器记录又称为NS记录，在区域文件中用于设置当前域的DNS服务器名称

	@               IN      NS      ns1.ln128.net.

“@”符号在区域文件中代表默认的域（当前域）

3)添加地址记录

地址记录又称为A记录，用于设置主机名到IP地址的对应记录

	ns1          IN      A       192.168.216.128
	www          IN      A       192.168.216.1
	bbs          IN      A       192.168.216.2
	mp3          IN      A       192.168.216.3
	blog         IN      A       192.168.216.4

4)添加别名记录

别名记录又称CNAME记录，用于在区域文件中对主机名称设置别名

	indec            IN      CNAME   www.ln128.net.
	bbs2             IN      CNAME   bbs.ln128.net.

5)添加邮件交换记录

邮件交换记录又称MX记录，用于设置当前域中提供邮件服务的服务器名称

	@              IN      MX      5       mail.ln128.net.

C、建立反向区域文件

/var/named/chroot/var/named/ln128.net

1)基本设置

内容与正向区域文件中的基本设置相同

2)域名服务器设置

内容与正向区域文件中的基本设置相同

添加反向地址解析记录

	128                   IN      PTR     ns1.ln128.net.
	1                     IN      PTR     www.ln128.net.
	2                     IN      PTR     bbs.ln128.net.
	3                     IN      PTR     mp3.ln128.net.
	3                     IN      PTR     blog.ln128.net.

>注意：一定要修改数据域解析文件的所属组为named

![linux-dns-014-014][linux-dns-014-014]

3.构建从域名服务器

构建的方法和主服务器的大致一样，区别在于：

1)在named.rfc1912.zones文件中设置域

建立正向解析域

	zone “ln128.net” {
        type slave;
        file “slaves/ln128.z”
        masters { 192.168.216.128 ; };
    };

建立反向解析域

	zone “216.168.192.in-addr.arpa” {
        type slave;
        file ” slaves/ln128.f”;
        masters { 192.168.216.128 ; };
    }; 

![linux-dns-015-014][linux-dns-015-014]

说明：

>a)type设置为“slave”，表示当前DNS服务器是该域的从域名服务器类型
>
>b)从域名服务器中的区域文件应设置保存在 “slaves”子目录中，区域文件将从主域名服务器中获取并保存在该目录中
>
>c)使用masters设置主域名服务器的IP地址

2)不用设置数据解析文件，如果配置成功后会在/var/named/chroot/var/named/slaves下生成对应的数据解析文件

![linux-dns-016-014][linux-dns-016-014]

![linux-dns-017-014][linux-dns-017-014]

>特别注意：如果主服务器修改数据解析文件后一定要修改文件标识号，否则不会同步 

![linux-dns-018-014][linux-dns-018-014]

###DNS测试原理 

DNS服务器的主要测试方法

设置客户机使用指定的DNS服务器，通过使用网络客户端程序访问主机域名对DNS服务器进行简单的测试

使用nslookup、dig和host等专用工具可以对DNS服务器进行较全面的测试, nslookup命令在Linux和Windows系统中都默认安装，是比较常用的测试工具

使用nslookup测试DNS服务器

进入nslookup命令交换环境

	# nslookup
	>
	设置使用指定的DNS服务器
	> www.ln128.net
	测试localhost主机域名的正向解析
	> localhost
	测试localhost主机域名的反向解析
	> 127.0.0.1 

![linux-dns-019-014][linux-dns-019-014]

>注意：在测试该DNS的时候首先确保一下两点：
>
>1)测试机和DNS服务器网络互通
>
>2)测试机的DNS是DNS服务器的地址

![linux-dns-020-014][linux-dns-020-014]

[linux-dns-001-014]: /image/linux/linux-dns-001-014.png
[linux-dns-002-014]: /image/linux/linux-dns-002-014.png
[linux-dns-003-014]: /image/linux/linux-dns-003-014.png
[linux-dns-004-014]: /image/linux/linux-dns-004-014.png
[linux-dns-005-014]: /image/linux/linux-dns-005-014.png
[linux-dns-006-014]: /image/linux/linux-dns-006-014.png
[linux-dns-007-014]: /image/linux/linux-dns-007-014.png
[linux-dns-008-014]: /image/linux/linux-dns-008-014.png
[linux-dns-009-014]: /image/linux/linux-dns-009-014.png
[linux-dns-010-014]: /image/linux/linux-dns-010-014.png
[linux-dns-011-014]: /image/linux/linux-dns-011-014.png
[linux-dns-012-014]: /image/linux/linux-dns-012-014.png
[linux-dns-013-014]: /image/linux/linux-dns-013-014.png
[linux-dns-014-014]: /image/linux/linux-dns-014-014.png
[linux-dns-015-014]: /image/linux/linux-dns-015-014.png
[linux-dns-016-014]: /image/linux/linux-dns-016-014.png
[linux-dns-017-014]: /image/linux/linux-dns-017-014.png
[linux-dns-018-014]: /image/linux/linux-dns-018-014.png
[linux-dns-019-014]: /image/linux/linux-dns-019-014.png
[linux-dns-020-014]: /image/linux/linux-dns-020-014.png
