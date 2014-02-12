title: C 语言中 extern 关键字详解
date: 2013-05-14 18:13:16
tags: extern 
categories: C 语言
---

###用extern 声明外部变量

定义：外部变量是指在函数或者文件外部定义的全局变量。外部变量定义必须在所有的函数之外，且只能定义一次。

(1) 在一个文件内声明的外部变量

作用域：如果在变量定义之前要使用该变量，则在用之前加 extern 声明变量，作用域扩展到从声明开始，到本文件结束。

例子：

```
	#include <stdio.h>

	int max(int x, int y); // 函数提前声明
	int main(int argc, char *argv[])
	{
		int result;
		extern int X;
		extern int Y;
		result = max(X, Y);
		printf("the max value is %d\n", result);
		return 0;
	}

	int X = 10; //定义外部变量
	int Y = 20;

	int max(int x, int y)
	{
		return (x > y ? x : y);
	}
```

其中,用 extern 声明外部变量时，类型名可以省略。例如， "extern int X;" , 可以改写成 "extern X;"。
小结： 这种方法简单，实用性不大.

(2) 在多个文件中声明外部变量

作用域：如果整个工程有多个文件组成，在一个文件中想引用另外一个文件中已经定义的外部变量时，则只需在引用变量的文件中用extern 关键字加以声明即可。可见，其作用域从一个文件扩展到多个文件了。
例子：
文件 a.c 的内容

```
	#include <stdio.h>
	int BASE = 2;
	extern int exe(int x);
	
	int main(int argc, char *argv[])
	{
		int a = 10;
		printf("%d^%d = %d\n", BASE, a, exe(a));
		return 0;
	}
```

文件 b.c 的内容

```
	#include <stdio.h>
	extern BASE; // 声明的外部变量
	int exe(int x)
	{
		int i;
		int ret = 1;
		for (i = 0; i < x; i++) {
			ret *= BASE;
		}
	
		return ret;
	}
```


利用gcc 工具编译gcc a.c b.c -o demo, 再运行 ./demo, 结果为 2^10 = 1024 . 其中，在a.c 文件中定义 BASE = 2, 在 b.c 中引用 BASE 时，需要用 extern 关键字声明其为外部变量，否则编译会找不到该变量. 

小结：对于多个文件的工程，可以采用这种方法来操作。实际工程中，对于模块化的程序文件，在其文件中可以预先留好外部变量的接口，也就是只采用 extern 声明变量，不定义变量，也通常在模块程序的头文件中声明，在使用该模块时，只需要在使用时定义一下即可，如上述 b.c 文件，做好相应的函数接口，留好需要改变 BASE 值的声明，在需要使用该模块时，只需要在需要调用的文件中定义具体的值即可。
引用外部变量和通过函数形参值传递变量的区别：用extern 引用外部变量，可以在引用的模块内修改其值，而形参值传递的变量则不能修改其值，除非是地址传递。
因此，如果多个文件同时对需要应用的变量进行同时操作，可能会修改该变量，类似于形参的地址传递，从而影响其他模块的使用，因此要慎重的使用。

(3) 在多个文件中声明外部结构体变量
前一节中，只是适合一般变量的外部声明，但是对于声明外部结构体变量时，则有些不同，需要加以注意。
例子:
文件 a.c 的内容:

```
	#include <stdio.h>
	#include "b.h"
	#include "c.h"
	
	A_class local_post = {1, 2, 3};
	A_class next_post = {10, 9, 8};
	
	int main(int argc, char *argv[])
	{
		A_class ret;
		print("fist point", local_post);
		print("second point", next_post);
		ret = fun(local_post, next_post);
		printf("the vector is (%d %d %d)\n", ret.x, ret.y, ret.z);
		return 0;
	}
```

文件 b.h 的内容:

```
	#ifndef __B_H
	#define __B_H
	#if 1
	typedef struct {
		int x;
		int y;
		int z;
	} A_class;
	#endif
	
	extern A_class local_post;  // 外部结构体变量声明
	extern A_class fun(A_class x, A_class y); // 接口函数声明
	#endif
```

文件 b.c 的内容：

```
	#include <stdio.h>
	#include "b.h"
	
	A_class fun(A_class first, A_class next)
	{
		A_class ret;
		ret.x = next.x - first.x;
		ret.y = next.y - first.y;
		ret.z = next.z - first.z;
		return ret;
	}
```

文件 c.h 的内容:

```
	#ifndef __C_H
	#define __C_H
	extern int print(char *, A_class post);
	#endif
```

文件 c.c 的内容: 

```
	#include <stdio.h>
	#include "b.h"
	
	int print(char *str, A_class post)
	{
		printf("%s:(%d,%d,%d)\n", str, post.x, post.y, post.z);
		return 0;
	}
```

利用 gcc 工具编译 gcc a.c b.c c.c -o demo ，在运行 ./demo ,结果为: 

```
	[shell]
	fist point:(1,2,3)
	second point:(10,9,8)
	the vector is (9 7 5)
```

小结： 在 a.c 文件中定义全局变量 A\_class local\_post 结构体，并且调用 b.c 中的接口函数 A\_class fun(int x, int y) 和 c.c 中的int print(char *str, A\_class post), 在b.h 文件中，如果屏蔽掉 A\_class 的实现，而在 b.h以外实现，此生将编译出错，由于 c.c 文件中用到 A\_class 定义的类型，所以需要在该文件中包含 b.h。
这里需要说明的是，如果调用外部结构体等多层结构体变量时，需要对这种变量进行实现，使用时，加上模块的头文件即可，否则会报错。
实际工程中，模块化程序文件，一般提供一个 .c 和一个 .h 文件， 其中 .h 文件被 .c 文件调用， .h 文件中实现.

###用 extern 声明外部函数 

a. 定义函数时，在函数的返回值类型前面加上extern 关键字，表示此函数时外部函数，可供其他文件调用，如 extern int func(int x, int y), C语言规定，此时 extern 可以省略，隐形为外部函数。
b. 调用次函数时，需要用extern 对函数做出声明. 

作用域: 使用 extern 声明能够在一个文件中调用其他文件的函数，即把被调用函数的作用域扩展到本文件。C语言中规定，声明时可以省略 extern
例子：
文件 a.c 的内容:

```
	#include <stdio.h>
	#include "b.h"
	
	int main(int argc, char *argv[])
	{
		int x = 10, y = 5;
		printf("x = 10, y = 5\n");
		printf("x + y = %d\n", add(x, y));
		printf("x - y = %d\n", sub(x, y));
		printf("x * y = %d\n", mult(x, y));
		printf("x / y = %d\n", div(x, y));
		return 0;
	}
```

文件 b.h 的内容:

```
	#ifndef __F_H
	#define __F_H
	extern int add(int, int);
	extern int sub(int, int);
	extern int mult(int, int);
	extern int div(int, int);
	#endif
```

文件 b.c 的内容:

```
	#include <stdio.h>
	
	int add(int x, int y)
	{
		return (x + y);
	}
	
	int sub(int x, int y)
	{
		return x - y;
	}
	
	int mult(int x, int y)
	{
		return x * y;
	}
	
	int div(int x, int y)
	{
		if (y != 0) {
			return (x / y);
		}
	
		printf("mult()fail second para can not be zero!\n");
		return -1;
	}
```

利用 gcc 工具编译 gcc a.c b.c -o demo ，再运行 ./demo ， 结果为：

```
	x = 10, y = 5
	x + y = 15
	x - y = 5
	x * y = 50
	x / y = 2
```

小结：由上面简单的例子可以看出，在 b.h 文件中声明好 b.c 的函数，使用时，只需要在 a.c 中包含 #include "b.h" 头文件即可，这样就可以使用 b.c 的接口函数了，在实际工程中，通常也是采用这种方式， .c 文件中实现函数，.h文件中声明函数接口，需要调用.c文件的函数接口时，只需包含.h文件即可。

###总结 

在实际工程中，有两种情况比较多。一是利用 extern 只声明外部函数，不需要传递需要外部声明的变量，一个模块化接口文件对应一个声明接口的头文件，需要调用接口函数时，需要包含头文件。二是利用用extern 声明外部函数，同时声明需要传递的外部变量，做法和第一种情况一样，声明都放在头文件中，但是模块文件也需要包含该头文件。另外，如果结构体等比较复杂的变量，则需要包含其定义的头文件。另外，定义的外部变量属于全局变量，其存储方式为静态存储，生存周期为整个的生存周期。

