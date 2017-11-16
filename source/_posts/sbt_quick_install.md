title: SBT 快速入门 ------ 安装
date: 2015-06-02 09:13:16
tags: SBT 
categories: SBT 快速入门
---

创建一个用 SBT 构建的工程大致需要如下几步：

* 安装 SBT 并创建一个启动脚本
* 创建一个简单的项目，以 [Hello World](sbt_quick_hello_world.md) 为例
    * 创建项目目录和项目代码相关文件
    * 配置项目构建定义文件
* 参考[运行 SBT](sbt_quick_running.md)章节学习SBT如何运行
* 参考[配置文件 .sbt](sbt_quick_build_define.md)章节学习更多的 SBT 相关定义

基本上SBT的安装可以归纳为一个 Jar 文件和一个启动脚本，但是依赖于具体的平台，我们提供了几种平台的安装步骤，在此不累赘叙述了。

### Linux 平台安装 SBT

#### 通过通用的包安装

下载 [ZIP][down-zip] 包或 [TGZ][down-tgz] 包解压

#### RPM 和 DEB

* [RPM][down-rpm]包
* [DEB][down-deb]包


> 注意： 请将任何和这两个包相关的问题反馈到[sbt-launcher-package][sbt-launcher]项目 issue

**Gentoo**

In the official tree there is no ebuild for sbt. But there are ebuilds to merge sbt from binaries. To merge sbt from this ebuilds you can do:

```
$ mkdir -p /usr/local/portage && cd /usr/local/portage
$ git clone git://github.com/whiter4bbit/overlays.git
$ echo "PORTDIR_OVERLAY=$PORTDIR_OVERLAY /usr/local/portage/overlays" >> /etc/make.conf
$ emerge sbt-bin
```

> 注意: 有任何和 ebuild 相关的问题请反馈到 [ebuild issue][ebuild]


**手动安装**

参考[手动安装 SBT](install_sbt_manual.html)

[down-zip]:(https://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.zip)
[down-tgz]:(https://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.tgz)
[ebuild]:(https://github.com/whiter4bbit/overlays/issues)
[sbt-launcher]:(https://github.com/sbt/sbt-launcher-package)
[down-rpm]:(https://dl.bintray.com/sbt/rpm/sbt-0.13.6.rpm)
[down-deb]:(https://dl.bintray.com/sbt/debian/sbt-0.13.6.deb)

### Mac 平台安装 SBT

#### 通过第三方的包安装

    注意：第三方的包可能没有提供最新版本，可以将相关任何问题反馈给包相关的维护者

**通过 [Macports](http://macports.org/) 安装**

```
$ port install sbt
```

**通过 [Homebrew](http://mxcl.github.com/homebrew/) 安装**

```
$ brew install sbt
```

#### 通过通用的包安装

下载 [ZIP][down-zip] 包或 [TGZ][down-tgz] 包解压

#### 手动安装

参考[手动安装 SBT](install_sbt_manual.html)

[down-zip]:(https://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.zip)
[down-tgz]:(https://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.tgz)

### Windows 平台安装 SBT


#### 通过 Windows 安装包安装

下载 [msi 安装包][down-msi]并安装

#### 通过通用的包安装

下载 [ZIP][down-zip] 包或 [TGZ][down-tgz] 包解压

#### 手动安装

参考[手动安装 SBT](install_sbt_manual.html)

[down-zip]:(https://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.zip)
[down-tgz]:(https://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.tgz)
[down-msi]:(https://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.msi)

### 手动安装 SBT

#### Unix

将[sbt-launch.jar][sbt-jar]包放到目录 ~/bin中

创建一个运行jar包的脚本 ~/bin/sbt, 脚本内容为：

```
SBT_OPTS="-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M"
java $SBT_OPTS -jar `dirname $0`/sbt-launch.jar "$@"
```

确保脚本有执行权限

```
$ chmod u+x ~/bin/sbt
```

[sbt-jar]:(http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.5/sbt-launch.jar)
