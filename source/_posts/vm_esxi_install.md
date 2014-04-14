title: 安装 ESXI 
date: 2014-04-11 23:13:16
tags: esxi
categories: 虚拟技术
---

### 硬件环境

主板：华硕P8B75 **板载Realtek RTL8111F千兆网卡** 注意：RLT类型的网卡 VM默认安装不支持，需要重新打包安装（下面详细说明）
CPU: 英特尔 第三代酷睿 i5-3570K @ 3.40GHz
内存: 16 GB

### 用到的软件下载

- [VMware-VMvisor-Installer-5.5.0.update01-1623387.x86_64.iso][esxi_download]
- [rufus-1.4.6][rufus_download]
- [ESXi-Customizer-v2.7.1][ESXi-Customizer_download]
- [VMware_bootbank_net-r8168_8.013.00-3vmw.510.0.0.799733.vib][net_download]

#### 制作 U盘安装镜像

首先将 RLT 网卡驱动打包进安装包中，需要用到 ESXi-Customizer 软件，具体步骤如下：

![自定义安装包][esxi-001]

将打包出来的软件安装包 ISO 文件利用 rufus 安装到U盘中，具体步骤如下：

选择镜像文件
![制作U盘安装盘][esxi-002]

当开始制作的时候会弹出如下的提示：

![选择 NO 不修改现有的镜像][esxi-003]

#### 安装 ESXI

####安装 VMware-viclient

安装好 ESXI server 后，可以用 client进行管理 server，进行虚拟机安装


[esxi_download]: https://my.vmware.com/cn/web/vmware/info/slug/datacenter_cloud_infrastructure/vmware_vsphere/5_5
[rufus_download]: http://pan.baidu.com/s/1kTkcCv1
[ESXi-Customizer_download]: http://pan.baidu.com/s/1eQwyc8a
[net_download]: http://pan.baidu.com/s/1rM2We

[esxi-001]: /image/vm/vm-esxi-001-001.jpg
[esxi-002]: /image/vm/vm-esxi-003-001.png
[esxi-003]: /image/vm/vm-esxi-002-001.png
