title: 文件和目录
date: 2013-05-14 18:13:16
tags: directory  
categories: 《unix 高级编程》-Note
---

###stat、fstat 和 lstat 函数

```
	#include <sys/stat.h>
	int stat(const char *restrict pathname, struct stat *restrict buf);
	int fstat(int filedes, struct stat *buf);
	int lstat(const char *restrict pathname, struct stat *restrict buf);
	// 三个函数的返回值：若成功返回0，若出错返回 -1
```

一旦给出了pathname，stat函数就返回与此命令文件有关的信息结构。fstat函数获取已在描述符fieldes上打开文件的有关信息。lstat函数类似于stat,但是当命名的文件是一个符号链接时，lstat返回该符号链接的有关信息,而不是由该符号链接引用文件的信息。

第二个参数buf是指针，指向一个stat 的结构体：

```
	struct stat {
		mode_t    st_mode;
		ino_t     st_ino;
		dev_t     st_dev;
		dev_t     st_rdev;
		nlink_t   st_nlink;
		uid_t     st_uid;
		gid_t     st_gid;
		off_t     st_size;
		time_t    st_atime;
		time_t    st_mtime;
		time_t    st_ctime;	
		blksize_t st_blksize;
		blkcnt_t  st_blksize
	}
```

###文件类型

* 普通文件：是最常用的文件类型，这种文件包含了某种形式的数据.
* 目录文件：这种文件包含了其他文件的名字以及指向与这些文件有关信息的指针。对一个目录文件具有读权限的任意进程可以读该目录的内容，但是只有内核可以直接写目录文件。
* 块特殊文件：这种文件类型提供对设备（例如磁盘）带缓存的访问，每次访问以固定长度为单位进行。
* 字符特殊文件：这种文件类型提供了对设备不带缓存的访问，每次访问的长度可变。
* FIFO: 这种类型文件用于进程间通信，有时也称命名管道.
* 套接字：这种文件类型用于进程间的网络通信，套接字也可用于在一台宿主机上进程间的非网络通信.
* 符号链接：这种文件类型指向了另一个文件。


文件类型可以有以下宏来确定：

* S_ISREG()  普通文件
* S_ISDIR()  目录文件
* S_ISCHR()  字符特殊文件
* S_ISBLK()  块特殊文件
* S_ISFIFO() 管道或FIFO
* S_ISLNK()  符号链接
* S_ISSOCK() 套接字


POSIX.1允许实现将进程间通信（IPC）对象表示为文件，以下宏可以确定类型，它们的参数并非st_mode,而是指向stat结构的指针:

* S_TYPEISMQ()   消息队列
* S_TYPEISSEM()  信号量
* S_TYPEISSHM()  共享存储对象

```
	#include "../apue.h"
	
	int main(int argc, char *argv[])
	{
		int i;
		struct stat buf;
		char *ptr;
	
		for(i = 1; i < argc; i++)
		{
			printf("%s: ", argv[i]);
			if (lstat(argv[i], &buf) < 0) {
				err_ret("lstat error");
				continue;
			}
	
			if (S_ISREG(buf.st_mode)) {
				ptr = "regular";
			} else if (S_ISDIR(buf.st_mode)) {
				ptr = "directory";
			} else if (S_ISCHR(buf.st_mode)) {
				ptr = "character special";
			} else if (S_ISBLK(buf.st_mode)) {
				ptr = "block special";
			} else if (S_ISFIFO(buf.st_mode)) {
				ptr = "fifo";
			} else if (S_ISLNK(buf.st_mode)) {
				ptr = "symbolic link";
			} else if (S_ISSOCK(buf.st_mode)) {
				ptr = "socket";
			} else {
				ptr = "** unknown mode **";
			}
	
			printf("%s \n", ptr);
		}
	
		exit(0);
	}
```

###设置用户ID和设置组ID

* 实际用户ID和实际组ID标识我们究竟是谁。
* 有效用户 ID，有效组ID已经附加组ID决定了我们的文件访问权限.
* 保存的设置用户ID和保存呢的设置组ID在执行一个程序时包含了有效用户ID和有效组ID的副本。


###文件权限位

  * S_IRUSR 用户-读
  * S_IWUSR 用户-写
  * S_IXUSR 用户-执行
  

  * S_IRGRP 组-读
  * S_IWGRP 组-写
  * S_IXGRP 组-执行


  * S_IROTH 其他-读
  * S_IWOTH 其他-写
  * S_IXOTH 其他-执行


###access 函数

当用open函数打开一个文件时，内核以进程的有效用户ID和有效组ID为基础执行其访问权限测试。有时，进程也希望按其实际用户ID和实际组ID来测试其访问能力，例如当一个进程使用设置用户ID或设置组ID特征作为另一个用户运行时，就可能会有这种需要，access函数是按实际用户ID和实际组ID进行访问权限测试。

```
	#include <unistd.h>
	int access(const char *pathname, int mode);
	
	// 返回值：若成功则返回0，若出错则返回-1
```

其中，mode是以下的常量按位或：

* R_OK 测试读权限
* W_OK 测试写权限
* X_OK 测试执行权限
* F_OK 测试文件是否存在

```
	#include "../apue.h"
	#include <fcntl.h>
	
	int main(int argc, char *argv[])
	{
		if (argc != 2) {
			err_quit("usage:a.out <pathname>");
		}
	
		if (access(argv[1], R_OK) < 0) {
			err_ret("access error for %s", argv[1]);
		} else {
			printf("read access OK\n");
		}
	
		if (open(argv[1], O_RDONLY) < 0) {
			err_ret("open error for %s", argv[1]);
		} else {
			printf("open for reading OK \n");
		}
	
		exit(0);
	}
```

###umask函数

umask 函数为进程设置文件模式创建屏蔽字，并返回以前的值。

```
	#include <sys/stat.h>
	mode_t umask(mode_t cmask);
	// 返回以前的文件模式创建的屏蔽字
	
	#include "../apue.h"
	#include <fcntl.h>
	
	#define RWRWRW (S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH)
	
	int main(void)
	{
		umask(0);
		if (creat("foo", RWRWRW) < 0) {
			err_sys("create error for foo");
		}
	
		umask(S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH);
	
		if (creat("bar", RWRWRW) < 0) {
			err_sys("create error for bar");
		}
	
		exit(0);
	}
```

运行结果：

```
	-rw------- 1 root root    0 May 25 00:42 bar
	-rw-rw-rw- 1 root root    0 May 25 00:42 foo
```


###chmod 和 fchmod 函数

这两个函数使我们可以更改现有文件的访问权限：

```
	#include <sys/stat.h>
	int chmod(const char *pathname, mode_t mode);
	int fchmod(int filedes, mode_t mode);
	
	// 这两个函数返回值：若成功返回 0，出错返回 -1
```

参数mode 是由以下常量按位或运算构成：

* S_ISUID 执行时设置用户ID
* S_ISGID 执行时设置组ID
* S_ISVTX 保存正文(粘着位)


* S_IRWXU 用户（所有者）读、写和执行
* S_IRUSR 用户-读
* S_IWUSR 用户-写
* S_IXUSR 用户-执行


* S_IRWXG 组读、写和执行
* S_IRGRP 组-读
* S_IWGRP 组-写
* S_IXGRP 组-执行


* S_IRWXO 其他读、写和执行
* S_IROTH 其他-读
* S_IWOTH 其他-写
* S_IXOTH 其他-执行


```
	#include "../apue.h"
	
	int main(void)
	{
		struct stat statbuf;
	
		if (stat("foo", &statbuf) < 0) {
			err_sys("stat error for foo");
		}
	
		if (chmod("foo", (statbuf.st_mode & ~S_IXGRP) | S_ISGID) < 0) {
			err_sys("chmod error for foo");
		}
	
		if (chmod("bar", S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH) < 0) {
			err_sys("chmod error for bar");
		}
	
		exit(0);
	}
```

运行结果：

```
	-rw-r--r-- 1 root root    0 May 25 00:42 bar
	-rw-rwSrw- 1 root root    0 May 25 00:42 foo
```


###chown, fchown, 和 lchown 函数

下面几个chown函数可用于更改文件的用户ID和组ID：

```
	#include <unistd.h>
	
	int chown(const char *pathname,uid_t owner, gid_t group);
	int fchown(int filedes, uid_t owner, gid_t group);
	int lchown(const char *pathname, uid_t owner, gid_t group);
	// 三个函数的返回值：成功返回0， 若出错则返回-1
```

除了所引用的文件是符号链接以外，这个三个函数的操作相似。在符号连接下的情况下，lchown更改符号链接本身的所有者，而不是该符号链接所指的文件。

如果两个参数owner或group中的任意一个是 -1，则对应的ID不变。

如果这些函数由非超级用户进程调用，则在成功返回时，该文件设置用户ID位和设置组位都会被清除。

###文件长度

stat 结构成员 st_size 表示以字节为单位的文件长度。此字段对普通文件、目录文件和符号链接有意义。

* 对于普通文件，其文件长度可以是0，在读这种文件时，将得到文件结束指示.
* 对于目录，文件长度通常是一个数的倍数.
* 对于符号链接，文件长度是文件名中的实际字节数。


大多数UNIX系统提供字段st_blksize和st_blocks，其中，第一个对文件I/O较合适的块长度，第二个是所分配的实际512字节块数量。

###文件截短

有时我们需要在文件尾端处截取一些数据以缩短文件，将一个文件清空为0是一个特例，在打开文件时使用O_TRUNC标志可以做到这一点。

```
	#include <unistd.h>
	int truncate(const char *pathname, off_t length);
	int ftruncate(int filedes, off_t length);
	
	// 两个函数的返回值：若成功则返回0，如果出错返回-1
```

###link、unlink、remove和rename函数

任何一个文件可以多个目录项指向其i节点。创建一个指向现有文件的链接的方法就是使用link函数

```
	#include <unistd.h>
	
	int link(const char *existingpath, const char *newpath);
	// 返回值：若成功则返回0，若出错则返回 -1
```

此函数创建一个新目录项newpath, 它引用现有的文件existingpath, 如若newpath已经存在，则返回出错。只创建newpath中的最后一个分量，路劲中的其他部分应当已经存在。

为了删除一个现有的目录项，可以调用unlink函数。

```
	#include <unistd.h>
	
	int unlink(const char *pathname);
	// 返回值：若成功则返回0，若出错则返回-1
```

此函数删除目录项，并将由pathname所引用文件的链接计数减1.如果还有指向该文件的其他链接，则仍可通过其他链接访问文件的数据。如果出错，则不对该文件做任何更改。

只有当链接计数达到0时，该文件的内容才可被删除。另一个条件也会阻止删除文件的内容---只要有进程打开了该文件，其内容也不能删除。关闭一个文件时，内核首先检查打开该文件的进程数。如果该数达到0，然后内核检查其链接数，如果这个数也是0，那么就删除该文件的内容。

```
	#include "../apue.h"
	#include <fcntl.h>
	
	int main(void)
	{
		if (open("tempfile", O_RDWR) < 0) {
			err_sys("open error");
		}
	
		if (unlink("tempfile") < 0) {
			err_sys("unlink error");
		}
	
		printf("file unlinked\n");
		sleep(15);
		printf("done\n");
		exit(0);
	}
```

用remove函数解除对一个文件或目录的链接。对于文件，remove的功能与unlink相同，对于目录，remove的功能与rmdir相同.

```
	#include <stdio.h>
	
	int remove(const char *pathname);
	// 返回值：若成功则返回0，若出错则返回-1
```

文件或目录用rename函数更名：

```
	#include <stdio.h>
	
	int rename(const char *oldname, const char *newname);
	// 返回值：若成功则返回0，若出错则返回 -1
```

* 如果oldname指的是一个文件而不是目录，那么为该文件或符号链接就更名。在这种情况下，如果newname已存在，则它不能引用一个目录，如果newname已存在，而且不是一个目录，则先将该目录想删除然后将oldname更名为newname。
* 如若oldname指的是一个目录，那么为该目录更名，如果newname已存在，则它必须引用一个目录，而且该目录应当是空目录。如果newname存在，则现将其删除，然后将oldname更名为newname.
* 如若oldname或newname引用符号链接，则处理的是符号链接本身，而不是它所引用的文件.
* 作为一个特例，如果oldname和newname引用同一个文件，则函数不做任何更改而成功返回.


###symlink 和 readlink 函数

symlink函数创建一个符号链接函数:

```
	#include <unistd.h>
	
	int symlink(const char *actualpath, const char *sympath);
	// 返回值：若成功则返回0，若出错则返回 -1
```

该函数创建了一个指向actualpath的新目录项sympath,在创建此符号链接时，并不要求actualpath已经存在，并且，actualpath和sympath并不需要位于同一个文件系统。

因为open函数跟随符号链接，所以需要有一种方法打开该链接本身，并读该链接中的名字.

```
	#include <unistd.h>
	
	ssize_t readlink(const char *restrict pathname, char *restrict buf, size_t bufsize);
	// 返回值：若成功则返回读到的字节数，若出错则返回-1
```

此函数组合了open,read和close的所有操作。如果此函数成功执行，则它返回读入buf的字节数，在buf中返回的符号链接的内容不以null字符终止。

###文件时间

* st_atime 文件数据的最后访问时间，read (ls -lu)
* st_mtime 文件数据的最后修改时间，write (ls 默认)
* st_ctime i节点状态的最后修改时间 chmod,chwon (ls -lc)


注意修改时间(st_mtime) 和更改状态时间(st_ctime)之间的区别，修改时间文件内容最后一次被修改的时间，更改状态时间是该文件的i 节点最后一次被修改的时间。注意，文件并不保存对一个i节点的最后一次访问时间，所以access和stat函数并不更改这三个时间。

###utime函数

一个文件的访问和修改时间可以用utime函数更改。

```
	#include <utime.h>
	
	int utime(const char *pathname, const struct utimbuf *times);
	
	// 返回值：若成功则返回0， 若出错则返回 -1
	
	数据结构：
	struct utimbuf {
		time_t actime; // access time
		time_t modtime; // modify time	
	};
```

此函数的操作以及执行它所要求的特权取决于times参数是否是NULL:

* 如果times 是一个空指针，则访问时间和修改时间两者都设置为当前时间。
* 如果times 是非空指针，则访问时间和修改时间被设置为times所指向结构中的值。

  
注意，我们不能对更改状态时间st_ctime指定一个值，当调用utime函数时，此字段自动更新.

```
	#include "../apue.h"
	#include <fcntl.h>
	#include <utime.h>
	
	int main(int argc, char *argv[])
	{
		int i, fd;
		struct stat statbuf;
		struct utimbuf timebuf;
	
		for (i = 1; i < argc; i++) {
			if (stat(argv[i], &statbuf) < 0) {
				err_ret("%s : stat error", argv[i]);
				continue;
			}
	
			if ((fd = open(argv[i], O_RDWR | O_TRUNC)) < 0) {
				err_ret("%s : open error", argv[i]);
				continue;
			}
			close(fd);
	
			timebuf.actime = statbuf.st_atime;
			timebuf.modtime = statbuf.st_mtime;
	
			if (utime(argv[i], &timebuf) < 0) {
				err_ret("%s : utime error", argv[i]);
				continue;
			}
		}
	
		exit(0);
	}
```

###mkdir 和 rmdir 函数

用 mkdir 函数创建目录，用 rmdir 函数删除目录:

```
	#include <sys/stat.h>
	
	int mkdir(const char *pathname, mode_t mode);
	
	// 返回值：若成功则返回0，若出错则返回-1
```

此函数创建一个新的空目录，其中 . 和 .. 目录项自动创建的，所指定的文件访问权限mode 由进程的文件模式创建屏蔽字修改.

常见的错误是指定与文件相同的mode(只指定读、写权限). 但是，对于目录通常至少要设置1个执行权限位，以允许访问该目录中的文件名.

用rmdir 函数可以删除一个空目录，空目录是只包含. 和 .. 这两项的目录.

```
	#include <unistd.h>
	
	int rmdir(const char *pathname);
	
	// 返回值：若成功返回0，若出错则返回 -1
```


###读目录

```
	#include <dirent.h>
	
	DIR *opendir(const char *pathname);
	// 返回值：若成功返回指针，若出错则返回NULL
	
	struct dirent *readdir(DIR *dp);
	// 返回值：若成功则返回指针，若在目录结尾或出错则返回NULL
	
	void rewinddir(DIR *dp);
	
	int closedir(DIR *dp);
	// 返回值：若成功则返回0，若出错则返回-1
	
	long telldir(DIR *dp);
	// 返回值：与dp 关联的目录中的当前位置
	
	void seekdir(DIR *dp, long loc);
	
	
	数据结构：
	
	struct dirent{
		ino_t d_ino;
		char d_name[NAME_MAX + 1];
	};
```


实例：递归降序遍历目录层次结构，并按文件类型计数

```
	#include "../apue.h"
	#include <dirent.h>
	#include <errno.h>
	#include <limits.h>
	
	typedef int Myfunc(const char *, const struct stat *, int);
	
	static Myfunc myfunc;
	static int myftw(char *, Myfunc *);
	static int dopath(Myfunc *);
	char *path_alloc(int *sizep);
	
	static long nreg, ndir, nblk, nchr, nfifo, nslink, nsock, ntot;
	
	int main(int argc, char *argv[])
	{       
		int ret;
		if (argc != 2) {
			err_quit("usage: ftw <starting-pathname>");
		}
	
		ret = myftw(argv[1], myfunc);
	
		ntot = nreg + ndir + nblk + nchr + nfifo + nslink + nsock;
		if (ntot == 0) {
			ntot = 1;
		}
	
		printf("regular files = %7ld, %5.2f %%\n", nreg, (nreg * 100.0) / ntot);
		printf("directories files = %7ld, %5.2f %%\n", ndir, ndir * 100.0 / ntot);
		printf("block special  = %7ld, %5.2f %%\n", nblk, nblk * 100.0 / ntot);
		printf("char special   = %7ld, %5.2f %%\n", nchr, nchr * 100.0 / ntot);
		printf("FIFOs          = %7ld, %5.2f %%\n", nfifo, nfifo * 100.0 / ntot);
		printf("symbolic links = %7ld, %5.2f %%\n", nslink, nslink * 100.0 / ntot);
		printf("sockets        = %7ld, %5.2f %%\n", nsock, nsock * 100.0 / ntot);
	
		exit(ret);
	}
	
	#define FTW_F 1
	#define FTW_D 2
	#define FTW_DNR 3
	#define FTW_NS 4
	
	static char *fullpath;
	
	static int myftw(char *pathname, Myfunc *func)
	{
		int len;
		fullpath = path_alloc(&len);
	
		strncpy(fullpath, pathname, len);
	
		return (dopath(func));
	}
	
	static int dopath(Myfunc *func)
	{
		struct stat statbuf;
		struct dirent *dirp;
		DIR *dp;
		int ret;
		char *ptr;
	
		if (lstat(fullpath, &statbuf) < 0) {
			return (func(fullpath, &statbuf, FTW_NS));
		}
	
		if (S_ISDIR(statbuf.st_mode) == 0) {
			return (func(fullpath, &statbuf, FTW_F));
		}
	
		ptr = fullpath + strlen(fullpath);
		*ptr++ = '/';
		*ptr = 0;
	
		if ((dp = opendir(fullpath)) == NULL) {
			return (func(fullpath, &statbuf, FTW_DNR));
		}
	
		while((dirp = readdir(dp)) != NULL) {
			if (strcmp(dirp->d_name, ".") == 0 || strcmp(dirp->d_name, "..") == 0) {
				continue;
			}
	
			strcpy(ptr, dirp->d_name);
	
			if ((ret = dopath(func)) != 0) {
				break;
			}
		}
	
		ptr[-1] = 0;
	
		if (closedir(dp) < 0) {
			err_ret("cant't close directory %s", fullpath);
		}
	
		return ret;
	}
	
	static int myfunc(const char *pathname, const struct stat *statptr, int type)
	{
		switch(type) {
			case FTW_F:
				switch (statptr->st_mode & S_IFMT) {
					case S_IFREG: nreg++; break;
					case S_IFBLK: nblk++; break;
					case S_IFCHR: nchr++; break;
					case S_IFIFO: nfifo++; break;
					case S_IFLNK: nslink++; break;
					case S_IFSOCK: nsock++; break;
					case S_IFDIR:
								   err_dump("for S_ISDIR for %s", pathname);
				}
				break;
			case FTW_D:
				ndir++;
				break;
			case FTW_DNR:
				err_ret("can't read directory %s", pathname);
				break;
			case FTW_NS:
				err_ret("stat error for %s", pathname);
				break;
			default:
				err_dump("unknown type %d for pathname %s", type, pathname);
		}
	
		return 0;
	}
```


path_alloc 的实现方法:

```
	#include "../apue.h"
	#include <errno.h>
	#include <limits.h>
	
	#ifdef PATH_MAX
	static int pathmax = PATH_MAX;
	#else
	static int pathmax = 0;
	#endif
	#define SUSV3 200112L
	static long posix_version = 0;
	#define PATH_MAX_GUESS 1024
	
	char *path_alloc(int *sizep)
	{       
		void *ptr;
		int size;
	
		if (posix_version == 0) {
			posix_version = sysconf(_SC_VERSION);
		}
	
		if (pathmax == 0) {
			errno = 0;
			if ((pathmax = pathconf("/", _PC_PATH_MAX)) < 0) {
				if (errno == 0) {
					pathmax = PATH_MAX_GUESS;
				} else {
					err_sys("pathconf error for _PC_PATH_MAX"); 
				}
			} else {
				pathmax++;
			}
		}
	
		if (posix_version < SUSV3) {
			size = pathmax + 1;
		} else {
			size = pathmax;
		}
	
		if ((ptr = malloc(size)) == NULL) {
			err_sys("malloc error for pathname");
		}
	
		if (sizep != NULL) {
			*sizep = size;
		}
	
		return (char *) ptr;
	}
```


###chdir 、fchdir 和 getcwd 函数

每个进程都有一个当前的工作目录，进程通过调用 chdir 或 fchdir 函数可以更改当前工作目录.

```
	#include <unistd.h>
	int chdir(const char *pathname);
	int fchdir(int filedes);
	// 两个函数的返回值：若成功则返回0，若出错则返回 -1
```

因为当前工作目录是进程的一个属性没，所以它只影响调用chdir的进程本身，而不影响其他进程。

```
	#include "../apue.h"
	
	int main(void)
	{
		if (chdir("/tmp") < 0) {
			err_sys("chdir failed.");
		}
		printf("chdir to /tmp succeeded\n");
		exit(0);
	}
```

函数 getcwd() 可以获取当前进程的工作目录：

```
	#include <unistd.h>
	
	char *getcwd(char *buf, size_t size);
	// 返回值：若成功则返回buf, 若出错则返回NULL
```

向此函数传递两个参数，一个是缓存地址buf, 另一个是缓存的长度 size .该缓存必须由足够的长度若纳绝对路径名再加上一个 NULL 终止字符.

```
	#include "../apue.h"
	
	int main(void)
	{
		char *ptr;
		int size;
	
		if (chdir("/usr") < 0) {
			err_sys("chdir failed.");
		}
	
		ptr = path_alloc(&size);
		if (getcwd(ptr, size) == NULL) {
			err_sys("getcwd failed.");
		}
	
		printf("cwd = %s\n", ptr);
		exit(0);
	}
```


###设备特殊文件

* 每个文件系统所在的存储设备都由其主、次设备号表示。设备号所用的数据类型是基本系统数据类型 dev_t
* 我们通常可以使用两个宏即 major 和 minor来访问主、次设备号。大多数实现都定义了这两个宏。
* 系统中的每个文件关联的 st_dev 值是文件系统的设备号，该文件系统包含了这一文件名以及与其对应的 i 节点。
* 只有字符特殊文件和块特殊文件才有st_rdev 值，此值包含实际设备的设备号。


打印 st\_dev 和 st_rdev 值(在 linux 下未编译通过)

```
	#include "../apue.h"
	
	#ifdef SOLARIS
	#include <sys/mkdev.h>
	#endif
	
	int main(int argc, char *argv[])
	{
		int i;
		struct stat buf;
	
		for (i = 1; i < argc; i++) {
			printf("%s:", argv[i]);
			if (stat(argv[i], &buf) < 0) {
				err_ret("stat error");
				continue;   
			}   
	
			printf("dev = %d/%d", major(buf.st_dev), minor(buf.st_dev));
			if (S_ISBLK(buf.st_mode) || S_ISLNK(buf.st_mode)) {
				printf(" (%s) rdev = %d/%d", (S_ISCHR(buf.st_mode)) ? "character" : "block",
						major(buf.st_rdev), minor(buf.st_rdev));    
			}                               
	
			printf("\n");
		}   
	
		exit(0);
	}
```

