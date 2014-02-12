title: Linux系统中防火墙配置
date: 2013-02-12 18:13:16
tags: firewall 
categories: linux
---

###网络层防火墙的应用原理

1.网络防火墙工作在TCP/IP的网络层

![linux-iptables-001-017][linux-iptables-001-017]

2.iptables规则链

![linux-iptables-002-017][linux-iptables-002-017]

3.iptables的三个表

iptables缺省具有3个规则表

1)Filter：用于设置包过滤

Filter：INPUT、FORWARD、OUTPUT

2)NAT：用于设置地址转换

NAT：PREROUTING、POSTROUTING、OUTPUT

3)Mangle：用于设置网络流量整形等应用

Mangle：PREROUTING、POSTROUTING、INPUT、OUTPUT和FORWARD

4.查看iptables防火墙

	# iptables -t filter -L   ==>iptables -L
	
	# iptables -t nat –L 

![linux-iptables-003-017][linux-iptables-003-017]

5.使用iptables脚本保存防火墙设置

iptables脚本可以保存当前防火墙配置

1)在保存防火墙当前配置前应先将原有配置进行备份

/etc/sysconfig/iptables iptables.raw

2)iptables脚本的save命令可以保存防火墙配置

service iptables save

3)配置内容将保存在“/etc/sysconfig/iptables”文件中，文件原有的内容将被覆盖

6.iptables命令的使用

1)iptables命令的操作对象包括

a.规则表（table）由规则链的集合组成，不同的规则表用于实现不同类型的功能

b.规则链（chain）由规则的集合组成，保存在规则表中；在规则表中不同的规则链代表了不同的数据包流向

c.规则（rule）是最基本的设置项，用于对防火墙的策略进行设置；流经某个数据链的数据将按照先后顺序经过规则的“过滤”

2)iptables命令查看规则表

a.基本语法

	iptables [-t table] -[L] [chain] [options]

b.不指定表名称时查看filter表的内容

	# iptables -L

c.查看指定的规则表

	# iptables -t nat -L

3)清空表中的规则

a.命令格式：

	iptables [-t table] -F [chain] [options] –X [chain]

b.清空filter表中的所有规则

	# iptables -F

c.清空nat表中的所有规则

	# iptables -t nat –F

d.删除表中所有的自定义规则链

	#iptables [-t table] -X

4)添加规则

a.命令格式

	iptables [-t table] -A chain rule-specification [options]

b.在INPUT规则链中添加规则，允许“eth0”网络接口中来自“192.168.1.0/24”子网的所有数据包

	# iptables -A INPUT -i eth0 -s 192.168.1.0/24 -j ACCEPT

5)删除规则

a.命令格式

	iptables [-t table] -D chain rule-specification [options]

b.删除规则的iptables命令与添加规则的命令格式类似

c.删除INPUT规则表中已有的规则

	# iptables -D INPUT -i eth0 -s 192.168.1.0/24 -j ACCEPT

6)设置内置规则链的缺省策略

a.命令格式

	iptables [-t table] -P chain target [options]

b.只有内建规则链才能够设置“缺省策略”

c.将INPUT规则链的缺省策略设置为“DROP”

	# iptables -P INPUT DROP

---
[扩展知识]

网络OSI七层模型

>7层==>应用层
>
>6层==>表示层
>
>5层==>会话层  //五六七层决定的数据的内容，压缩，加密，会话
>
>4层==>传输层  //源端口和目标端口
>
>3层==>网络层  //源ip和目标ip
>
>2层==>数据链路层 //源mac和目标mac
>
>1层==>物理层  //网线

-----

###防火墙应用实例

1.利用iptables实现多个用户通过adsl共享上网,并且开机自拨号和配置iptables nat

[实验原理]

由于不知道公网WEB的网关而且公司内部的局域网和公网就不可能通信，那么一般是通过拨号会动态获取一个公网IP，当内部计算机和这个带防火墙的路由器链接时会用防火墙的POSTROUTING规则链将公司内部请求的实际IP转化成公网动态获取的IP，这时由公司内部发出的所有请求就是合法的IP了就可以上网了。

[案例实验背景]

A.本实验是模拟共享上网，提前预设adsl拨号上网后获取的动态IP为192.168.129.254

B.模拟环境构架

1)一台模拟公网的WEB服务器假设IP：192.168.129.1网关在模拟公网是不需要设定的。

2)一台带防火墙的路由器(本实验其实是一台虚拟机，这个是2个网卡)

3)至少一台模拟公司员工机器(这些是局域网)

详细参见下图： 

![linux-iptables-004-017][linux-iptables-004-017]

[实验步骤]

A.架设模拟公网的WEB服务器

1)IP设置为192.168.129.1

2)网关不要设置

3)构建一个Apache服务器

B.架设模拟公司内部员工机器

1)IP设置为192.168.128.0/24

2)网关：192.168.128.254

C.架设带防火墙的路由器(在这里其实就是另一台VM)

1)本机是两块网卡eth0/eth1

>eth0的IP：192.168.128.254(链接公司内部)
>eth1的IP：192.168.129.254(公网动态获取的IP)

2)开启linux的路由器功能

	#echo 1 >/proc/sys/net/ipv4/ip_forward

![linux-iptables-005-017][linux-iptables-005-017]

D.在防火墙没有做任何操作是测试看看是否能通？

测试方法在本环境下是，在公司内部机器上访问http://192.168.129.1/

肯定是不通的，因为WEB服务器中没有设置网关路由器肯定是不能通信的

E.配置防火墙

	#iptables -t nat -A  PREROUTING -o eth1 -j MASQUERADE

其中eth1是指防火墙中连接WEB的网卡，换句话就是公网的动态获取IP，由于实际中这个IP是动态变化的，所以这里使用端口自动转化技术。 

![linux-iptables-006-017][linux-iptables-006-017]

F.测试上网

http://192.168.129.1/

![linux-iptables-007-017][linux-iptables-007-017]

2.只用一个公网IP架设服务器集群

[实验原理]

只有一个公网IP建立服务器集群，这样用带防火墙的路由器一个网卡链接公网IP，另一个链接局域网的所有的服务器，其中运用防火墙中的PREROUTING规则链将公网上访问的该公网IP转化成另一个网卡上的局域网IP，这样就实现了服务器集群。

[案例实验背景]

A.本实验是模拟服务器，提前假设有一个公网IP：192.168.128.254

B.模拟环境构架

1)一台模拟公网的个人计算机，假设IP：192.168.128.1(和假设一个网段为了是使其是互通的，实际中本来就是互通的)不设定网关就可以模拟一台公网计算机。

2)一台带防火墙的路由器(本实验其实是一台虚拟机，这个是2个网卡)

3)至少一台WEB服务器(这些是局域网)

详细参见下图： 

![linux-iptables-008-017][linux-iptables-008-017]

[实验步骤]

A.架设模拟公网的个人计算机

1)IP设置为192.168.128.1

2)网关不要设置

B.架设模拟局域网内WEB服务器

1)IP设置为192.168.129.1

2)网关：192.168.129.254

C.架设带防火墙的路由器(在这里其实就是另一台VM)

1)本机是两块网卡eth0/eth1

>eth0的IP：192.168.128.254(公网分配的IP)
>eth1的IP：192.168.129.254(链接局域网的IP)

2)开启linux的路由器功能

	#echo 1 >/proc/sys/net/ipv4/ip_forward

D.配置防火墙

	#iptables -t nat -A  PREROUTING -d 192.168.129.254 -j DNAT –to 192.168.129.1

其中192.168.129.254是模拟公网IP也就是公网用户直接访问的IP地址，192.168.129.1是真正的局域网WEB服务器 

![linux-iptables-009-017][linux-iptables-009-017]

E.测试上网

http://192.168.128.254/

![linux-iptables-010-017][linux-iptables-010-017]

3.通过防火墙禁止指定IP：192.168.128.1不能访问Apache

以下的几个实验的环境结构如图： 

![linux-iptables-011-017][linux-iptables-011-017]

[实验步骤]

1)在防火墙没有任何操作前测试WEB是否能正常使用

如果配置正确是可以使用的 

![linux-iptables-012-017][linux-iptables-012-017]

2)配置防火墙

    #iptables -t filter -A FORWARD -s 192.168.128.1 -d 192.168.129.1 -p tcp –dport 80 -j DROP 

![linux-iptables-013-017][linux-iptables-013-017]

4.禁止外网计算机192.168.128.1 ping到WEB服务器192.168.129.1，但允许WEB服务器ping通外网主机

以下是实验的环境结构和上个实验一样

[实验步骤]

1)在设置防火墙前： 

![linux-iptables-014-017][linux-iptables-014-017]

2)设置防火墙 

![linux-iptables-015-017][linux-iptables-015-017]

3)设置后ping

![linux-iptables-016-017][linux-iptables-016-017]

![linux-iptables-017-017][linux-iptables-017-017]


[linux-iptables-001-017]: /image/linux/linux-iptables-001-017.png
[linux-iptables-002-017]: /image/linux/linux-iptables-002-017.png
[linux-iptables-003-017]: /image/linux/linux-iptables-003-017.png
[linux-iptables-004-017]: /image/linux/linux-iptables-004-017.png
[linux-iptables-005-017]: /image/linux/linux-iptables-005-017.png
[linux-iptables-006-017]: /image/linux/linux-iptables-006-017.png
[linux-iptables-007-017]: /image/linux/linux-iptables-007-017.png
[linux-iptables-008-017]: /image/linux/linux-iptables-008-017.png
[linux-iptables-009-017]: /image/linux/linux-iptables-009-017.png
[linux-iptables-010-017]: /image/linux/linux-iptables-010-017.png
[linux-iptables-011-017]: /image/linux/linux-iptables-011-017.png
[linux-iptables-012-017]: /image/linux/linux-iptables-012-017.png
[linux-iptables-013-017]: /image/linux/linux-iptables-013-017.png
[linux-iptables-014-017]: /image/linux/linux-iptables-014-017.png
[linux-iptables-015-017]: /image/linux/linux-iptables-015-017.png
[linux-iptables-016-017]: /image/linux/linux-iptables-016-017.png
[linux-iptables-017-017]: /image/linux/linux-iptables-017-017.png
