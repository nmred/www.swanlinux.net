title: 编译PHP中rrdtool扩展库
date: 2014-02-25 18:13:16
tags: rrdtool 
categories: php
---

在 php 中编译rrdtool时发现的错误及解决方案.

目前版本：

rrdtool: 1.4.7
php-rrd: 1.1.3


### 编译配置是的错误

在编译配置的时候

``` bash
	./configure --with-php-config=/usr/local/swan/opt/bin/php-config --with-rrd=/usr/local/swan/opt/
	checking for egrep... grep -E
	checking for a sed that does not truncate output... /bin/sed
	checking for cc... cc
	checking for C compiler default output file name... a.out
	checking whether the C compiler works... yes
	checking whether we are cross compiling... no
	checking for suffix of executables... 
	checking for suffix of object files... o
	checking whether we are using the GNU C compiler... yes
	checking whether cc accepts -g... yes
	checking for cc option to accept ANSI C... none needed
	checking how to run the C preprocessor... cc -E
	checking for icc... no
	checking for suncc... no
	checking whether cc understands -c and -o together... yes
	checking for system library directory... lib
	checking if compiler supports -R... no
	checking if compiler supports -Wl,-rpath,... yes
	checking build system type... i686-pc-linux-gnu
	checking host system type... i686-pc-linux-gnu
	checking target system type... i686-pc-linux-gnu
	checking for PHP prefix... /usr/local/swan/opt
	checking for PHP includes... -I/usr/local/swan/opt/include/php -I/usr/local/swan/opt/include/php/main -I/usr/local/swan/opt/include/php/TSRM -I/usr/local/swan/opt/include/php/Zend -I/usr/local/swan/opt/include/php/ext -I/usr/local/swan/opt/include/php/ext/date/lib
	checking for PHP extension directory... /usr/local/swan/opt/lib/php/extensions/no-debug-non-zts-20121212
	checking for PHP installed headers prefix... /usr/local/swan/opt/include/php
	checking if debug is enabled... no
	checking if zts is enabled... no
	checking for re2c... no
	configure: WARNING: You will need re2c 0.13.4 or later if you want to regenerate PHP parsers.
	checking for gawk... gawk
	checking for rrdtool support... yes, shared
	checking for rrdtool... no
	configure: creating ./config.status
	config.status: creating tests/rrdtool-bin.inc
	configure: creating ./config.status
	config.status: creating tests/rrdtool-bin.inc
	config.status: creating tests/data/Makefile
	checking if rrdtool specified path is valid... yes
	checking for rrd_create in -lrrd... yes
	checking for rrd_graph_v... no
	checking for __rrd_graph_v... no
	checking for rrd_graph_v in -lrrd... yes
	configure: error: rrd lib version seems older than 1.3.0, update to 1.3.0+
```

发生这个错误有2中情况，一种是 rrdtool 的版本确实是小于 1.3.0，第二种也是我遇到的问题是编译配置的检测函数的bug具体修复方法如下：

修改 config.m4 文件：

```
	   dnl rrd_graph_v is available in 1.3.0+
	   -  PHP_CHECK_FUNC(rrd_graph_v, rrd)
	   -  if test "$ac_cv_func_rrd_graph_v" != yes; then
	   -    AC_MSG_ERROR([rrd lib version seems older than 1.3.0, update to 1.3.0+])
	   -  fi
	   +  PHP_CHECK_LIBRARY(rrd, rrd_graph_v,
	   +  [],[
	   +    PHP_CHECK_LIBRARY(rrd, rrd_graph_v,
	   +    [],[
	   +      AC_MSG_ERROR([rrd lib version seems older than 1.3.0, update to 1.3.0+])
	   +    ],[
	   +      -L$RRDTOOL_LIBDIR
	   +    ])
	   +  ],[
	   +    -L$RRDTOOL_LIBDIR
	   +  ])

	   `rrd_lastupdate_r` 修改方法和 `rrd_graph_v` 类似
```

### 编译时的错误

```
	[root@sina rrd-1.1.3]# make -j 4
	/bin/sh /root/soft/rrd-1.1.3/libtool --mode=compile cc  -I. -I/root/soft/rrd-1.1.3 -DPHP_ATOM_INC -I/root/soft/rrd-1.1.3/include -I/root/soft/rrd-1.1.3/main -I/root/soft/rrd-1.1.3 -I/usr/local/swan/opt/include/php -I/usr/local/swan/opt/include/php/main -I/usr/local/swan/opt/include/php/TSRM -I/usr/local/swan/opt/include/php/Zend -I/usr/local/swan/opt/include/php/ext -I/usr/local/swan/opt/include/php/ext/date/lib -I/usr/local/swan/opt//include  -DHAVE_CONFIG_H  -g -O2   -c /root/soft/rrd-1.1.3/rrd.c -o rrd.lo 
	mkdir .libs
	 cc -I. -I/root/soft/rrd-1.1.3 -DPHP_ATOM_INC -I/root/soft/rrd-1.1.3/include -I/root/soft/rrd-1.1.3/main -I/root/soft/rrd-1.1.3 -I/usr/local/swan/opt/include/php -I/usr/local/swan/opt/include/php/main -I/usr/local/swan/opt/include/php/TSRM -I/usr/local/swan/opt/include/php/Zend -I/usr/local/swan/opt/include/php/ext -I/usr/local/swan/opt/include/php/ext/date/lib -I/usr/local/swan/opt//include -DHAVE_CONFIG_H -g -O2 -c /root/soft/rrd-1.1.3/rrd.c  -fPIC -DPIC -o .libs/rrd.o
	 /root/soft/rrd-1.1.3/rrd.c: In function ‘zif_rrd_lastupdate’:
	 /root/soft/rrd-1.1.3/rrd.c:250: error: too many arguments to function ‘rrd_lastupdate’
```

这个错误是由于 rrdtool 的接口重构参数导致的，具体的修复方法是修改 rrd.c

```
	// 添加
	#define  HAVE_RRD_LASTUPDATE_R = 1
```
