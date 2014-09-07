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

### kill 和 raise 函数

kill 函数将信号发送给进程或进程组，raise 函数则允许进程向自身发送信号。

```
	#include <signal.h>
	int kill(pid_t pid, int signo);
	int raise(int signo);

	// 两个函数返回值：若成功则返回0， 若出错则返回 -1

```

kill 的 pid 参数有 4 种不同的情况：

- pid > 0  将该信号发送给进程 ID 为pid 的进程
- pid == 0 将该信号发送给与发送进程属于同一进程组的所有进程，而且发送进程具有向这些进程发送信号的权限。
- pid < 0  将该信号发送给其进程组 ID 等于 pid 的绝对值，而且发送进程具有向其发送信号的权限。
- pid == -1 将该信号发送给发送进程有权限向它们发送信号的系统上的所有进程。

进程将信号发送给其他进程需要权限，超级用户可将信号发送给任一进程。对于非超级用户，其基本规则是发送者的实际或有效用户 ID 必须等于接受者的实际或有效用户 ID 。在对权限进行测试时也有一个特例，如果被发送的信号时 SIGCONT, 则进程可将它发送给属于同一会话的任何其他进程。

信号编号为0的信号定义为空信号，如果signo参数是0，则kill仍执行正常的错误检查，但不发送信号。这常被用来确定一个特定进程是否仍旧存在。如果向一个并不存在的进程发送空信号，则kill返回-1将errno设置为ESRCH.

### alarm 和 pause 函数

使用 alarm 函数可以设置一个计时器，产生 SIGALRM 信号，如果不忽略或不捕捉次信号，则其默认动作时终止调用该 alarm 函数的进程。

```
	#include <unistd.h>
	unsigned int alarm(unsigned int seconds);

	// 返回值： 0或以前设置的闹钟时间的余留时间
```

每个进程只能有一个闹钟，如果在调用 alarm时，以前以为该进程设置过的闹钟时钟，而且它还没有超时，则将该闹钟的余留值作为本次alarm函数调用的值返回，以前登记的闹钟时钟则被新值代替。

如果有以前进程登记的尚未超过的闹钟时钟，而且本次调用的 seconds值是 0， 则取消以前的闹钟时钟，其余留值仍作为alarm函数的返回值。

pause函数使调用进程挂起直至捕捉到一个信号。

```
	#include <unistd.h>
	int pause(void);

	// 返回值： -1， 并将errno设置为 EINTR
```

sleep 的简单而不完整的实现

```
	#include <signal.h>
	#include <unistd.h>
	
	static void sig_alrm(int signo)
	{
	    // nothing to do    
	}
	
	unsigned int sleep1(unsigned int nsec)
	{
	    if (signal(SIGALRM, sig_alrm) == SIG_ERR) {
	        return (nsec);
	    }
	
	    alarm(nsec);
	    pause();
	    return (alarm(0));
	}
	
	int main(void)
	{
	    printf("start.....");
	    sleep1(2);
	    printf("end.....");
	    return 0;
	}
```

这种简单实现有下列三个问题：

- 如果在调用sleep之前，调用者已设置了闹钟，则它会被sleep1函数中的第一次alarm调用擦除，可用下列方法更正这一点：检查第一次调用alarm的返回值，如其小于本次调用alarm的参数值，则只应等到上次设置的闹钟超时，如果上次设置闹钟的超时时间晚于本次设置值，则在 sleep1 函数返回之前，复位此闹钟，使其在上次闹钟的设定时间再次发生超时。

- 该程序中修改了对 SIGALRM 的配置，如果编写了一个函数供其他函数调用，则在该函数被调用时先要保存原配置，在该函数返回前再恢复原配置，更正这一点的方法是：保存signal函数的返回值，在返回前复位原配置。

- 在第一次调用alarm和调用 pause 之间有一个竞争条件，在一个繁忙的系统中，可能alarm 在调用 pause 之前超时，并调用了信号处理程序，如果发生这种情况，则在调用 pause后如果没有捕捉到其他信号，则调用者将永远挂起，更正这一问题：第一种方法用setjmp,另一种用sigprocmask和sigsuspend

sleep的另一个（不完整）实现：

```
	#include "apue.h"
	#include <setjmp.h>
	#include <signal.h>
	#include <unistd.h>
	
	static jmp_buf env_alrm;
	static void sig_alrm(int signo)
	{
	    longjmp(env_alrm, 1);
	}
	
	unsigned int sleep2(unsigned int nsecs)
	{
	    if (signal(SIGALRM, sig_alrm) == SIG_ERR) {
	        return (nsecs);
	    }
	    if (setjmp(env_alrm) == 0) {
	        alarm(nsecs);
	        pause();
	    }
	    return alarm(0);
	}
	
	int main(void)
	{
	    sleep2(1);
	}
```

### 信号集



[unix_note_003_001]:  /image/unix_note/unix_note_003_001.png
