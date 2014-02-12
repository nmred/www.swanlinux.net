title: Linux 文件共享之 SSH
date: 2013-02-12 18:13:16
tags: sshd 
categories: linux
---

###SSH的服务程序启动及停止 

OpenSSH的服务程序名称是sshd

1.sshd服务程序的启动脚本

/etc/init.d/sshd

sshd服务程序缺省状态为自动启动

2.sshd服务的启动与停止

	启动服务程序
	service sshd start
	停止服务程序
	service sshd stop 

###OpenSSH的典型用户登录

使用ssh命令登录SSH服务器
   
	# ssh root@192.168.1.2

1.首次登录SSH服务器

为了建立加密的SSH连接需要用户在客户端确认服务器发来的RSA密钥 （输入yes）

2.用户认证

每次登录SSH服务器都需要输入正确的用户口令

SSH登录使用的是SSH服务器主机中的用户帐号

3.SSH的用户目录

1)“.ssh”目录

在SSH客户主机的用户宿主目录中，使用名为“.ssh”的目录保存用户的SSH客户端信息

2)~/.ssh/

a.  “.ssh”目录在用户首次进行SSH登录后自动建立

b.   “known_hosts”文件用于保存当前用户所有登录过的SSH服务器的RSA密钥 

![linux-ssh-001-013][linux-ssh-001-013]

[扩展知识]

SSH密钥认证的原理

![linux-ssh-002-013][linux-ssh-002-013]

###基于密钥的SSH认证登录过程

A、设置密钥认证的一般步骤
1.在SSH客户端生成用户的公钥和私钥对文件

1)使用ssh-keygen命令生成密钥对
	
	$ssh-keygen -t rsa

2)公钥和私钥文件

ssh-keygen命令将在“.ssh”目录中生成公钥和私钥文件

id_rsa是私钥文件，内容需要严格保密

id_rsa.pub是公钥文件，可发布到SSH服务器中

![linux-ssh-003-013][linux-ssh-003-013]

注意：提示输入密码  时什么也不要输入


2.将SSH客户的公钥添加到SSH服务器中用户的认证文件中

1)复制公钥文件

2)将客户端中的用户公钥文件复制到SSH服务器中

3)公钥文件的复制可使用软盘、U盘或网络

ssh-copy-id -i id_rsa.pub 192.168.10.1

![linux-ssh-004-013][linux-ssh-004-013]

4)最后在服务器的.ssh下把id_rsa.pub改名为authorized_keys 

![linux-ssh-005-013][linux-ssh-005-013]

3.验证密钥的认证

B、SSH密钥认证过程

基于密钥的用户认证过程

1.用户使用ssh命令登录SSH服务器时，将使用客户机中的私钥与服务器中的公钥进行认证，认证成功后将允许用户登录

2.密钥的认证过程是ssh命令与SSH服务器自动完成的

3.用户登录过程中将不再提示输入用户口令 

###禁止root用户的SSH登录 

为了提高Linux服务器的安全性，可以禁止root用户进行SSH登录

	设置sshd_config文件
	# vi /etc/ssh/sshd_config
  	  PermitRootLogin no
	重新启动sshd服务程序
	# service sshd restart 

![linux-ssh-006-013][linux-ssh-006-013]

再次登录SSH服务器时将不能使用root帐号进行登录

###SSH涉及到的常用命令

1.ssh命令

ssh命令的两种格式

>格式1：ssh username@sshserver
>
>格式2：ssh -l username sshserver

不指定用户名的ssh命令

ssh命令中如果不指定用户名，将使用SSH客户机中当前用户的名字登录SSH服务器

	# ssh 192.168.1.2

2.scp命令

1)scp命令可以实现SSH服务器与客户机之间的文件复制

2)scp命令的格式类似于cp命令

3)SSH服务器可以作为scp命令中的源文件或目标文件

4)命令实例

	将SSH服务器中的文件复制到客户机
	#scp root@192.168.1.2:/etc/passwd .
	将客户机中的文件复制到SSH服务器
	#scp test mike@192.168.1.2:~

3.rsync命令

1)rsync -e ssh -arv /mnt root@192.168.0.1:/mnt

>-v, –verbose      详细模式输出
>
>-q, –quiet        精简输出模式 
>
>-c, –checksum     强制对文件传输进行校验 
>
>-a, –archive      归档模式，并保持所有文件属性 
>
>-r, –recursive    对子目录以递归模式处理

2)用rsync进行远程备份时，最好使用公钥认证的ssh方式和crontab来一起完成 


[linux-ssh-001-013]: /image/linux/linux-ssh-001-013.png
[linux-ssh-002-013]: /image/linux/linux-ssh-002-013.png
[linux-ssh-003-013]: /image/linux/linux-ssh-003-013.png
[linux-ssh-004-013]: /image/linux/linux-ssh-004-013.png
[linux-ssh-005-013]: /image/linux/linux-ssh-005-013.png
[linux-ssh-006-013]: /image/linux/linux-ssh-006-013.png
