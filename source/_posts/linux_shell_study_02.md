title: Linux 系统 Shell 编程二
date: 2013-02-12 18:13:16
tags: shell 
categories: linux
---

###条件测试操作

**test命令**

用途：测试特定的表达式是否成立，当条件成立时，命令执行后的返回值为0，否则为其他数值

格式：test 条件表达式 [ 条件表达式 ]

常见的测试类型

>测试文件状态

>字符串比较

>整数值比较

>逻辑测试

1.测试文件状态

格式：[ 操作符 文件或目录 ]

常用的测试操作符

>-d：测试是否为目录（Directory）
>
>-e：测试目录或文件是否存在（Exist）
>
>-f：测试是否为文件（File）
>
>-r：测试当前用户是否有权限读取（Read）
>
>-w：测试当前用户是否有权限写入（Write）
>
>-x：测试当前用户是否可执行（Excute）该文件
>
>-L：测试是否为符号连接（Link）文件 

	[root@localhost ~]# [ -d /etc/vsftpd ]
	
	[root@localhost ~]# echo $?
	
	0
	
	[root@localhost ~]# [ -d /etc/hosts ]
	
	[root@localhost ~]# echo $?
	
	1 

----------------

	[root@localhost ~]# [ -e /media/cdrom ] && echo “YES”
	
	YES
	
	[root@localhost ~]# [ -e /media/cdrom/Server ] && echo “YES“
	
	[root@localhost ~]# 

2、整数值比较

格式：[ 整数1 操作符 整数2 ]

常用的测试操作符

>-eq：等于（Equal）

>-ne：不等于（Not Equal）

>-gt：大于（Greater Than）

>-lt：小于（Lesser Than）

>-le：小于或等于（Lesser or Equal）

>-ge：大于或等于（Greater or Equal）

	[root@localhost ~]# who | wc -l
	
	5
	
	[root@localhost ~]# [ `who | wc -l` -le 10 ] && echo “YES”
	
	YES 
	
------
	
	[root@localhost ~]# df -hT | grep “/boot” | awk ‘{print $6}’
	
	12%
	
	[root@localhost ~]# BootUsage=`df -hT | grep “/boot” | awk ‘{print $6}’ | cut -d “%” -f 1`
	
	[root@localhost ~]# echo $BootUsage
	
	12
	
	[root@localhost ~]# [ $BootUsage -gt 95 ] && echo “YES” 

3.字符串比较

格式：[ 字符串1 = 字符串2 ]

[ 字符串1 != 字符串2 ]

[ -z 字符串 ]

常用的测试操作符

>=：字符串内容相同
>
>!=：字符串内容不同，! 号表示相反的意思
>
>-z：字符串内容为空 

	[root@localhost ~]# read -p “Location：” FilePath
	
	Location：/etc/inittab
	
	[root@localhost ~]# [ $FilePath = "/etc/inittab" ] && echo “YES”
	
	YES 
	
----
	
	[root@localhost ~]# [ $LANG != "en.US" ] && echo $LANG
	
	zh_CN.UTF-8 

4.逻辑测试

格式：[ 表达式1 ] 操作符 [ 表达式2 ] …

常用的测试操作符

>-a或&&：逻辑与，“而且”的意思
>
>  前后两个表达式都成立时整个测试结果才为真，否则为假
>
>-o或||：逻辑或，“或者”的意思
>
>  操作符两边至少一个为真时，结果为真，否则结果为假
>
>!：逻辑否
>
>  当指定的条件不成立时，返回结果为真

	[root@localhost ~]# echo $USER
	
	root
	
	[root@localhost ~]# [ $USER != "teacher" ] && echo “Not teacher”
	
	Not teacher
	
	[root@localhost ~]# [ $USER = "teacher" ] || echo “Not teacher”
	
	Not teacher 

###Shell 编程中常见语法

1、if条件语句 — 单分支

应用示例：

如果/boot分区的空间使用超过80%，输出报警信息

2、if条件语句 — 双分支

应用示例：

判断mysqld是否在运行，若已运行则输出提示信息，否则重新启动mysqld服务

3、if条件语句 — 多分支

	if 条件测试命令1; then
		命令序列1
	elif 条件测试命令2; then
		命令序列2
	elif ...
	else
		命令序列n
	fi

4、for循环语句

应用示例1：

>依次输出3条文字信息，包括一天中的“Morning”、“Noon”、“Evening”字串

应用示例2：

>对于使用“/bin/bash”作为登录Shell的系统用户，检查他们在“/opt”目录中拥有的子目录或文件数量，如果超过100个，则列出具体个数及对应的用户帐号

5、while循环语句

应用示例1：

>批量添加20个系统用户帐号， 用户名依次为“stu1”、“stu2”、……、“stu20”

>这些用户的初始密码均设置为“123456”

应用示例2：

>批量删除上例中添加的20个系统用户帐号 

6、case多重分支语句

![swicth][linux-shell-switch]

应用示例1：

>编写脚本文件 mydb.sh，用于控制系统服务mysqld
>
>当执行 ./mydb.sh start 时，启动mysqld服务
>
>当执行 ./mydb.sh stop 时，关闭mysqld服务
>
>如果输入其他脚本参数，则显示帮助信息

应用示例2：

>提示用户从键盘输入一个字符，判断该字符是否为字母、数字或者其它字符，并输出相应的提示信息

7、shift迁移语句

用于迁移位置变量，将 $1~$9 依次向左传递

>1）例如，若当前脚本程序获得的位置变量如下：
>
>      $1=file1、$2=file2、$3=file3、$4=file4
>
>2）则执行一次shift命令后，各位置变量为：
>
>      $1=file2、$2=file3、$3=file4
>
> 3）再次执行shift命令后，各位置变量为：
>
>     $1=file3、$2=file4

应用示例：

>通过命令行参数传递多个整数值，并计算总和

8、循环控制语句

a.break语句

在for、while、until等循环语句中，用于跳出当前所在的循环体，执行循环体后的语句

b.continue 语句

在for、while、until等循环语句中，用于跳过循环体内余下的语句，重新判断条件以便执行下一次循环 

###Shell 函数运用

![函数][linux-shell-function]

应用示例：

>在脚本中定义一个加法函数，用于计算2个整数的和
>
>调用该函数计算（12+34）、（56+789）的和

	[root@localhost ~]# sh adderfun.sh
	
	46
	
	845 

[linux-shell-function]: /image/linux/linux-shell-function-002.png
[linux-shell-switch]: /image/linux/linux-shell-switch-002.png
