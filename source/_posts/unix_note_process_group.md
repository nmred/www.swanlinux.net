title: 进程关系 
date: 2014-03-04 22:02:16
tags: process
categories: 《unix 高级编程》-Note
---

### 进程组

进程组是一个或多个进程的集合，通常，它们与同一作业相关联，可以接收来自同一终端的各种信号，每个进程组有一个唯一的进程组ID，进程组ID类似于进程ID － 它是一个正整数，可以存放在 pid_t 数据类型中。

函数 getpgrp() 返回调用进程的进程组 ID；

```
	#include <unistd.h>
	pid_t getpgrp(void);

	// 返回值：调用进程的进程组 ID
```

getpgid 函数：

```
	#include <unistd.h>
	pid_t getpgid(pid_t pid);

	// 返回值：若成功则返回进程组 ID， 若出错则返回 -1
```

进程可以通过调用 setpgid 来加入一个现有的组或者创建一个新的进程组：

```
	#include <unistd.h>
	int setpgid(pid_t pid, pid_t pgid);

	// 返回值：若成功则返回 0， 若出错则返回 -1

```
