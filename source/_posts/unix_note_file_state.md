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
	
	#include <grp.h> // on linux and solaris
	#include <unistd.h> // on freebsd and macos

	int setgroups(int ngroups, const gid_t grouplist[]);

	int intgroups(const char *username, git_t basegid);
```

作为一个特例，如若 gidsetsize 为 0, 则函数只返回附加组 ID数， 而对数组 grouplist 则不作修改.

setgroups 可由超级用户调用以便调用进程设置附加组 ID表，grouplist 是组 ID 数组，而 ngroups 指定了数组中的元素个数， ngroups 的值不能大于 NGROUPS_MAX.

initgroups 函数调用 setgroups ，initgroups 读取整个组文件，然后对 username 确定组的成员关系，然后调用 setgroups ，以便为该用户初始化附加组 ID 表.

### 登陆账户记录

大多数 UNIX 系统都提供下列两个数据文件：utmp 文件，它记录当前登录进系统的各个用； wtmp 文件，它跟踪各个登录和注销事件.

```
	struct utmp {
		char ut_line[8]; // tty line: "ttyd0",'ttyp0'...
		char ut_name[8]; // login name
		long ut_time;	 // seconds since epoch
	}
```

登录时， login 程序填写此类型结构，然后将其写入到 utmp 文件中，同时也将其填写到 wtmp 文件中。注销时，init进程将 utmp 文件中相应的记录檫除，并将一个新记录添写到 wtmp文件中，在 wtmp 文件的注销记录中，将 ut_name 字段清 0, 在系统重启时，以及更改系统时间和日期的前后，都在 wtmp 文件中添写特殊的记录项。

### 系统标识

uname 函数，它返回与当前主机和操作系统有关的信息

```
	#include <sys/utsname.h>
	int uname(struct utsname *name);

	// 返回值: 若成功返回非负值，若出错则返回 -1
```

通过该函数的参数向其传递一个 utsname 结构的地址，然后该函数填写此结构.

```
	struct utsname {
		char sysname[]; // 操作系统的名称
		char nodename[]; // 节点名称
		char release[]; // 当前系统的 release 版本
		char version[]; // 当前版本
		char machine[]; // 硬件平台	
	}
```

BSD 派生的系统提供了 gethostname 函数，它只返回主机名，该名字通常就是 TPC/IP 网络上主机的名字.

```
	#include <unistd.h>

	int gethostname(char *name, int namelen);

	// 返回值：若成功则返回 0，若出错则返回 -1

```

现在 gethostname 函数已经定义为 POSIX.1 的一部分，它指定最大主机名长度是 HOST_NAME_MAX.

### 时间和日期例程

Unix 在时间日期方面和其他操作系统的区别是：

- 以国际标准时间而非本地时间计时；
- 可以自动进行转换，例如夏时制；
- 将时间和日期作为一个量值保存

time 函数返回时间和日期

```
	#include <time.h>
	time_t time(time_t *calptr)

	// 返回值：若成功则返回时间值，若出错则返回 -1
```

时间总是作为函数返回，如果参数不为空，则时间值也存放在由 calptr 指向的单元内。

与 time 函数相比，gettimeofday提供了更高的分辨率

```
	#include <sys/time.h>
	int gettimeofday(struct timeval *restrict tp, void *restrict tzp);

	// 返回值，总是返回 0
```

该函数作为XSI 扩展定义在 Single UNIX Specification 中， tzp的唯一合法值是 NULL, 其他值则将产生不确定的结果。

gettimeofday 函数返回的 timeval 结构如下:

```
	struct timeval {
		time_t tv_sec; // 秒
		long tv_usec; // 微秒	
	}
```

![各个时间函数之间的关系][unix_note_001_001]

两个函数 localtime 和 gmtime 将日历时间转化成以年、月、日、时、分、秒、周日表示的时间， tm 结构如下:

```
	struct tm {
		int tm_sec;
		int tm_min;
		int tm_hour;
		int tm_mday;
		int tm_mon;
		int tm_year;
		int tm_wday;
		int tm_yday;
		int tm_isdst;
	}
```

秒可以超过 59 的理由是可以表示闰秒，如果夏时制生效，则夏时制标志值为正，如果为非夏时制时间，则该标志值为 0；如果此信息不可用，则其值为负。

```
	#include <time.h>
	struct tm *gmtime(const time_t *calptr);
	struct tm *localtime(const time_t *calptr);

	// 两个函数返回值：指向 tm 结构的指针
```

localtime 和 gmtime 之间的区别是：localtime 将日历时间转换成本地时间，而 gmtime 则将日历时间转换成国际标准时间的年、月、日、分、秒、周日。

函数 mktime 以本地时间的年、月、日等作为参数，将其转换为 time_t 值

```
	#include <time.h>
	
	time_t mktime(struct tm *tmptr);

	// 返回值：若成功则返回日历时间，若出错则返回 -1
```

asctime 和 ctime 函数产生 26 字节的字符串如：

> Tue Feb 10 18:27:38 2014\n\0

```
	#include <time.h>

	char *asctime(const struct tm *tmptr);

	char *ctime(const time_t *calptr);

	// 两个函数返回值：指向以 null 结尾的字符串的指针
```

asctime 的参数是指向年、月、日等字符串的指针，而 ctime 的参数则是指向日历时间的指针。

最后一个时间函数 strftime:

```
	#include <time.h>
	size_t strftime(char *restrict buf, size_t maxsize,
					const char *restrict format,
					const struct tm *restrict tmptr);
	// 返回值：若有空间返回存入数组的字符串，否则返回 0
```

最后一个参数是要格式化的时间值，有一个指向 tm 结构的指针指定，格式化结果存放在一个长度为 maxsize 个字符的 buf 数组中，如果 buf 长度足以存放格式化结果及一个 null 终止符，则该函数返回在 buf 中存放的字符数，否则该函数返回 0.

对于常量 TZ 会影响 localtime, mktime, ctime 和strftime 四个函数,如果定义了则其值代替系统默认值，否则使用国际标准时间 UTC.

(完)
[unix_note_001_001]:/image/unix_note/unix_note_001_001.png
