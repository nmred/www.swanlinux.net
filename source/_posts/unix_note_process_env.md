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

[unix_note_002_001]: /image/unix_note/unix_note_002_001.png
