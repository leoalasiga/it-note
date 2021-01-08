

# docker

> docker学习

+ docker概述
+ docker安装
+ docker命令
  + 镜像命令
  + 容器命令
  + 操作命令
  + ..
+ daocker镜像
+ 容器数据卷
+ dockerFile
+ docker网络原理
+ idea整合docker
+ docker compose
+ docker swarm
+ ci\cd jenkins



## docker概述

### 为什么要docker

开发======上线 两套环境,应用环境,应用配置



开发及运维

环境配置十分麻烦

=>项目+环境进行部署,开发打包部署上线,一套流程做完



docker给了解决方案

java --- jar(环境) --- 打包项目带上环境(镜像)--- docker仓库(商店)---下载发布的镜像---直接运行就好



docker的思想来自于集装箱

JRE--多个应用(端口冲突)--原来是交叉的

**隔离:docker的核心思想,打包装箱,每个箱子是互相隔离的**

docker通过隔离机制,可以将服务器利用到极致



### docker历史

2010 dotcloud

混不下去

开源-2013

虚拟机:属于虚拟化技术

docker:容器技术,也是一种虚拟化技术

> 聊聊docker

docker基于go开发的

+ 官网 https://www.docker.com/
+ 文档地址 https://docs.docker.com/
  + docker的文档
+ 仓库地址 https://hub.docker.com/
  + 类似于git的仓库



### docker能干嘛?

> 之前的虚拟机技术

![image-20210104175327477](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210104175327477.png)

虚拟机技术缺点

+ 资源占用十分多
+ 冗余步骤多
+ 启动很慢

> 容器化技术

容器化技术不是一个完整的操作系统

![image-20210104175529355](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210104175529355.png)

docker与虚拟机不同

+ 传统虚拟机是一个完成整的操作系统,然后这个系统上安装软件
+ 容器的应用直接运行在宿主机的内容,没有自己的内核,没有自己的硬件,所以很轻量
+ 每个容器互相隔离,每个容器内都有一个属于自己的文件系统



> devops(开发,运维)

+ 应用更快速的交付部署
  + 打包镜像,发布测试,一建运行
+ 更快速的升级和扩缩容
+ 更简单的系统运维
  + 容器化之后,开发测试环境保持高度一致
+ 更高效的计算资源利用
  + docker是内核级别的虚拟化,一个物理机上可以运行很多容器实例



## Docker安装

### docker的基本构成

 ![image-20210104180308670](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210104180308670.png)

**镜像(image)**

就是一个模板,通过模板来创建容器服务,tomcat镜像=>run=>tomcat

**容器(container)**

docker利用容器技术,独立运行一个或者一组应用,通过镜像来创建的

启动,停止,删除,基本命令



**仓库(repository)**

存放镜像的地方

+ 共有仓库
+ 私有仓库



## 安装docker

> 环境准备

1.会linux基础

2.centos7

3.使用xshell进行远程操作

> 环境查看

```shell
# 系统内核
[root@liujiajie ~]# uname -r
3.10.0-1062.1.2.el7.x86_64
```

```shell
# 系统版本
[root@liujiajie ~]# cat /etc/os-release 
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
```

> 安装

```shell
#卸载老的版本
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

```shell
# 安装需要的安装工具
sudo yum install -y yum-utils
```

```shell
# 设置镜像仓库(推荐使用阿里云)
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

```shell
# 查看yum仓库里的docker所有版本
yum list docker-ce --showduplicates | sort -r
```

```shell
#安装yum缓存索引
yum makecache fast
```

```shell
# 安装docker
sudo yum install docker-ce docker-ce-cli containerd.io
```

```shell
#安装指定版本
sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
```

```shell
#启动docker
 sudo systemctl start docker
```

```shell
#验证是否正确安装
docker version
```

```shell
#hello world
sudo docker run hello-world
```

```shell
# 查看镜像
dokcer image
```

```shell
# 卸载docker
#卸载docker引擎,cli
sudo yum remove docker-ce docker-ce-cli containerd.io
#卸载镜像
sudo rm -rf /var/lib/docker
```

阿里云镜像加速

1.登录阿里云找到容器服务

2.找到镜像加速地址

3.配置镜像加速器

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://e2aov5sv.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 回顾hello-word镜像的流程

```shell
[root@liujiajie ~]# docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```

![image-20210105135408576](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210105135408576.png)



### 底层原理

**docker是怎么工作的?**

docker是一个client-server结构的系统,dokcer的守护程运行在主机上,通过socket客户端访问

dockerserver接收到dockerclient的指令,就回去执行

![image-20210105134937131](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210105134937131.png)

docker为什么比VM快

1.docker比虚拟机更小的抽象层

2.docker利用的是宿主机的内核他,vm需要的是guest os

![image-20210105135023957](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210105135023957.png)

所以说,新建一个容器的时候,docker不需要像虚拟机一样重新加载一个操作系统内核,避免引导,虚拟机是加载guestos,分钟级别的,而docker是利用宿主机的内核,省略了这个复杂的过程,秒级

![image-20210105135336244](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210105135336244.png)



## docker的常用命令

### 帮助命令

```shell
docker version #显示docker版本信息
docker info # 显示docker的系统信息,包括镜像和容器数量
docker 命令 --help # 帮助命令
```

帮助文档地址: https://docs.docker.com/reference/

镜像命令

docker images # 查看所有本地主机上的镜像

```shell
[root@liujiajie ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
hello-world   latest    bf756fb1ae65   12 months ago   13.3kB

# REPOSITORY 镜像的仓库源
# TAG 镜像的标签
# IMAGE ID 镜像的ID
# CREATED 创建时间
# SIZE 大小


[root@liujiajie ~]# docker images --help

Usage:  docker images [OPTIONS] [REPOSITORY[:TAG]]

List images

Options:
  -a, --all             Show all images (default hides intermediate images)
      --digests         Show digests
  -f, --filter filter   Filter output based on conditions provided
      --format string   Pretty-print images using a Go template
      --no-trunc        Don't truncate output
  -q, --quiet           Only show image IDs

```

docker search 搜索镜像

```shell
[root@liujiajie ~]# docker search mysql
NAME                              DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
mysql                             MySQL is a widely used, open-source relation…   10339     [OK]       

```

docker pull 下载镜像

```shell
[root@liujiajie ~]# docker pull mysql
Using default tag: latest #如果不写tag 默认就是latest
latest: Pulling from library/mysql
6ec7b7d162b2: Pull complete #分层下载
fedd960d3481: Pull complete 
7ab947313861: Pull complete 
64f92f19e638: Pull complete 
3e80b17bff96: Pull complete 
014e976799f9: Pull complete 
59ae84fee1b3: Pull complete 
ffe10de703ea: Pull complete 
657af6d90c83: Pull complete 
98bfb480322c: Pull complete 
6aa3859c4789: Pull complete 
1ed875d851ef: Pull complete 
Digest: sha256:78800e6d3f1b230e35275145e657b82c3fb02a27b2d8e76aac2f5e90c1c30873
Status: Downloaded newer image for mysql:latest
docker.io/library/mysql:latest #真实地址


#等价于
docker pull mysql = docker pull docker.io/library/mysql:latest

 
#指定版本下载
docker pull mysql:5.7
[root@liujiajie ~]# docker pull mysql:5.7
5.7: Pulling from library/mysql
6ec7b7d162b2: Already exists  #发现公用分层
fedd960d3481: Already exists 
7ab947313861: Already exists 
64f92f19e638: Already exists 
3e80b17bff96: Already exists 
014e976799f9: Already exists 
59ae84fee1b3: Already exists 
7d1da2a18e2e: Pull complete 
301a28b700b9: Pull complete 
529dc8dbeaf3: Pull complete 
bc9d021dc13f: Pull complete 
Digest: sha256:c3a567d3e3ad8b05dfce401ed08f0f6bf3f3b64cc17694979d5f2e5d78e10173
Status: Downloaded newer image for mysql:5.7
docker.io/library/mysql:5.7

```

docker rmi 删除镜像

```shell
docker rmi -f
```





### 容器命令

说明:我们有了镜像才可以创建容器,linux,下载一个centos镜像来测试学习

```shell
docker pull centos
```

#### 新建容器并启动

```shell
docker run [可选参数] image


# 参数说明
--name="Name" 容器名字,用来区分容器
-d 后台运行
-it 使用交互方式运行,进入容器查看内容
-p 指定容器的端口 -p 8080:8080
	-p ip:主机端口:容器端口
	-p 主机端口:容器端口(常用)
	-p 容器端口
-P 随机指定端口

#测试,启动并进入容器
[root@liujiajie ~]# docker run -it centos /bin/bash
# 查看容器内的centos,基础版本,很多命令不完善 
[root@1de6b1a4d3c1 /]# ls
bin  etc   lib	  lost+found  mnt  proc  run   srv  tmp  var
dev  home  lib64  media       opt  root  sbin  sys  usr

#退出容器,返回主机
[root@1de6b1a4d3c1 /]# exit
```

#### 列出所有运行的容器

```shell
[root@liujiajie ~]# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[root@liujiajie ~]# docker ps -a
CONTAINER ID   IMAGE         COMMAND       CREATED         STATUS                          PORTS     NAMES
1de6b1a4d3c1   centos        "/bin/bash"   3 minutes ago   Exited (0) About a minute ago             youthful_joliot
1733c4be653a   hello-world   "/hello"      2 hours ago     Exited (0) 2 hours ago                    goofy_kirch
b1cf4c2d9529   hello-world   "/hello"      3 hours ago     Exited (0) 3 hours ago                    crazy_lehmann
[root@liujiajie ~]# 

```

+ -a 列出所有当前正在运行的容器+以前运行过的容器
+ -n=[数字] 显示最近创建的容器
+ -q 显示容器的编号



#### 退出容器

exit #直接容器

停止并退出



ctrl + p + q #容器不停止



#### 删除容器

docker rm 容器id   #删除指定容器(不能删除正在运行的容器)

docker rm -f  $(docker ps -aq) #删除所有容器

docker ps -a -q|xargs docker rm # 删除所有容器



#### 启动停止容器

docker start 容器id #启动容器

docker restart 容器id #重启容器

docker stop 容器id #停止容器

docker kill  容器id #强制停止容器



### 常用其他命令

#### 后台启动容器

docker run -d  centos #通过这个命启动,用docker ps ,发现centos停止了

#常见的坑,docker容器使用后台运行,就必须要有一个前台的进程,docker发现没有应用,就会自动停止



#### 查看日志

docker logs

```shell
docker logs -f -t --tail 容器id
#发现没有日志


#自己编写一个脚本
[root@liujiajie ~]# docker run -d centos /bin/sh -C "while true;do echo liujiajie;sleep 1;done"

# 查看镜像id
[root@liujiajie ~]# docker run -d centos /bin/sh -C "while true;do echo liujiajie;sleep 1;done"

# 显示日志
[root@liujiajie ~]# docker logs -tf --tail 10  bb1a571f4862

# -tf               #显示日志
# --tail [number]   #显示日志行数

```

#### 查看容器中的进程信息

```shell
#docker top 容器id
[root@liujiajie ~]# docker top bb1a571f4862
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                16712               16692               0                   10:11               ?                   00:00:00            /bin/sh -c while true;do echo liujiajie;sleep 1;done
root                17120               16712               0                   10:16               ?                   00:00:00            /usr/bin/coreutils --coreutils-prog-shebang=sleep /usr/bin/sleep 1

```

#### 查看镜像元数据

```shell
# docker inspect 容器id
[root@liujiajie ~]# docker inspect bb1a571f4862
[
    {
        "Id": "bb1a571f4862004000873139defd3bab9f572894b872431dc37a53319eec829e",#id名
        "Created": "2021-01-07T02:11:01.237410273Z",
        "Path": "/bin/sh",
        "Args": [
            "-c",
            "while true;do echo liujiajie;sleep 1;done"
        ],
        "State": { #状态
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 16712,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2021-01-07T02:11:01.574169625Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:300e315adb2f96afe5f0b2780b87f28ae95231fe3bdd1e16b9ba606307728f55",
        "ResolvConfPath": "/var/lib/docker/containers/bb1a571f4862004000873139defd3bab9f572894b872431dc37a53319eec829e/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/bb1a571f4862004000873139defd3bab9f572894b872431dc37a53319eec829e/hostname",
        "HostsPath": "/var/lib/docker/containers/bb1a571f4862004000873139defd3bab9f572894b872431dc37a53319eec829e/hosts",
        "LogPath": "/var/lib/docker/containers/bb1a571f4862004000873139defd3bab9f572894b872431dc37a53319eec829e/bb1a571f4862004000873139defd3bab9f572894b872431dc37a53319eec829e-json.log",
        "Name": "/recursing_satoshi",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "host",
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "KernelMemory": 0,
            "KernelMemoryTCP": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": false,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": [
                "/proc/asound",
                "/proc/acpi",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/eb5282ea8a534626cebd3fdb338cdf30f5a9d2708c002771fc072cd44baffb6e-init/diff:/var/lib/docker/overlay2/3c1ddc9bcdfcfa16b7942a0a06103838926d9396bcbde0a6d533fa57736f0073/diff",
                "MergedDir": "/var/lib/docker/overlay2/eb5282ea8a534626cebd3fdb338cdf30f5a9d2708c002771fc072cd44baffb6e/merged",
                "UpperDir": "/var/lib/docker/overlay2/eb5282ea8a534626cebd3fdb338cdf30f5a9d2708c002771fc072cd44baffb6e/diff",
                "WorkDir": "/var/lib/docker/overlay2/eb5282ea8a534626cebd3fdb338cdf30f5a9d2708c002771fc072cd44baffb6e/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "bb1a571f4862",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/sh",
                "-c",
                "while true;do echo liujiajie;sleep 1;done"
            ],
            "Image": "centos",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.label-schema.build-date": "20201204",
                "org.label-schema.license": "GPLv2",
                "org.label-schema.name": "CentOS Base Image",
                "org.label-schema.schema-version": "1.0",
                "org.label-schema.vendor": "CentOS"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "d23033e6bc3e2de8ac3aba9fa8c34ccfe1602df5e3d517094063c3ed1b226f7a",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/d23033e6bc3e",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "dc5689662da1bde37410e5a02f9c213555129dc7bd31ac15526056056101d2d9",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "01f8f6519aaa6fd3fba656efee8179de494f943efe69ecc79319e52ff2295785",
                    "EndpointID": "dc5689662da1bde37410e5a02f9c213555129dc7bd31ac15526056056101d2d9",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]

```

#### 进入当前正在运行的容器

```shell
# 我们通常容器是要后台运行的,需要进入容器,修改配置

#命令
# 方式一
docker exec -it 容器id bashShell
[root@liujiajie ~]# docker exec -it bb1a571f4862 /bin/bash
[root@bb1a571f4862 /]# 

# 方式二
docker attach 容器id
[root@liujiajie ~]# docker attach 0d43e1f6cd2a
[root@0d43e1f6cd2a /]# 

#docker exec 进入容器后开启一个新的终端,可以在里面操作(常用)
#docker attach 进入容器正在运行的终端,不会启动新的进程
```

#### 从容器内拷贝文件到主机

```shell
docker cp 容器id:容器路径

# 进入docker目录,穿件文件
[root@liujiajie /]# docker run -it  centos /bin/bash
[root@3dfe29c54f1e /]# 
[root@3dfe29c54f1e /]# cd /home
[root@3dfe29c54f1e home]# ls
[root@3dfe29c54f1e home]# touch test.java
[root@3dfe29c54f1e home]# exit
exit
#退出之后,docker的容器里还有这个文件
[root@liujiajie /]# docker ps -a
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS                      PORTS     NAMES
3dfe29c54f1e   centos    "/bin/bash"   38 seconds ago   Exited (0) 10 seconds ago             quirky_almeida
#使用cp命令拷贝出文件
[root@liujiajie /]# docker cp 3dfe29c54f1e:/home/test.java /home
[root@liujiajie home]# ls
liujiajie.java  test.java
#完成将文件拷贝到主机上,拷贝是一个手动过程,未来使用-v卷技术,实现自动同步

```

#### 总结

![image-20210107164416127](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210107164416127.png)



> docker安装nginx

```shell
[root@liujiajie home]# docker pull nginx
Using default tag: latest
latest: Pulling from library/nginx
6ec7b7d162b2: Already exists 
cb420a90068e: Pull complete 
2766c0bf2b07: Pull complete 
e05167b6a99d: Pull complete 
70ac9d795e79: Pull complete 
Digest: sha256:4cf620a5c81390ee209398ecc18e5fb9dd0f5155cd82adcbae532fec94006fb9
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
[root@liujiajie home]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
mysql         latest    a347a5928046   2 weeks ago     545MB
nginx         latest    ae2feff98a0c   3 weeks ago     133MB
centos        latest    300e315adb2f   4 weeks ago     209MB
hello-world   latest    bf756fb1ae65   12 months ago   13.3kB
[root@liujiajie home]# docker run -d --name nginx01 -p 3344:80 nginx
d31d1ebc53986beeef259d069c77995ec59af13df0d8c20c64c3710a687b7087
[root@liujiajie home]# 
[root@liujiajie home]# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                  NAMES
d31d1ebc5398   nginx     "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:3344->80/tcp   nginx01
[root@liujiajie home]# curl localhost:3344
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>


# --name指定容器名字
# -p 外网端口:容器端口

#进入容器内部
[root@liujiajie home]# docker exec -it nginx01 /bin/bash
root@d31d1ebc5398:/# whereis nginx
nginx: /usr/sbin/nginx /usr/lib/nginx /etc/nginx /usr/share/nginx

```

端口暴露的概念

![image-20210107170550121](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210107170550121.png)

>  每次修改nginx配置都需要进入容器内部,十分麻烦?

我们可以在容器外部提供一个映射路径,达到容器修改文件名,容器内部就可以自动的修改...  (-v数据卷技术)



> docker使用tomcat

```shell
# 官方版本
$ docker run -it --rm tomcat:9.0
# --rm 退出及删除 (一般用来测试)

[root@liujiajie home]# docker run -d --name tomact01 -p 8080:8080 -h tomcathost01 tomcat
62ef1c58ac8bd4b83a8d87ca4a867b42600b4703b559198299be78e9b3a99386
[root@liujiajie home]# docker exec -it 62ef1c58ac8b /bin/bash
root@tomcathost01:/usr/local/tomcat# ls
BUILDING.txt	 LICENSE  README.md	 RUNNING.txt  conf  logs	    temp     webapps.dist
CONTRIBUTING.md  NOTICE   RELEASE-NOTES  bin	      lib   native-jni-lib  webapps  work
root@tomcathost01:/usr/local/tomcat# cd webapps
root@tomcathost01:/usr/local/tomcat/webapps# 

# 发现问题 
# 1.linux命令少了
# 2.没有webapps
# 原因,阿里云镜像的原因,默认最小的镜像,所有不必须的都剔除了,保证了最小可运行的环境
```



>  docker 部署es和kibana

```shell
# es 暴露端口很多
# es耗内存
# es 的数据需要挂载出去

# --net somework 这是网络配置

#启动elasticsearch
$ docker run -d --name elasticsearch --net somenetwork -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:tag


#启动了 linux服务器就卡住了
docker stats #查看cpu状态

#测试es

#限制内存,修改配置文件 -e 环境配置参数
$ docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx512m"  elastics
3d719c406b85cf98a70f9cb1fa03e13386736fc9f5e519ecb2c1b4172545a7a8

#docker states查看内存使用
CONTAINER ID   NAME            CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O       PIDS
3d719c406b85   elasticsearch   0.55%     399.1MiB / 1.795GiB   21.71%    2.94kB / 576B   109MB / 729kB   42

#测试是否连通
[root@liujiajie ~]# curl localhost:9200
{
  "name" : "3d719c406b85",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "K_paIlkGSKGeaMzSeNm3cQ",
  "version" : {
    "number" : "7.6.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "ef48eb35cf30adf4db14086e8aabd07ef6fb113f",
    "build_date" : "2020-03-26T06:34:37.794943Z",
    "build_snapshot" : false,
    "lucene_version" : "8.4.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}

```



> 使用kibana连接kibana

![image-20210108160317721](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210108160317721.png)



## 可视化

+ portainer

```shell
docker run -d -p 8088:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock --privileged=true portainer/portainer
```

+ Rancher(CI/CD)



什么是portanier

> docker的图形化管理工具,提供一个后台供我们操作

![image-20210108165845827](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210108165845827.png)

![image-20210108170011810](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210108170011810.png)

可视化面板,可以操作



## Docker镜像

### 镜像是什么?

镜像是一种轻量级.可执行的独立软件包,用来打包软件运行环境和基于运行环境开发的软件,它包含摸个软件所需的所有内容,包括代码,运行时库,环境变量和配置文件

所有的应用,直接打包docker镜像,可以直接跑起来

如何得到镜像:

+ 从远程仓库下载
+ 自己制作一个dockerFile
+ 从别处拷贝



### Docker镜像的加载原理

> unionFS(联合文件系统)

之前下载镜像一层一层就是这个

unionFS:union文件系统是一种分层,轻量级并且高性能的文件系统,支持文件系统作为一次提交来层层叠加,同时,可以将不同目录挂载到同一个虚拟文件系统下,union文件系统是docker镜像的基础,docker通过封层来进行继承,基于基础镜像,可以制作具体的应用镜像

特性:一次同时加载多个文件系统,但从外面看来,只能看到一个文件系统,联合加载就是把各层文件系统叠加起来,这样最终的文件系统会包含所有底层的文件和目录

> docker镜像加载原理

docker的镜像实际上是有一层一层的文件系统组成,这种层级的文件系统就是unionFS

bootFs(boot file system)主要包含bootloader和kernel,bootloader主要是引导加载kernel,linux刚启动就会加载bootfs文件系统,在docker镜像的最底层是bootfs,这一层与我们典型的linux/unix是一致的,包含boot加载器和内核,当boot加载之后整个内核都在内存中了,此时内存的使用权已由bootfs转交给内核,此时系统也会卸载bootfs

rootfs(root file system)

