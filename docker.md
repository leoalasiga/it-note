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









