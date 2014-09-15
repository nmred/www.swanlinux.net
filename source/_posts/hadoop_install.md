title:  Hadoop 2.x 集群安装 
date: 2014-09-14 13:02:16
tags: hadoop 
categories: Hadoop 
---

### 安装介绍

该集群安装6台机器，利用 DNS 服务做主机名解析， NFS 做免密码共享

机器部署情况：

```
    h1 192.168.1.112  (安装DNS服务器，NFS服务器， Hadoop)
    h2 192.168.1.113 
    h3 192.168.1.114
    h4 192.168.1.115
    h5 192.168.1.116
    h6 192.168.1.117
```

### 安装前环境配置

#### DNS 服务器配置

具体安装过程参考 : [Linux系统配置DNS主从及缓存服务器][dns-install] 这里只介绍配置过程

- 修改 /etc/named.conf

```
options {
    // 将 127.0.0.1 修改为 any
    listen-on port 53 { any; };
    listen-on-v6 port 53 { ::1; };
    directory   "/var/named";
    dump-file   "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
    // 将 127.0.0.1 修改为 any
    allow-query     { any; };
    recursion yes;

    dnssec-enable yes;
    dnssec-validation yes;
    dnssec-lookaside auto;

    /* Path to ISC DLV key */
    bindkeys-file "/etc/named.iscdlv.key";

    managed-keys-directory "/var/named/dynamic";
};
```

- 修改 /etc/named.rfc1912.zones 文件

在文件下面添加 正向解析和反向解析的配置

```
zone "hadoop.com"{
        type master;
        file "hadoop.com.z";
        allow-update { none; };
};

zone "1.168.192.in-addr.arpa"{
        type master;
        file "hadoop.com.f";
        allow-update { none; };
};
```

- 配置域名正向解析配置文件

配置文件 /var/named/chroot/var/named/hadoop.com.z

```
$TTL 1D
@   IN SOA  h1.hadoop.com. grid.h1.hadoop.com. (
                    0   ; serial
                    1D  ; refresh
                    1H  ; retry
                    1W  ; expire
                    3H )    ; minimum
@   IN  NS  h1.hadoop.com.
h1.hadoop.com.  IN  A   192.168.1.112
h2.hadoop.com.  IN  A   192.168.1.113
h3.hadoop.com.  IN  A   192.168.1.114
h4.hadoop.com.  IN  A   192.168.1.115
h5.hadoop.com.  IN  A   192.168.1.116
h6.hadoop.com.  IN  A   192.168.1.117
```

- 配置域名反向解析配置文件

配置文件 /var/named/chroot/var/named/hadoop.com.f

```
$TTL 1D
@   IN SOA  h1.hadoop.com. grid.h1.hadoop.com. (
                    0   ; serial
                    1D  ; refresh
                    1H  ; retry
                    1W  ; expire
                    3H )    ; minimum
@   IN  NS  h1.hadoop.com.
112   IN  PTR h1.hadoop.com.
113   IN  PTR h2.hadoop.com.
114   IN  PTR h3.hadoop.com.
115   IN  PTR h4.hadoop.com.
116   IN  PTR h5.hadoop.com.
117   IN  PTR h6.hadoop.com.
```

- 修改好重启 named 服务

```
service named restart
chkconfig --add named
chkconfig named on
```

- 测试 DNS 服务

```
[root@h1 ~]# nslookup 
> h1.hadoop.com
Server:     192.168.1.112
Address:    192.168.1.112#53
```

#### NFS 配置及免密码配置

- NFS 安装

由于系统是 Centos 6.5 和 5.x 的区别是 portmap 在 6.x 中对应的是 rpcbind ，在安装 NFS 中需要安装 rpcbind, 在挂在 nfs服务的节点中需要安装 nfs-utils , rpcbind

除此之外参考 [Linux 系统中文件共享之 NFS][nfs-install]

- NFS 共享目录配置

将 /data 目录作为共享目录

```
vim /etc/exports

添加
/data *(sync,rw,no_root_squash)

```

- NFS 目录挂载

所有的客户端节点将统一挂载到 /home/nmred/nfs_share/ 目录

```
mount -t nfs h1.hadoop.com:/data /home/nmred/nfs_share/
```

修改 /etc/fstab

```
添加 (让服务器重启时自动挂载)
h1.hadoop.com:/data     /home/nmred/nfs_share   nfs     defaults        1 1
```

- 免密码配置

**注意：** Hadoop 必须在运行用户可以免密码 ssh 登陆节点机器时才可以正常运行，所以需要对集群 nmred 用户需要做免密码登陆处理

生成公钥：利用 ssh-keygen 生成

将所有节点的 公钥写入到 /home/nmred/nfs_share/authorized_keys 文件中共享

```
[root@h2 ~]# cat ~/.ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA37St4CEP7G5ghLF0oschDvwoa9A/t3Wa8ssK7xFKUTTkNsELRtvd/RxwkMjFQB54hJPTFSU12gN3VzybeHD+SRx4a77sIqH8O37plYWgQWia7ud7NdfF5SmLZJLja+v19ULTvw6czTB6q0Hi9DT26t9YPqFhRMezokrhZ/3QHbsRFWUq2yGYpdvOf3LwJlsI9K5RkLbOQxz6akIl8sZHBQ4zzyLMHq0jpl7EQn/NQlRUbM8ozVjQlZH+BBcYSHwuoCwSkLVqdUZucNNePWhD04TDbMIr/wKyOkCd90C1J1W0sirk/3TY/d72jJszGbrmZl89A5zNka2VkvbSCrF7sw== root@hadoop02
[root@h2 ~]#
```

将所有节点的做软连接

```
ln -s /home/nmred/nfs_share/authorized_keys /home/nmred/.ssh/authorized_keys 
```

**注意** 对于.ssh目录，公钥、私钥的权限都有严格的要求

```
1. 用户目录755或700，不能使77*
2. .ssh目录755
3. .pub或authorized_key 644
4. 私钥600
```

这块如果权限不对免密码登陆不会成功

#### 编译hadoop2.x 包

- 需要用yum 安装用到或依赖的软件包

```
yum -y install svn autoconf automake libtool cmake ncurses-devel openssl-devel gcc*
```

- 安装maven， java-jdk

下载maven , jdk, bin类型的tar包直接解压到 /usr/local 下,然后设置环境变量如下图：

![环境设置][hadoop-img-001]

- 编译安装protobuf

![编译protobuf][hadoop-img-002]

- 在nmred普通用户下克隆hadoop 2.30 源代码，并且执行

```
mvnpackage -Pdist,native-DskipTests–Dtar
```

最终编译完成或有一个这样的提示：

![编译成功][hadoop-img-003]

在代码目录下有一个

![hadoop target 目录][hadoop-img-004]

就是编译好的hadoop 安装包，到此就x64位系统的安装包已经制作完成。

#### Hadoop 部署

将打包好的hadoop安装包和 JDK 解压到 /home/nmred/distRunDir

- Hadoop 配置

修改hadoop-env.sh 

```
export JAVA_HOME=/home/nmred/distRunDir/jdk1.7.0_55/
```

修改core-site.xml 

```
<configuration>
    <property>
            <name>fs.defaultFS</name>
            <value>hdfs://h1.hadoop.com:9000</value>
    </property>
    <property>
            <name>io.file.buffer.size</name>
            <value>131072</value>
    </property>
    <property>
            <name>hadoop.tmp.dir</name>
            <value>file:/home/nmred/distRunDir/hadoop-2.3.0/tmp</value>
            <description>Abase for other temporary directories.</description>
    </property>
    <property>
            <name>hadoop.proxyuser.hduser.hosts</name>
            <value>*</value>
    </property>
    <property>
            <name>hadoop.proxyuser.hduser.groups</name>
            <value>*</value>
    </property>
</configuration>
```

修改hdfs-site.xml

```
<configuration>
    <property>
            <name>dfs.namenode.secondary.http-address</name>
            <value>h1.hadoop.com:9001</value>
    </property>
    <property>
            <name>dfs.namenode.name.dir</name>
            <value>file:/home/nmred/distRunDir/hadoop-2.3.0/name</value>
    </property>
    <property>
            <name>dfs.datanode.data.dir</name>
            <value>file:/home/nmred/distRunDir/hadoop-2.3.0/data</value>
    </property>
    <property>
            <name>dfs.replication</name>
            <value>1</value>
    </property>
    <property>
            <name>dfs.webhdfs.enabled</name>
            <value>true</value>
    </property>
</configuration>
```

修改 mapred-site.xml

```
<configuration>
    <property>
            <name>mapreduce.framework.name</name>
            <value>yarn</value>
    </property>
    <property>
            <name>mapreduce.jobhistory.address</name>
            <value>h1.hadoop.com:10020</value>
    </property>
    <property>
            <name>mapreduce.jobhistory.webapp.address</name>
            <value>h1.hadoop.com:19888</value>
    </property>
</configuration>
```

修改 yarn-site.xml 

```
<configuration>

<!-- Site specific YARN configuration properties -->
    <property>
            <name>yarn.nodemanager.aux-services</name>
            <value>mapreduce_shuffle</value>
    </property>
    <property>
            <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
            <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
            <name>yarn.resourcemanager.address</name>
            <value>h1.hadoop.com:8032</value>
    </property>
    <property>
            <name>yarn.resourcemanager.scheduler.address</name>
            <value>h1.hadoop.com:8030</value>
    </property>
    <property>
            <name>yarn.resourcemanager.resource-tracker.address</name>
            <value>h1.hadoop.com:8031</value>
    </property>
    <property>
            <name>yarn.resourcemanager.admin.address</name>
            <value>h1.hadoop.com:8033</value>
    </property>
    <property>
            <name>yarn.resourcemanager.webapp.address</name>
            <value>h1.hadoop.com:8088</value>
    </property>
</configuration>
```

修改 slaves

```
h2.hadoop.com
h3.hadoop.com
h4.hadoop.com
h5.hadoop.com
h6.hadoop.com
```

- 发布脚本

```

#!/bin/bash

cat /home/nmred/distRunDir/hadoop-2.3.0/etc/hadoop/slaves | awk '{print "scp -rp /home/nmred/distRunDir/ nmred@"$1":/home/nmred/distRunDir/"}' > publish.sh

chmod 755 publish.sh

./publish.sh
```

[dns-install]:http://www.swanlinux.net/2013/02/12/linux_dns/
[nfs-install]:http://www.swanlinux.net/2013/02/12/linux_nfs/
[hadoop-img-001]: /image/hadoop/hadoop-001-001.png
[hadoop-img-002]: /image/hadoop/hadoop-001-002.png
[hadoop-img-003]: /image/hadoop/hadoop-001-003.png
[hadoop-img-004]: /image/hadoop/hadoop-001-004.png
