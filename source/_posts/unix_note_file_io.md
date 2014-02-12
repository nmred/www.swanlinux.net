title: 文件IO
date: 2013-05-14 18:13:16
tags: file io 
categories: 《unix 高级编程》-Note
---

###文件描述符

对于内核而言，所有打开的文件都通过文件描述符引用。文件描述符是一个非负整数。当打开一个现有文件或创建一个新文件时，内核向进程返回一个文件描述符。当读写一个文件时，使用 open 或 creat 返回的文件描述符表示该文件。将其作为参数传给 read 或 write.

按照惯例，UNIX 系统 shell使用文件描述符 0 与进程的标准输入相关联，文件描述符1与标准输出相关联，文件描述符2与标准出错输出相关联。

在依从POSIX的应用程序中，幻数 0，1，2应当替换成符号常量 STDIN_FILENO、STDOUT_FILENO、STDERR_FILENO,这些常量都定义在头文件<unistd.h>中。

###open 函数

调用open 函数可以打开或创建一个文件.

```
	#include <fcntl.h>
	int open(const char *pathname, int oflag, .../* mode_t mode*/);
	// 返回值：如果成功返回文件描述符，如果出错则返回 -1
```

pathname 是要打开或创建文件的名字。oflag 参数可用来说明函数的多个选项。用下列一个或多个常量进行 "或" 运算成 oflag 参数：

* O_RDONLY  只读打开
* O_WRONLY  只写打开
* O_RDWR    读、写打开


在这三个常量中必须指定一个且只能指定一个。下列常量则是可选择的：

* O_APPEND  每次写时都追加到文件的尾端。
* O_CREAT   若此文件不存在，则创建它。使用此选项时，需要第三个参数 mode. 用来其指定该新文件的访问权限位.
* O\_EXCL    如果同时指定了 O_CREAT , 而文件已经存在，则会出错。用此可以测试一个文件是否存在，如果不存在，则创建此文件，这使测试和创建两者成为一个原子操作。
* O_TRUNC   如果此文件存在，而且为只写或读写成功打开，则将其长度截短为 0.
* O_NOCTTY  如果 pathname 指的是终端设备，则不将该设备分配作为此进程的控制终端。
* O_NONBLOCK 如果 pathname 指的是一个FIFO、一个块特殊文件或一个字符特殊文件，则此选项为文件的本次打开操作和后续的I/O操作设置非阻塞模式。


下面三个标志也是可选的。它们是 Single Unix Specification 中同步输入和输出选项的一部分： \\ 

* O_DSYNC 使每次 write 等待物理I/O操作完成，但是写操作并不影响读取刚写入的数据，则不等待文件属性被更新. 
* O_RSYNC 使每一个以文件描述符作为参数的read操作等待，直至任何对文件同一部分进行的未决写操作都完成.
* O_SYNC  使每次write都等到物理I/O操作完成，包括由write操作引起的文件属性更新所需的I/O. 


**O\_DSYNC 和 O\_SYNC 标志的区别：仅当文件属性需要更新以反映文件数据变化时，O\_DSYNC标志仅影响文件属性，而设置 O\_SYNC 标志后，数据和属性总是同步更新。** 

###creat 函数

也可以调用creat 函数创建一个新文件.

```
	#include <fcntl.h>
	int creat(const char *pathname, mode_t mode);
	//返回值：若成功则返回为只写打开的文件描述符，如果出错则返回 -1.
	注意，此函数等效于：
	
	open(pathname, O_WRONLY | O_CREAT | O_TRUNC, mode);
```


###close 函数

可以调用close 函数关闭一个打开的文件：

```
	#include <unistd.h>
	int close(int filedes);
	// 返回值：若成功则返回0，若出错则返回 -1
```


关闭一个文件时还会释放加在该文件上的所有记录锁，当一个进程终止时，内核自动关闭它所有打开的文件。

###lseek 函数

可以调用 lseek 显式地为一个打开的文件设置其偏移量。 

```
	#include <unistd.h>
	off_t lseek(int filedes, off_t offset, int whence);
	// 返回值：如果成功返回新的文件偏移量，如果出错返回 -1
```

对参数offset的解释与参数whence有关

* 如果whence 是SEEK_SET,则将该文件的偏移量设置为距文件开始处offset个字节.
* 如果whence 是SEEK_CUR,则将该文件的偏移量为文件长度加offset，offset可为正或负.
* 如果whence 是SEEK_END,则将该文件的偏移量设置为文件长度加offset，offset可为正或负.


这种方法也可用来确定所涉及的文件是否可以设置偏移量。如果文件描述符引用的是一个管道、FIFO或网络套接字，则lseek返回-1，并将errno设置为ESPIPE.

```
	#include "../apue.h"
	  
	int main(void)
	{
		if (lseek(STDIN_FILENO, 0, SEEK_CUR) == -1) {
			printf("cantnot seek\n");
		} else {
			printf("seek OK \n");
		}
	
		exit(0);
	}
```

通常，文件的当前偏移量应当是一个非负整数，但是，某些设备也可能允许负的偏移量。但对于普通文件，则其偏移量必须是非负值。因为偏移量可能是负值，所以在比较lseek的返回值时应当谨慎，不要测试它是否小于0，而要测试它是否等于 -1.

```
	#include "../apue.h"
	#include <fcntl.h>
	
	char buf1[] = "abcdefghij";
	char buf2[] = "ABCDEFGHIJ";
	
	int main(void)
	{
		int fd;
		if ((fd = creat("file.hole", FILE_MODE)) < 0) {
			err_sys("creat error");
		}
	
		if (write(fd, buf1, 10) != 10) {
			err_sys("buf1 write error");
		}
	
		if (lseek(fd, 16384, SEEK_SET) == -1) {
			err_sys("lseek error");
		}
	
		if (write(fd, buf2, 10) != 10) {
			err_sys("buf2 write error");
		}
	
		exit(0);
	}
```

###read 函数

调用read 函数从打开文件中读数据.

```
	#include <unistd.h>
	ssize_t read(int filedes, void *buf, size_t nbytes);
	// 返回值：如果成功则返回读到的字节数，如果已到文件结尾则返回0，如果出错则返回 -1
```

有多种情况可使实际读到的字节数小于要求读的字节数:
 
* 读普通文件时，在读到要求字节数之前已到了文件尾端。
* 当从终端设备读时，通常一次最多读一行。
* 当网络读时，网络中的缓存机构可能造成返回值小于所要求读的字节数.
* 当从管道或FIFO读时，如果管道包含的字节少于所需的数量，那么read将只返回实际可用的字节数。
* 当从某些面向记录的设备读时，一次最多返回一个记录。
* 当某个信号造成中断，而已经读了部分数据量时。


###write 函数

调用write函数向打开的文件写数据

```
	#include <unistd.h>
	ssize_t write(int filedes, const void *buf, size_t nbytes);
	// 返回值：如果成功则返回已写的字节数,如果出错则返回 -1
```

####dup和dup2函数

下面两个函数都可用复制一个现存的文件描述符:
 
```
	#include <unistd.h>
	int dup(int filedes);
	int dup2(int filedes, int filedes2);
	// 两个函数的返回值：如果成功则返回新的文件描述符，若出错则返回 -1
```

由dup返回的新文件描述符一定是当前可用文件描述符中的最小数值。用dup2则可以用filedes2 参数指定新描述符的数值。如果filedes2已经打开，则先将其关闭。如果filedes等于filedes2，则dup2返回filedes2，而不关闭它。

这些函数返回的新文件描述符与参数filedes共享一个文件表项。

复制一个描述符的另一种方法是使用fcntl函数，实际上调用： 

```
		dup(filedes); 
	等效于 
		fcntl(filedes, F_DUPFD, 0);
	而调用 
		dup2(filedes, filedes2);
	等效于 
		close(filedes2);  
		fcntl(filedes, F_DUPFD, filedes2);
```
	
在后一种情况下，dup2并不完全等同于close加上fcntl.它们之间的区别是：

- dup2 是一个原子操作，而close及fcntl则包括两个函数调用。有可能在close 和 fcntl 之间插入执行信号捕获函数，它可能修改文件描述符。
- dup2 和fcntl有某些不同的errno.


###原子操作： pread 和 pwrite 函数

Single UNIX Specification 包括了XSI扩展，该扩展允许原子性地定位搜索(seek)和执行 I/O. pread 和 pwrite 就是这种扩展.

```
	#include <unistd.h>
	ssize_t pread(int filedes, void *buf, size_t nbytes, off_t offset);
	// 返回值: 读到的字节数，如果已到文件结尾则返回0，如果出错则返回 -1
	ssize_t pwrite(int filedes, const void *buf, size_t nbytes, off_t offset);
	// 返回值：如果成功则返回已写的字节数，如果出错则返回 -1
```

调用pread相当于顺序调用lseek和read,但是pread又与这种顺序调用有下列重要区别：  

* 调用 pread时，无法中断其定位和读操作。
* 不更新文件指针


调用 pwrite 相当于顺序调用 lseek 和write ,但也与它们有类似的差别.

###sync、fsync、fdatasync 函数

传统的UNIX实现在内核中设有缓存区高速缓存和页面高速缓存，大多数的磁盘I/O都通过缓存进行，这种方式减少了磁盘的读写次数，但是降低了文件内容的更新速度，使得欲写到文件中的数据在一段时间内并没有写到磁盘上，当系统发生故障时，这种延时可能造成文件更新内容的丢失。为了保证磁盘上实际文件系统和缓存区高速缓存中内容的一致性，Unix系统提供了sync、fsync、fdatasync三个函数.

```
	#include <unistd.h>
	
	int sync(int filedes);
	
	int fdatasync(int filedes);
	
	// 返回值：如果成功则返回0，如果出错则返回 -1
	
	void sync(void);
```

sync 函数只是将所有修改过的块缓存区排入写队列，然后就返回，它并不等待实际写磁盘操作结束. 

通常称为 update 的系统守护进程会周期性地(一般每隔30秒)调用sync函数，这就保证了定期冲洗内核的块缓存区。

fsync 函数只对由文件描述符filedes 指定的单一文件起作用，并且等待写磁盘操作结束，然后返回。fsync可用与数据库这样的应用程序，这种程序需要确保将修改过的块立即写到磁盘上。

fdatasync 函数类似与fsync,但它只影响文件的数据部分。而除数据外，fsync还会同步更新文件的属性.

###fcntl 函数

fcntl函数可以改变已打开的文件的性质：

```
	#include <fcntl.h>
	int fcntl(int filedes, int cmd, .../* int arg*/);
	// 返回值：如果成功则依赖cmd,如果出错则返回 -1
```

本函数的第三个参数总是一个整数，与上面所示函数原型中的注释部分相对应，但是在说明记录锁时，第三个参数则是指向一个结构的指针。

fcntl 函数的5中的功能：

* 复制一个现有的描述符 (cmd = F\_DUPFD);
* 获得/设置文件描述符标记(cmd = F\_GETFD 或 F_SETFD);
* 获得/设置文件状态(cmd = F\_GETFL或 F_SETFL);
* 获得/设置异步I/O所有权(cmd = F\_GETOWN 或 F_SETOWN);
* 获得/设置记录锁(cmd = F\_GETLK 、F\_SETLK 或 F_SETLKW);


各个状态值详解:

  * F\_DUPFD 复制文件描述符filedes. 新文件描述符作为函数值返回。它是尚未打开的各描述符中大于或等于第三个参数值中各值的最小值。新描述符与filedes共享同一文件表项。但是，新描述符有自己的一套的文件描述符标记，其FD_CLOEXEC文件描述符被清除.
  * F\_GETFD 对应于filedes的文件描述符标志作为函数值返回。当前只定义了一个文件描述符标志FD_CLOEXEC.
  * F_SETFD 对于filedes设置文件描述符标志。新标志按第三个参数设置.
  * F\_GETFL 对应于filedes 的文件状态标志作为函数值返回。在说明open函数时，已说明了文件状态标志。不幸的是 ** 三个访问标志(O_RDONLY、O_WRONLY以及O_RDWR)并不是各占一位，因此首先必须用屏蔽字O_ACCMODE取得访问模式位，然后将结果与这三种值中的任一种做比较** . 
  * F\_SETFL  将文件状态标志设置为第三个参数的值。可以更改的几个标记是：O\_APPEND、O_NONBLOCK、O_SYNC、O_DSYNC、O_RSYNC、O_FSYNC和O_ASYNC.
  * F_GETOWN 取当前接收SIGIO和SIGURG信号的进程ID或进程组ID
  * F_SETOWN 设置接收SIGIO和SIGURG信号的进程ID或进程组ID


```
	#include "../apue.h"
	#include <fcntl.h>
	
	int main(int argc, char *argv[])
	{
		int val;
	
		if (argc != 2) {
			err_quit("usage: a.out <descriptor#>");
		}
	
		if ((val = fcntl(atoi(argv[1]), F_GETFL, 0)) < 0) {
			err_sys("fcntl error for fd %d", atoi(argv[1]));
		}
	
		switch (val & O_ACCMODE) {
			case O_RDONLY:
				printf("read only");
				break;
			case O_WRONLY:
				printf("write only");
				break;
			case O_RDWR:
				printf("read write");
				break;
			default:
				err_dump("unknown access mode");
		}
	
		if (val & O_APPEND) {
			printf(", append");
		}
	
		if (val & O_NONBLOCK) {
			printf(", nonblocking");
		}
	
	#if defined(O_SYNC)
		if (val & O_SYNC) {
			printf(", synchronous writes");
		}
	#endif
	#if !defined(_POSIX_C_SOURCE) && defined(O_FSYNC)
		if (val & O_FSYNC) {
			printf(", synchronous writes");
		}
	#endif
		putchar('\n');
		exit(0);
	}
```

在修改文件描述符标志或文件状态时必须谨慎，先要取得现有的标志值，然后根据需要修改它，最后设置新标志值，不能只是执行F_SETFD或F_SETFL命令，这样会关闭以前设置的标志位.

```
	#include "../apue.h"
	#include <fcntl.h>
	
	void get_fl(char *filename[]);
	void add_fl(char *filename[], int flags);
	void del_fl(char *filename[], int flags);
	
	int main(int argc, char *argv[])
	{   
		if (argc != 2) {
			err_quit("usage: a.out <descriptor#>");
		}   
	
		get_fl(&argv[1]);
		add_fl(&argv[1], O_APPEND);
		get_fl(&argv[1]);
		del_fl(&argv[1], O_APPEND);
		get_fl(&argv[1]);
		exit(0);
	}
	
	void add_fl(char *filename[], int flags) 
	{   
		int val;
		if ((val = fcntl(atoi(*filename), F_GETFL, 0)) < 0) {
			err_sys("fcntl error for fd %d", atoi(*filename));
		}
	
		val |= flags;
	
		if (fcntl(atoi(*filename), F_SETFL, val)) {
			err_sys("fcntl error for fd %d", atoi(*filename));
		}
	}
	
	void del_fl(char *filename[], int flags)
	{
		int val;
		if ((val = fcntl(atoi(*filename), F_GETFL, 0)) < 0) {
			err_sys("fcntl error for fd %d", atoi(*filename));
		}
	
		val &= ~flags;
	
		if (fcntl(atoi(*filename), F_SETFL, val)) {
			err_sys("fcntl error for fd %d", atoi(*filename));
		}
	}
	
	void get_fl(char *filename[])
	{
		int val;
		if ((val = fcntl(atoi(*filename), F_GETFL, 0)) < 0) {
			err_sys("fcntl error for fd %d", atoi(*filename));
		}
	
		switch (val & O_ACCMODE) {
			case O_RDONLY:
				printf("read only");
				break;
			case O_WRONLY:
				printf("write only");
				break;
			case O_RDWR:
				printf("read write");
				break;
			default:
				err_dump("unknown access mode");
		}
	
		if (val & O_APPEND) {
			printf(", append");
		}
	
		if (val & O_NONBLOCK) {
			printf(", nonblocking");
		}
	
	#if defined(O_SYNC)
	if (val & O_SYNC) {
		printf(", synchronous writes");
	}
	#endif
	#if !defined(_POSIX_C_SOURCE) && defined(O_FSYNC)
		if (val & O_FSYNC) {
			printf(", synchronous writes");
		}
	#endif
		putchar('\n');
	}
```
