title: Linux中的Apache配置
date: 2013-02-12 18:13:16
tags: apache
categories: linux
---

###HTTPD服务的目录结构

####HTTPD安装的说明

   [安装APACHE的部分配置]
	
   	./configure –prefix=/usr/local/apache2/ –sysconfdir=/etc/httpd/conf
                         安装APACHE的目录                安装APACHE时的配置文件目录


####按照上述安装APACHE的目录

>服务目录：/usr/local/apache2/
>
>主配置文件：/etc/httpd/conf/httpd.conf
>
>网页目录：/usr/local/apache2/htdocs/
>
>服务脚本：/usr/local/apache2/bin/apachectl
>
>执行程序：/usr/local/apache2/bin/httpd
>
>访问日志： /usr/local/apache2/log/access_log
>
>错误日志： /usr/local/apache2/log/error_log 

###构建基本可用的Web服务器

####构建的步骤

1) 修改主配置文件httpd.conf，进行相关设置

2) 进行语法检查
	
    /usr/local/apache2/bin/apachectl  -t
    或者
    /usr/local/apache2/bin/httpd  -t

3) 启动httpd服务

    /usr/local/apache2/bin/apachectl start

4) 访问网站进行测试

http://www.lamp.com

####httpd.conf配置文件

1)常用的全局配置参数 

>ServerRoot：              服务目录
>
>ServerAdmin：             管理员邮箱
>
>User：                    运行服务的用户身份
>
>Group：                   运行服务的组身份
>
>ServerName：              网站服务器的域名
>
>DocumentRoot              网页文档的根目录
>
>Listen：                  监听的IP地址、端口号
>
>PidFile：                 保存httpd进程PID号的文件
>
>DirectoryIndex：          默认的索引页文件
>
>ErrorLog：                错误日志文件的位置
>
>CustomLog：               访问日志文件的位置
>
>LogLevel：                记录日志的级别，默认为warn
>
>Timeout：                 网络连接超时，默认为300秒
>
>KeepAlive：               是否保持连接，可选On或Off
>
>MaxKeepAliveRequests：    每次连接最多请求文件数
>
>KeepAliveTimeout：        保持连接状态时的超时时间
>
>Include：                 需要包含进来的其他配置文件
>
>StartServers 8            http启动进程的数目 


2)httpd服务的日志

两类日志文件

>访问日志：/usr/local/apache2/logs/access_log
>
>错误日志：/usr/local/apache2/logs/error_log

3)载入模块指令 

Apache服务器采用动态共享对象（DSO，Dynamic Shared Object）的机制，在启动Apache服务器时可根据实际需要载入适当的模块，使其具有相应的功能。

载入模块的相关指令有：

>LoadModule
>ClearModuleList
>AddModule

LoadModule指令用于动态载入模块，即将模块外挂在Apache服务器上。

语法：

LoadModule 模块名称  模块文件路径全名

实例：

LoadModule status\_module modules/mod_status.so 

4)容器指令

容器指令（container directive）通常包括在<\>括号内，较容易识别，常用的容器指令有：

	<Directory>
	<Files>
	<Location>
	<VirtualHost>

a.使用<Directory>… </Directory>设置指定目录的访问权限，其中可包含：

	Options
	AllowOverride
	Order
	Allow
	Deny

五个属性:

I.Options属性

Options  FollowSymLinks  Indexes  MultiViews

Options可以组合设置下列选项：

>All：用户可以在此目录中作任何事情。
>
>ExecCGI：允许在此目录中执行CGI程序。
>
>FollowSymLinks：服务器可使用符号链接指向的文件或目录。
>
>Indexes：服务器可生成此目录的文件列表。
>
>None：不允许访问此目录
>
>multiviews: 允许多用户浏览

II.AllowOverride

>AllowOverride None

AllowOverride会根据设定的值决定是否读取目录中的.htaccess文件，来改变原来所设置的权限。

>All：读取.htaccess文件的内容，修改原来的访问权限。
>
>None：不读取.htaccess文件

为避免用户自行建立.htaccess文件修改访问权限，http.conf文件中默认设置每个目录为： AllowOverride None。

III.Allow

设定允许访问Apache服务器的主机

>Allow from all
>
>允许所有主机的访问

Allow from 202.96.0.97 202.96.0.98

允许来自指定IP地址主机的访问

IV.Deny

设定拒绝访问Apache服务器的主机

>Deny from  all
>
>拒绝来自所有主机的访问

Deny from  202.96.0.99  202.96.0.88

拒绝指定IP地址主机的访问

V.Order

Order allow,deny

Order用于指定allow和deny的先后次序。

范例：

>Order deny,allow
>
>Deny from all
>
>Allow from 202.96.0.97
>
>Order allow,deny
>
>Allow from all
>
>Deny from 202.96.0.97

b.<Files>容器包含只应用于指定文件的指令，文件应该由文件名（必要时使用统配符）指定

实例：

	<Files  =  “^\.ht”>
	Order allow,deny
	Deny from all
	</Files>

c.<Location>容器包含只应用于特定URL的指令。

实例：

	<Location /server-status>
	SetHandler server-status
	order deny,allow
	allow from 127.0.0.1
	deny from all
	</Location>

5)认证和授权

a.认证类型:

Basic

digest(摘要认证)

b.建立认证与授权的步骤

建立用户库

配置服务器的保护域

什么用户具有访问权限

c.认证指令：

>Authname     受保护领域名称
>
>Authtype     认证方式
>
>Authuserfile     认证口令文件
>
>authgroupfile 认证组文件
>
>Require user        授权指定用户
>
>Require group    授权指定组
>
>Require valid-user    授权给认证口令文件用户

d.建立用户库基本认证

>htpasswd -c authfile username
>
>口令文件格式
>
>Username:password 

####httpd服务的访问控制

1)基于用户的访问控制

添加认证授权设置

![linux-apache-001-015][linux-apache-001-015]

2)创建存储认证用户账号及口令的文件

需使用htpasswd工具 

![linux-apache-002-015][linux-apache-002-015]

3)配置内容解释(应用到上面认证与授权知识)

a.AuthType Basic

AuthType指令用于设置身份认证时传送密码的编码方式。设置为“Basic”时利用uuencode编码方式传送密码。

AuthType需与AuthName 、Require、AuthUserFile一同使用。

b.AuthName auth-domain

AuthName指令对当前定义的认证区域进行命名，该名称会出现在浏览器客户端的用户认证对话框中，以标识用户被认证的区域。如认证区域名称中包含空格需用“”括起。

AuthName需与AuthType、Require、AuthUserFile一同使用。

c.Require

Require指令用于设定可进行身份验证的用户。

Require user 用户名 [用户名] ……

设置指定用户名的用户可通过身份验证访问区域。

Require group 组名 [组名 ] ……

设置指定组内的用户可通过身份验证访问区域。

Require valid-user

设置所有合法用户可通过身份验证访问区域。

d.htpasswd命令

htpasswd指令用于创建密码文件和设置用户密码：

>htpasswd -c 文件名  用户名
>例： htpasswd –c .htpasswd user1

htpasswd 文件名  用户名

在指定的密码文件中添加指定用户的密码，如该用户已存在则修改用户密码

e.AuthUserFile

AuthUserFile file-path

AuthUserFile指令用于设置验证用户身份的密码文件，该文件名需设置绝对路径。

例如：

>AuthUserFile /etc/httpd/conf/.htpasswd
>
>密码文件是用htpasswd命令创建的。

AuthType指令用于设置身份认证时传送密码的编码方式。设置为“Basic”时利用uuencode编码方式传送密码。

AuthType需与AuthName 、Require、AuthUserFile一同使用 

####Apache虚拟目录

虚拟目录的优点:

>便于访问
>
>便于移动站点目录
>
>加大磁盘空间
>
>安全性好

应用案例：

为Apache在linux的根增加一个目录/vln128

>1)mkdir /vln128
>
>2)vi /etc/httpd/conf/http.conf

在其中添加如下配置内容即可. 

![linux-apache-003-015][linux-apache-003-015]

![linux-apache-004-015][linux-apache-004-015]

####构建虚拟Web主机

1)虚拟Web主机

即在同一台服务器中运行多个Web站点的应用，其中每一个站点并不独立占用一台真正的计算机

2)httpd支持的虚拟主机类型

>基于IP地址的虚拟主机
>
>基于端口的虚拟主机
>
>基于域名的虚拟主机

3)构建虚拟Web主机-基于IP地址

>应用示例：
>
>构建2个虚拟Web站点：
>
>www.lamp.com，IP地址为 192.168.10.1
>
>www.accp.com，IP地址为 192.168.4.1
>
>在浏览器中访问这两个IP时，分别显示不同的内容 

![linux-apache-005-015][linux-apache-005-015]

4)构建虚拟Web主机-基于端口

>应用示例：
>
>构建2个虚拟Web站点：
>
>www.lamp.com，IP地址、端口为 192.168.10.1:80
>
>www.accp.com，IP地址、端口为 192.168.10.1:8080
>
>在浏览器中访问这两个端口时，分别显示不同的内容

![linux-apache-006-015][linux-apache-006-015]

5)构建虚拟Web主机-基于域名(一般生产环境的解决方案)

>应用示例：
>
>构建2个虚拟Web站点：
>
>www.lamp.com，IP地址为 192.168.216.128
>
>www.accp.com，IP地址为 192.168.216.128
>
>在浏览器中访问这两个域名时，分别显示不同的内容

![linux-apache-007-015][linux-apache-007-015]

![linux-apache-008-015][linux-apache-008-015]

![linux-apache-009-015][linux-apache-009-015]

####建立系统用户的个人主页

1) 修改httpd.conf，启用个人主页功能

UserDir public_html

![linux-apache-010-015][linux-apache-010-015]

确认目录区域设置

2) 建立个人主页测试网页

~/public_html/index.html

添加权限：chmod o+x /home/jerry/

3) 重新启动httpd服务

/usr/local/apache2/bin/apachectl  restart

4) 访问测试

http://www.lamp.com/~user

####Apache Rewrite 拟静态配置

1)mod_rewrite 简介和配置

Rewirte主要的功能就是实现URL的跳转和隐藏真实地址，基于Perl语言的正则表达式规范。平时帮助我们实现拟静态，拟目录，域名跳转，防止盗链等

2)apache配置rewrite

支持httpd.conf 配置和目录 .htaccess配置

a.启用rewrite

	# LoadModule rewrite_module            modules/mod_rewrite.so
	去除前面的 #
	LoadModule rewrite_module modules/mod_rewrite.so

b.启用.htaccess

>AllowOverride None    修改为:  AllowOverride All

3)mod_rewrite 规则的使用(一般为了兼容性编写到.htaccess)

	RewriteEngine on               启动rewrite引擎

	RewriteCond %{HTTP_HOST} !^www.lamp.com  [NC]          判断主机

	RewriteRule   ^/(.*) http://www.lamp.com/ [L]              跳转到

	RewriteEngine on                启动rewrite引擎
	RewriteRule ^/test([0-9]*).html$ /test.php?id=$1
	RewriteRule ^/new([0-9]*)/$ /new.php?id=$1 [R]            跳转到

4)mod_rewrite 规则修正符

>a) R 强制外部重定向
>
>b) F 禁用URL,返回403HTTP状态码
>
>c) G 强制URL为GONE，返回410HTTP状态码
>
>d) P 强制使用代理转发
>
>e) L 表明当前规则是最后一条规则，停止分析以后规则的重写
>
>f) N 重新从第一条规则开始运行重写过程
>
>g) C 与下一条规则关联
>
>h) NS  只用于不是内部子请求
>
>i) NC 不区分大小写
>
>j) NE 不在输出转义特殊字符   \%3d$1  等价于 =$1

5)apache rewrite日志功能

	vi /etc/httpd/httpd.conf
	
	rewritelog /usr/local/apache/logs/rewrite.log  rewriteloglevel 9

这样就可以把用apache做过的所有的rewrite过程全记录下来.

当需要调试时请用rewritelog and rewriteloglevel 9联合,9为最大即得到最多的调试信息,最小为1，最小的调试信息，默认为0,没有调试信息

6)应用案例

a.将输入 en.lamp.com 的域名时跳转到www.lamp.com

	RewriteEngine on
	RewriteCond %{HTTP_HOST} ^en. lamp.com [NC]
	RewriteRule ^(.*) http://www.lamp.com/ [L]

b. 将http://ss.kiya.cn/bbs/tread-60.html, 让它在新的域名下继续有效，点击后转发到http://bbs.lamp.com/index.html

	RewriteEngine On
	RewriteCond %{REQUEST_URI} ^/bbs/
	RewriteRule ^bbs/(.*) http://bbs.lmap.com/$1 [L] 

[linux-apache-001-015]: /image/linux/linux-apache-001-015.png
[linux-apache-002-015]: /image/linux/linux-apache-002-015.png
[linux-apache-003-015]: /image/linux/linux-apache-003-015.png
[linux-apache-004-015]: /image/linux/linux-apache-004-015.png
[linux-apache-005-015]: /image/linux/linux-apache-005-015.png
[linux-apache-006-015]: /image/linux/linux-apache-006-015.png
[linux-apache-007-015]: /image/linux/linux-apache-007-015.png
[linux-apache-008-015]: /image/linux/linux-apache-008-015.png
[linux-apache-009-015]: /image/linux/linux-apache-009-015.png
[linux-apache-010-015]: /image/linux/linux-apache-010-015.png
