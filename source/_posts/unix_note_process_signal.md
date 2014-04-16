title: 信号 
date: 2014-03-04 22:02:16
tags: process
categories: 《unix 高级编程》-Note
---

### 信号

信号处理的方式：

- 忽略信号：大多数信号都可以使用这种方式进行处理，但有两种信号却不能被忽略，它们是 SIGKILL 和 SIGSTOP
- 捕捉信号：要通知内核在某种信号发生时调用一个用户的函数。
- 执行系统默认的动作：大多数信号的默认动作是终止进程

### signal 函数

```
	#include <signal.h>

	void (*signal(int signo, void (*func)(int)))(int);

	// 返回值：若成功则返回信号以前的处理配置，若出错则返回 SIG_ERR
```

func 的值是常量 SIG\_IGN, 常量 SIG\_DFL 或当接到此信号后调用的函数的地址。如果指定 SIG\_IGN, 则向内核表示忽略此信号，其中 SIGKILL 和 SIGSTOP 不能忽略，如果指定 SIG\_DFL, 则表示接到信号后的动作是系统默认动作。

一下是一个简单的信号处理程序：

```
	#include "apue.h"

	static void sig_usr(int);

	int main(void)
	{
		if (signal(SIGUSR1, sig_usr) == SIG_ERR) {
			err_sys("can't catch SIGUSR1");
		}
		if (signal(SIGUSR2, sig_usr) == SIG_ERR) {
			err_sys("can't catch SIGUSR2");
		}
		for(;;) {
			pause();
		}
	}

	static void sig_usr(int signo) 
	{
		if (signo == SIGUSR1) {
			printf("received SIGUSR1\n");
		} else if (signo == SIGUSR2) {
			printf("received SIGUSR2\n");
		} else {
			err_dump("received signal %d\n", signo);
		}
	}

```

需要注意的是，当一个进程调用fork时，其子进程继承父进程的信号处理方式。因为子进程在开始时复制了父进程的存储映像，所以信号捕捉函数的地址在子进程中是有意义的。

### 可重入函数

进程捕捉到信号并对其进行处理时，进程正在执行的指令序列就被信号处理程序临时中断，它首先执行该信号处理程序中的指令。 如果从信号处理程序返回，则继续执行在捕捉到信号时进程正在执行的正常指令序列，但是在信号处理程序中，不能判断捕捉到信号时进程在何处执行，如果进程正在执行malloc，在其堆中分配另外的存储空间，而此时由于捕捉到信号而插入执行该信号处理程序，其中又调用malloc，例如执行 getpwnam 这种将其结果存放在静态存储单元中的函数，期间插入执行信号处理程序，它又调用这样的函数，返回给正常掉用者可能被信号处理程序的信心覆盖。下表是信号处理程序可以调用的可重入函数：

![信号处理程序可以调用的可重入函数][unix_note_003_001]

除表外大多数函数是不可重入的函数，其原因为:

- 已知它们使用静态数据结构
- 它们调用 malloc 和 free
- 它们是标准 I/O 函数

下面案例是信号处理程序 my\_alarm 调用不可重入函数 getpwnam, 而 my\_alarm 每秒钟被调用一次。

```
	#include "apue.h"
	#include <pwd.h>

	static void my_alarm(int signo)
	{
		struct passwd *rootptr;

		printf("in signal handler\n");
		if ((rootptr = getpwnam("root")) == NULL) {
			err_sys("getpwnam(root) error");
		}
		alarm(1);
	}

	int main(void)
	{
		struct passwd *ptr;
		signal(SIGALRM, my_alarm);
		alarm(1);
		for (;;) {
			if ((ptr = getpwnam("swan")) == NULL) {
				err_sys("getpwnam error");
			}
			if (strcmp(ptr->pw_name, "swan") != 0) {
				printf("return value corrupted!, pw_name = %s\n", ptr->pw_name);
			}
		}
	}
```


从此实例中可以看出，若在信号处理程序中调用一个不可重入函数，则其结果是不可预见的。

[unix_note_003_001]:  /image/unix_note/unix_note_003_001.png
