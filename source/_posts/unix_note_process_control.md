title: 进程控制 
date: 2014-02-17 22:02:16
tags: process 
categories: 《unix 高级编程》-Note
---

### 进程标识符

ID 为 0 的进程通常是调度进程，常常被称为交换进程。该进程是内核的一部分，它并不执行任何磁盘上的程序，因此也被称为系统进程。进程ID 1通常是 init 进程，在自举过程结束时由内核调用。该进程的程序文件在UNIX的早期版本中是/etc/init, 在较新的版本中是 /sbin/init. 此进程负责在自举内核后启动一个 UNIX 系统。

init 进程决不会终止。它是一个普通的用户进程，但是它以超级用户特权运行，init是回收所有孤儿进程的父进程。

```
	#include <unistd.h>
	pid_t getpid(void);

	// 返回值：调用进程的进程 ID

	pid_t getppid(void);

	// 返回值：调用进程的父进程 ID

	uid_t getuid(void);

	// 返回值：调用进程的实际用户 ID

	uid_t geteuid(void);

	// 返回值：调用进程的有效用户 ID

	gid_t getgid(void);

	// 返回值：调用进程的实际组 ID

	gid_t getegid(void);

	// 返回值：调用进程的有效组 ID
```

### fork 函数

```
	#include <unistd.h>

	pid_t fork(void);

	// 返回值：子进程中返回 0，父进程中返回子进程 ID，出错返回 -1
```

由 fork 创建的新进程被称为子进程。fork函数被调用一次，但返回两次。两次返回的唯一区别是子进程的返回值是0,而父进程的返回值则是新子进程的进程 ID。将子进程 ID返回给父进程的理由是：因为一个进程的子进程可以有多个，并且没有一个函数使一个进程可以获得其所有子进程的进程ID。fork使子进程得到返回值 0的理由是：一个进程只会有一个父进程，所以子进程总是可以调用 getppid 以获得其父进程的进程 ID。

```
	#include "../apue.h"
	
	int glob = 6;
	char buf[] = "a write to stdout\n";
	
	int main(void)
	{
	    int var;
	    pid_t pid;
	
	    var = 88;
	    if (write(STDOUT_FILENO, buf, sizeof(buf) - 1) != sizeof(buf) - 1) {
	        err_sys("write error");
	    }
	
	    printf("before fork\n");
	    if ((pid = fork()) < 0) {
	        err_sys("fork error");
	    } else if (pid == 0) {
	        glob++;
	        var++;
	    } else {
	        sleep(2);
	    }
	
	    printf("pid = %d, glob= %d, var = %d \n", getpid(), glob,   var);
	    exit(0);
	}
```

运行结果

``` bash
	a write to stdout
	before fork
	pid = 5926, glob= 7, var = 89 

	pid = 5925, glob= 6, var = 88 
```

在 fork 之后处理文件描述符有两种情况：

- 父进程等待子进程完成，在这种情况下，父进程无需对其描述符做任何处理。当子进程终止后，它曾进行过读、写操作的任意共享描述符的文件偏移量已执行了相应更新。
- 父、子进程各自执行不同的程序段。在这种情况下，在fork之后，父、子进程各自关闭它们不需使用的文件描述符，这样就不会干扰对方使用的文件描述符。

父、子进程之间的区别：

- fork 的返回值
- 进程 ID 不同
- 两个进程具有不同的父进程 ID： 子进程的父进程ID 是创建它的进程的 ID，而父进程的父进程 ID 则不变
- 子进程的 tms\_utime、tms\_stime、tms\_cutime 已经 tms\_ustime 均被设置成 0.
- 父进程设置的文件锁不会被子进程继承
- 子进程的未处理的闹钟被清除
- 子进程的未处理信号集设置为空集

### vfork 函数

vfork 与 fork 一样都创建一个子进程，但是它并不是将父进程的地址空间完全复制到子进程中，因为子进程会立即调用 exec ，于是也就不会存访该地址空间。相反，在子进程调用 exec或exit之前，它在父进程的空间中运行。


vfork 和 fork 之间的另一个区别是：vfork 保证子进程先运行，在它调用 exec 或 exit 之后父进程才可能被调度运行。


```
	#include "../apue.h"
	
	int glob = 6;
	
	int main(void)
	{
	    int var;
	    pid_t  pid;
	
	    var = 88;
	    printf("before vfork\n");
	    if ((pid = fork()) < 0) {
	        err_sys("vfork error");
	    } else if (pid == 0) {
	        glob++;
	        var++;
	        _exit(0);
	    }
	
	    printf("pid = %d, glob = %d, var = %d\n", getpid(), glob,   var);
	    exit(0);
	}
```

运行结果：

```
	before vfork
	pid = 5985, glob = 6, var = 88
```

子进程对变量 glob 和 var 做增1操作，结果改变了父进程中的变量值，因为子进程在父进程的地址空间中运行。

