title: 进程环境 
date: 2014-02-16 11:47:16
tags: process 
categories: 《unix 高级编程》-Note
---

### main 函数

```
	int main(int argc, char *argv[]);
```

其中，argc 是命令行参数的数目，argv是指向参数的各个指标所构成的数组。

当内核执行 C 程序时 (使用一个 exec 函数) ， 在调用mian前先调用一个特殊的启动例程。可执行程序文件将此启动例程指定为程序的起始地址--这是由连接编译器设置的，而连接编译器由C编译器调用。

### 进程终止

有8中方式进程终止，其中5中位正常终止:

- 从main返回
- 调用 exit
- 调用 \_exit 或 \_Eixt
- 最后一个线程从其启动例程返回
- 最后一个线程调用 pthread_exit

异常终止有 3 种方式，它们是：

- 调用 abort
- 接到一个信号并终止
- 最后一个线程对取消请求作出响应

**1.exit 函数 **

有三个函数用于正常终止一个程序：\_exit 和 \_Exit 立即进入内核，exit 则先执行一些清理处理，然后进入内核。

```
	#include <stdlib.h>
	void exit(int status);
	void _Exit(int status);
	#include <unistd.h>
	void _exit(int status);
```

exit 函数总是执行一个标准 I/O 库的清理关闭操作：为所有打开流调用 fclose 函数。

三个 exit 函数都带有一个整形参数，称之为终止状态。

**2. atexit函数**

一个进程可以登记多达 32 个函数，这些函数将由 exit 自动调用称为这这些函数为终止处理程序，并调用 atexit 函数来登记这些函数。

```
	#include <stdlib.h>

	int atexit(void (*func)(void));

	// 返回值：若成功则返回 0 ，若出错则返回非 0 值
```

其中，atexit 的参数是一个函数地址，当调用次函数时无需向它传送任何参数，也不期望它返回一个值。exit调用这些函数的顺序与它们登记时候的顺序相反。同一函数如若登记多次，则也会被调用多次。

注意，内核使程序执行的唯一方法是调用一个exec 函数。进程自愿终止的唯一方法是显示或隐式地调用 \_exit 或 \_Exit. 进程也可自愿地由一个信号使其终止。

```
	#include "../apue.h"

	static void my_exit1(void);
	static void my_exit2(void);

	int main(void)
	{
		if (atexit(my_exit2) != 0) {
			err_sys("can't register my_exit2");
		}

		if (atexit(my_exit1) != 0) {
			err_sys("can't register my_exit1");
		}

		if (atexit(my_exit1) != 0) {
			err_sys("can't register my_exit1");
		}

		return 0;
	}

	static void my_exit1(void)
	{
		printf("first exit handler\n");
	}

	static void my_exit2(void)
	{
		printf("second exit handler\n");
	}
```

### 环境表

每个程序都会接收到一张环境表，与参数表一样，环境表也是一个字符串指针数组，其中每个指针包含一个以 null 结束的 C 字符的地址。全局变量 environ 则包含了该指针数组的地址。

```
	extern char **environ;
```

![由5个C字符串组成的环境][unix_note_002_001]

通常用getenv 和 putenv 函数来访问特定的环境变量，而不是用 environ 变量。但是要查看整个环境，则必须使用 environ 指针。

### 存储器分配

ISO C 说明了三个用于存储空间动态分配的函数：

- malloc: 分配制定字节的存储区，此存储区中的初始值不确定
- calloc: 为指定数量具指定长度的对象分配存储空间，该空间中的每一位都初始化为 0
- realloc: 更改以前分配区的长度，当增加长度时，可能需要将以前分配区的内容移到另一个足够大的区域，以便在尾端提供增加的存储区，而新增区域内的初始值则不确定。

```
	#include <stdlib.h>
	
	void *malloc(size_t size);

	void *calloc(size_t nobj, size_t size);

	void *realloc(void *ptr, size_t newsize);

	// 三个函数返回值：若成功则返回非空指针，若出错则返回NULL

	void free(void *ptr);
```

如果在该存储区后有足够的空间可供扩充，则可则原存储区位置上向高地址方向扩充，无需移动任何原先的内容，并返回传送给它的同样的指针值，如果在原存储区后没有足够的空间，则 realloc 分配另一个足够大的存储区，将原先的内容复制到新分配的存储区。

其他可能产生的致命性的错误是：释放一个已经释放了的块，调用 free 事所用的指针不是三个alloc 函数的返回值等，如若一个进程调用 malloc 函数，但却忘记调用 free 函数，那么该进程占用的存储器就会连续增加，这被称为泄露。

### 环境变量

ISO C 定义了一个函数 getenv ，可以用其环境变量值，但是该标准又称为环境的内容是由实现定义的

```
	#include <stdlib.h>

	char *getenv(const char *name);

	// 返回值：指向与 name 关联的value的指针，若未找到则返回 NULL
```

注意，此函数返回一个指针，它指向 name = value 字符串中的value，使用 getenv 从环境变量中取一个指定环境变量的值，而不是直接访问 environ.

设置环境变量:

```
	#include <stdlib>

	int putenv(char *str);

	int setenv(const *name, const char *value, int rewrite);

	int unsetenv(const char *name);

	// 三个函数返回值：若成功则返回 0， 若出错则返回非 0 值
```

设置环境变量的区别：

- putenv 取形式为 name = value 的字符串，将其放到环境表中，如果name已存在，则先删除其原来的定义。
- setenv 将name 设置为value, 如果在环境中name已经存在，那么若 rewrite 非 0，则首先删除其现有的定义，若 rewrite 为0，则不删除其现有的定义
- unsetenv 删除name的定义。

注意：putenv 和setenv 之间的区别，setenv 必须分配存储区，以便依据其创建参数 name=value 的字符串，同时，putenv 则无需将传送给它的参数字符串直接放到环境中。

### setjmp 和 longjmp 函数

在C中，goto语句是不能跨越函数的，而执行这类跳转功能的是函数 setjmp 和longjmp，这两个函数对于处理发生在深层嵌套函数调用中的出错情况是非常有用的。

```
	#include <setjmp.h>

	int setjmp(jmp_buf env);

	// 返回值：若直接调用则返回 0， 若从longjmp 调用返回则返回非 0 值

	void longjmp(jmp_buf env, int val);
```

setjmp 参数 env 的类型是一个特殊类型jmp_buf,这一类型是某种形式的数组，其中存放在调用 longjmp 时能用来恢复栈状态的所有信息，因为需在另一个函数中引用 env 变量，所以规范的处理方式是将 env 变量定义为全局变量。

### getrlimit 和 setrlimit 函数

每个进程都有一组资源限制，其中一些可以用 getrlimit 和 setrlimit 函数查询和更改。

```
	#include <sys/resource.h>
	int getrlimit(int resource, struct rlimit *rlptr);

	int setrlimit(int resource, const struct rlimit *rlptr);

	// 两个函数返回值：若成功则返回0，若出错则返回非0值
```

两个函数的每一次调用都会指定一个资源以及一个指向下列结构指针.

```
	struct rlimit {
		rlimit rlim_cur; // 当前限制值
		rlimit rlim_max; // 最大限制值
	}
```

在更改资源限制时，须遵循下列原则：

- 任何一个进程都可将一个软限制值更改为小于或等于其应限制值。
- 任何一个进程都可降低其应限制值，但它必须大于或等于其软限制值，这种降低对普通用户是不可逆的。
- 只有超级用户进程可以提高应限制值。

常量 RLIM_INFINITY 指定了一个无限量的限制。

- RLIMIT_AS: 进程可用存储区的最大总长度。
- RLIMIT_CORE: core 文件的最大字节数，若其值为0则阻止创建 core 文件
- RLIMIT_CPU: CPU 时间的最大量值（秒），当超过此软限制时，向该进程发送 SIGXCPU 信号。
- RLIMIT_DATA: 数据段的最大字节长度，非初始化以及堆的总和。
- RLIMIT_FSIZE: 可以创建的文件的最大字节长度，当超过此软限制时，则向该进程发送 SIGXFSZ 信号。
- RLIMIT_LOCKS: 一个进程可持有的文件锁的最大数
- RLIMIT_MEMLOCK: 一个进程使用能够锁定在存储器中的最大字节长度
- RLIMIT_NOFILE: 每个进程能打开的最大文件数
- RLIMIT_NPROC: 每个实际用户 ID 可拥有的最大子进程数
- RLIMIT_RSS: 最大驻内存集的字节长度
- RLIMIT_SBSIZE: 用户任意给定时刻可以占用的套接字缓存区的最大长度
- RLIMIT_STACK: 栈的最大字节长度
- RLIMITA\_VMEM: RLIMIT\_AS 的同义词

打印当前资源限制：
```
	#include "../apue.h"
	
	#if defined(BSD) || defined(MACOS)
	#include <sys/time.h>
	#define FMT "%101ld "
	#else
	#define FMT "%10ld "
	#endif
	        
	#include <sys/resource.h>
	        
	#define doit(name) pr_limits(#name, name)
	
	static void pr_limits(char *, int);
	
	int main(void)
	{       
	    #ifdef RLIMIT_AS
	        doit(RLIMIT_AS);
	    #endif
	        doit(RLIMIT_CORE); 
	        doit(RLIMIT_CPU);
	        doit(RLIMIT_DATA);
	        doit(RLIMIT_FSIZE);
	    #ifdef RLIMIT_LOCKS
	        doit(RLIMIT_LOCKS);
	    #endif
	    #ifdef RLIMIT_MEMLOCK
	        doit(RLIMIT_MEMLOCK);
	    #endif
	        doit(RLIMIT_NOFILE);
	    #ifdef RLIMIT_NPROC
	        doit(RLIMIT_NPROC);
	    #endif
	    #ifdef RLIMIT_RSS
	        doit(RLIMIT_RSS);
	    #endif
	    #ifdef RLIMIT_SBSIZE
	        doit(RLIMIT_SBSIZE);
	    #endif
	        doit(RLIMIT_STACK);
	    #ifdef RLIMIT_VMEM
	        doit(RLIMIT_VMEM);
	    #endif
	
	    exit(0);
	}
	
	static void pr_limits(char *name, int resource)
	{
	    struct rlimit limit;
	
	    if (getrlimit(resource, &limit) < 0) {
	        err_sys("getrlimit error for %s", name);
	    }
	    printf("%-14s  ", name);
	    if (limit.rlim_cur == RLIM_INFINITY) {
	        printf("(infinite)  ");
	    } else {
	        printf(FMT, limit.rlim_cur);
	    }
	    if (limit.rlim_max == RLIM_INFINITY) {
	        printf("(infinite)  ");
	    } else {
	        printf(FMT, limit.rlim_max);
	    }
	
	    putchar((int)'\n');
	}
```

执行结果：

``` bash
	RLIMIT_AS       (infinite)  (infinite)  
	RLIMIT_CORE              0 (infinite)  
	RLIMIT_CPU      (infinite)  (infinite)  
	RLIMIT_DATA     (infinite)  (infinite)  
	RLIMIT_FSIZE    (infinite)  (infinite)  
	RLIMIT_LOCKS    (infinite)  (infinite)  
	RLIMIT_MEMLOCK       32768      32768 
	RLIMIT_NOFILE         1024       1024 
	RLIMIT_NPROC         81920      81920 
	RLIMIT_RSS      (infinite)  (infinite)  
	RLIMIT_STACK      10485760 (infinite)
```
[unix_note_002_001]: /image/unix_note/unix_note_002_001.png
