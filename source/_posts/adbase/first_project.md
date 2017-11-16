title: ADBASE 快速入门 ------ 第一个项目
date: 2017-02-08 09:13:16
tags: [ADBASE,C++]
categories: Adbase 文档
---
### 介绍

为了让大家跟好的入门 Adbase 的开发，我们采用一个完整的例子逐步的讲解开发过程。以开发一个多模匹配服务为例

[全部源代码](https://github.com/weiboad/adbase_case/tree/master/pattern)

#### 多模匹配服务

在实际业务开发中可能需要用到一个高性能的匹配服务，用来做关键词过滤等功能。本例中采用 Wu-Manber 多模匹配算法来实现匹配服务，具体的 Wu-Manber 算法实现细节大家没有必要深入研究，感兴趣的可以参考[Wu-Manber](https://memorycn.wordpress.com/2011/11/05/matching_algorithm_-_wu-manber_algorithm_based_on_the_the_suffix_search_of_multi-mode/)，本例子重点是利用这个应用场景来详细的讲解基于 Adbase 开发后端服务

#### 需求

编写一个支持 Http 、Memcache 协议通信的匹配服务，匹配的词典存放到文件中，在启动的时候加载，客户端通过 Http 或者 Memcache 协议给定匹配文本进行匹配计算，最终将匹配结果返回

- 交互数据格式

	- 参数: 
		
	```
	{
		"dict": "parrent_dict_name",
		"contents": [
			"近日俄罗斯两名五岁幼童越园了！两人经过预谋，用小铲子挖洞，逃出幼儿园要去买豪车！两人到了豪车展示厅，但是没钱买…一热心市民后将他们送到了警察局",
			"买枪, 卫星电视安装、卫星电视接收器材、电视锅、卫星锅"
		]
	}
	// dict ：由于该服务支持多个匹配关键词字典，指定匹配的字典
	// contents : 指定要匹配的文本内容
	```

	- 请求返回接口

	```
	{
		"code": 200,
		"exposure_id": "1441789531430499",
		"result": [
			{
				"hit": 5,
				"patterns": [
					"买枪",
					"卫星电视安装",
					"卫星电视接收器材",
					"卫星锅",
					"电视锅"
				]
			},
			{
				"hit": 0,
				"patterns": []
			}
		]
	}

	// 如果匹配到了列出匹配到的关键字和匹配到的个数，如果没有则返回空数组
	```

- Http 接口

	- 接口：/api/pattern
	- 请求方式：POST

- Memcache 接口

	- 使用 get 命令
	- key 为请求参数
	- 最终 get 返回的数据即为请求返回数据


### 需求分析

通过上述需求描述我们需要做的是实现 Wumanber 算法提供匹配计算，并且要实现 HTTP Server、Memcache Server 做网络交互, 在 Adbase 中有 Adbase Seed 基于 Adbase 进一步封装了 Http/Memcache Server 的实现，并且通过 Adbase Seed 生成的骨架代码替我们完成了整个项目构建等等一些列通用的代码。所以我们采用 Adbase 中的 Seed 生成项目骨架代码，然后基于这个骨架代码实现匹配逻辑即可, 大致的项目如图所示：

![匹配服务概况](/image/adbase/adbase_parrent.png "匹配服务")

### Adbase Seed 生成项目骨架代码

为了快速入门第一个项目示例采用 Adbase Seed 生成项目骨架代码，Seed 在使用时仅需要配置一个 adbase.ini 配置文件，运行 `adbase_skeleton` 命令即可。假如该项目名称为 `pattern`，生成骨架代码的步骤如下：

#### 创建项目代码目录

```
mkdir pattern
cd pattern
```

#### 配置 adbase.ini 

在项目根目录中创建 adbase.ini 配置文件，内容如下
```
[project]
; 项目名称
ADINF_PROJECT_NAME=pattern
; 项目描述
ADINF_PROJECT_SUMMARY=Adbase case
; 项目主页
ADINF_PROJECT_URL=https://github.com/weiboad/adbase
; 项目打包维护信息
ADINF_PROJECT_VENDOR=nmred  <nmred_2008@126.com>
ADINF_PROJECT_PACKAGER=nmred  <nmred_2008@126.com>

[module]
; 是否启用生成 adserver 相关代码，如果使用 http/memcache rpc 服务请开启
adserver=yes
; 是否启用生成 timer 相关代码，如果需要定时执行一些操作请开启
timer=no
; 是否启用生成 kafka 相关代码，如果使用 kafka 做消息队列相关操作请开启
kafkac=no
kafkap=no
; 是否启用生成 logging 相关代码，建议开启
logging=yes

[params]
; 对于 timer 模块该参数生效，定时器名称，多个定时器用逗号分隔
timers=
; 对于 adserver 模块该参数生效，http server 的 controller 名称, 多个用逗号分隔
http_controllers=Api
;对于 aims consumer 模块该参数生效，分别是kafka consumer 名称、topic、groupid, 多个用逗号分隔, 三个参数的个数必须一一对应
kafka_consumers=
kafka_consumers_topics=
kafka_consumers_groups=
;对于 aims producer 模块该参数生效，分别是kafka producer 名称、topic, 多个用逗号分隔, 两个参数的个数必须一一对应
kafka_producers=
kafka_producers_topics=

[files]
src/main.cpp=src/@ADINF_PROJECT_NAME@.cpp
rpm/main.spec.in=rpm/@ADINF_PROJECT_NAME@.spec.in

[execs]
cmake.sh=1
build_rpm.in=1
```

在这个配置文件中对代码生成比较重要的配置信息是 project 段和 module 段，project 提供给生成器项目的一些基础信息，module 用来配置生成代码模块，由于本案例中仅仅使用 RPC 服务，所以仅需要选择 adserver 和 logging 模块即可，其他模块将在后续章节详细介绍

#### 运行 adbase_skeleton 生成代码

```
[zhongxiu@bpdev pattern]$ adbase_skeleton
20170220 06:21:26.441379Z 140081539787104 INFO  ./ - Seed.cpp:714
Generate file list:
	./rpm/pattern.spec.in
	./rpm/build_rpm.in
	./src/Timer.hpp
	./src/BootStrap.cpp
	./src/HeadProcessor.cpp
	./src/AdbaseConfig.hpp
	./src/McProcessor.hpp
	./src/pattern.cpp
	./src/Http.hpp
	./src/AdServer.hpp
	./src/McProcessor.cpp
	./src/HeadProcessor.hpp
	./src/AdServer.cpp
	./src/Http/Api.hpp
	./src/Http/Server.cpp
	./src/Http/HttpInterface.hpp
	./src/Http/Server.hpp
	./src/Http/Api.cpp
	./src/Http/HttpInterface.cpp
	./src/Timer.cpp
	./src/BootStrap.hpp
	./src/CMakeLists.txt
	./src/App.hpp
	./src/App.cpp
	./src/Http.cpp
	./src/Version.hpp.in
	./conf/system.ini
	./cmake.sh
	./CMakeLists.txt
```

#### 编译测试

- 生成项目构建配置

```
[zhongxiu@bpdev pattern]$ ./cmake.sh
Start cmake configure.....
编译 Debug 级别 [Debug(D)|Release(R)]: D
cmake -DCMAKE_BUILD_TYPE=Debug -DADINFVERSION= -DGIT_SHA1=a6af14f8 -DGIT_DIRTY=0 -DBUILD_ID=bpdev-1487574668 -DOPVERSION=el6.5 ..
-- The C compiler identification is GNU
-- The CXX compiler identification is GNU
-- Check for working C compiler: /usr/bin/gcc
-- Check for working C compiler: /usr/bin/gcc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
CMake Warning (dev) in CMakeLists.txt:
  No cmake_minimum_required command is present.  A line of code such as

    cmake_minimum_required(VERSION 2.6)

  should be added at the top of the file.  The version specified may be lower
  if you wish to support older CMake versions for this project.  For more
  information run "cmake --help-policy CMP0000".
This warning is for project developers.  Use -Wno-dev to suppress it.

-- Configuring done
-- Generating done
-- Build files have been written to: /usr/home/zhongxiu/code/adbase_case/pattern/build
```

- 编译项目

```
[zhongxiu@bpdev pattern]$ cd build/
[zhongxiu@bpdev build]$ make -j 12
Scanning dependencies of target pattern
[ 18%] [ 27%] [ 27%] [ 36%] [ 45%] [ 54%] [ 63%] [ 72%] [ 81%] Building CXX object bin/CMakeFiles/pattern.dir/pattern.o
Building CXX object bin/CMakeFiles/pattern.dir/BootStrap.o
Building CXX object bin/CMakeFiles/pattern.dir/App.o
Building CXX object bin/CMakeFiles/pattern.dir/AdServer.o
Building CXX object bin/CMakeFiles/pattern.dir/Http.o
Building CXX object bin/CMakeFiles/pattern.dir/Http/HttpInterface.o
Building CXX object bin/CMakeFiles/pattern.dir/Http/Server.o
Building CXX object bin/CMakeFiles/pattern.dir/Http/Api.o
Building CXX object bin/CMakeFiles/pattern.dir/McProcessor.o
[ 90%] [100%] Building CXX object bin/CMakeFiles/pattern.dir/HeadProcessor.o
Building CXX object bin/CMakeFiles/pattern.dir/Timer.o
Linking CXX executable pattern
[100%] Built target pattern
```

- 运行项目

```
[zhongxiu@bpdev build]$ mkdir logs
[zhongxiu@bpdev build]$ ./bin/pattern -c ../conf/system.ini
20170220 15:15:31.170330 140302409378144 TRACE initHttp Init http server, host:0.0.0.0 port:10110 - AdServer.cpp:87
20170220 15:15:31.170470 140302409378144 DEBUG Server Init Http Server. - Server.cpp:49
20170220 15:15:31.170554 140302409378144 DEBUG registerLocation Server Location: /server/status register success. - Server.cpp:245
20170220 15:15:31.170573 140302409378144 DEBUG registerLocation Server Location: /api/index register success. - Server.cpp:245
20170220 15:15:31.170641 140302409378144 DEBUG Acceptor Bind: 0.0.0.0:10111 - Acceptor.cpp:29
20170220 15:15:31.170813 140302409378144 DEBUG start Create worker thread success - Server.cpp:195
20170220 15:15:31.170910 140302409378144 DEBUG start Create worker thread success - Server.cpp:195
20170220 15:15:31.170907 140302398879488 DEBUG threadFunc Start create base event. - Server.cpp:122
20170220 15:15:31.171008 140302388389632 DEBUG threadFunc Start create base event. - Server.cpp:122
20170220 15:15:31.171101 140302398879488 TRACE threadFunc Worker start. - Server.cpp:136
20170220 15:15:31.171117 140302388389632 TRACE threadFunc Worker start. - Server.cpp:136
20170220 15:15:31.171136 140302388389632 DEBUG threadFunc Start create new evhttp. - Server.cpp:138
20170220 15:15:31.171139 140302377899776 DEBUG threadFunc Start create base event. - Server.cpp:122
20170220 15:15:31.171142 140302409378144 DEBUG start Create worker thread success - Server.cpp:195
20170220 15:15:31.171151 140302388389632 DEBUG threadFunc Start set evhttp onRequest callback. - Server.cpp:145
20170220 15:15:31.171175 140302388389632 DEBUG threadFunc Start bind evhttp socket, host:0.0.0.0 port:10110 - Server.cpp:151
20170220 15:15:31.171124 140302398879488 DEBUG threadFunc Start create new evhttp. - Server.cpp:138
20170220 15:15:31.171198 140302398879488 DEBUG threadFunc Start set evhttp onRequest callback. - Server.cpp:145
20170220 15:15:31.171176 140302377899776 TRACE threadFunc Worker start. - Server.cpp:136
20170220 15:15:31.171229 140302377899776 DEBUG threadFunc Start create new evhttp. - Server.cpp:138
20170220 15:15:31.171250 140302377899776 DEBUG threadFunc Start set evhttp onRequest callback. - Server.cpp:145
20170220 15:15:31.171321 140302398879488 DEBUG threadFunc Start set accecp evhttp socket. - Server.cpp:166
20170220 15:15:31.171347 140302409378144 DEBUG start Create worker thread success - Server.cpp:195
20170220 15:15:31.171373 140302377899776 DEBUG threadFunc Start set accecp evhttp socket. - Server.cpp:166
20170220 15:15:31.171405 140302367409920 DEBUG threadFunc Start create base event. - Server.cpp:122
20170220 15:15:31.171491 140302367409920 TRACE threadFunc Worker start. - Server.cpp:136
20170220 15:15:31.171511 140302367409920 DEBUG threadFunc Start create new evhttp. - Server.cpp:138
20170220 15:15:31.171521 140302367409920 DEBUG threadFunc Start set evhttp onRequest callback. - Server.cpp:145
20170220 15:15:31.171533 140302367409920 DEBUG threadFunc Start set accecp evhttp socket. - Server.cpp:166
20170220 15:15:33.183004 140302409378144 DEBUG start Create all worker thread, total 4 thread. - Server.cpp:202
20170220 15:15:33.183114 140302409378144 DEBUG start Create worker thread success - TcpServer.cpp:36
20170220 15:15:33.183192 140302409378144 DEBUG start Create worker thread success - TcpServer.cpp:36
20170220 15:15:33.183289 140302409378144 DEBUG start Create worker thread success - TcpServer.cpp:36
20170220 15:15:33.183324 140302234384128 TRACE start Worker start. - TcpWorker.cpp:50
20170220 15:15:33.183422 140302409378144 DEBUG start Create worker thread success - TcpServer.cpp:36
20170220 15:15:33.183440 140301884716800 TRACE start Worker start. - TcpWorker.cpp:50
20170220 15:15:33.183325 140302244873984 TRACE start Worker start. - TcpWorker.cpp:50
20170220 15:15:33.183528 140301874226944 TRACE start Worker start. - TcpWorker.cpp:50
```

- 测试 Http 接口
访问 http://127.0.0.1:10010/server-status 结果如图所示

![http status](/image/adbase/adbase_http_status.png)

- 测试 memcache server 

```
nmred@ubuntu12:~$ telnet 10.13.4.162 10111
Trying 10.13.4.162...
Connected to 10.13.4.162.
Escape character is '^]'.
version
VERSION 0.1.0
get test
VALUE test 0 4
test
END

```

如果上述测试通过恭喜你完成了 adbase 第一个项目的开发，下面将要做的就是将核心业务逻辑增加到项目中即可

走到这一步可能心里即窃喜又懵逼，窃喜的是很多代码自动完成了，仅仅需要写核心业务逻辑即可。懵逼的是生成这么一坨不知从何入手写业务逻辑，在正式开发前先介绍一下生成的代码的目录结构及其作用。

### 骨架代码

如下是是通过 seed 工具生成的代码骨架

```
.
├── adbase.ini
├── CMakeLists.txt 	项目构建 cmake 配置文件
├── cmake.sh
├── conf  项目配置文件
│   └── system.ini
├── rpm   项目打包 rpm 相关脚本配置
│   ├── build_rpm.in
│   └── pattern.spec.in
└── src   项目代码
    ├── AdbaseConfig.hpp	Adbase 全局配置
    ├── AdServer.cpp		AdServer 代码实现，包含 http memcache adhead server 实现
    ├── AdServer.hpp
    ├── App.cpp				App 项目入口，main 函数最终调用 bootstrap 后调用 app->run 执行
    ├── App.hpp
    ├── BootStrap.cpp	    项目引导初始化
    ├── BootStrap.hpp
    ├── CMakeLists.txt		cmake 配置文件
    ├── HeadProcessor.cpp
    ├── HeadProcessor.hpp
    ├── Http				Http 接口实现目录，如果扩展 http 接口请在此目录修改
    │   ├── Api.cpp			该项目配置生成器自动生成 /api/xxx 接口的 controller
    │   ├── Api.hpp
    │   ├── HttpInterface.cpp Http 接口实现基类
    │   ├── HttpInterface.hpp
    │   ├── Server.cpp		Seed 自动生成的用来实时查询整个项目的运行状态信息
    │   └── Server.hpp
    ├── Http.cpp			Http Server 实现
    ├── Http.hpp
    ├── McProcessor.cpp     Memcache Server 回调方法实现，如果实现 memcache 具体命令请修改该文件实现
    ├── McProcessor.hpp
    ├── pattern.cpp			项目 main 入口
    ├── Timer.cpp			定时器实现
    ├── Timer.hpp
    └── Version.hpp.in		自动管理版本
```

#### 骨架代码运行流程图

![流程图](/image/adbase/adbase_seed.png)

如图所示本图按照不同的颜色将线程归类，主线程为红色的，日志处理线程为绿色、AdServer线程为紫色、用户自定义线程为黑色. 骨架代码在启动的时候会执行 bootstrap 初始化、注册信号回调、bootstrap run 三个过程，在 bootstrap run 中使用 evenloop 调用主线程进行工作。

- bootstrap init

	在执行 bootstrap init 这个阶段会做以下事情：

	- 将解析配置并且将配置对象 `AdbaseConfig` 保存在 BootStrap 中，贯穿项目整个生命周期
	- 初始化 daemon 守护进程
	- 初始化日志工具，创建日志异步处理线程

- 注册信号回调
	
	注册信号处理回调，骨架代码会处理两类型的信息，分别是终止类型的和 SIGUSR1 信号

	- 终止类型：调用 bootstrap stop 回收资源结束进程
	- SIGUSR1: 重新加载配置文件，开发者可以在 `App->reload` 方法中自定义在重载配置后执行的操作

- bootstrap run

	这个步骤是骨架代码核心的部分，也是在下一步实际开发中需要理解执行过程的一步，具体执行步骤如下：

	- 度量工具库初始化，该模块是用来统计项目运行时的一些状态参数
	- `App->run` 这个方法初始化情况下是空的，需要用户自定义，类似于 main 函数的功能，用户可以在这个方法中初始化线程，或者初始化内存堆变量等
	- 设置 AdServer 上下文指针，这个过程调用 `App->setAdServerContext` 方法，用户可以在该方法中设置传递给 Server 线程的变量指针，用来关联 RPC 服务数据源
	- 初始化启动 AdServer, 该过程是通过配置文件，默认骨架代码包含 Http/Memcache/Adhead Server的实现，可以根据需求在配置文件中配置要启动的 Server
	- 初始化定时器, 如果需要定义定时器，将在这个过程中初始化


#### 骨架代码配置

### 开发项目

#### 项目配置

由于业务需求是支持多个关键字字典的匹配服务，所以我们要允许项目启动的时候通过配置文件配置关键词字典名称和对应的字典路劲，这样面临的问题是如何在 Adbase Seed 骨架代码上增加配置解析和配置读取以及配置定义

###### 配置定义

在骨架代码中增加一个全局的配置项，需要在 ini 配置文件增加配置项和在 AdbaseConfig 这个结构体总增加定义

修改 conf/system.ini 文件增加匹配服务本身的配置项，用来配置匹配服务支持的字典

```
[pattern]
dicta=./dicta.txt
dictb=./dictb.txt
```
	
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/conf/system.ini#L46-L48)

修改 src/AdbaseConfig.hpp 在 `AdbaseConfig` 这个结构体中增加属性 patternConfig 用来存储匹配关键字字典的映射关系

```c
std::unordered_map<std::string, std::string> patternConfig;
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/AdbaseConfig.hpp#L70)

###### 配置解析

在定义好配置项后下一步是通过解析 ini 配置文件，将配置文件中的配置项和 `AdbaseConfig` 这个全局的配置变量中的配置项关联起来，这块在骨架代码中启动的时候会将 Ini 配置文件解析，具体的 `AdbaseConfig` 关联是通过回调 `App->loadConfig` 这个方法实现的，所以我们要解析一个配置到全局配置中，需要在这个方法中实现，具体的操作如下：

修改后的 `App->loadCondig` 代码如下

```c
void App::loadConfig(adbase::IniConfig& config) {
    // 解析词库配置
    std::vector<std::string> patternKeys  = config.options("pattern");
    std::unordered_map<std::string, std::string> patternConfig;
    for (auto & t : patternKeys) {
        patternConfig[t] = config.getOption("pattern", t);
    }
    _configure->patternConfig = patternConfig;
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/App.cpp#L82-L90)

###### 配置读取

在解析了配置后，需要在项目中用到配置对于 `App` 这个对象中提供一个 `_configure` 指针，开发者可以将该指针进行传递来读取配置，对于该项目我们将在下面的匹配服务核心逻辑实现时会用到

#### 匹配服务核心逻辑实现

匹配服务核心逻辑分为两部分，一部分是 Wumanber 算法的实现，一部分是用来管理 Wumanber 对象的。如图所示

![核心匹配逻辑](/image/adbase/adbase_pattern_wumanber.png)

多个 `Wumanber` 实例对应多个匹配关键字字典，对于后面的 RPC 调用直接和 Pattern Manager 这个对象交互，分别有两个交互方法，一个是在系统启动的时候加载关键词字典并初始化 Wumanber 的 `Init` 方法， 一个是提供匹配的检索方法`Search`


###### Wumanber 算法实现

在 src 中创建目录 `app` , 并且创建对应的 `Wumanber.cpp` 和 `Wumanber.hpp`

```cpp
// src/app/Wumanber.hpp

#ifndef PATTERN_WUMANBER_HPP
#define PATTERN_WUMANBER_HPP
#include <stdint.h>

#include <vector>
#include <string>
#include <set>

namespace app {

typedef std::set<std::string> ResultSetType;
typedef std::pair<unsigned int, int> PrefixIdPairType;
typedef std::vector<PrefixIdPairType> PrefixTableType;

class WuManber {
    public:
        WuManber();
        ~WuManber();

        /**
         * init Function
         * 
         * @param patterns      pattern list to be matched
         */
        bool init(const std::vector<std::string>& patterns);

        /** 
         * @param text           raw text
         * @param textLength     length of text
         * @param res            string set containing matched patterns
         * 
         * @return value 0: no pattern matchs, n: n patterns matched(n>0)
         */
        int search( const char* text, const int textLength, ResultSetType& res);

        /**
         * @param  str           raw text
         * @param  res           string set containing matched patterns
         *
         * @return value 0: no pattern matchs, n: n patterns matched(n>0)
         */
         int search(const std::string& str, ResultSetType& res);

        /**
         * @brief search text 
         *
         * @return value 0: no pattern matchs, n: n patterns matched(n>0)
         */
        int search(const char* text, const int textLength);

        /**
         * @brief search text
         *
         * @return value 0: no pattern matchs, n: n patterns matched(n>0)
         */
        int search(const std::string& str);

    private:
        // minmum length of patterns
        int32_t mMin;
        // SHIFT table
        std::vector<int32_t> mShiftTable;
        // a combination of HASH and PREFIX table 
        std::vector<PrefixTableType> mHashTable;
        // patterns
        std::vector<std::string> mPatterns;
        // size of SHIFT and HASH table
        int32_t mTableSize;
        // size of block
        int32_t mBlock;
};
}

#endif
```

[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/app/WuManber.hpp)

```cpp
// src/app/Wumanber.cpp
#include <cmath>
#include <iostream>
#include <adbase/Logging.h>
#include "WuManber.hpp"

using namespace std;

namespace app {
// {{{ hashCode()

/** 
 * @brief   String hash function.
 * 
 * @param str   the string needed to be hashed
 * @param len   length of the substr should be hashed
 * 
 * @return hash code
 */
unsigned int hashCode(const char* str, int len) {
    unsigned int hash = 0;
    while (*str && len>0) {
        hash = (*str++) + (hash << 6) + (hash << 16) - hash;
        --len;
    }
    return (hash & 0x7FFFFFFF);
}

// }}}
// {{{ WuManber::WuManber()

/** 
 * @brief constructor 
 */
WuManber::WuManber() : mMin(0), mTableSize(0), mBlock(3) {
    //VOID
}

// }}}
// {{{ WuManber::init()

/**
 * @brief init
 */
bool WuManber::init(const vector<string>& patterns) {
    int patternSize = patterns.size();

    //check if no pattern specified
    if (patternSize == 0) {
		LOG_ERROR << "wumanber init failed because no pattern specified.";
        return false;
    }
    
    //caculate the minmum pattern length
    mMin = patterns[0].length();
    int32_t lenPattern = 0;
    for (int i = 0; i < patternSize; ++i) {
        lenPattern = patterns[i].length();
        if (lenPattern < mMin) {
            mMin = lenPattern;
        }
    }

    //check if mBlock larger than mMin
    if (mBlock > mMin) {
		LOG_WARN << "mBlock is larger than minmum pattern length, reset mBlock to minmum, but it will seriously affect the effiency.";
        mBlock = mMin;
    }

    //choose a suitable mTableSize for SHIFT, HASH table
    int32_t primes[6] = {1003, 10007, 100003, 1000003, 10000019, 100000007};
    vector<int32_t> primeList(&primes[0], &primes[6]);

    int32_t threshold = 10 * mMin;
    for (size_t i = 0; i < primeList.size(); ++i) {
        if (primeList[i] > patternSize && primeList[i] / patternSize > threshold) {
            mTableSize = primeList[i];
            break;
        }
    }
    
    //if size of patternList is huge.
    if (0 == mTableSize) {
		LOG_WARN << "amount of pattern is very large, will cost a great amount of memory.";
        mTableSize = primeList[5];
    }

    //construct ShiftTable and HashTable, and set default value for SHIFT table
    mPatterns = patterns;
    mHashTable.resize(mTableSize);
    // default value is m-mBlock+1 for shift
    int32_t defaultValue = mMin - mBlock + 1;
    mShiftTable.resize(mTableSize, defaultValue);

    //loop through patterns
    for (int id = 0; id < patternSize; ++id) { 
        // loop through each pattern from right to left
        for (int index = mMin; index >= mBlock; --index) {
            unsigned int hash = hashCode(patterns[id].c_str() + index - mBlock, mBlock) % mTableSize;
            if (mShiftTable[hash] > (mMin - index)) {
                mShiftTable[hash]  = mMin - index;
            }
            if (index == mMin) {
                unsigned int prefixHash = hashCode(patterns[id].c_str(), mBlock);
                mHashTable[hash].push_back(make_pair(prefixHash, id));
            }
        }
    }

    return true;
}

// }}}
// {{{ WuManber::~WuManber()

/** 
 * @brief destructor
 */
WuManber::~WuManber() {
    //VOID
}

// }}}
// {{{ WuManber::search()

/**
 * @public
 * @brief search multiple pattern in text at one time
 */
int WuManber::search(const char* text, const int textLength, ResultSetType& res) {
    //hit count: value to be returned
    int hits = 0;
    int32_t index = mMin - 1; // start off by matching end of largest common pattern
    
    int32_t blockMaxIndex = mBlock - 1;
    int32_t windowMaxIndex = mMin - 1;
    
    while (index < textLength) {
        unsigned int blockHash = hashCode(text + index - blockMaxIndex, mBlock);
        blockHash = blockHash % mTableSize;
        int shift = mShiftTable[blockHash];
        if (shift > 0) {
            index += shift;
        } else {  
            // we have a potential match when shift is 0
            unsigned int prefixHash = hashCode(text + index - windowMaxIndex, mBlock);
            PrefixTableType &element = mHashTable[blockHash];
            PrefixTableType::iterator iter = element.begin();

            while (element.end() != iter) {
                if (prefixHash == iter->first) {   
                    // since prefindex matches, compare target substring with pattern
                    // we know first two characters already match
                    const char* indexTarget = text + index - windowMaxIndex;    //+mBlock
                    const char* indexPattern = mPatterns[iter->second].c_str(); //+mBlock
                    
                    while (('\0' != *indexTarget) && ('\0' != *indexPattern)) {
                        // match until we reach end of either string
                        if (*indexTarget == *indexPattern) {
                            // match against chosen case sensitivity
                            ++indexTarget;
                            ++indexPattern;
                        } else {
                            break;
						}
                    }
                    // match succeed since we reach the end of the pattern.
                    if ('\0' == *indexPattern) {
                        res.insert(string(mPatterns[iter->second]));
                        ++hits;
                    }
                } //end if
                ++iter;
            } //end while
            ++index;
        } //end else
    } //end while

    return hits;
}

// }}}
// {{{ WuManber::search()

/**
 * search
 */
int WuManber::search(const string& str, ResultSetType& res) {
    return search(str.c_str(), str.length(), res);
}

// }}}
// {{{ WuManber::search()

/**
 * search
 */
int WuManber::search(const char* text, const int textLength) {
    //hit count: value to be returned
    int hits = 0;
    int index = mMin - 1; // start off by matching end of largest common pattern

    uint32_t blockMaxIndex = mBlock - 1;
    uint32_t windowMaxIndex = mMin - 1;

    while (index < textLength) {
        unsigned int blockHash = hashCode(text + index - blockMaxIndex, mBlock);
        blockHash = blockHash % mTableSize;
        int shift = mShiftTable[blockHash];
        if (shift > 0) {
            index += shift;
        } else {
            // we have a potential match when shift is 0
            unsigned int prefixHash = hashCode(text + index - windowMaxIndex, mBlock);
            //prefixHash = prefixHash % mTableSize;
            PrefixTableType &element = mHashTable[blockHash];
            PrefixTableType::iterator iter = element.begin();

            while (element.end() != iter) {
                if (prefixHash == iter->first) {
                    // since prefindex matches, compare target substring with pattern
                    // we know first two characters already match
                    const char* indexTarget = text + index - windowMaxIndex;    //+mBlock
                    const char* indexPattern = mPatterns[iter->second].c_str();  //+mBlock

                    while (('\0' != *indexTarget) && ('\0' != *indexPattern)) {
                        // match until we reach end of either string
                        if (*indexTarget == *indexPattern) {
                            // match against chosen case sensitivity
                            ++indexTarget;
                            ++indexPattern;
                        } else {
                            break;
						}
                    }
                    // match succeed since we reach the end of the pattern.
                    if ('\0' == *indexPattern) {
                        ++hits;
                    }
                }//end if
                ++iter;
            }//end while
            ++index;
        }//end else
    }//end while

    return hits;
}

// }}}
// {{{ WuManber::search()

int WuManber::search(const string& str) {
    return search(str.c_str(), str.length());
}

// }}}
}
```

[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/app/WuManber.cpp)

###### 实现 Wumanber 管理类

用来管理多个 Wumanber 实例，读取多个关键字字典并初始化对应 Wumanber 实现, 创建对应 `PatternManager.hpp` 和 `PatternManager.cpp`

```cpp
// src/app/PatternManager.hpp
fndef PATTERN_PATTERNMANAGER_HPP_
#define PATTERN_PATTERNMANAGER_HPP_

#include <unordered_map>
#include "AdbaseConfig.hpp"
#include "WuManber.hpp"
#include <fstream>
#include <set>

namespace app {

typedef std::unordered_map<std::string, std::string> PatternConfig;
typedef std::unordered_map<std::string, WuManber*> WuManberMap;
class PatternManager {
public:
    PatternManager(AdbaseConfig* config);
    void init();
    int search(std::string& type, std::string& text, std::set<std::string>& patternResult);
    int search(std::string& type, std::string& text);
    ~PatternManager();

private:
    AdbaseConfig* _config;
    WuManberMap _wuManbers;
};

}

#endif
```

[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/app/PatternManager.hpp)


```cpp
// src/app/PatternManager.cpp
#include "PatternManager.hpp"
#include <adbase/Logging.hpp>

namespace app {
// {{{ PatternManager::PatternManager()

PatternManager::PatternManager(AdbaseConfig* config) :
    _config(config) {
}

// }}}
// {{{ PatternManager::~PatternManager()

PatternManager::~PatternManager() {
    if (!_wuManbers.size()) {
        return;
    }

    for (auto & t: _wuManbers) {
        if (t.second != nullptr) {
            delete t.second;
            t.second = nullptr;
        }
    }
}

// }}}
// {{{ void PatternManager::init()

void PatternManager::init() {
    if (!_config->patternConfig.size()) {
        LOG_FATAL << "Must has pattern text config.";
    }

    for (auto &t : _config->patternConfig) {
        std::vector<std::string> patterns;
        std::ifstream pat(t.second);
        if (!pat.good() || !pat.is_open()) {
            LOG_FATAL << "Pattern type :" << t.first << " config file: " << t.second << " is not good.";
        }
        std::string str;
        while (pat>> str) {
            patterns.push_back(str);
        }

        WuManber* wumanber = new WuManber;
        wumanber->init(patterns);
        _wuManbers[t.first] = wumanber; 
        LOG_INFO << "Init dict " << t.first << " complete.";
    }
}

// }}}
// {{{ int PatternManager::search() 

int PatternManager::search(std::string& type, std::string& text, std::set<std::string>& patternResult) {
    if (_wuManbers.find(type) == _wuManbers.end()) {
        LOG_INFO << "Search pattern type `" << type << "` not exists."; 
        return -1;
    }   

    WuManber* wumanber = _wuManbers[type];
    wumanber->search(text, patternResult);
    return static_cast<int>(patternResult.size());
}

// }}}
// {{{ int PatternManager::search() 

int PatternManager::search(std::string& type, std::string& text) {
    if (_wuManbers.find(type) == _wuManbers.end()) {
        LOG_INFO << "Search pattern type `" << type << "` not exists."; 
        return -1;
    }   

    WuManber* wumanber = _wuManbers[type];
    return wumanber->search(text);
}

// }}}
}
```

[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/app/PatternManager.cpp)

###### 配置构建文件

修改 CMake 构建配置文件 `src/CMakeLists.txt`，增加上述两个 cpp 源文件

```
app/Wumanber.cpp
app/PatternManager.cpp
```

[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/CMakeLists.txt#L34-L35)


#### App 对象增加 PatternManager 属性

由于 PatternManager 对象实例在整个项目的生命周期都存在，所以我们将 PatternManager 对象保存在 App 这个对象中，在后面的 RPC 调用时通过 AdServer 上下文的方式将 PatternManager 的指针传递过去即可调用

###### 创建对象

App.hpp 中引入 PatternManager.hpp

```cpp
#include "app/PatternManager.hpp"
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/App.hpp#L6)

在 App.hpp 中增加 PatternManager 指针属性

```cpp
app::PatternManager* _patternManager;
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/App.hpp#L23)

在 `App->run` 中创建 PatternManager 对象

```
void App::run() {
    _patternManager = new app::PatternManager(_configure);
    _patternManager->init();
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/App.cpp#L44-L47)

在 `App->stop` 中销毁 PatternManager 对象

```
void App::stop() {
    if (_patternManager != nullptr) {
        delete _patternManager;
        _patternManager = nullptr;
    }
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/App.cpp#L58-L63)

###### 设置 Adserver 上下文

设置 Adserver 上下文指针供 Adserver 调用

修改 AdbaseConfig.cpp 中 adserverContext 这个结构体，在该结构体中增加一个属性 `patternManager`

```cpp
app::PatternManager* patternManager;
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/AdbaseConfig.hpp#L83)


为了防止依赖，我们采用前置申明的方式声明 `app::PatternManager`

```cpp
namespace app {
	class PatternManager;
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/AdbaseConfig.hpp#L74-L76)

修改 `App::setAdServerContext` 方法

```cpp
void App::setAdServerContext(AdServerContext* context) {
	context->app = this;
	context->patternManager = _patternManager;
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/App.cpp#L68-L71)

这样后面 AdServer 中通过使用 `context->patternManager` 的方式就可以引用匹配管理对象实例了

#### 引入 Json 库

首先由于接口交互都是 Json 格式所以我们需要引入 

```shell
git submodule add https://github.com/miloyip/rapidjson.git pattern/src/thirdparty/rapidjson
```

修改项目构建配置文件 `src/CMakeLists.txt`, 增加如下配置

```
INCLUDE_DIRECTORIES(./thirdparty/rapidjson/include)
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/CMakeLists.txt#L3)

将 rapidjson 下载到 `src/thirdparty/rapidjson` 目录中, 在 `src/app` 中创建 `Json.hpp` 引入 json 头文件，后面再使用json库的时候直接引用即可

```cpp
// src/app/Json.hpp
#ifndef PATTERN_JSON_HPP_
#define PATTERN_JSON_HPP_

#pragma GCC diagnostic ignored "-Wconversion"
#pragma GCC diagnostic ignored "-Wold-style-cast"
#include "rapidjson/document.h"
#include "rapidjson/error/en.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#pragma GCC diagnostic warning "-Wconversion"
#pragma GCC diagnostic warning "-Wold-style-cast"

#endif
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/app/Json.hpp)

#### 开发 HTTP 接口

到目前为止我们的匹配服务的核心逻辑已经实现，暴露出来一个方法 `search` 可以用来匹配, 通过设置上面设置 Adserver 的上下文指针 `PatternManager*` 来调用 search 方法

在 `Http/Api.hpp` 和 `Http/Api.cpp` 增加接口方法 `pattern` 的声明和实现

```cpp
void pattern(adbase::http::Request* request, adbase::http::Response* response, void*);
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/Http/Api.hpp#L13)

###### 实现接口逻辑

```cpp
void Api::pattern(adbase::http::Request* request, adbase::http::Response* response, void*) {
    std::string data = request->getPostData();
    rapidjson::Document documentData;
    documentData.Parse(data.c_str());
    if (documentData.HasParseError()) {
        LOG_ERROR << rapidjson::GetParseError_En(documentData.GetParseError());
	    responseJson(response, "", 10000, rapidjson::GetParseError_En(documentData.GetParseError()), true);
        return;
    }

    if (!documentData.IsObject()) {
        std::string error = "pattern format is invalid.";
        LOG_ERROR << error;
	    responseJson(response, "", 10000, error, true);
        return;
    }

    if (!documentData.HasMember("dict") || !documentData.HasMember("contents")) {
        std::string error = "pattern format is invalid.";
        LOG_ERROR << error;
	    responseJson(response, "", 10000, error, true);
        return;
    }

    rapidjson::Value& contents = documentData["contents"];
    if (!contents.IsArray() || !static_cast<uint32_t>(contents.Size())) {
        std::string error = " contents not is array or empty.";
        LOG_ERROR << error;
	    responseJson(response, "", 10000, error, true);
        return;
    }

    std::string patternType = documentData["dict"].GetString();

    rapidjson::Document document;
    rapidjson::Document::AllocatorType& allocator = document.GetAllocator();
    rapidjson::Value result(rapidjson::kArrayType);
    for (int i = 0; i < static_cast<int>(contents.Size()); i++) {
        if (!contents[i].IsString()) {
            continue;
        }

        rapidjson::Value item(rapidjson::kObjectType);
        std::set<std::string> patternResult;
        std::string text = std::string(contents[i].GetString());
        LOG_INFO << "Pattern type: `" << patternType << "` text: " << text;
        int hit = _context->patternManager->search(patternType, text, patternResult);

        rapidjson::Value patterns(rapidjson::kArrayType);
        for (auto &t : patternResult) {
            rapidjson::Value messageValue;
            messageValue.SetString(t.c_str(), static_cast<unsigned int>(t.size()), allocator);
            patterns.PushBack(messageValue, allocator);
        }
        item.AddMember("hit", hit, allocator);
        item.AddMember("patterns", patterns, allocator);
        result.PushBack(item, allocator);
    }

    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    result.Accept(writer);

	responseJson(response, buffer.GetString(), 0, "");
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/Http/Api.cpp#L33-L97)

###### 注册接口

在给某个 controller 增加接口时需要在`registerLocation` 方法中使用 宏 `ADSERVER_HTTP_ADD_API` 注册

```cpp
void Api::registerLocation(adbase::http::Server* http) {
	ADSERVER_HTTP_ADD_API(http, Api, index)
	ADSERVER_HTTP_ADD_API(http, Api, pattern)
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/Http/Api.cpp#L19)

#### 实现 Memcache get

对于实现 Memcache 协议 get 比较简单，将业务逻辑写在 McProcessor 中的get 方法中即可

```cpp
adbase::mc::ProtocolBinaryResponseStatus McProcessor::get(const void* key,
			uint16_t keylen,
			adbase::Buffer *data) {
	std::string keyData(static_cast<const char*>(key), static_cast<size_t>(keylen));
    rapidjson::Document documentData;

    // base64 decode
    char decodeData[static_cast<size_t>(keylen)];
    memset(decodeData, 0, static_cast<size_t>(keylen));
    int length = 0;
    adbase::base64Decode(decodeData, &length, keyData);

    documentData.Parse(decodeData);
    if (documentData.HasParseError()) {
        return adbase::mc::PROTOCOL_BINARY_RESPONSE_KEY_ENOENT;
    }

    if (!documentData.IsObject()) {
        std::string error = "pattern format is invalid.";
        LOG_ERROR << error;
        return adbase::mc::PROTOCOL_BINARY_RESPONSE_KEY_ENOENT;
    }

    if (!documentData.HasMember("dict") || !documentData.HasMember("contents")) {
        std::string error = "pattern format is invalid.";
        LOG_ERROR << error;
        return adbase::mc::PROTOCOL_BINARY_RESPONSE_KEY_ENOENT;
    }

    rapidjson::Value& contents = documentData["contents"];
    if (!contents.IsArray() || !static_cast<uint32_t>(contents.Size())) {
        std::string error = " contents not is array or empty.";
        LOG_ERROR << error;
        return adbase::mc::PROTOCOL_BINARY_RESPONSE_KEY_ENOENT;
    }

    std::string patternType = documentData["dict"].GetString();

    rapidjson::Document document;
    rapidjson::Document::AllocatorType& allocator = document.GetAllocator();
    rapidjson::Value result(rapidjson::kArrayType);
    for (int i = 0; i < static_cast<int>(contents.Size()); i++) {
        if (!contents[i].IsString()) {
            continue;
        }

        rapidjson::Value item(rapidjson::kObjectType);
        std::set<std::string> patternResult;
        std::string text = std::string(contents[i].GetString());
        LOG_INFO << "Pattern type: `" << patternType << "` text: " << text;
        int hit = _context->patternManager->search(patternType, text, patternResult);

        rapidjson::Value patterns(rapidjson::kArrayType);
        for (auto &t : patternResult) {
            rapidjson::Value messageValue;
            messageValue.SetString(t.c_str(), static_cast<unsigned int>(t.size()), allocator);
            patterns.PushBack(messageValue, allocator);
        }
        item.AddMember("hit", hit, allocator);
        item.AddMember("patterns", patterns, allocator);
        result.PushBack(item, allocator);
    }

    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    result.Accept(writer);

	data->append(static_cast<const char*>(buffer.GetString()), static_cast<size_t>(buffer.GetSize()));
	return adbase::mc::PROTOCOL_BINARY_RESPONSE_SUCCESS;
}
```
[GITHUB代码段](https://github.com/weiboad/adbase_case/blob/master/pattern/src/McProcessor.cpp#L102-L171)


#### 结束

到目前为止使用 Adbase 开发的第一个项目就开发完成了，可以编译测试了


### 项目部署
