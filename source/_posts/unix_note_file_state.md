title: 系统数据文件和信息
date: 2013-05-14 18:13:16
tags: file io  
categories: 《unix 高级编程》-Note
---

###口令文件

POSIX.1 只定义了两个获取口令文件项的函数，在给出用户登录名或数值用户 ID 后，这两个函数就能查询相关项。

结构：

```
	struct {
		char *pw_name;   // 用户名
		char *pw_passwd; // 加密口令
		uid_t pw_uid;    // 数值用户ID
		gid_t pw_gid;    // 数值组ID
		char *pw_gecos;  // 注释字段
		char *pw_dir;    // 初始化工作目录
		char *pw_shell;  // 初始shell
		char *pw_class;  // 用户访问类
		time_t pw_change;// 下次更改口令时间
		time_t pw_expire;// 账户到期时间
	};

	#include <pwd.h>
	
	struct passwd *getpwuid(uid_t uid);
	
	struct passwd *getpwnam(const char *name);
	
	// 两个函数返回值：若成功则返回指针，若出错则返回 NULL
```


这两个函数都返回一个指向 passwd 结构的指针，该结构已由这两个函数在执行时填入信息，passwd结构通常是相关函数内的静态变量，只要调用相关函数，其内容就会被重写。

下列三个函数则可用于获取整个口令文件：

```
	#include <pwd.h>
	
	struct passswd *getpwent(void);
	
	// 返回值：若成功则返回指针，若出错或到达文件结尾则返回 NULL
	
	void setpwent(void);
	
	void endpwent(void);
```

调用 getpwent时，它返回口令文件中的下一个记录项，函数setpwent 反绕它所使用的文件，endpwent 则关闭这些文件。

```
	#include <stddef.h>
	#include <string.h>
	#include <stdio.h>
	#include <pwd.h>
	
	//struct passwd * getpwnam(const char *name)
	//{
	//  struct passwd *ptr;
	//
	//  setpwent();
	//  while ((ptr = getpwent()) !== NULL) {
	//      if (strcmp(name, ptr->pw_name) == 0) {
	//          break;  
	//      }
	//  }
	//
	//  endpwent();
	//  return ptr;
	//}
	//
	int main(void)
	{
		struct passwd *swan;
		setpwent();
		while ((swan = getpwent()) != NULL) {
			printf("system user: %s\n", swan->pw_name);
		}
	
		endpwent();
		return 0;
	}
```

###阴影口令

加密口令是经单向加密算法处理过的用户口令副本，因此此算法是单向的，所以不能从加密口令猜测到原来的口令。

在 linux 中，与访问口令文件的一组函数类似，有另一组函数可用于访问阴影口令文件。

结构：

```
	struct spwd {
		char *sp_namp; // 用户登录名
		char *sp_pwdp; // 加密口令
		int sp_lstchg; // 上次更改口令以来经过的时间
		int sp_min;  // 经过多少天后允许修改
		int sp_max;  // 要求更改尚余天数
		int sp_warn; // 到期告警天数
		int sp_inact; // 账户不活动之前的尚余天数
		int sp_expire; // 账户到期天数
		unsigned int sp_flag; // 保留
	}
	
	#include <shadow.h>
	
	struct spwd *getspnam(const char *name);
	struct spwd *getspent(void);
	
	// 两个函数返回值：若成功则返回指针，若出错则返回NULL
	
	void setspent(void);
	void endspent(void);
```


###组文件

UNIX组文件的结构，该结构在<grp.h>中定义：

```
	struct {
		char *gr_name;  //组名
		char *gr_passwd; //加密口令
		int gr_gid;  //数值组ID
		char **grmem; //指向各个用户名的指针数组	
	};
```

可以用下列两个函数查看组名和数值组ID:

```
	#include <grp.h>
	struct group *getgrgid(gid_t gid);
	struct group getgrnam(const char *name);
	
	// 两个函数返回值：若成功则返回指针，若出错则返回NULL
```

如同对口令文件进行操作的函数一样，这两个函数通常也返回指向一个静态变量的指针，在每次调用时都重写该静态变量。

如果需要搜索整个组文件，则需要使用另外几个函数，下列三个函数类似于针对口令文件的三个函数。

```
	#include <grp.h>
	
	struct group *getgrenet(void);
	
	// 返回值：若成功则返回指针，若出错或到达文件结尾则返回NULL
	
	void setgrent(void);
	void endgrent(void);
```

setgrent函数打开组文件并反绕它，getrent函数从组文件中读下一个记录，如若该文件尚未打开它则先打开它，endgrent函数关闭组文件。

使用附加组ID的有点是不必再显式地经常更改组，一个用户会参与多个项目，因此也就要同时属于多个组，此类情况是经常有的。

为了获取和设置附加组ID，提供了下列三个函数：

```
	#include <unistd.h>
	
	int getgroups(int gidsetsize, gid_t grouplist[]);
	
	// 返回值：若成功则返回附加组ID数，若出错则返回 -1
	
	#include <grp.h>
	#include <>
```

