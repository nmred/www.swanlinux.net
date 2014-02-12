title: 标准 IO 库
date: 2013-05-14 18:13:16
tags: file io 
categories: 《unix 高级编程》-Note
---

###流和 FILE 对象

标准I/O文件流可用于单字节或多字节字符集，流的定向决定了所读、写的字符是单字节还是多字节的。当一个流最初被创建时，它并没有定向。如若在一个未定向的流上使用一个多字节的I/O函数，则将该流的定向设置为宽定向的，如若在未定向的流上使用一个单字节的I/O函数，则将该流的定向设置为字节定向的。只有两个函数可以改变流的定向。freopen函数清除一个流的定向；fwide函数设置流的定向。

```
	#include <stdio.h>
	#include <wchar.h>
	
	int fwide(FILE *fp, int mode);
	
	// 返回值：若流是宽定向的则返回正值，若流是字节定向的则返回负值，或者若流是未定向的则返回0
```
	

根据mode参数的不同值，fwide函数执行不同的工作：

* 如若mode参数值为负，fwide将试图使指定的流是字节定向的。
* 如若mode参数值为正，fwide将试图使指定的流是宽定向的。
* 如若mode参数值为0，fwide将不试图设置流的定向，但返回标识该流定向的值。


###标准输入、标准输出和标准出错

对一个进程预定义了三个流，并且这三个流可以自动地被进程使用，它们是：标准输入、标准输出和标准出错。这些流引用的文件是文件IO描述符 STDIN_FILENO 、STDOUT_FILENO和STDERR_FILENO所引用的文件相同。这三个标准I/O流通过预定义文件指针stdin、stdout和stderr加以引用，这三个文件指针同样定义在头文件<stdio.h>中.

###缓冲

标准I/O提供了三种类型的缓冲：

- **全缓冲**


这种情况下，在填满标准IO缓冲区后才进行实际IO操作，对于驻留在磁盘上的文件通常是有标准IO库实施全缓冲的。

术语冲洗说名标准IO缓冲区的写操作，缓冲区可由标准IO例程自动冲洗，或者可以调用幻数fflush冲洗一个流。值得引起注意的是在UNIX环境中，flush有两种意思。在标准IO库方面，flush意味着将缓冲区中的内容写到磁盘上。在终端驱动程序方面，flush表示丢弃已存储在缓冲期区中的数据。


- **行缓冲**


在这种情况下，当输入和输出遇到换行符是，标准IO库执行操作。这允许我们一次输出一个字符，但只有写了一行之后才进行实际IO操作，当流涉及一个终端时，通常使用行缓冲.


- **不带缓冲**


标准IO库不对字符进行缓存存储，标准出错流stderr通常是不带缓冲的，这就使得出错信息可以尽快显示出来，而不管它们是否含有一个换行符。

很多系统默认使用下来类型的缓冲：

* 标准出错是不带缓冲的。
* 如若是涉及终端设备的其他流，则它们是行缓冲的；否则是全缓冲的。


可以调用下列两个函数中的一个更改缓冲类型：

```
	#include <stdio.h>
	
	void setbuf(FILE *restrict fp, char *restrict buf);
	int setvbuf(FILE *restrict fp, char *restrict buf, int mode, size_t size);
	
	// 返回值：若成功则返回0， 若出错则返回非0值
```

可以使用setbuf 函数打开或关闭缓冲机制，为了带缓冲进行I/O，参数buf必须指向一个长度为 BUFSIZ 的缓冲区。通常在此之后该流就是全缓冲的，但是如果该流与一个终端设备相关，那么某些系统也可将其设置为行缓冲的，为了关闭缓冲，将buf设置为NULL；

使用setvbuf,我们可以精确地指定所需的缓冲类型，这是用mode参数实现的：

* _IOFBF 全缓冲
* _IOLBF 行缓冲
* _IONBF 不缓冲


如果指定一个不带缓冲的流，则忽略buf和size参数，如果指定全缓冲或行缓冲，则buf和size可选择地指定一个缓冲区及其长度。如果该流是带缓冲的，而buf是NULL，则标准I/O库将自动地为该流分配适合长度的缓冲区。适当长度指的是有常量BUFSIZ 所指定的值。

任何时候都可以强制冲洗一个流：

```
	#inclue <stdio.h>
	
	int fflush(FILE *fp);
	
	// 返回值: 若成功则返回0，若出错则返回EOF
```

此函数使该流所有未写的数据都被传送至内核，作为一个特例，如若 fp 是NULL，则此函数将导致所有输出流被冲洗。

###打开流

下列三个函数打开一个标准I/O流：

```
	#include <stdio.h>
	
	FILE *fopen(const char *restrict pathname, const char *restrict type);
	
	FILE *freopen(const char *restrict pathname, const char *restrict type, FILE *restrict fp);
	
	FILE *fdopen(int filedes, const char *type);
	
	// 三个函数的返回值：若成功则返回文件指针，若出错则返回NULL
```


三个函数的区别：

- fopen打开一个指定的文件.


- freopen在一个指定的流上打开一个指定的文件，如若该流已经打开，则先关闭该流，若该流已经定向，则 freopen清除该定向，此函数一般用于将一个指定的文件打开为一个预定义的流：标准输入、标准输出或标准出错.


- fdopen 获取一个现有的文件描述符，并使一个标准的I/O流与该描述符相结合.


调用 fclose() 关闭一个打开的流：

```
	#include <stdio.h>
	
	int fclose(FILE *fp);
	
	// 返回值：若成功则返回0， 若出错则返回 EOF
```

###读和写流

一旦打开了流，则可在三种不同类型的非格式化I/O中进行选择，对其进行读、写操作：

(1) 每次一个字符的I/O，一次读或写一个字符，如果流是带缓冲的，则标准I/O函数会处理所有的缓冲。

(2) 每次一行的I/O，如果想要一次读或写一行，则使用fgets和fputs，每行都以一个换行符终止，当调用fgets时，应说明处理的最大行长。

(3) 直接I/O，
fread和fwrite函数支持这种类型的I/O，每次I/O操作读或写某种数量的对象，而每个对象具有指定的长度，这两个函数常用于从二进制文件中每次读写一个结构。

###输入函数

以下三个函数可用于一次读一个字符：

```
	#include <stdio.h>
	
	int getc(FILE *fp);
	int fgetc(FILE *fp);
	int getchar(void);
	
	// 三个函数的返回值：若成功则返回一下个字符，若已到达文件结尾或出错则返回EOF
```

函数getchar等价于getc(stdin) , 前两个函数的分别是getc可被实现为宏，而fgetc则不能实现为宏，这意味着：

(1) getc的参数不应当是具有副作用的表达式。

(2) 因为 fgetc一定是一个函数，所以可以得到其地址，这就允许将fgetc的地址作为一个参数传送给另一个函数。

(3) 调用fgetc所需要的时间可能大于调用getc,因为调用函数通常所需要的时间大于调用宏。

注意，不管是出错还是到达文件尾端这三个函数返回同样的值，为了区分这两种不同的情况，必须调用ferror或feof

```
	#include <stdio.h>
	
	int ferror(FILE *fp);
	
	int feof(FILE *fp);
	
	// 两个函数返回值：若条件为真则返回非0值，否则返回0
	
	
	void clearerr(FILE *fp);
```

调用 clearerr() 则清除这两个标志

从流中读取数据以后，可以调用ungetc()将字符再压送回流中

```
	#include <stdio.h>
	
	int ungetc(int c, FILE *fp);
	
	// 返回值：若成功则返回c, 若出错则返回EOF
```

压送回到流中的字符以后又可从流中读出，但读出字符的顺序与压送回的顺序相反。虽然ISO C 允许实现支持任何次数大的回送，但是它要求实现提供一次只送回一个字符，我们不能期望一次能送回多个字符。

###输出函数

```
	#include <stdio.h>
	
	int putc(int c, FILE *fp);
	
	int fputc(int c, FILE *fp);
	
	int putchar(int c);
	
	// 三个函数返回值：若成功则返回C, 若出错则返回EOF
```

###每次一行I/O

下面两个函数提供每次输入一行的功能：

```
	#include <stdio.h>
	
	char *fgets(char *restrict buf, int n, FILE *restrict fp);
	
	char *gets(char *buf);
	
	// 两个函数返回值：若成功则返回buf, 若已到达文件结尾或出错则返回NULL
```

这两个函数都指定了缓冲区的地址，读入的行将送入其中。gets从标准输入读，而fgets则从指定的流读。

对于fgets,必须指定缓冲区的长度n ， 此函数一直读到一下个换行符为止，但是不超过n - 1 个字符，读入的字符被送入缓冲区。该缓冲区以null字符结尾。

fputs 和 puts 提供每次输出一行的功能：

```
	#include <stdio.h>
	
	int fputs(const char *restrict str, FILE *restrict fp);
	
	int puts(const char *str);
	
	// 两个函数返回值：若成功则返回非负值，若出错则返回EOF
```

如果总是使用 fgets和fputs,那么就会熟知在每行终止处我们必须自己处理换行符.

用 getc 和 putc 将标准输入复制到标准输出

```
	#include "../apue.h"
	
	int main(void)
	{
		int c;
		while((c = getc(stdin)) != EOF) {
			if (putc(c, stdout) == EOF) {
				err_sys("output error");
			}
	
		}
	
		if (ferror(stdin)) {
			err_sys("input error");
		}
	
		exit(0);
	}
```

用 fgets 和 fputs 将标准输入复制到标准输出

```
	#include "../apue.h"
	
	int main(void)
	{
		char buf[MAXLINE];
	
		while(fgets(buf, MAXLINE, stdin) != NULL) {
			if (fputs(buf, stdout) == EOF) {
				err_sys("output error");
			}
		}
	
		if (ferror(stdin)) {
			err_sys("input error");
		}
	
		exit(0);
	}
```

###二进制I/O

下列两个函数以执行二进制I/O操作：

```
	#include <stdio.h>
	
	size_t fread(void *restrict ptr, size_t size, size_t nobj, FILE *restrict fp);
	
	size_t fwrite(void *restrict ptr, size_t size, size_t nobj, FILE *restrict fp);
	
	// 两个函数的返回值：读或写的对象数
```

这些函数有两种常见的用法：

(1) 读或写一个二进制数组. 

```
	// 将一个浮点数组的第2~5个元素写至一个文件上：
	
	float data[10];
	
	if(fwrite(&data[2], sizeof(float), 4, fp) != 4) {
		err_sys("fwrite error");
	}
```

(2) 读或写一个结构

```
	struct {
		short count;
		long total;
		char name[NAMESIZE];
	} item;
	
	if (fwrite(&item, sizeof(item), 1, fp) != 1) {
		err_sys("fwrite error");
	}
```


###定位流

有三种方法定位标准I/O流：

(1) ftell 和 fseek 函数， 但是它们都假定文件的位置可以存放在一个长整型中。

(2) ftello 和 fseeko 函数，可以使文件偏移量不必一定使用长整型，它们使用off_t数据类型代替了长整型.

(3) fgetpos 和 fsetpos 函数，它们使用一个抽象数据类型 fpos_t 记录文件的位置，这种数据类型可以定义为记录一个文件位置所需的长度.

```
	#include <stdio.h>
	
	long ftell(FILE *fp);
	
	// 返回值：若成功则返回当前文件位置指示，若出错则返回 -1L
	
	int fseek(FILE *fp, long offset, int whence);
	
	// 返回值：若成功则返回0，若出错则返回非0值；
	
	void rewind(FILE *fp);
```

除了offset 类型是off_t 而非long以外，ftello 函数与 ftell相同， fseeko 函数与 fseek相同。

```
	#include <stdio.h>
	
	off_t ftello(FILE *fp);
	
	// 返回值：若成功则返回当前文件位置指示，若出错则返回 -1
	
	int fseeko(FILE *fp, off_t offset, int whence);
	
	// 返回值：若成功则返回0，若出错则返回非0值
```


fgetpos 和 fsetpos 这两个函数是 C 标准引进的：

```
	#include <stdio.h>
	
	int fgetpos(FILE *restrict fp, fpos_t *restrict pos);
	
	int fsetpos(FILE *fp, const fpos_t *pos);
	
	// 两个函数返回值：若成功则返回0，若出错则返回非0值
```

###格式化I/O

###格式化输出

执行格式化输出处理的是4个printf 函数：

```
	#include <stdio.h>
	
	int printf(const char *restrict format, ...);
	
	int fprintf(FILE *restrict fp, const char *restrict format, ...);
	
	// 两个函数返回值：若成功则返回输出字符数，若输出出错则返回负值
	
	int sprintf(char *restrict buf, const char *restrict format, ...);
	
	int snprintf(char *restrict buf, size_t n, const char *restrict format, ...);
	
	// 两个函数返回值：若成功则返回存入数组的字符数，若编码出错则返回负值
```

printf 将格式化数据写到标准输出，fprintf写至指定的流，sprintf将格式化的字符送入数组buf中。sprintf在该数组的尾端自动加一个null字节，但该字节不包括在返回值中。注意，sprintf 函数可能会造成由 buf 指向的缓冲区溢出，调用者有责任确保该缓冲区足够大。为了解决这中缓冲区溢出问题，引入了snprintf函数，在还函数中，缓冲区长度是以个显示参数，超过缓冲区的尾端写的任何字符都会被丢弃。

下列4种printf族的变体类型类似于上面的4种，但是可变参数表(...)代换成 arg:

```
	#include <stdarg.h>
	#include <stdio.h>
	
	int vprintf(const char *restrict format, va_list arg);
	
	int vfprintf(FILE *restrict fp, const char *restrict format, va_list arg);
	
	// 两个函数返回值：若成功则返回输出字符数，若输出出错则返回负值
	
	int vsprintf(char *restrict buf, const char *restrict format, va_list arg);
	
	int vsnprintf(char *restrict buf, size_t n, const char *restrict format, va_list arg);
	
	// 两个函数的返回值：若成功则返回存入数组的字符数，若编码出错则返回负值
```


###格式化输入

执行格式化输入处理的三个 scanf 函数:

```
	#include <stdio.h>
	
	int scanf(const char *restrict format, ...);
	
	int fscanf(FILE *restrict fp, const char *restrict format, ...);
	
	int sscanf(const char *restrict buf, const char *restrict format, ...);
	
	// 三个函数返回值：指定的输入项数，若输入出错或在任意变换前已到达文件结尾则返回EOF
```

scanf族用于分析输入字符串，并将字符序列转化成指定类型的变量，格式之后的各参数包含了变量的地址，以用转化结果初始化这些变量。

与printf族一样，scanf族也支持函数使用由<stdarg.h>说明的可变参数表

```
	#include <stdarg.h>
	#include <stdio.h>
	
	int vscanf(const char *restrict format, va_list arg);
	
	int vfscanf(FILE * restrict fp, const char *restrict format, va_list arg);
	
	int vsscanf(const char *restrict buf, const char *restrict format, va_list arg);
	
	// 三个函数返回值：指定的输入项数，若输入出错或在任一变化前已到达文件结尾则返回EOF
```

###实现细节

每个标准I/O流都有一个与其相关联的文件描述符，可以对一个流调用 fileno 函数以获得其描述符。

```
	#include <stdio.h>
	
	int fileno(FILE *fp);
	
	// 返回值：与该流相关联的文件描述符
```

如果要调用dup或fcntl等函数，则需要此函数。

```
	#include "../apue.h"
	
	void pr_stdio(const char *, FILE *);
	
	int main(void)
	{
		FILE *fp;
	
		fputs("enter any character\n", stdout);
		if (getchar() == EOF) {
			err_sys("get char error");
		}
	
		fputs("one line to standard error\n", stderr);
	
		pr_stdio("stdin", stdin);
		pr_stdio("stdout", stdout);
		pr_stdio("stderr", stderr);
	
		if ((fp = fopen("/etc/passwd", "r")) == NULL) {
			err_sys("fopen error");                                                        
		}                                                                                  
	
		if (getc(fp) == EOF) {                                                             
			err_sys("getc error");                                                         
		}                
	
		pr_stdio("/etc/passwd", fp);
	
		return 0;
	}
	
	void pr_stdio(const char *name, FILE *fp)
	{
		printf("stream = %s", name);
	
		if (fp->_IO_file_flags & _IO_UNBUFFERED) {
			printf("unbuffered");
		} else if (fp->_IO_file_flags & _IO_LINE_BUF) {
			printf("line buffered");
		} else {
			printf("full buffered");
		}
	
		printf(", buffer size = %d\n", fp->_IO_buf_end - fp->_IO_buf_base);
	}
```

###临时文件

标准 I/O 库提供了两个函数以帮助创建临时文件:

```
	#include <stdio.h>
	
	char *tmpnam(char *ptr);
	
	// 指向唯一路劲名的指针
	
	FILE *tmpfile(void);
	
	// 返回值：若成功则返回文件指针，若出错则返回NULL
```

tmpnam 函数产生一个与现有文件名不同的一个有效路劲名字符串，每次调用它时，它都产生一个不同的路劲名，最多调用次数是 TMP_MAX, TMP_MAX 定义在 <stdio.h> 中。

若 ptr 是NULL，则所产生的路劲名存放在一个静态区中，指向该静态区的指针作为函数值返回。下一次再调用 tmpnam 时，会重写该静态区（这意味着，如果调用此函数多次，而且想保存路劲名，则我们应当保存该路劲名的副本，而不是指针的副本）。如若ptr不是NULL，则认为它指向长度至少是L_tmpnam个字符的数组。所产生的路劲名存放在该数组中，ptr也作为函数值返回。

tmpfile 创建一个临时二进制文件，在关闭该文件或程序结束时将自动删除这种文件。注意，UNIX 对二进制文件不作特殊区分。

```
	#include "../apue.h"
	
	int main(void)
	{
		char name[L_tmpnam], line[MAXLINE];
		FILE *fp;
	
		printf("%s\n", tmpnam(NULL));
	
		tmpnam(name);
		printf("%s\n", name);
	
		if ((fp = tmpfile()) == NULL) {
			err_sys("tmpfile error");
		}
		fputs("one line of output\n", fp);
		rewind(fp);
		if (fgets(line, sizeof(line), fp) == NULL) {
			err_sys("fgets error");
		}
	
		fputs(line, stdout);
		return 0;
	}
```

Single UNIX Specification 为处理临时文件定义了另外两个函数，它们是XSI的扩展部分，其中一个是 tempnam 函数：

```
	#include <stdio.h>
	
	char *tempnam(const char *directory, const char *prefix);
	
	// 返回值：指向唯一路劲名的指针
```

tempnam 是 tmpnam的一个变体，它允许调用者为所产生的路径名指定目录和前缀。

```
	#include "../apue.h"                                                                   
	
	int main(int argc, char *argv[])                                                       
	{                                                                                      
		if (argc != 3) {                                                                   
			err_quit("usage: a.out <directory> <prefix>");                                 
		}                                                                                  
	
		printf("%s\n", tempnam(argv[1][0] != ' ' ? argv[1] : NULL, (argv[2][0] != ' ' ? argv[2] : NULL)));
	
		return 0;                                                                          
	}
```

XSI定义的第二个函数是 mkstemp ，它类似于 tmpfile ,但是该函数返回的不是文件指针，而是临时的文件的打开文件描述符。

```
	int mkstemp(char *template);
	
	// 返回值：若成功则返回文件描述符，若出错则返回 -1
```

它所返回的文件描述符可用于读、写该文件。临时文件的名字是用 template 字符串参数选择的。与tempfile不同的是，mkstemp 创建的临时文件不会自动的被删除。如若想删除需要调用unlink.

使用tmpnam 和 tempnam的不足之处是，它返回唯一的路劲名和应用程序用该路劲名创建文件之间有一个时间窗口，在该时间窗口期间，另一个进程可能创建一个同名文件，tempfile 和mkstemp 函数则不会产生此种问题。
