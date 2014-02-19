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

### wait 和 waitpid 函数

当一个进程正常或异常终止时，内核就向其父进程发送 SIGCHLD 信号，因为子进程终止是个异步事件（这可以在父进程运行的任何时候）,所以这种信号也是内核向父进程发的异步通知。父进程可以选择忽略该信号，或者提供一个该信号发生时即被调用执行的函数（信号处理程序）。对于这种信号的系统默认动作时忽略它。

调用 wait 或 waitpid 会发生以下情况：

- 如果其所有子进程都在运行，则阻塞。
- 如果一个子进程已终止，正等待父进程获取其终止状态，则取得该子进程的终止状态立即返回。
- 如果它没有任何子进程，则立即出错返回。

如果进程由于接收到 SIGCHLD 信号而调用 wait, 则可期望 wait 会立即返回，但是如果在任意时刻调用 wait， 则进程可能会阻塞。

```
	#include <sys/wait.h>

	pid_t wait(int *statloc);

	pid_t waitpid(pid_t pid, int *statloc, int options);

	// 两个函数返回值：若成功则返回进程 ID，若出错返回 -1
```

这两个函数的区别如下：

- 在一个子进程终止前，wait使其调用则阻塞，而 waitpid 有一个选项，可使调用者不阻塞。
- waitpid 并不等待在其调用之后的第一个终止子进程，它有若干个选项，可以控制它所等待的进程。

这两个函数的参数 statloc 是一个整形指针，如果 statloc 不是一个空指针，则终止进程的终止状态就存放在它所指向的单元内，如果不关心终止状态，则可将该参数指定为空指针。

检查 wait 和 waitpid 所返回的终止状态的宏：

- WIFEXITED(status) ：若为正常终止子进程返回的状态，则为真，对于这种情况可执行 WEXITSTATUS(status)，取子进程传送给 exit, \_exit或 \_Exit参数的低8位
- WIFSIGNALED(status): 若为异常终止子进程返回的状态，则为真，对于这种情况，可执行 WTERMSIG(stauts) 取得子进程终止的信号编号，另外，有些实现定义宏 WCOREDUMP(status), 若产生终止进程的 core 文件，则它返回。
- WIFSTOPPED(status): 若当前暂停子进程返回的状态，则取真，对于这种情况，可指向 WSTOPSIG(status) ，取使进程暂停的信号编号
- WIFCONTINUED(status): 若在作业控制暂停后已经继续的子进程返回了状态，则为真。


演示不同的 exit:

```
#include "../apue.h"
#include <sys/wait.h>
    
void pr_exit(int status);

int main(void) 
{       
    pid_t pid;
    int status;
    
    if ((pid = fork()) < 0) {
        err_sys("fork error.");
    } else if (pid == 0) {
        exit(7);
    }

    if (wait(&status) != pid) {
        err_sys("wait error.");
    } 
    pr_exit(status);
    
    if ((pid = fork()) < 0) {
        err_sys("fork error.");
    } else if (pid == 0) {
        abort();
    }

    if (wait(&status) != pid) {
        err_sys("wait error.");
    } 
    pr_exit(status);

    if ((pid = fork()) < 0) {
        err_sys("fork error.");
    } else if (pid == 0) {
        status /= 0;
    }

    if (wait(&status) != pid) {
        err_sys("wait error.");
    }
    pr_exit(status);
}

void pr_exit(int status)
{
    if (WIFEXITED(status)) {
        printf("normal termination, exit status = %d\n", WEXIT  STATUS(status));
    } else if (WIFSIGNALED(status)) {
        printf("abnormal termination, signal number = %d%s\n",   WTERMSIG(status),
        #ifdef WCOREDUMP
            WCOREDUMP(status) ? "(core file generated)" : ""
        #else
            ""
        #endif
        );
    } else if (WIFSTOPPED(status)) {
        printf("child stopped, signal number = %d\n", WSTOPSIG  (status));
    }
}
```

运行结果：

``` bash
normal termination, exit status = 7
abnormal termination, signal number = 6
abnormal termination, signal number = 8
```

对于 waitpid 函数中 pid 参数的作用解释如下：

- pid == -1 等待任意个子进程，和 wait 函数等效
- pid > 0 等待其进程 ID 与 pid 相等的子进程
- pid == 0 等待其组 ID 等于调用进程组ID 的任一子进程
- pid < -1 等待其组ID 等于 pid 绝对值的任一子进程

waitpid 函数返回终止子进程的进程 ID, 并将该子进程的终止状态存放在由 statloc 指向的存储单元中，对于 wait， 其唯一的出错是调用进程没有子进程，但是对于 waitpid, 如果指定的进程或进程组不存在，或参数pid 指定的进程不是调用进程的子进程则都将出错。

waitpid 的 options 常量：

- WCONTINUED: 若实现支持作业控制，那么由 pid 指定的任一子进程在暂停后已经继续，但其状态尚未报告，则返回其状态。
- WNOHANG: 若由 pid 指定的子进程并不是立即可用的，则 waitpid 不阻塞，此时其返回值为0。
- WUNTRACED: 若某实现支持作业控制，而由 pid 指定的任一子进程以处于暂停状态，并且其状态自暂停以来还未报告过，则返回其状态。

waitpid 函数提供了 wait 函数没有提供的三个功能：

- waitpid 可等待一个特定的进程，而wait则返回任意终止子进程的状态。
- waitpid 提供了一个 wait 的非阻塞版本，有时用户希望取得一个子进程的状态，但不想阻塞。
- waitpid 支持作业控制。



