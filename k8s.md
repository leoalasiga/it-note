# k8s

## 前世今生

iaas(infrastructure as a service)



paas(platform as a service)



saas(software as a service)



apache mesos(开源分布式资源管理框架) => docker swarm=>kubernetes



go语言 对 borg进行重写=>k8s

特点:

+ 轻量级:消耗资源少
+ 开源
+ 弹性伸缩
+ 负载均衡:IPVS



## 知识图谱

k8s:

+ 介绍说明:
  + 发展历史
    + 公共云类型说明
    + 资源管理器对比
    + k8s其优势
  + 组件说明
    + borg组件说明
    + k8s结构说明
      + 网络结构
      + 组件结构
  + k8s中的关键字解释
+ 基础概念
  + pod概念()
    + 自主式pod
    + 管理器管理的pod
      + RS , RC
      + deployment
      + HPA
      + StatefullSet
      + DaemonSet
      +  Job,cronjob
    + 服务发现
    + pod协同
  + 网络通讯模式
    + 网络通讯模式说明
    + 组件通讯模式说明
+ kubernetes安装
  + 系统初始化
  + kuberadm部署安装
  + 常见问题分析
+ 资源清单
  + k8s中资源概念
    +  什么是资源
    + 名称空间级别资源
    + 集群级别资源
  + 资源清单-yaml语法格式
  + 通过资源清单编写pod
  + **pod的声明周期**
    + initC
    + pod phase
    + 容器探针
      + livenessProbe
      + readinessProbe
    + pod hook
    + 重启策略
+ pod控制器
  + pod控制器说明
    + 什么是控制器
    + 控制器类型说明
      + replicationController和ReplicaSet
      + Deployment
      + DaemonSet
      + Job
      + CronJob
      + StatefulSet
      + Horizontal Pod Autoscaling
+ 服务发现 
  + service原理
    + service含义
    + service常见分类
      + clusterIp
      + nodePort
      + ExternalName
    + service实现方式
      + userspace
      + iptables
      + ipvs
  + ingress
    + nginx
      + http代理访问
      + https代理访问
      + 使用cookie实现会话关联
      + basicauth
      + nginx进行重写
+ 存储
  + pv
    + 概念解释
      + pv
      + pvc
      + 类型说明
    + pv
      + 后端类型
      + pv访问模式说明
      + 回收策略
      + 状态
      + 实例演示
      + pvc(PVC实践演示)
  + volume
    + 定义概念-卷的类型
    + emptyDir
      + 说明
      + 用途假设
      + 实验演示
    + hostPath
      + 说明
      + 用途说明
      + 实验演示
  + secret
    + 定义概念
    + service account
    + opaque secret
      + 特殊说明
      + 创建
      + 使用
        + secret挂载到volume
        + secret导出到环境变量中
    + kubernetes.io/dockerconfigjson
  + configmap
    + 定义概念
    + 创建configmap
      + 使用目录创建
      + 使用文件创建
      + 使用字面值创建
    + pod中使用configmap
      + configmap来替代环境变量
      + configmap设置命令行参数
      + 通过数据卷插件使用configmap
    + configmap热更新
      + 实现演示
      + 更新触发说明
+ 调度器
  + 调度器概念
    + 概念
    + 调度过程
    + 自定义调度器
  +  调度亲和性
+ 集群安全机制 集群的认证 鉴权 访问控制 原理及流程
+ helm:linux yum管理工具 掌握原理 helm模板自定义 
+ 运维
  + k8s源码修改
  + k8s高可用构建







服务分类

+ 有状态服务(有情绪的,丢失了会生气,有影响的):如dbms(数据库连接)
+ 无状态服务 



## 组件说明

 **borg架构图**

![image-20210104155601115](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210104155601115.png) 



**k8s架构图**

![image-20210104155902078](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210104155902078.png)



etcd是可信赖的分布式键值存储服务

+ v2存内存
+ v3存数据库

**etcd内部架构**

![image-20210104160616139](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210104160616139.png)





高可用集群数>=3的奇数

**apiserver**:所有服务统一的访问入口

**controllermanager**:维持副本期望数目

**scheduler**:负责接收任务,选择合适的节点惊醒分配任务

**etcd**:键值对数据库,存储k8是所有重要信息(持久化)

**kubelet**:直接跟容器引擎交互实现容器的生命周期管理

**kube-proxy**:负责写入规则至iptables,ipvs实现服务映射访问

**coredns**: 可以为集群中的svc创建一个域名ip的对应关系解析

**dashboard**: 给k8s集群提供一个b/s结构访问体系

**ingress controller**: 官方只能实现四层代理,ingress可以实现七层代理

**fedetation**:提供一个可以跨集群中心多k8s统一管理功能

**prometheus**:提供k8s集群的监控能力

**elk**:提供k8s集群日志统一分析接入平台







## pod概念

+ 自主式pod
+ 控制器管理的pod



pause

同一个pod里端口不能重复

同一个pod既共享网络用共享卷

 

**replicationController**:用来确保容器应用的副本数始终保持在用户定义的副本数.如果由容器异常退出,会自动创建新的pod代替,多出来的会被自动回收

**replicaSet**:跟replicationController没有本质区别,且支持集合式的selector,**新版本推荐使用**

replicaSet虽然可以独立使用,但是建议用**Deployment**自动管理replicaSet(rs不支持滚动更新,Deployment支持)



Hpa(horizontal pod autoscaling)仅适用于deployment和replicaset,在v1版本中支持根据pod的cpu利用率扩容



statefulset是为了解决有状态的服务问题

(replicaSet和Deployment是为了无状态服务设计的)

+ 稳定的持久化存储,即pod重新调用后还能访问到想用的持久化数据
+ 稳定的网络标识,即pod重新调度后其podname和hostname不变,基于headless service来实现
+ 有序部署有序扩展,即pod是有顺序的,在部署货站扩展的时候要依据定义的顺序依次进行(从0到n-1,在下一个pod运行之前所有的pod必须都是running和ready状态),基于init containers来实现
+ 有序收缩,有序删除 



daemonset

确保全部node上运行一个pod副本

+ 运行集群存储daemon
+ 在每个node上运行日志收集daemon
+ 在每个node上运行监控daemon

 

job

负责批处理任务,即仅执行一次的任务,保证批处理任务的一个或多个pod成功结束

cron job管理基于时间的job



服务发现

![image-20210104164456326](C:\Users\leoalasiga\AppData\Roaming\Typora\typora-user-images\image-20210104164456326.png)



 













## 网络通讯方式