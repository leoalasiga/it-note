# Kubernetes深入解析

## 容器技术概念入门

### 从进程开始

> 容器本身没有价值，有价值的是“容器编排”。

1. 容器，到底是怎么一回事儿？

```txt
容器其实是一种沙盒技术。顾名思义，沙盒就是能够像一个集装箱一样，把你的应用“装”起来的技术。这样，应用与应用之间，就因为有了边界而不至于相互干扰；而被装进集装箱的应用，也可以被方便地搬来搬去，这不就是 PaaS 最理想的状态嘛。
```

**所以，我就先来跟你说说这个“边界”的实现手段**

假如，现在你要写一个计算加法的小程序，这个程序需要的输入来自于一个文件，计算完成后的结果则输出到另一个文件中。

由于计算机只认识 0 和 1，所以无论用哪种语言编写这段代码，最后都需要通过某种方式翻译成二进制文件，才能在计算机操作系统中运行起来。

而为了能够让这些代码正常运行，我们往往还要给它提供数据，比如我们这个加法程序所需要的输入文件。这些数据加上代码本身的二进制文件，放在磁盘上，就是我们平常所说的一个“程序”，也叫代码的可执行镜像（executable image）。

然后，我们就可以在计算机上运行这个“程序”了。

首先，操作系统从“程序”中发现输入数据保存在一个文件中，所以这些数据就会被加载到内存中待命。同时，操作系统又读取到了计算加法的指令，这时，它就需要指示 CPU 完成加法操作。而 CPU 与内存协作进行加法计算，又会使用寄存器存放数值、内存堆栈保存执行的命令和变量。同时，计算机里还有被打开的文件，以及各种各样的 I/O 设备在不断地调用中修改自己的状态。

就这样，一旦“程序”被执行起来，它就从磁盘上的二进制文件，变成了计算机内存中的数据、寄存器里的值、堆栈中的指令、被打开的文件，以及各种设备的状态信息的一个集合。**像这样一个程序运行起来后的计算机执行环境的总和，就是我们今天的主角：进程**。

```txt
所以，对于进程来说，它的静态表现就是程序，平常都安安静静地待在磁盘上；而一旦运行起来，它就变成了计算机里的数据和状态的总和，这就是它的动态表现。
```

而容器技术的核心功能，**就是通过约束和修改进程的动态表现，从而为其创造出一个“边界”**。

对于 Docker 等大多数 Linux 容器来说，**Cgroups 技术**是用来制造约束的主要手段，而 **Namespace 技术**则是用来修改进程视图的主要方法。



你可能会觉得 Cgroups 和 Namespace 这两个概念很抽象，别担心，接下来我们一起动手实践一下，你就很容易理解这两项技术了。

假设你已经有了一个 Linux 操作系统上的 Docker 项目在运行，比如我的环境是 Ubuntu 16.04 和 Docker CE 18.05。接下来，让我们首先创建一个容器来试试。

```shell
$ docker run -it busybox /bin/sh/ 
/#
```

这个命令是 Docker 项目最重要的一个操作，即大名鼎鼎的 docker run。

而 -it 参数告诉了 Docker 项目在启动容器后，需要给我们分配一个文本输入 / 输出环境，也就是 TTY，跟容器的标准输入相关联，这样我们就可以和这个 Docker 容器进行交互了。而 /bin/sh 就是我们要在 Docker 容器里运行的程序。

所以，上面这条指令翻译成人类的语言就是：请帮我启动一个容器，在容器里执行 /bin/sh，并且给我分配一个命令行终端跟这个容器交互。

这样，我的 Ubuntu 16.04 机器就变成了一个宿主机，而一个运行着 /bin/sh 的容器，就跑在了这个宿主机里面。

上面的例子和原理，如果你已经玩过 Docker，一定不会感到陌生。此时，如果我们在容器里执行一下 ps 指令，就会发现一些更有趣的事情

```shell
/ # ps
PID  USER   TIME COMMAND
1 root   0:00 /bin/sh
10 root   0:00 ps
```

可以看到，我们在 Docker 里最开始执行的 /bin/sh，就是这个容器内部的第 1 号进程（PID=1），而这个容器里一共只有两个进程在运行。这就意味着，前面执行的 /bin/sh，以及我们刚刚执行的 ps，已经被 Docker 隔离在了一个跟宿主机完全不同的世界当中。

>  这究竟是怎么做到的呢？

本来，每当我们在宿主机上运行了一个 /bin/sh 程序，操作系统都会给它分配一个进程编号，比如 PID=100。这个编号是进程的唯一标识，就像员工的工牌一样。所以 PID=100，可以粗略地理解为这个 /bin/sh 是我们公司里的第 100 号员工，而第 1 号员工就自然是比尔 · 盖茨这样统领全局的人物。

而现在，我们要通过 Docker 把这个 /bin/sh 程序运行在一个容器当中。这时候，Docker 就会在这个第 100 号员工入职时给他施一个“障眼法”，让他永远看不到前面的其他 99 个员工，更看不到比尔 · 盖茨。这样，他就会错误地以为自己就是公司里的第 1 号员工。

这种机制，其实就是对被隔离应用的进程空间做了手脚，使得这些进程只能看到重新计算过的进程编号，比如 PID=1。可实际上，他们在宿主机的操作系统里，还是原来的第 100 号进程。

**这种技术，就是 Linux 里面的 Namespace 机制。**而 Namespace 的使用方式也非常有意思：它其实只是 Linux 创建新进程的一个可选参数。我们知道，在 Linux 系统中创建线程的系统调用是 clone()，比如：

```shell
int pid = clone(main_function, stack_size, SIGCHLD, NULL); 
```

这个系统调用就会为我们创建一个新的进程，并且返回它的进程号 pid

而当我们用 clone() 系统调用创建一个新进程时，就可以在参数中指定 CLONE_NEWPID 参数，比如：

```shell
int pid = clone(main_function, stack_size, CLONE_NEWPID | SIGCHLD, NULL); 
```

这时，新创建的这个进程将会“看到”一个全新的进程空间，在这个进程空间里，它的 PID 是 1。之所以说“看到”，是因为这只是一个“障眼法”，在宿主机真实的进程空间里，这个进程的 PID 还是真实的数值，比如 100。

当然，我们还可以多次执行上面的 clone() 调用，这样就会创建多个 PID Namespace，而每个 Namespace 里的应用进程，都会认为自己是当前容器里的第 1 号进程，它们既看不到宿主机里真正的进程空间，也看不到其他 PID Namespace 里的具体情况。

而**除了我们刚刚用到的 PID Namespace，Linux 操作系统还提供了 Mount、UTS、IPC、Network 和 User 这些 Namespace，用来对各种不同的进程上下文进行“障眼法”操作**。

比如，Mount Namespace，用于让被隔离进程只看到当前 Namespace 里的挂载点信息；Network Namespace，用于让被隔离进程看到当前 Namespace 里的网络设备和配置。

**这，就是 Linux 容器最基本的实现原理了。**

所以，Docker 容器这个听起来玄而又玄的概念，实际上是在创建容器进程时，指定了这个进程所需要启用的一组 Namespace 参数。这样，容器就只能“看”到当前 Namespace 所限定的资源、文件、设备、状态，或者配置。而对于宿主机以及其他不相关的程序，它就完全看不到了。

**所以说，容器，其实是一种特殊的进程而已。**

**总结**

谈到为“进程划分一个独立空间”的思想，相信你一定会联想到虚拟机。而且，你应该还看过一张虚拟机和容器的对比图。

![img](https://static001.geekbang.org/resource/image/d1/96/d1bb34cda8744514ba4c233435bf4e96.jpg)

这幅图的左边，画出了虚拟机的工作原理。其中，名为 Hypervisor 的软件是虚拟机最主要的部分。它通过硬件虚拟化功能，模拟出了运行一个操作系统需要的各种硬件，比如 CPU、内存、I/O 设备等等。然后，它在这些虚拟的硬件上安装了一个新的操作系统，即 Guest OS。

这样，用户的应用进程就可以运行在这个虚拟的机器中，它能看到的自然也只有 Guest OS 的文件和目录，以及这个机器里的虚拟设备。这就是为什么虚拟机也能起到将不同的应用进程相互隔离的作用。

而这幅图的右边，则用一个名为 Docker Engine 的软件替换了 Hypervisor。这也是为什么，很多人会把 Docker 项目称为“轻量级”虚拟化技术的原因，实际上就是把虚拟机的概念套在了容器上。

**可是这样的说法，却并不严谨。**

在理解了 Namespace 的工作方式之后，你就会明白，跟真实存在的虚拟机不同，在使用 Docker 的时候，并没有一个真正的“Docker 容器”运行在宿主机里面。Docker 项目帮助用户启动的，还是原来的应用进程，只不过在创建这些进程时，Docker 为它们加上了各种各样的 Namespace 参数。

这时，这些进程就会觉得自己是各自 PID Namespace 里的第 1 号进程，只能看到各自 Mount Namespace 里挂载的目录和文件，只能访问到各自 Network Namespace 里的网络设备，就仿佛运行在一个个“容器”里面，与世隔绝。



### 隔离与限制

Namespace。而通过这些讲解，你应该能够明白，**Namespace 技术实际上修改了应用进程看待整个计算机“视图”，即它的“视线”被操作系统做了限制，只能“看到”某些指定的内容**。但对于宿主机来说，这些被“隔离”了的进程跟其他进程并没有太大区别。

在之前虚拟机与容器技术的对比图里，不应该把 Docker Engine 或者任何容器管理工具放在跟 Hypervisor 相同的位置，因为它们并不像 Hypervisor 那样对应用进程的隔离环境负责，也不会创建任何实体的“容器”，真正对隔离环境负责的是宿主机操作系统本身：

![img](https://static001.geekbang.org/resource/image/d1/96/d1bb34cda8744514ba4c233435bf4e96.jpg)

所以，在这个对比图里，我们应该把 Docker 画在跟应用同级别并且靠边的位置。这意味着，用户运行在容器里的应用进程，跟宿主机上的其他进程一样，都由宿主机操作系统统一管理，只不过这些被隔离的进程拥有额外设置过的 Namespace 参数。而 Docker 项目在这里扮演的角色，更多的是旁路式的辅助和管理工作。

我在后续分享 CRI 和容器运行时的时候还会专门介绍，其实像 Docker 这样的角色甚至可以去掉。

这样的架构也解释了为什么 Docker 项目比虚拟机更受欢迎的原因

这是因为，使用虚拟化技术作为应用沙盒，就必须要由 Hypervisor 来负责创建虚拟机，这个虚拟机是真实存在的，并且它里面必须运行一个完整的 Guest OS 才能执行用户的应用进程。这就不可避免地带来了额外的资源消耗和占用。

根据实验，一个运行着 CentOS 的 KVM 虚拟机启动后，在不做优化的情况下，虚拟机自己就需要占用 100~200 MB 内存。此外，用户应用运行在虚拟机里面，它对宿主机操作系统的调用就不可避免地要经过虚拟化软件的拦截和处理，这本身又是一层性能损耗，尤其对计算资源、网络和磁盘 I/O 的损耗非常大。

而相比之下，容器化后的用户应用，却依然还是一个宿主机上的普通进程，这就意味着这些因为虚拟化而带来的性能损耗都是不存在的；而另一方面，使用 Namespace 作为隔离手段的容器并不需要单独的 Guest OS，这就使得容器额外的资源占用几乎可以忽略不计。

所以说，**“敏捷”和“高性能”是容器相较于虚拟机最大的优势，也是它能够在 PaaS 这种更细粒度的资源管理平台上大行其道的重要原因。**

不过，有利就有弊，基于 Linux Namespace 的隔离机制相比于虚拟化技术也有很多不足之处，其中最主要的问题就是：**隔离得不彻底**

<font style="color:orange">首先，既然容器只是运行在宿主机上的一种特殊的进程，那么多个容器之间使用的就还是同一个宿主机的操作系统内核。</font>

尽管你可以在容器里通过 Mount Namespace 单独挂载其他不同版本的操作系统文件，比如 CentOS 或者 Ubuntu，但这并不能改变共享宿主机内核的事实。这意味着，如果你要在 Windows 宿主机上运行 Linux 容器，或者在低版本的 Linux 宿主机上运行高版本的 Linux 容器，都是行不通的。

而相比之下，拥有硬件虚拟化技术和独立 Guest OS 的虚拟机就要方便得多了。最极端的例子是，Microsoft 的云计算平台 Azure，实际上就是运行在 Windows 服务器集群上的，但这并不妨碍你在它上面创建各种 Linux 虚拟机出来。

其次，在 Linux 内核中，有很多资源和对象是不能被 Namespace 化的，最典型的例子就是：**时间**。

这就意味着，如果你的容器中的程序使用 settimeofday(2) 系统调用修改了时间，整个宿主机的时间都会被随之修改，这显然不符合用户的预期。相比于在虚拟机里面可以随便折腾的自由度，在容器里部署应用的时候，“什么能做，什么不能做”，就是用户必须考虑的一个问题。

此外，由于上述问题，尤其是共享宿主机内核的事实，容器给应用暴露出来的攻击面是相当大的，应用“越狱”的难度自然也比虚拟机低得多。

更为棘手的是，尽管在实践中我们确实可以使用 Seccomp 等技术，对容器内部发起的所有系统调用进行过滤和甄别来进行安全加固，但这种方法因为多了一层对系统调用的过滤，必然会拖累容器的性能。何况，默认情况下，谁也不知道到底该开启哪些系统调用，禁止哪些系统调用。

所以，在生产环境中，没有人敢把运行在物理机上的 Linux 容器直接暴露到公网上。当然，我后续会讲到的基于虚拟化或者独立内核技术的容器实现，则可以比较好地在隔离与性能之间做出平衡。

**在介绍完容器的“隔离”技术之后，我们再来研究一下容器的“限制”问题。**

也许你会好奇，我们不是已经通过 Linux Namespace 创建了一个“容器”吗，为什么还需要对容器做“限制”呢？

我还是以 PID Namespace 为例，来给你解释这个问题

虽然容器内的第 1 号进程在“障眼法”的干扰下只能看到容器里的情况，但是宿主机上，它作为第 100 号进程与其他所有进程之间依然是平等的竞争关系。这就意味着，虽然第 100 号进程表面上被隔离了起来，但是它所能够使用到的资源（比如 CPU、内存），却是可以随时被宿主机上的其他进程（或者其他容器）占用的。当然，这个 100 号进程自己也可能把所有资源吃光。这些情况，显然都不是一个“沙盒”应该表现出来的合理行为

而 **Linux Cgroups 就是 Linux 内核中用来为进程设置资源限制的一个重要功能**。

有意思的是，Google 的工程师在 2006 年发起这项特性的时候，曾将它命名为“进程容器”（process container）。实际上，在 Google 内部，“容器”这个术语长期以来都被用于形容被 Cgroups 限制过的进程组。后来 Google 的工程师们说，他们的 KVM 虚拟机也运行在 Borg 所管理的“容器”里，其实也是运行在 Cgroups“容器”当中。这和我们今天说的 Docker 容器差别很大。

**Linux Cgroups 的全称是 Linux Control Group。它最主要的作用，就是限制一个进程组能够使用的资源上限，包括 CPU、内存、磁盘、网络带宽等等。**

此外，Cgroups 还能够对进程进行优先级设置、审计，以及将进程挂起和恢复等操作。在今天的分享中，我只和你重点探讨它与容器关系最紧密的“限制”能力，并通过一组实践来带你认识一下 Cgroups。

在 Linux 中，Cgroups 给用户暴露出来的操作接口是文件系统，即它以文件和目录的方式组织在操作系统的 /sys/fs/cgroup 路径下。在 Ubuntu 16.04 机器里，我可以用 mount 指令把它们展示出来，这条命令是:

```shell
[root@liujiajie cgroup]# mount -t cgroup
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_prio,net_cls)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpuacct,cpu)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids)
```

它的输出结果，是一系列文件系统目录。如果你在自己的机器上没有看到这些目录，那你就需要自己去挂载 Cgroups，具体做法可以自行 Google。

可以看到，在 /sys/fs/cgroup 下面有很多诸如 cpuset、cpu、 memory 这样的子目录，也叫子系统。这些都是我这台机器当前可以被 Cgroups 进行限制的资源种类。而在子系统对应的资源种类下，你就可以看到该类资源具体可以被限制的方法。比如，对 CPU 子系统来说，我们就可以看到如下几个配置文件，这个指令是：

```shell
$ ls /sys/fs/cgroup/cpu
cgroup.clone_children cpu.cfs_period_us cpu.rt_period_us  cpu.shares notify_on_release
cgroup.procs      cpu.cfs_quota_us  cpu.rt_runtime_us cpu.stat  tasks
```

如果熟悉 Linux CPU 管理的话，你就会在它的输出里注意到 cfs_period 和 cfs_quota 这样的关键词。这两个参数需要组合使用，可以用来限制进程在长度为 cfs_period 的一段时间内，只能被分配到总量为 cfs_quota 的 CPU 时间

而这样的配置文件又如何使用呢？

你需要在对应的子系统下面创建一个目录，比如，我们现在进入 /sys/fs/cgroup/cpu 目录下：

```shell
root@ubuntu:/sys/fs/cgroup/cpu$ mkdir container
root@ubuntu:/sys/fs/cgroup/cpu$ ls container/
cgroup.clone_children cpu.cfs_period_us cpu.rt_period_us  cpu.shares notify_on_release
cgroup.procs      cpu.cfs_quota_us  cpu.rt_runtime_us cpu.stat  tasks
```

这个目录就称为一个“控制组”。你会发现，操作系统会在你新创建的 container 目录下，自动生成该子系统对应的资源限制文件。

现在，我们在后台执行这样一条脚本：

```shell
$ while : ; do : ; done &
[1] 226
```

显然，它执行了一个死循环，可以把计算机的 CPU 吃到 100%，根据它的输出，我们可以看到这个脚本在后台运行的进程号（PID）是 226。

这样，我们可以用 top 指令来确认一下 CPU 有没有被打满：

```shell
$ top
%Cpu0 :100.0 us, 0.0 sy, 0.0 ni, 0.0 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st
```

在输出里可以看到，CPU 的使用率已经 100% 了（%Cpu0 :100.0 us）

而此时，我们可以通过查看 container 目录下的文件，看到 container 控制组里的 CPU quota 还没有任何限制（即：-1），CPU period 则是默认的 100 ms（100000 us）：

```shell
$ cat /sys/fs/cgroup/cpu/container/cpu.cfs_quota_us 
-1
$ cat /sys/fs/cgroup/cpu/container/cpu.cfs_period_us 
100000
```

接下来，我们可以通过修改这些文件的内容来设置限制。

比如，向 container 组里的 cfs_quota 文件写入 20 ms（20000 us）：

```shell
$ echo 20000 > /sys/fs/cgroup/cpu/container/cpu.cfs_quota_us
```

结合前面的介绍，你应该能明白这个操作的含义，它意味着在每 100 ms 的时间里，被该控制组限制的进程只能使用 20 ms 的 CPU 时间，也就是说这个进程只能使用到 20% 的 CPU 带宽。

接下来，我们把被限制的进程的 PID 写入 container 组里的 tasks 文件，上面的设置就会对该进程生效了：

```shell
$ echo 226 > /sys/fs/cgroup/cpu/container/tasks 
```

我们可以用 top 指令查看一下：

```sh
$ top
%Cpu0 : 20.3 us, 0.0 sy, 0.0 ni, 79.7 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st
```

可以看到，计算机的 CPU 使用率立刻降到了 20%（%Cpu0 : 20.3 us）。

除 CPU 子系统外，Cgroups 的每一个子系统都有其独有的资源限制能力，比如：

+ blkio，为块设备设定I/O 限制，一般用于磁盘等设备；
+ cpuset，为进程分配单独的 CPU 核和对应的内存节点；
+ memory，为进程设定内存使用的限制。

**Linux Cgroups 的设计还是比较易用的，简单粗暴地理解呢，它就是一个子系统目录加上一组资源限制文件的组合**。而对于 Docker 等 Linux 容器项目来说，它们只需要在每个子系统下面，为每个容器创建一个控制组（即创建一个新目录），然后在启动容器进程之后，把这个进程的 PID 填写到对应控制组的 tasks 文件中就可以了。

而至于在这些控制组下面的资源文件里填上什么值，就靠用户执行 docker run 时的参数指定了，比如这样一条命令：

```shell
$ docker run -it --cpu-period=100000 --cpu-quota=20000 ubuntu /bin/bash
```

在启动这个容器后，我们可以通过查看 Cgroups 文件系统下，CPU 子系统中，“docker”这个控制组里的资源限制文件的内容来确认：

```sh
$ cat /sys/fs/cgroup/cpu/docker/5d5c9f67d/cpu.cfs_period_us 
100000
$ cat /sys/fs/cgroup/cpu/docker/5d5c9f67d/cpu.cfs_quota_us 
20000
```

这就意味着这个 Docker 容器，只能使用到 20% 的 CPU 带宽。

**总结**

在这篇文章中，我首先介绍了容器使用 Linux Namespace 作为隔离手段的优势和劣势，对比了 Linux 容器跟虚拟机技术的不同，进一步明确了“容器只是一种特殊的进程”这个结论。

除了创建 Namespace 之外，在后续关于容器网络的分享中，我还会介绍一些其他 Namespace 的操作，比如看不见摸不着的 Linux Namespace 在计算机中到底如何表示、一个进程如何“加入”到其他进程的 Namespace 当中，等等。

紧接着，我详细介绍了容器在做好了隔离工作之后，又如何通过 Linux Cgroups 实现资源的限制，并通过一系列简单的实验，模拟了 Docker 项目创建容器限制的过程。

通过以上讲述，你现在应该能够理解，一个正在运行的 Docker 容器，其实就是一个启用了多个 Linux Namespace 的应用进程，而这个进程能够使用的资源量，则受 Cgroups 配置的限制。

这也是容器技术中一个非常重要的概念，即：**容器是一个“单进程”模型**

由于一个容器的本质就是一个进程，用户的应用进程实际上就是容器里 PID=1 的进程，也是其他后续创建的所有进程的父进程。这就意味着，在一个容器中，你没办法同时运行两个不同的应用，除非你能事先找到一个公共的 PID=1 的程序来充当两个不同应用的父进程，这也是为什么很多人都会用 systemd 或者 supervisord 这样的软件来代替应用本身作为容器的启动进程。

但是，在后面分享容器设计模式时，我还会推荐其他更好的解决办法。这是因为容器本身的设计，就是希望容器和应用能够**同生命周期**，这个概念对后续的容器编排非常重要。否则，一旦出现类似于“容器是正常运行的，但是里面的应用早已经挂了”的情况，编排系统处理起来就非常麻烦了

另外，跟 Namespace 的情况类似，Cgroups 对资源的限制能力也有很多不完善的地方，被提及最多的自然是 /proc 文件系统的问题。

众所周知，Linux 下的 /proc 目录存储的是记录当前内核运行状态的一系列特殊文件，用户可以通过访问这些文件，查看系统以及当前正在运行的进程的信息，比如 CPU 使用情况、内存占用率等，这些文件也是 top 指令查看系统信息的主要数据来源

但是，你如果在容器里执行 top 指令，就会发现，它显示的信息居然是宿主机的 CPU 和内存数据，而不是当前容器的数据。

造成这个问题的原因就是，/proc 文件系统并不知道用户通过 Cgroups 给这个容器做了什么样的资源限制，即：/proc 文件系统不了解 Cgroups 限制的存在

在生产环境中，这个问题必须进行修正，否则应用程序在容器里读取到的 CPU 核数、可用内存等信息都是宿主机上的数据，这会给应用的运行带来非常大的困惑和风险。这也是在企业中，容器化应用碰到的一个常见问题，也是容器相较于虚拟机另一个不尽如人意的地方

### 深入理解容器镜像

我讲解了 Linux 容器最基础的两种技术：Namespace 和 Cgroups。希望此时，你已经彻底理解了“容器的本质是一种特殊的进程”这个最重要的概念

而正如我前面所说的，Namespace 的作用是“隔离”，它让应用进程只能看到该 Namespace 内的“世界”；而 Cgroups 的作用是“限制”，它给这个“世界”围上了一圈看不见的墙。这么一折腾，进程就真的被“装”在了一个与世隔绝的房间里，而这些房间就是 PaaS 项目赖以生存的应用“沙盒”。

可是，还有一个问题不知道你有没有仔细思考过：这个房间四周虽然有了墙，但是如果容器进程低头一看地面，又是怎样一副景象呢？

换句话说，**容器里的进程看到的文件系统又是什么样子的呢？**

可能你立刻就能想到，这一定是一个关于 Mount Namespace 的问题：容器里的应用进程，理应看到一份完全独立的文件系统。这样，它就可以在自己的容器目录（比如 /tmp）下进行操作，而完全不会受宿主机以及其他容器的影响。

那么，真实情况是这样吗？

“左耳朵耗子”叔在多年前写的一篇关于 Docker 基础知识的博客里，曾经介绍过一段小程序。这段小程序的作用是，在创建子进程时开启指定的 Namespace。

下面，我们不妨使用它来验证一下刚刚提到的问题。

```sh
#define _GNU_SOURCE
#include <sys/mount.h> 
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>
#define STACK_SIZE (1024 * 1024)
static char container_stack[STACK_SIZE];
char* const container_args[] = {
  "/bin/bash",
  NULL
};

int container_main(void* arg)
{  
  printf("Container - inside the container!\n");
  execv(container_args[0], container_args);
  printf("Something's wrong!\n");
  return 1;
}

int main()
{
  printf("Parent - start a container!\n");
  int container_pid = clone(container_main, container_stack+STACK_SIZE, CLONE_NEWNS | SIGCHLD , NULL);
  waitpid(container_pid, NULL, 0);
  printf("Parent - container stopped!\n");
  return 0;
}
```

这段代码的功能非常简单：在 main 函数里，我们通过 clone() 系统调用创建了一个新的子进程 container_main，并且声明要为它启用 Mount Namespace（即：CLONE_NEWNS 标志）。

而这个子进程执行的，是一个“/bin/bash”程序，也就是一个 shell。所以这个 shell 就运行在了 Mount Namespace 的隔离环境中。

我们来一起编译一下这个程序：

```shell
$ gcc -o ns ns.c
$ ./ns
Parent - start a container!
Container - inside the container!
```

这样，我们就进入了这个“容器”当中。可是，如果在“容器”里执行一下 ls 指令的话，我们就会发现一个有趣的现象： /tmp 目录下的内容跟宿主机的内容是一样的。

```sh
$ ls /tmp
# 你会看到好多宿主机的文件
```

也就是说：

​	即使开启了 Mount Namespace，容器进程看到的文件系统也跟宿主机完全一样。

这是怎么回事呢？

仔细思考一下，你会发现这其实并不难理解：**Mount Namespace 修改的，是容器进程对文件系统“挂载点”的认知**。但是，这也就意味着，只有在“挂载”这个操作发生之后，进程的视图才会被改变。而在此之前，新创建的容器会直接继承宿主机的各个挂载点。

```shell
int container_main(void* arg)
{
  printf("Container - inside the container!\n");
  // 如果你的机器的根目录的挂载类型是shared，那必须先重新挂载根目录
  // mount("", "/", NULL, MS_PRIVATE, "");
  mount("none", "/tmp", "tmpfs", 0, "");
  execv(container_args[0], container_args);
  printf("Something's wrong!\n");
  return 1;
}
```

可以看到，在修改后的代码里，我在容器进程启动之前，加上了一句 mount(“none”, “/tmp”, “tmpfs”, 0, “”) 语句。就这样，我告诉了容器以 tmpfs（内存盘）格式，重新挂载了 /tmp 目录。

这段修改后的代码，编译执行后的结果又如何呢？我们可以试验一下：

```sh
$ gcc -o ns ns.c
$ ./ns
Parent - start a container!
Container - inside the container!
$ ls /tmp
```

可以看到，这次 /tmp 变成了一个空目录，这意味着重新挂载生效了。我们可以用 mount -l 检查一下：

```sh
$ mount -l | grep tmpfs
none on /tmp type tmpfs (rw,relatime)
```

可以看到，容器里的 /tmp 目录是以 tmpfs 方式单独挂载的。

更重要的是，因为我们创建的新进程启用了 Mount Namespace，所以这次重新挂载的操作，只在容器进程的 Mount Namespace 中有效。如果在宿主机上用 mount -l 来检查一下这个挂载，你会发现它是不存在的：

```sh
# 在宿主机上
$ mount -l | grep tmpfs
```

**这就是 Mount Namespace 跟其他 Namespace 的使用略有不同的地方：它对容器进程视图的改变，一定是伴随着挂载操作（mount）才能生效。**

可是，作为一个普通用户，我们希望的是一个更友好的情况：每当创建一个新容器时，我希望容器进程看到的文件系统就是一个独立的隔离环境，而不是继承自宿主机的文件系统。怎么才能做到这一点呢？

不难想到，我们可以在容器进程启动之前重新挂载它的整个根目录“/”。而由于 Mount Namespace 的存在，这个挂载对宿主机不可见，所以容器进程就可以在里面随便折腾了。

在 Linux 操作系统里，有一个名为 chroot 的命令可以帮助你在 shell 中方便地完成这个工作。顾名思义，它的作用就是帮你“change root file system”，即改变进程的根目录到你指定的位置。它的用法也非常简单。

假设，我们现在有一个 $HOME/test 目录，想要把它作为一个 /bin/bash 进程的根目录。

首先，创建一个 test 目录和几个 lib 文件夹：

```shell
$ mkdir -p $HOME/test
$ mkdir -p $HOME/test/{bin,lib64,lib}
$ cd $T
```

然后，把 bash 命令拷贝到 test 目录对应的 bin 路径下

```sh
$ cp -v /bin/{bash,ls} $HOME/test/bin
```

接下来，把 bash 命令需要的所有 so 文件，也拷贝到 test 目录对应的 lib 路径下。找到 so 文件可以用 ldd 命令：

```sh
$ T=$HOME/test
$ list="$(ldd /bin/ls | egrep -o '/lib.*\.[0-9]')"
$ for i in $list; do cp -v "$i" "${T}${i}"; done
```

最后，执行 chroot 命令，告诉操作系统，我们将使用 $HOME/test 目录作为 /bin/bash 进程的根目录

```sh
$ chroot $HOME/test /bin/bash
```

这时，你如果执行 "ls /"，就会看到，它返回的都是 $HOME/test 目录下面的内容，而不是宿主机的内容。

更重要的是，对于被 chroot 的进程来说，它并不会感受到自己的根目录已经被“修改”成 $HOME/test 了

这种视图被修改的原理，是不是跟我之前介绍的 Linux Namespace 很类似呢？

没错！

**实际上，Mount Namespace 正是基于对 chroot 的不断改良才被发明出来的，它也是 Linux 操作系统里的第一个 Namespace。**

当然，为了能够让容器的这个根目录看起来更“真实”，我们一般会在这个容器的根目录下挂载一个完整操作系统的文件系统，比如 Ubuntu16.04 的 ISO。这样，在容器启动之后，我们在容器里通过执行 "ls /" 查看根目录下的内容，就是 Ubuntu 16.04 的所有目录和文件。

**而这个挂载在容器根目录上、用来为容器进程提供隔离后执行环境的文件系统，就是所谓的“容器镜像”。它还有一个更为专业的名字，叫作：rootfs（根文件系统）。**

所以，一个最常见的 rootfs，或者说容器镜像，会包括如下所示的一些目录和文件，比如 /bin，/etc，/proc 等等：

```sh
$ ls /
bin dev etc home lib lib64 mnt opt proc root run sbin sys tmp usr var
```

而你进入容器之后执行的 /bin/bash，就是 /bin 目录下的可执行文件，与宿主机的 /bin/bash 完全不同。

现在，你应该可以理解，对 Docker 项目来说，它最核心的原理实际上就是为待创建的用户进程：

1. 启用 Linux Namespace 配置；
2. 设置指定的 Cgroups 参数；
3. 切换进程的根目录（Change Root）。

这样，一个完整的容器就诞生了。不过，Docker 项目在最后一步的切换上会优先使用 pivot_root 系统调用，如果系统不支持，才会使用 chroot。这两个系统调用虽然功能类似，但是也有细微的区别，这一部分小知识就交给你课后去探索了。

另外**，需要明确的是，rootfs 只是一个操作系统所包含的文件、配置和目录，并不包括操作系统内核。在 Linux 操作系统中，这两部分是分开存放的，操作系统只有在开机启动时才会加载指定版本的内核镜像**

所以说，rootfs 只包括了操作系统的“躯壳”，并没有包括操作系统的“灵魂”

那么，对于容器来说，这个操作系统的“灵魂”又在哪里呢？

实际上，同一台机器上的所有容器，都共享宿主机操作系统的内核。

这就意味着，如果你的应用程序需要配置内核参数、加载额外的内核模块，以及跟内核进行直接的交互，你就需要注意了：这些操作和依赖的对象，都是宿主机操作系统的内核，它对于该机器上的所有容器来说是一个“全局变量”，牵一发而动全身。

这也是容器相比于虚拟机的主要缺陷之一：毕竟后者不仅有模拟出来的硬件机器充当沙盒，而且每个沙盒里还运行着一个完整的 Guest OS 给应用随便折腾。

不过，**正是由于 rootfs 的存在，容器才有了一个被反复宣传至今的重要特性：一致性。**

什么是容器的“一致性”呢？

我在专栏的第一篇文章《小鲸鱼大事记（一）：初出茅庐》中曾经提到过：由于云端与本地服务器环境不同，应用的打包过程，一直是使用 PaaS 时最“痛苦”的一个步骤

但有了容器之后，更准确地说，有了容器镜像（即 rootfs）之后，这个问题被非常优雅地解决了。

**由于 rootfs 里打包的不只是应用，而是整个操作系统的文件和目录，也就意味着，应用以及它运行所需要的所有依赖，都被封装在了一起。**

事实上，对于大多数开发者而言，他们对应用依赖的理解，一直局限在编程语言层面。比如 Golang 的 Godeps.json。**但实际上，一个一直以来很容易被忽视的事实是，对一个应用来说，操作系统本身才是它运行所需要的最完整的“依赖库”。**

有了容器镜像“打包操作系统”的能力，这个最基础的依赖环境也终于变成了应用沙盒的一部分。这就赋予了容器所谓的一致性：无论在本地、云端，还是在一台任何地方的机器上，用户只需要解压打包好的容器镜像，那么这个应用运行所需要的完整的执行环境就被重现出来了。

**这种深入到操作系统级别的运行环境一致性，打通了应用在本地开发和远端执行环境之间难以逾越的鸿沟。**

不过，这时你可能已经发现了另一个非常棘手的问题：难道我每开发一个应用，或者升级一下现有的应用，都要重复制作一次 rootfs 吗？

比如，我现在用 Ubuntu 操作系统的 ISO 做了一个 rootfs，然后又在里面安装了 Java 环境，用来部署我的 Java 应用。那么，我的另一个同事在发布他的 Java 应用时，显然希望能够直接使用我安装过 Java 环境的 rootfs，而不是重复这个流程。

一种比较直观的解决办法是，我在制作 rootfs 的时候，每做一步“有意义”的操作，就保存一个 rootfs 出来，这样其他同事就可以按需求去用他需要的 rootfs 了。

但是，这个解决办法并不具备推广性。原因在于，一旦你的同事们修改了这个 rootfs，新旧两个 rootfs 之间就没有任何关系了。这样做的结果就是极度的碎片化。

那么，既然这些修改都基于一个旧的 rootfs，我们能不能以增量的方式去做这些修改呢？这样做的好处是，所有人都只需要维护相对于 base rootfs 修改的增量内容，而不是每次修改都制造一个“fork”。

答案当然是肯定的。

这也正是为何，Docker 公司在实现 Docker 镜像时并没有沿用以前制作 rootfs 的标准流程，而是做了一个小小的创新：

> Docker 在镜像的设计中，引入了层（layer）的概念。也就是说，用户制作镜像的每一步操作，都会生成一个层，也就是一个增量 rootfs

当然，这个想法不是凭空臆造出来的，而是用到了一种叫作联合文件系统（Union File System）的能力。

Union File System 也叫 UnionFS，最主要的功能是将多个不同位置的目录联合挂载（union mount）到同一个目录下。比如，我现在有两个目录 A 和 B，它们分别有两个文件：

```sh
$ tree
.
├── A
│  ├── a
│  └── x
└── B
  ├── b
  └── x
```

然后，我使用联合挂载的方式，将这两个目录挂载到一个公共的目录 C 上：

```sh
$ mkdir C
$ mount -t aufs -o dirs=./A:./B none ./C
```

这时，我再查看目录 C 的内容，就能看到目录 A 和 B 下的文件被合并到了一起：

可以看到，在这个合并后的目录 C 里，有 a、b、x 三个文件，并且 x 文件只有一份。这，就是“合并”的含义。此外，如果你在目录 C 里对 a、b、x 文件做修改，这些修改也会在对应的目录 A、B 中生效。

那么，在 Docker 项目中，又是如何使用这种 Union File System 的呢？

我的环境是 Ubuntu 16.04 和 Docker CE 18.05，这对组合默认使用的是 AuFS 这个联合文件系统的实现。你可以通过 docker info 命令，查看到这个信息。

AuFS 的全称是 Another UnionFS，后改名为 Alternative UnionFS，再后来干脆改名叫作 Advance UnionFS，从这些名字中你应该能看出这样两个事实：

1. 它是对 Linux 原生 UnionFS 的重写和改进；
2. 它的作者怨气好像很大。我猜是 Linus Torvalds（Linux 之父）一直不让 AuFS 进入 Linux 内核主干的缘故，所以我们只能在 Ubuntu 和 Debian 这些发行版上使用它。

对于 AuFS 来说，它最关键的目录结构在 /var/lib/docker 路径下的 diff 目录：

```sh
/var/lib/docker/aufs/diff/<layer_id>
```

**而这个目录的作用，我们不妨通过一个具体例子来看一下**

现在，我们启动一个容器，比如：

```sh
$ docker run -d ubuntu:latest sleep 3600
```

这时候，Docker 就会从 Docker Hub 上拉取一个 Ubuntu 镜像到本地。

这个所谓的“镜像”，实际上就是一个 Ubuntu 操作系统的 rootfs，它的内容是 Ubuntu 操作系统的所有文件和目录。不过，与之前我们讲述的 rootfs 稍微不同的是，Docker 镜像使用的 rootfs，往往由多个“层”组成：

```sh
$ docker image inspect ubuntu:latest
...
     "RootFS": {
      "Type": "layers",
      "Layers": [
        "sha256:f49017d4d5ce9c0f544c...",
        "sha256:8f2b771487e9d6354080...",
        "sha256:ccd4d61916aaa2159429...",
        "sha256:c01d74f99de40e097c73...",
        "sha256:268a067217b5fe78e000..."
      ]
    }
```

可以看到，这个 Ubuntu 镜像，实际上由五个层组成。这五个层就是五个增量 rootfs，每一层都是 Ubuntu 操作系统文件与目录的一部分；而在使用镜像时，Docker 会把这些增量联合挂载在一个统一的挂载点上（等价于前面例子里的“/C”目录）。

这个挂载点就是 /var/lib/docker/aufs/mnt/，比如：

```sh
/var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fcfa2a2f5c89dc21ee30e166be823ceaeba15dce645b3e
```

不出意外的，这个目录里面正是一个完整的 Ubuntu 操作系统：

```sh
$ ls /var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fcfa2a2f5c89dc21ee30e166be823ceaeba15dce645b3e
bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var
```

那么，前面提到的五个镜像层，又是如何被联合挂载成这样一个完整的 Ubuntu 文件系统的呢？

这个信息记录在 AuFS 的系统目录 /sys/fs/aufs 下面。

首先，通过查看 AuFS 的挂载信息，我们可以找到这个目录对应的 AuFS 的内部 ID（也叫：si）：

```sh
$ cat /proc/mounts| grep aufs
none /var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fc... aufs rw,relatime,si=972c6d361e6b32ba,dio,dirperm1 0 0
```

即，si=972c6d361e6b32ba。

然后使用这个 ID，你就可以在 /sys/fs/aufs 下查看被联合挂载在一起的各个层的信息：

```sh
$ cat /sys/fs/aufs/si_972c6d361e6b32ba/br[0-9]*
/var/lib/docker/aufs/diff/6e3be5d2ecccae7cc...=rw
/var/lib/docker/aufs/diff/6e3be5d2ecccae7cc...-init=ro+wh
/var/lib/docker/aufs/diff/32e8e20064858c0f2...=ro+wh
/var/lib/docker/aufs/diff/2b8858809bce62e62...=ro+wh
/var/lib/docker/aufs/diff/20707dce8efc0d267...=ro+wh
/var/lib/docker/aufs/diff/72b0744e06247c7d0...=ro+wh
/var/lib/docker/aufs/diff/a524a729adadedb90...=ro+wh
```

从这些信息里，我们可以看到，镜像的层都放置在 /var/lib/docker/aufs/diff 目录下，然后被联合挂载在 /var/lib/docker/aufs/mnt 里面。

**而且，从这个结构可以看出来，这个容器的 rootfs 由如下图所示的三部分组成：**

![img](https://static001.geekbang.org/resource/image/8a/5f/8a7b5cfabaab2d877a1d4566961edd5f.png)

**第一部分，只读层。**

它是这个容器的 rootfs 最下面的五层，对应的正是 ubuntu:latest 镜像的五层。可以看到，它们的挂载方式都是只读的（ro+wh，即 readonly+whiteout，至于什么是 whiteout，我下面马上会讲到）。

这时，我们可以分别查看一下这些层的内容：

```sh
$ ls /var/lib/docker/aufs/diff/72b0744e06247c7d0...
etc sbin usr var
$ ls /var/lib/docker/aufs/diff/32e8e20064858c0f2...
run
$ ls /var/lib/docker/aufs/diff/a524a729adadedb900...
bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var
```

可以看到，这些层，都以增量的方式分别包含了 Ubuntu 操作系统的一部分。

**第二部分，可读写层。**

它是这个容器的 rootfs 最上面的一层（6e3be5d2ecccae7cc），它的挂载方式为：rw，即 read write。在没有写入文件之前，这个目录是空的。而一旦在容器里做了写操作，你修改产生的内容就会以增量的方式出现在这个层中。

可是，你有没有想到这样一个问题：如果我现在要做的，是删除只读层里的一个文件呢？

为了实现这样的删除操作，AuFS 会在可读写层创建一个 whiteout 文件，把只读层里的文件“遮挡”起来。

比如，你要删除只读层里一个名叫 foo 的文件，那么这个删除操作实际上是在可读写层创建了一个名叫.wh.foo 的文件。这样，当这两个层被联合挂载之后，foo 文件就会被.wh.foo 文件“遮挡”起来，“消失”了。这个功能，就是“ro+wh”的挂载方式，即只读 +whiteout 的含义。我喜欢把 whiteout 形象地翻译为：“白障”。

所以，最上面这个可读写层的作用，就是专门用来存放你修改 rootfs 后产生的增量，无论是增、删、改，都发生在这里。而当我们使用完了这个被修改过的容器之后，还可以使用 docker commit 和 push 指令，保存这个被修改过的可读写层，并上传到 Docker Hub 上，供其他人使用；而与此同时，原先的只读层里的内容则不会有任何变化。这，就是增量 rootfs 的好处。

**第三部分，Init 层。**

它是一个以“-init”结尾的层，夹在只读层和读写层之间。Init 层是 Docker 项目单独生成的一个内部层，专门用来存放 /etc/hosts、/etc/resolv.conf 等信息。

需要这样一层的原因是，这些文件本来属于只读的 Ubuntu 镜像的一部分，但是用户往往需要在启动容器时写入一些指定的值比如 hostname，所以就需要在可读写层对它们进行修改。

可是，这些修改往往只对当前的容器有效，我们并不希望执行 docker commit 时，把这些信息连同可读写层一起提交掉。

所以，Docker 做法是，在修改了这些文件之后，以一个单独的层挂载了出来。而用户执行 docker commit 只会提交可读写层，所以是不包含这些内容的。

最终，这 7 个层都被联合挂载到 /var/lib/docker/aufs/mnt 目录下，表现为一个完整的 Ubuntu 操作系统供容器使用。

**总结**

在今天的分享中，我着重介绍了 Linux 容器文件系统的实现方式。而这种机制，正是我们经常提到的容器镜像，也叫作：rootfs。它只是一个操作系统的所有文件和目录，并不包含内核，最多也就几百兆。而相比之下，传统虚拟机的镜像大多是一个磁盘的“快照”，磁盘有多大，镜像就至少有多大。

通过结合使用 Mount Namespace 和 rootfs，容器就能够为进程构建出一个完善的文件系统隔离环境。当然，这个功能的实现还必须感谢 chroot 和 pivot_root 这两个系统调用切换进程根目录的能力。

而在 rootfs 的基础上，Docker 公司创新性地提出了使用多个增量 rootfs 联合挂载一个完整 rootfs 的方案，这就是容器镜像中“层”的概念。

通过“分层镜像”的设计，以 Docker 镜像为核心，来自不同公司、不同团队的技术人员被紧密地联系在了一起。而且，由于容器镜像的操作是增量式的，这样每次镜像拉取、推送的内容，比原本多个完整的操作系统的大小要小得多；而共享层的存在，可以使得所有这些容器镜像需要的总空间，也比每个镜像的总和要小。这样就使得基于容器镜像的团队协作，要比基于动则几个 GB 的虚拟机磁盘镜像的协作要敏捷得多。

更重要的是，一旦这个镜像被发布，那么你在全世界的任何一个地方下载这个镜像，得到的内容都完全一致，可以完全复现这个镜像制作者当初的完整环境。这，就是容器技术“强一致性”的重要体现。

而这种价值正是支撑 Docker 公司在 2014~2016 年间迅猛发展的核心动力。容器镜像的发明，不仅打通了“开发 - 测试 - 部署”流程的每一个环节，更重要的是：

**容器镜像将会成为未来软件的主流发布方式。**

**思考题**

1. 既然容器的 rootfs（比如，Ubuntu 镜像），是以只读方式挂载的，那么又如何在容器里修改 Ubuntu 镜像的内容呢？（提示：Copy-on-Write）

```txt
上面的读写层通常也称为容器层，下面的只读层称为镜像层，所有的增删查改操作都只会作用在容器层，相同的文件上层会覆盖掉下层。知道这一点，就不难理解镜像文件的修改，比如修改一个文件的时候，首先会从上到下查找有没有这个文件，找到，就复制到容器层中，修改，修改的结果就会作用到下层的文件，这种方式也被称为copy-on-write
```

2. 除了 AuFS，你知道 Docker 项目还支持哪些 UnionFS 实现吗？你能说出不同宿主机环境下推荐使用哪种实现吗？

```txt
 查了一下，包括但不限于以下这几种：aufs, device mapper, btrfs, overlayfs, vfs, zfs。aufs是ubuntu 常用的，device mapper 是 centos，btrfs 是 SUSE，overlayfs ubuntu 和 centos 都会使用，现在最新的 docker 版本中默认两个系统都是使用的 overlayfs，vfs 和 zfs 常用在 solaris 系统。
```

3. 目录联合挂载时，如果A和B目录里的x文件内容不一样，这时如何处理？

```txt
aufs是一层一层往上盖的，所以我给的例子里，A里面的x会覆盖B里面的x。
```

### 重新认识Docker容器

而在今天的分享中，我会通过一个实际案例，对“白话容器基础”系列的所有内容做一次深入的总结和扩展。希望通过这次的讲解，能够让你更透彻地理解 Docker 容器的本质。

在开始实践之前，你需要准备一台 Linux 机器，并安装 Docker。这个流程我就不再赘述了。

这一次，我要用 Docker 部署一个用 Python 编写的 Web 应用。这个应用的代码部分（app.py）非常简单：

```python
from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>"           
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname())
    
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```

在这段代码中，我使用 Flask 框架启动了一个 Web 服务器，而它唯一的功能是：如果当前环境中有“NAME”这个环境变量，就把它打印在“Hello”之后，否则就打印“Hello world”，最后再打印出当前环境的 hostname。

这个应用的依赖，则被定义在了同目录下的 requirements.txt 文件里，内容如下所示：

```sh
$ cat requirements.txt
Flask
```

而将这样一个应用容器化的第一步，是制作容器镜像。

不过，相较于我之前介绍的制作 rootfs 的过程，Docker 为你提供了一种更便捷的方式，叫作 Dockerfile，如下所示。

```dockerfile
# 使用官方提供的Python开发镜像作为基础镜像
FROM python:2.7-slim

# 将工作目录切换为/app
WORKDIR /app

# 将当前目录下的所有内容复制到/app下
ADD . /app

# 使用pip命令安装这个应用所需要的依赖
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# 允许外界访问容器的80端口
EXPOSE 80

# 设置环境变量
ENV NAME World

# 设置容器进程为：python app.py，即：这个Python应用的启动命令
CMD ["python", "app.py"]
```

通过这个文件的内容，你可以看到 **Dockerfile 的设计思想，是使用一些标准的原语（即大写高亮的词语），描述我们所要构建的 Docker 镜像。并且这些原语，都是按顺序处理的。**

比如 FROM 原语，指定了“python:2.7-slim”这个官方维护的基础镜像，从而免去了安装 Python 等语言环境的操作。否则，这一段我们就得这么写了：

```sh
FROM ubuntu:latest
RUN apt-get update -yRUN apt-get install -y python-pip python-dev build-essential
...
```

其中，RUN 原语就是在容器里执行 shell 命令的意思。

而 WORKDIR，意思是在这一句之后，Dockerfile 后面的操作都以这一句指定的 /app 目录作为当前目录

所以，到了最后的 CMD，意思是 Dockerfile 指定 python app.py 为这个容器的进程。这里，app.py 的实际路径是 /app/app.py。所以，CMD ["python", "app.py"]等价于"docker run \<image\> python app.py"

另外，在使用 Dockerfile 时，你可能还会看到一个叫作 ENTRYPOINT 的原语。实际上，它和 CMD 都是 Docker 容器进程启动所必需的参数，**完整执行格式是：“ENTRYPOINT CMD”**。

但是，默认情况下，Docker 会为你提供一个隐含的 ENTRYPOINT，即：/bin/sh -c。所以，在不指定 ENTRYPOINT 时，比如在我们这个例子里，实际上运行在容器里的完整进程是：/bin/sh -c "python app.py"，即 CMD 的内容就是 ENTRYPOINT 的参数。

> 备注：基于以上原因，**我们后面会统一称 Docker 容器的启动进程为 ENTRYPOINT，而不是 CMD。**

需要注意的是，Dockerfile 里的原语并不都是指对容器内部的操作。就比如 ADD，它指的是把当前目录（即 Dockerfile 所在的目录）里的文件，复制到指定容器内的目录当中。

读懂这个 Dockerfile 之后，我再把上述内容，保存到当前目录里一个名叫“Dockerfile”的文件中：

```sh
$ ls
Dockerfile  app.py   requirements.txt
```

接下来，我就可以让 Docker 制作这个镜像了，在当前目录执行：

```shell
$ docker build -t helloworld .
```

其中，-t 的作用是给这个镜像加一个 Tag，即：起一个好听的名字。docker build 会自动加载当前目录下的 Dockerfile 文件，然后按照顺序，执行文件中的原语。而这个过程，实际上可以等同于 Docker 使用基础镜像启动了一个容器，然后在容器中依次执行 Dockerfile 中的原语。

**需要注意的是，Dockerfile 中的每个原语执行后，都会生成一个对应的镜像层**。即使原语本身并没有明显地修改文件的操作（比如，ENV 原语），它对应的层也会存在。只不过在外界看来，这个层是空的。

docker build 操作完成后，我可以通过 docker images 命令查看结果：

```shell
$ docker image ls

REPOSITORY            TAG                 IMAGE ID
helloworld         latest              653287cdf998
```

通过这个镜像 ID，你就可以使用在《白话容器基础（三）：深入理解容器镜像》中讲过的方法，查看这些新增的层在 AuFS 路径下对应的文件和目录了。

接下来，我使用这个镜像，通过 docker run 命令启动容器：

```shell
$ docker run -p 4000:80 helloworld
```

在这一句命令中，镜像名 helloworld 后面，我什么都不用写，因为在 Dockerfile 中已经指定了 CMD。否则，我就得把进程的启动命令加在后面：

```shell
$ docker run -p 4000:80 helloworld python app.py
```

容器启动之后，我可以使用 docker ps 命令看到：

```shell
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED
4ddf4638572d        helloworld       "python app.py"     10 seconds ago
```

同时，我已经通过 -p 4000:80 告诉了 Docker，请把容器内的 80 端口映射在宿主机的 4000 端口上。

这样做的目的是，只要访问宿主机的 4000 端口，我就可以看到容器里应用返回的结果：

```shell
$ curl http://localhost:4000
<h3>Hello World!</h3><b>Hostname:</b> 4ddf4638572d<br/>
```

否则，我就得先用 docker inspect 命令查看容器的 IP 地址，然后访问“http://< 容器 IP 地址 >:80”才可以看到容器内应用的返回。

至此，我已经使用容器完成了一个应用的开发与测试，如果现在想要把这个容器的镜像上传到 DockerHub 上分享给更多的人，我要怎么做呢？

为了能够上传镜像，我**首先需要注册一个 Docker Hub 账号，然后使用 docker login 命令登录。**

接下来，我要用 **docker tag 命令给容器镜像起一个完整的名字**

```sh
$ docker tag helloworld geektime/helloworld:v1
```

>  注意：你自己做实验时，请将"geektime"替换成你自己的 Docker Hub 账户名称，比如 zhangsan/helloworld:v1

其中，geektime 是我在 Docker Hub 上的用户名，它的“学名”叫镜像仓库（Repository）；“/”后面的 helloworld 是这个镜像的名字，而“v1”则是我给这个镜像分配的版本号。

然后，我执行 docker push：

```sh
$ docker push geektime/helloworld:v1
```

这样，我就可以把这个镜像上传到 Docker Hub 上了。

此外，我还可以使用 docker commit 指令，把一个正在运行的容器，直接提交为一个镜像。一般来说，需要这么操作原因是：这个容器运行起来后，我又在里面做了一些操作，并且要把操作结果保存到镜像里，比如：

```sh
$ docker exec -it 4ddf4638572d /bin/sh
# 在容器内部新建了一个文件
root@4ddf4638572d:/app# touch test.txt
root@4ddf4638572d:/app# exit

#将这个新建的文件提交到镜像中保存
$ docker commit 4ddf4638572d geektime/helloworld:v2
```

这里，我使用了 docker exec 命令进入到了容器当中。在了解了 Linux Namespace 的隔离机制后，你应该会很自然地想到一个问题：docker exec 是怎么做到进入容器里的呢？

实际上，Linux Namespace 创建的隔离空间虽然看不见摸不着，但一个进程的 Namespace 信息在宿主机上是确确实实存在的，并且是以一个文件的方式存在

比如，通过如下指令，你可以看到当前正在运行的 Docker 容器的进程号（PID）是 25686：

```sh
$ docker inspect --format '{{ .State.Pid }}'  4ddf4638572d
25686
```

这时，你可以通过查看宿主机的 proc 文件，看到这个 25686 进程的所有 Namespace 对应的文件：

```sh
$ ls -l  /proc/25686/ns
total 0
lrwxrwxrwx 1 root root 0 Aug 13 14:05 cgroup -> cgroup:[4026531835]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 ipc -> ipc:[4026532278]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 mnt -> mnt:[4026532276]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 net -> net:[4026532281]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 pid -> pid:[4026532279]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 pid_for_children -> pid:[4026532279]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Aug 13 14:05 uts -> uts:[4026532277]
```

可以看到，一个进程的每种 Linux Namespace，都在它对应的 /proc/[进程号]/ns 下有一个对应的虚拟文件，并且链接到一个真实的 Namespace 文件上。

有了这样一个可以“hold 住”所有 Linux Namespace 的文件，我们就可以对 Namespace 做一些很有意义事情了，比如：加入到一个已经存在的 Namespace 当中。

**这也就意味着：一个进程，可以选择加入到某个进程已有的 Namespace 当中，从而达到“进入”这个进程所在容器的目的，这正是 docker exec 的实现原理。**

而这个操作所依赖的，乃是一个名叫 setns() 的 Linux 系统调用。它的调用方法，我可以用如下一段小程序为你说明：

```sh
#define _GNU_SOURCE
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define errExit(msg) do { perror(msg); exit(EXIT_FAILURE);} while (0)

int main(int argc, char *argv[]) {
    int fd;
    
    fd = open(argv[1], O_RDONLY);
    if (setns(fd, 0) == -1) {
        errExit("setns");
    }
    execvp(argv[2], &argv[2]); 
    errExit("execvp");
}
```

这段代码功能非常简单：它一共接收两个参数，第一个参数是 argv[1]，即当前进程要加入的 Namespace 文件的路径，比如 /proc/25686/ns/net；而第二个参数，则是你要在这个 Namespace 里运行的进程，比如 /bin/bash。

这段代码的核心操作，则是通过 open() 系统调用打开了指定的 Namespace 文件，并把这个文件的描述符 fd 交给 setns() 使用。在 setns() 执行后，当前进程就加入了这个文件对应的 Linux Namespace 当中了。

现在，你可以编译执行一下这个程序，加入到容器进程（PID=25686）的 Network Namespace 中：

```sh
$ gcc -o set_ns set_ns.c 
$ ./set_ns /proc/25686/ns/net /bin/bash 
$ ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:ac:11:00:02  
          inet addr:172.17.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
     collisions:0 txqueuelen:0 
          RX bytes:976 (976.0 B)  TX bytes:796 (796.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
    collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

正如上所示，当我们执行 ifconfig 命令查看网络设备时，我会发现能看到的网卡“变少”了：只有两个。而我的宿主机则至少有四个网卡。这是怎么回事呢？

实际上，在 setns() 之后我看到的这两个网卡，正是我在前面启动的 Docker 容器里的网卡。也就是说，我新创建的这个 /bin/bash 进程，由于加入了该容器进程（PID=25686）的 Network Namepace，它看到的网络设备与这个容器里是一样的，即：/bin/bash 进程的网络设备视图，也被修改了。

而一旦一个进程加入到了另一个 Namespace 当中，在宿主机的 Namespace 文件上，也会有所体现。

在宿主机上，你可以用 ps 指令找到这个 set_ns 程序执行的 /bin/bash 进程，其真实的 PID 是 28499：

```sh
# 在宿主机上
ps aux | grep /bin/bash
root     28499  0.0  0.0 19944  3612 pts/0    S    14:15   0:00 /bin/bash
```

这时，如果按照前面介绍过的方法，查看一下这个 PID=28499 的进程的 Namespace，你就会发现这样一个事实：

```sh
$ ls -l /proc/28499/ns/net
lrwxrwxrwx 1 root root 0 Aug 13 14:18 /proc/28499/ns/net -> net:[4026532281]

$ ls -l  /proc/25686/ns/net
lrwxrwxrwx 1 root root 0 Aug 13 14:05 /proc/25686/ns/net -> net:[4026532281]
```

在 /proc/[PID]/ns/net 目录下，这个 PID=28499 进程，与我们前面的 Docker 容器进程（PID=25686）指向的 Network Namespace 文件完全一样。这说明这两个进程，共享了这个名叫 net:[4026532281]的 Network Namespace。

此外，Docker 还专门提供了一个参数，可以让你启动一个容器并“加入”到另一个容器的 Network Namespace 里，这个参数就是 -net，比如:

```sh
$ docker run -it --net container:4ddf4638572d busybox ifconfig
```

这样，我们新启动的这个容器，就会直接加入到 ID=4ddf4638572d 的容器，也就是我们前面的创建的 Python 应用容器（PID=25686）的 Network Namespace 中。所以，这里 ifconfig 返回的网卡信息，跟我前面那个小程序返回的结果一模一样，你也可以尝试一下。

而如果我指定–net=host，就意味着这个容器不会为进程启用 Network Namespace。这就意味着，这个容器拆除了 Network Namespace 的“隔离墙”，所以，它会和宿主机上的其他普通进程一样，直接共享宿主机的网络栈。这就为容器直接操作和使用宿主机网络提供了一个渠道。

**转了一个大圈子，我其实是为你详细解读了 docker exec 这个操作背后，Linux Namespace 更具体的工作原理。**

**这种通过操作系统进程相关的知识，逐步剖析 Docker 容器的方法，是理解容器的一个关键思路，希望你一定要掌握。**

现在，我们再一起回到前面提交镜像的操作 docker commit 上来吧。

docker commit，实际上就是在容器运行起来后，把最上层的“可读写层”，加上原先容器镜像的只读层，打包组成了一个新的镜像。当然，下面这些只读层在宿主机上是共享的，不会占用额外的空间。

而由于使用了联合文件系统，你在容器里对镜像 rootfs 所做的任何修改，都会被操作系统先复制到这个可读写层，然后再修改。这就是所谓的：Copy-on-Write。

而正如前所说，Init 层的存在，就是为了避免你执行 docker commit 时，把 Docker 自己对 /etc/hosts 等文件做的修改，也一起提交掉。

有了新的镜像，我们就可以把它推送到 Docker Hub 上了：

```shell
$ docker push geektime/helloworld:v2
```

你可能还会有这样的问题：我在企业内部，能不能也搭建一个跟 Docker Hub 类似的镜像上传系统呢？

当然可以，这个统一存放镜像的系统，就叫作 Docker Registry。感兴趣的话，你可以查看Docker 的官方文档，以及VMware 的 Harbor 项目。

最后，我再来讲解一下 Docker 项目另一个重要的内容：Volume（数据卷）

前面我已经介绍过，容器技术使用了 rootfs 机制和 Mount Namespace，构建出了一个同宿主机完全隔离开的文件系统环境。这时候，我们就需要考虑这样两个问题：

1. 容器里进程新建的文件，怎么才能让宿主机获取到？
2. 宿主机上的文件和目录，怎么才能让容器里的进程访问到？

这正是 Docker Volume 要解决的问题：**Volume 机制，允许你将宿主机上指定的目录或者文件，挂载到容器里面进行读取和修改操作。**

在 Docker 项目里，它支持两种 Volume 声明方式，可以把宿主机目录挂载进容器的 /test 目录当中：

```shell
$ docker run -v /test ...
$ docker run -v /home:/test ...
```

而这两种声明方式的本质，实际上是相同的：都是把一个宿主机的目录挂载进了容器的 /test 目录。

只不过，在第一种情况下，由于你并没有显示声明宿主机目录，那么 Docker 就会默认在宿主机上创建一个临时目录 /var/lib/docker/volumes/[VOLUME_ID]/_data，然后把它挂载到容器的 /test 目录上。而在第二种情况下，Docker 就直接把宿主机的 /home 目录挂载到容器的 /test 目录上。

那么，Docker 又是如何做到把一个宿主机上的目录或者文件，挂载到容器里面去呢？难道又是 Mount Namespace 的黑科技吗？

实际上，并不需要这么麻烦。

在《白话容器基础（三）：深入理解容器镜像》的分享中，我已经介绍过，当容器进程被创建之后，尽管开启了 Mount Namespace，但是在它执行 chroot（或者 pivot_root）之前，容器进程一直可以看到宿主机上的整个文件系统。

而宿主机上的文件系统，也自然包括了我们要使用的容器镜像。这个镜像的各个层，保存在 /var/lib/docker/aufs/diff 目录下，在容器进程启动后，它们会被联合挂载在 /var/lib/docker/aufs/mnt/ 目录中，这样容器所需的 rootfs 就准备好了。

所以，我们只需要在 rootfs 准备好之后，在执行 chroot 之前，把 Volume 指定的宿主机目录（比如 /home 目录），挂载到指定的容器目录（比如 /test 目录）在宿主机上对应的目录（即 /var/lib/docker/aufs/mnt/[可读写层 ID]/test）上，这个 Volume 的挂载工作就完成了。

更重要的是，由于执行这个挂载操作时，“容器进程”已经创建了，也就意味着此时 Mount Namespace 已经开启了。所以，这个挂载事件只在这个容器里可见。**你在宿主机上，是看不见容器内部的这个挂载点的。这就保证了容器的隔离性不会被 Volume 打破。**

> 注意：这里提到的"容器进程"，是 Docker 创建的一个容器初始化进程 (dockerinit)，而不是应用进程 (ENTRYPOINT + CMD)。dockerinit 会负责完成根目录的准备、挂载设备和目录、配置 hostname 等一系列需要在容器内进行的初始化操作。最后，它通过 execv() 系统调用，让应用进程取代自己，成为容器里的 PID=1 的进程。

而这里要使用到的挂载技术，就是 Linux 的绑定挂载（bind mount）机制。它的主要作用就是，允许你将一个目录或者文件，而不是整个设备，挂载到一个指定的目录上。并且，这时你在该挂载点上进行的任何操作，只是发生在被挂载的目录或者文件上，而原挂载点的内容则会被隐藏起来且不受影响。

其实，如果你了解 Linux 内核的话，就会明白，绑定挂载实际上是一个 inode 替换的过程。在 Linux 操作系统中，inode 可以理解为存放文件内容的“对象”，而 dentry，也叫目录项，就是访问这个 inode 所使用的“指针”

![img](https://static001.geekbang.org/resource/image/95/c6/95c957b3c2813bb70eb784b8d1daedc6.png)

正如上图所示，mount --bind /home /test，会将 /home 挂载到 /test 上。其实相当于将 /test 的 dentry，重定向到了 /home 的 inode。这样当我们修改 /test 目录时，实际修改的是 /home 目录的 inode。这也就是为何，一旦执行 umount 命令，/test 目录原先的内容就会恢复：因为修改真正发生在的，是 /home 目录里。

**所以，在一个正确的时机，进行一次绑定挂载，Docker 就可以成功地将一个宿主机上的目录或文件，不动声色地挂载到容器中。**

这样，进程在容器里对这个 /test 目录进行的所有操作，都实际发生在宿主机的对应目录（比如，/home，或者 /var/lib/docker/volumes/[VOLUME_ID]/_data）里，而不会影响容器镜像的内容。

那么，这个 /test 目录里的内容，既然挂载在容器 rootfs 的可读写层，它会不会被 docker commit 提交掉呢？

也不会。

这个原因其实我们前面已经提到过。容器的镜像操作，比如 docker commit，都是发生在宿主机空间的。而由于 Mount Namespace 的隔离作用，宿主机并不知道这个绑定挂载的存在。所以，在宿主机看来，容器中可读写层的 /test 目录（/var/lib/docker/aufs/mnt/[可读写层 ID]/test），**始终是空的。**

不过，由于 Docker 一开始还是要创建 /test 这个目录作为挂载点，所以执行了 docker commit 之后，你会发现新产生的镜像里，会多出来一个空的 /test 目录。毕竟，新建目录操作，又不是挂载操作，Mount Namespace 对它可起不到“障眼法”的作用。

结合以上的讲解，我们现在来亲自验证一下：

首先，启动一个 helloworld 容器，给它声明一个 Volume，挂载在容器里的 /test 目录上：

```sh
$ docker run -d -v /test helloworld
cf53b766fa6f
```

容器启动之后，我们来查看一下这个 Volume 的 ID：

```sh
$ docker volume ls
DRIVER              VOLUME NAME
local               cb1c2f7221fa9b0971cc35f68aa1034824755ac44a034c0c0a1dd318838d3a6d
```

然后，使用这个 ID，可以找到它在 Docker 工作目录下的 volumes 路径：

```sh
$ ls /var/lib/docker/volumes/cb1c2f7221fa/_data/
```

这个 _data 文件夹，就是这个容器的 Volume 在宿主机上对应的临时目录了。

接下来，我们在容器的 Volume 里，添加一个文件 text.txt：

```shell
$ docker exec -it cf53b766fa6f /bin/sh
cd test/
touch text.txt
```

这时，我们再回到宿主机，就会发现 text.txt 已经出现在了宿主机上对应的临时目录里：

```shell
$ ls /var/lib/docker/volumes/cb1c2f7221fa/_data/text.txt
```

可是，如果你在宿主机上查看该容器的可读写层，虽然可以看到这个 /test 目录，但其内容是空的（关于如何找到这个 AuFS 文件系统的路径，请参考我上一次分享的内容）：

```sh
$ ls /var/lib/docker/aufs/mnt/6780d0778b8a/test
```

可以确认，容器 Volume 里的信息，并不会被 docker commit 提交掉；但这个挂载点目录 /test 本身，则会出现在新的镜像当中。

以上内容，就是 Docker Volume 的核心原理了。

**总结**

在今天的这次分享中，我用了一个非常经典的 Python 应用作为案例，讲解了 Docke 容器使用的主要场景。熟悉了这些操作，你也就基本上摸清了 Docker 容器的核心功能

更重要的是，我着重介绍了如何使用 Linux Namespace、Cgroups，以及 rootfs 的知识，对容器进行了一次庖丁解牛似的解读

借助这种思考问题的方法，最后的 Docker 容器，我们实际上就可以用下面这个“全景图”描述出来：

![img](https://static001.geekbang.org/resource/image/31/e5/3116751445d182687ce496f2825117e5.jpg)

这个容器进程“python app.py”，运行在由 Linux Namespace 和 Cgroups 构成的隔离环境里；而它运行所需要的各种文件，比如 python，app.py，以及整个操作系统文件，则由多个联合挂载在一起的 rootfs 层提供。

这些 rootfs 层的最下层，是来自 Docker 镜像的只读层。

在只读层之上，是 Docker 自己添加的 Init 层，用来存放被临时修改过的 /etc/hosts 等文件。

而 rootfs 的最上层是一个可读写层，它以 Copy-on-Write 的方式存放任何对只读层的修改，容器声明的 Volume 的挂载点，也出现在这一层。

通过这样的剖析，对于曾经“神秘莫测”的容器技术，你是不是感觉清晰了很多呢？

**思考题**

1. 你在查看 Docker 容器的 Namespace 时，是否注意到有一个叫 cgroup 的 Namespace？它是 Linux 4.6 之后新增加的一个 Namespace，你知道它的作用吗？
2. 如果你执行 docker run -v /home:/test 的时候，容器镜像里的 /test 目录下本来就有内容的话，你会发现，在宿主机的 /home 目录下，也会出现这些内容。这是怎么回事？为什么它们没有被绑定挂载隐藏起来呢？（提示：Docker 的“copyData”功能）
3. 请尝试给这个 Python 应用加上 CPU 和 Memory 限制，然后启动它。根据我们前面介绍的 Cgroups 的知识，请你查看一下这个容器的 Cgroups 文件系统的设置，是不是跟我前面的讲解一致。

### 谈谈Kubernetes的本质

> 我以 Docker 项目为例，一步步剖析了 Linux 容器的具体实现方式。通过这些讲解你应该能够明白：一个“容器”，实际上是一个由 Linux Namespace、Linux Cgroups 和 rootfs 三种技术构建出来的进程的隔离环境。

从这个结构中我们不难看出，一个正在运行的 Linux 容器，其实可以被“一分为二”地看待：

1. 一组联合挂载在 /var/lib/docker/aufs/mnt 上的 rootfs，这一部分我们称为“容器镜像”（Container Image），是容器的静态视图；
2. 一个由 Namespace+Cgroups 构成的隔离环境，这一部分我们称为“容器运行时”（Container Runtime），是容器的动态视图。

更进一步地说，作为一名开发者，我并不关心容器运行时的差异。因为，在整个“开发 - 测试 - 发布”的流程中，真正承载着容器信息进行传递的，是容器镜像，而不是容器运行时。

这个重要假设，正是容器技术圈在 Docker 项目成功后不久，就迅速走向了“容器编排”这个“上层建筑”的主要原因：作为一家云服务商或者基础设施提供商，我只要能够将用户提交的 Docker 镜像以容器的方式运行起来，就能成为这个非常热闹的容器生态图上的一个承载点，从而将整个容器技术栈上的价值，沉淀在我的这个节点上。

更重要的是，只要从我这个承载点向 Docker 镜像制作者和使用者方向回溯，整条路径上的各个服务节点，比如 CI/CD、监控、安全、网络、存储等等，都有我可以发挥和盈利的余地。这个逻辑，正是所有云计算提供商如此热衷于容器技术的重要原因：通过容器镜像，它们可以和潜在用户（即，开发者）直接关联起来。

从一个开发者和单一的容器镜像，到无数开发者和庞大的容器集群，容器技术实现了从“容器”到“容器云”的飞跃，标志着它真正得到了市场和生态的认可。

这样，**容器就从一个开发者手里的小工具，一跃成为了云计算领域的绝对主角；而能够定义容器组织和管理规范的“容器编排”技术，则当仁不让地坐上了容器技术领域的“头把交椅”**。

这其中，最具代表性的容器编排工具，当属 Docker 公司的 Compose+Swarm 组合，以及 Google 与 RedHat 公司共同主导的 Kubernetes 项目。

我在前面介绍容器技术发展历史的四篇预习文章中，已经对这两个开源项目做了详细的剖析和评述。所以，在今天的这次分享中，我会专注于本专栏的主角 Kubernetes 项目，谈一谈它的设计与架构。

跟很多基础设施领域先有工程实践、后有方法论的发展路线不同，Kubernetes 项目的理论基础则要比工程实践走得靠前得多，这当然要归功于 Google 公司在 2015 年 4 月发布的 Borg 论文了。

Borg 系统，一直以来都被誉为 Google 公司内部最强大的“秘密武器”。虽然略显夸张，但这个说法倒不算是吹牛。

因为，相比于 Spanner、BigTable 等相对上层的项目，Borg 要承担的责任，是承载 Google 公司整个基础设施的核心依赖。在 Google 公司已经公开发表的基础设施体系论文中，Borg 项目当仁不让地位居整个基础设施技术栈的最底层。

![img](https://static001.geekbang.org/resource/image/c7/bd/c7ed0043465bccff2efc1a1257e970bd.png)

上面这幅图，来自于 Google Omega 论文的第一作者的博士毕业论文。它描绘了当时 Google 已经公开发表的整个基础设施栈。在这个图里，你既可以找到 MapReduce、BigTable 等知名项目，也能看到 Borg 和它的继任者 Omega 位于整个技术栈的最底层。

正是由于这样的定位，Borg 可以说是 Google 最不可能开源的一个项目。而幸运的是，得益于 Docker 项目和容器技术的风靡，它却终于得以以另一种方式与开源社区见面，这个方式就是 Kubernetes 项目。

所以，相比于“小打小闹”的 Docker 公司、“旧瓶装新酒”的 Mesos 社区，**Kubernetes 项目从一开始就比较幸运地站上了一个他人难以企及的高度：在它的成长阶段，这个项目每一个核心特性的提出，几乎都脱胎于 Borg/Omega 系统的设计与经验**。更重要的是，这些特性在开源社区落地的过程中，又在整个社区的合力之下得到了极大的改进，修复了很多当年遗留在 Borg 体系中的缺陷和问题。

所以，尽管在发布之初被批评是“曲高和寡”，但是在逐渐觉察到 Docker 技术栈的“稚嫩”和 Mesos 社区的“老迈”之后，这个社区很快就明白了：Kubernetes 项目在 Borg 体系的指导下，体现出了一种独有的“先进性”与“完备性”，而这些特质才是一个基础设施领域开源项目赖以生存的核心价值。

为了更好地理解这两种特质，我们不妨从 Kubernetes 的顶层设计说起。

<font style='color:orange'>首先，Kubernetes 项目要解决的问题是什么？</font>

编排？调度？容器云？还是集群管理？

实际上，这个问题到目前为止都没有固定的答案。因为在不同的发展阶段，Kubernetes 需要着重解决的问题是不同的。

但是，对于大多数用户来说，他们希望 Kubernetes 项目带来的体验是确定的：现在我有了应用的容器镜像，请帮我在一个给定的集群上把这个应用运行起来

更进一步地说，我还希望 Kubernetes 能给我提供路由网关、水平扩展、监控、备份、灾难恢复等一系列运维能力。

等一下，这些功能听起来好像有些耳熟？这不就是经典 PaaS（比如，Cloud Foundry）项目的能力吗？

而且，有了 Docker 之后，我根本不需要什么 Kubernetes、PaaS，只要使用 Docker 公司的 Compose+Swarm 项目，就完全可以很方便地 DIY 出这些功能了！

所以说，如果 Kubernetes 项目只是停留在拉取用户镜像、运行容器，以及提供常见的运维功能的话，那么别说跟“原生”的 Docker Swarm 项目竞争了，哪怕跟经典的 PaaS 项目相比也难有什么优势可言。

而实际上，在定义核心功能的过程中，Kubernetes 项目正是依托着 Borg 项目的理论优势，才在短短几个月内迅速站稳了脚跟，进而确定了一个如下图所示的全局架构：

![img](https://static001.geekbang.org/resource/image/8e/67/8ee9f2fa987eccb490cfaa91c6484f67.png)

我们可以看到，Kubernetes 项目的架构，跟它的原型项目 Borg 非常类似，都由 Master 和 Node 两种节点组成，而这两种角色分别对应着控制节点和计算节点。

其中，**控制节点，即 Master 节点**，由三个紧密协作的独立组件组合而成，它们分别是负责 API 服务的 kube-apiserver、负责调度的 kube-scheduler，以及负责容器编排的 kube-controller-manager。整个集群的持久化数据，则由 kube-apiserver 处理后保存在 Etcd 中。

而计算节点上最核心的部分，则是一个叫作 **kubelet 的组件**。

**在 Kubernetes 项目中，kubelet 主要负责同容器运行时（比如 Docker 项目）打交道**。而这个交互所依赖的，是一个称作 CRI（Container Runtime Interface）的远程调用接口，这个接口定义了容器运行时的各项核心操作，比如：启动一个容器需要的所有参数。

这也是为何，Kubernetes 项目并不关心你部署的是什么容器运行时、使用的什么技术实现，只要你的这个容器运行时能够运行标准的容器镜像，它就可以通过实现 CRI 接入到 Kubernetes 项目当中。

而具体的容器运行时，比如 Docker 项目，则一般通过 OCI 这个容器运行时规范同底层的 Linux 操作系统进行交互，即：把 CRI 请求翻译成对 Linux 操作系统的调用（操作 Linux Namespace 和 Cgroups 等）。

**此外，kubelet 还通过 gRPC 协议同一个叫作 Device Plugin 的插件进行交互**。这个插件，是 Kubernetes 项目用来管理 GPU 等宿主机物理设备的主要组件，也是基于 Kubernetes 项目进行机器学习训练、高性能作业支持等工作必须关注的功能

而 **kubelet 的另一个重要功能，则是调用网络插件和存储插件为容器配置网络和持久化存储**。这两个插件与 kubelet 进行交互的接口，分别是 CNI（Container Networking Interface）和 CSI（Container Storage Interface）。

实际上，kubelet 这个奇怪的名字，来自于 Borg 项目里的同源组件 Borglet。不过，如果你浏览过 Borg 论文的话，就会发现，这个命名方式可能是 kubelet 组件与 Borglet 组件的唯一相似之处。因为 Borg 项目，并不支持我们这里所讲的容器技术，而只是简单地使用了 Linux Cgroups 对进程进行限制。

这就意味着，像 Docker 这样的“容器镜像”在 Borg 中是不存在的，Borglet 组件也自然不需要像 kubelet 这样考虑如何同 Docker 进行交互、如何对容器镜像进行管理的问题，也不需要支持 CRI、CNI、CSI 等诸多容器技术接口。

可以说，kubelet 完全就是为了实现 Kubernetes 项目对容器的管理能力而重新实现的一个组件，与 Borg 之间并没有直接的传承关系。

> 备注：虽然不使用 Docker，但 Google 内部确实在使用一个包管理工具，名叫 Midas Package Manager (MPM)，其实它可以部分取代 Docker 镜像的角色。

<font style='color:orange'>那么，Borg 对于 Kubernetes 项目的指导作用又体现在哪里呢？</font>

答案是，Master 节点。

虽然在 Master 节点的实现细节上 Borg 项目与 Kubernetes 项目不尽相同，但它们的出发点却高度一致，即：如何编排、管理、调度用户提交的作业？

所以，Borg 项目完全可以把 Docker 镜像看作一种新的应用打包方式。这样，Borg 团队过去在大规模作业管理与编排上的经验就可以直接“套”在 Kubernetes 项目上了。

这些经验最主要的表现就是，**从一开始，Kubernetes 项目就没有像同时期的各种“容器云”项目那样，把 Docker 作为整个架构的核心，而仅仅把它作为最底层的一个容器运行时实现**。

而 Kubernetes 项目要着重解决的问题，则来自于 Borg 的研究人员在论文中提到的一个非常重要的观点：

> 运行在大规模集群中的各种任务之间，实际上存在着各种各样的关系。这些关系的处理，才是作业编排和管理系统最困难的地方。

事实也正是如此。

**其实，这种任务与任务之间的关系，在我们平常的各种技术场景中随处可见。比如，一个 Web 应用与数据库之间的访问关系，一个负载均衡器和它的后端服务之间的代理关系，一个门户应用与授权组件之间的调用关系。**

更进一步地说，同属于一个服务单位的不同功能之间，也完全可能存在这样的关系。比如，一个 Web 应用与日志搜集组件之间的文件交换关系。

而在容器技术普及之前，传统虚拟机环境对这种关系的处理方法都是比较“粗粒度”的。你会经常发现很多功能并不相关的应用被一股脑儿地部署在同一台虚拟机中，只是因为它们之间偶尔会互相发起几个 HTTP 请求。

更常见的情况则是，一个应用被部署在虚拟机里之后，你还得手动维护很多跟它协作的守护进程（Daemon），用来处理它的日志搜集、灾难恢复、数据备份等辅助工作。

但容器技术出现以后，你就不难发现，在“功能单位”的划分上，容器有着独一无二的“细粒度”优势：毕竟容器的本质，只是一个进程而已。

也就是说，只要你愿意，那些原先拥挤在同一个虚拟机里的各个应用、组件、守护进程，都可以被分别做成镜像，然后运行在一个个专属的容器中。它们之间互不干涉，拥有各自的资源配额，可以被调度在整个集群里的任何一台机器上。而这，正是一个 PaaS 系统最理想的工作状态，也是所谓“微服务”思想得以落地的先决条件。

当然，如果只做到“封装微服务、调度单容器”这一层次，Docker Swarm 项目就已经绰绰有余了。如果再加上 Compose 项目，你甚至还具备了处理一些简单依赖关系的能力，比如：一个“Web 容器”和它要访问的数据库“DB 容器”

在 Compose 项目中，你可以为这样的两个容器定义一个“link”，而 Docker 项目则会负责维护这个“link”关系，其具体做法是：Docker 会在 Web 容器中，将 DB 容器的 IP 地址、端口等信息以环境变量的方式注入进去，供应用进程使用，比如：

```sh
DB_NAME=/web/db
DB_PORT=tcp://172.17.0.5:5432
DB_PORT_5432_TCP=tcp://172.17.0.5:5432
DB_PORT_5432_TCP_PROTO=tcp
DB_PORT_5432_TCP_PORT=5432
DB_PORT_5432_TCP_ADDR=172.17.0.5
```

而当 DB 容器发生变化时（比如，镜像更新，被迁移到其他宿主机上等等），这些环境变量的值会由 Docker 项目自动更新。**这就是平台项目自动地处理容器间关系的典型例子**。

可是，如果我们现在的需求是，要求这个项目能够处理前面提到的所有类型的关系，甚至还要能够支持未来可能出现的更多种类的关系呢？

这时，“link”这种单独针对一种案例设计的解决方案就太过简单了。如果你做过架构方面的工作，就会深有感触：一旦要追求项目的普适性，那就一定要从顶层开始做好设计

所以，**Kubernetes 项目最主要的设计思想是，从更宏观的角度，以统一的方式来定义任务之间的各种关系，并且为将来支持更多种类的关系留有余地**。

比如，Kubernetes 项目对容器间的“访问”进行了分类，首先总结出了一类非常常见的“紧密交互”的关系，即：这些应用之间需要非常频繁的交互和访问；又或者，它们会直接通过本地文件进行信息交换。

在常规环境下，这些应用往往会被直接部署在同一台机器上，通过 Localhost 通信，通过本地磁盘目录交换文件。而在 Kubernetes 项目中，这些容器则会被划分为一个“Pod”，Pod 里的容器共享同一个 Network Namespace、同一组数据卷，从而达到高效率交换信息的目的。

Pod 是 Kubernetes 项目中最基础的一个对象，源自于 Google Borg 论文中一个名叫 Alloc 的设计。在后续的章节中，我们会对 Pod 做更进一步地阐述。

而对于另外一种更为常见的需求，比如 Web 应用与数据库之间的访问关系，Kubernetes 项目则提供了一种叫作“Service”的服务。像这样的两个应用，往往故意不部署在同一台机器上，这样即使 Web 应用所在的机器宕机了，数据库也完全不受影响。可是，我们知道，对于一个容器来说，它的 IP 地址等信息不是固定的，那么 Web 应用又怎么找到数据库容器的 Pod 呢？

所以，**Kubernetes 项目的做法是给 Pod 绑定一个 Service 服务，而 Service 服务声明的 IP 地址等信息是“终生不变”的。这个 Service 服务的主要作用，就是作为 Pod 的代理入口（Portal），从而代替 Pod 对外暴露一个固定的网络地址。**

这样，对于 Web 应用的 Pod 来说，它需要关心的就是数据库 Pod 的 Service 信息。不难想象，Service 后端真正代理的 Pod 的 IP 地址、端口等信息的自动更新、维护，则是 Kubernetes 项目的职责。

像这样，围绕着容器和 Pod 不断向真实的技术场景扩展，我们就能够摸索出一幅如下所示的 Kubernetes 项目核心功能的“全景图”。

![img](https://static001.geekbang.org/resource/image/16/06/16c095d6efb8d8c226ad9b098689f306.png)

按照这幅图的线索，我们从容器这个最基础的概念出发，首先遇到了容器间“紧密协作”关系的难题，于是就扩展到了 Pod；有了 Pod 之后，我们希望能一次启动多个应用的实例，这样就需要 Deployment 这个 Pod 的多实例管理器；而有了这样一组相同的 Pod 后，我们又需要通过一个固定的 IP 地址和端口以负载均衡的方式访问它，于是就有了 Service。

可是，如果现在两个不同 Pod 之间不仅有“访问关系”，还要求在发起时加上授权信息。最典型的例子就是 Web 应用对数据库访问时需要 Credential（数据库的用户名和密码）信息。那么，在 Kubernetes 中这样的关系又如何处理呢？

Kubernetes 项目提供了一种叫作 Secret 的对象，它其实是一个保存在 Etcd 里的键值对数据。这样，你把 Credential 信息以 Secret 的方式存在 Etcd 里，Kubernetes 就会在你指定的 Pod（比如，Web 应用的 Pod）启动时，自动把 Secret 里的数据以 Volume 的方式挂载到容器里。这样，这个 Web 应用就可以访问数据库了

**除了应用与应用之间的关系外，应用运行的形态是影响“如何容器化这个应用”的第二个重要因素。**

为此，Kubernetes 定义了新的、基于 Pod 改进后的对象。比如 Job，用来描述一次性运行的 Pod（比如，大数据任务）；再比如 DaemonSet，用来描述每个宿主机上必须且只能运行一个副本的守护进程服务；又比如 CronJob，则用于描述定时任务等等。

如此种种，正是 Kubernetes 项目定义容器间关系和形态的主要方法。

可以看到，Kubernetes 项目并没有像其他项目那样，为每一个管理功能创建一个指令，然后在项目中实现其中的逻辑。这种做法，的确可以解决当前的问题，但是在更多的问题来临之后，往往会力不从心。

相比之下，在 Kubernetes 项目中，我们所推崇的使用方法是：

+ 首先，通过一个“编排对象”，比如 Pod、Job、CronJob 等，来描述你试图管理的应用；
+ 然后，再为它定义一些“服务对象”，比如 Service、Secret、Horizontal Pod Autoscaler（自动水平扩展器）等。这些对象，会负责具体的平台级功能

**这种使用方法，就是所谓的“声明式 API”。这种 API 对应的“编排对象”和“服务对象”，都是 Kubernetes 项目中的 API 对象（API Object）。**

这就是 Kubernetes 最核心的设计理念，也是接下来我会重点剖析的关键技术点。

<font style='color:orange'>最后，我来回答一个更直接的问题：Kubernetes 项目如何启动一个容器化任务呢？</font>

比如，我现在已经制作好了一个 Nginx 容器镜像，希望让平台帮我启动这个镜像。并且，我要求平台帮我运行两个完全相同的 Nginx 副本，以负载均衡的方式共同对外提供服务。

+ 如果是自己 DIY 的话，可能需要启动两台虚拟机，分别安装两个 Nginx，然后使用 keepalived 为这两个虚拟机做一个虚拟 IP。
+ 而如果使用 Kubernetes 项目呢？你需要做的则是编写如下这样一个 YAML 文件（比如名叫 nginx-deployment.yaml）：

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

在上面这个 YAML 文件中，我们定义了一个 Deployment 对象，它的主体部分（spec.template 部分）是一个使用 Nginx 镜像的 Pod，而这个 Pod 的副本数是 2（replicas=2）。

然后执行：

```sh
$ kubectl create -f nginx-deployment.yaml
```

这样，两个完全相同的 Nginx 容器副本就被启动了。

不过，这么看来，做同样一件事情，Kubernetes 用户要做的工作也不少嘛。

别急，在后续的讲解中，我会陆续介绍 Kubernetes 项目这种“声明式 API”的种种好处，以及基于它实现的强大的编排能力。

**总结**

首先，我和你一起回顾了容器的核心知识，说明了容器其实可以分为两个部分：容器运行时和容器镜像。

然后，我重点介绍了 Kubernetes 项目的架构，详细讲解了它如何使用“声明式 API”来描述容器化业务和容器间关系的设计思想

实际上，过去很多的集群管理项目（比如 Yarn、Mesos，以及 Swarm）所擅长的，都是把一个容器，按照某种规则，放置在某个最佳节点上运行起来。这种功能，我们称为“调度”。

而 Kubernetes 项目所擅长的，是按照用户的意愿和整个系统的规则，完全自动化地处理好容器之间的各种关系。这种功能，**就是我们经常听到的一个概念：编排**。

所以说，Kubernetes 项目的本质，是为用户提供一个具有普遍意义的容器编排工具。

不过，更重要的是，Kubernetes 项目为用户提供的不仅限于一个工具。它真正的价值，乃在于提供了一套基于容器构建分布式系统的基础依赖。关于这一点，相信你会在今后的学习中，体会越来越深。

**思考题**

1. 这今天的分享中，我介绍了 Kubernetes 项目的架构。你是否了解了 Docker Swarm（SwarmKit 项目）和 Kubernetes 在架构上和使用方法上的异同呢？
2. 在 Kubernetes 之前，很多项目都没办法管理“有状态”的容器，即，不能从一台宿主机“迁移”到另一台宿主机上的容器。你是否能列举出，阻止这种“迁移”的原因都有哪些呢？

```txt
感觉不能迁移“有状态”的容器，是因为迁移的是容器的rootfs，但是一些动态视图是没有办法伴随迁移一同进行迁移的。
到目前为止，迁移都是做不到的，只能删除后在新的节点上重新创建
```

## Kubernetes一键部署利器：

### kubeadm

> **要真正发挥容器技术的实力，你就不能仅仅局限于对 Linux 容器本身的钻研和使用。**

这些知识更适合作为你的技术储备，以便在需要的时候可以帮你更快地定位问题，并解决问题。

而更深入地学习容器技术的关键在于，**如何使用这些技术来“容器化”你的应用。**

比如，我们的应用既可能是 Java Web 和 MySQL 这样的组合，也可能是 Cassandra 这样的分布式系统。而要使用容器把后者运行起来，你单单通过 Docker 把一个 Cassandra 镜像跑起来是没用的。

要把 Cassandra 应用容器化的关键，在于如何处理好这些 Cassandra 容器之间的编排关系。比如，哪些 Cassandra 容器是主，哪些是从？主从容器如何区分？它们之间又如何进行自动发现和通信？Cassandra 容器的持久化数据又如何保持，等等。

这也是为什么我们要反复强调 Kubernetes 项目的主要原因：这个项目体现出来的容器化“表达能力”，具有独有的先进性和完备性。这就使得它不仅能运行 Java Web 与 MySQL 这样的常规组合，还能够处理 Cassandra 容器集群等复杂编排问题。所以，对这种编排能力的剖析、解读和最佳实践，将是本专栏最重要的一部分内容。

不过，万事开头难。

作为一个典型的分布式项目，Kubernetes 的部署一直以来都是挡在初学者前面的一只“拦路虎”。尤其是在 Kubernetes 项目发布初期，它的部署完全要依靠一堆由社区维护的脚本。

其实，Kubernetes 作为一个 Golang 项目，已经免去了很多类似于 Python 项目要安装语言级别依赖的麻烦。但是，除了将各个组件编译成二进制文件外，用户还要负责为这些二进制文件编写对应的配置文件、配置自启动脚本，以及为 kube-apiserver 配置授权文件等等诸多运维工作

目前，各大云厂商最常用的部署的方法，是使用 SaltStack、Ansible 等运维工具自动化地执行这些步骤

但即使这样，这个部署过程依然非常繁琐。因为，SaltStack 这类专业运维工具本身的学习成本，就可能比 Kubernetes 项目还要高。

**难道 Kubernetes 项目就没有简单的部署方法了吗？**

这个问题，在 Kubernetes 社区里一直没有得到足够重视。直到 2017 年，在志愿者的推动下，社区才终于发起了一个独立的部署工具，名叫：kubeadm。

这个项目的目的，就是要让用户能够通过这样两条指令完成一个 Kubernetes 集群的部署：

```shell
# 创建一个Master节点
$ kubeadm init

# 将一个Node节点加入到当前集群中
$ kubeadm join <Master节点的IP和端口>
```

是不是非常方便呢？

不过，你可能也会有所顾虑：**Kubernetes 的功能那么多，这样一键部署出来的集群，能用于生产环境吗**？

为了回答这个问题，在今天这篇文章，我就先和你介绍一下 kubeadm 的工作原理吧

**kubeadm 的工作原理**

在上一篇文章《从容器到容器云：谈谈 Kubernetes 的本质》中，我已经详细介绍了 Kubernetes 的架构和它的组件。在部署时，它的每一个组件都是一个需要被执行的、单独的二进制文件。所以不难想象，SaltStack 这样的运维工具或者由社区维护的脚本的功能，就是要把这些二进制文件传输到指定的机器当中，然后编写控制脚本来启停这些组件

不过，在理解了容器技术之后，你可能已经萌生出了这样一个想法，**为什么不用容器部署 Kubernetes 呢**？

这样，我只要给每个 Kubernetes 组件做一个容器镜像，然后在每台宿主机上用 docker run 指令启动这些组件容器，部署不就完成了吗？

事实上，在 Kubernetes 早期的部署脚本里，确实有一个脚本就是用 Docker 部署 Kubernetes 项目的，这个脚本相比于 SaltStack 等的部署方式，也的确简单了不少。

但是，这样做会带来一个很麻烦的问题，即：**如何容器化 kubelet。**

我在上一篇文章中，已经提到 kubelet 是 Kubernetes 项目用来操作 Docker 等容器运行时的核心组件。可是，除了跟容器运行时打交道外，kubelet 在配置容器网络、管理容器数据卷时，都需要直接操作宿主机。

而如果现在 kubelet 本身就运行在一个容器里，那么直接操作宿主机就会变得很麻烦。对于网络配置来说还好，kubelet 容器可以通过不开启 Network Namespace（即 Docker 的 host network 模式）的方式，直接共享宿主机的网络栈。可是，要让 kubelet 隔着容器的 Mount Namespace 和文件系统，操作宿主机的文件系统，就有点儿困难了。

比如，如果用户想要使用 NFS 做容器的持久化数据卷，那么 kubelet 就需要在容器进行绑定挂载前，在宿主机的指定目录上，先挂载 NFS 的远程目录。

可是，这时候问题来了。由于现在 kubelet 是运行在容器里的，这就意味着它要做的这个“mount -F nfs”命令，被隔离在了一个单独的 Mount Namespace 中。即，kubelet 做的挂载操作，不能被“传播”到宿主机上。

对于这个问题，有人说，可以使用 setns() 系统调用，在宿主机的 Mount Namespace 中执行这些挂载操作；也有人说，应该让 Docker 支持一个–mnt=host 的参数。

但是，到目前为止，在容器里运行 kubelet，依然没有很好的解决办法，我也不推荐你用容器去部署 Kubernetes 项目。

正因为如此，kubeadm 选择了一种妥协方案：

> 把 kubelet 直接运行在宿主机上，然后使用容器部署其他的 Kubernetes 组件。

所以，你使用 kubeadm 的第一步，是在机器上手动安装 kubeadm、kubelet 和 kubectl 这三个二进制文件。当然，kubeadm 的作者已经为各个发行版的 Linux 准备好了安装包，所以你只需要执行：

```shell
$ apt-get install kubeadm
```

就可以了。

接下来，你就可以使用“kubeadm init”部署 Master 节点了。

#### **kubeadm init 的工作流程**

当你执行 kubeadm init 指令后，kubeadm 首先要做的，是一系列的检查工作，以确定这台机器可以用来部署 Kubernetes。这一步检查，我们称为“Preflight Checks”，它可以为你省掉很多后续的麻烦

其实，Preflight Checks 包括了很多方面，比如：

+ Linux 内核的版本必须是否是 3.10 以上？
+ Linux Cgroups 模块是否可用？
+ 机器的 hostname 是否标准？
+ 在 Kubernetes 项目里，机器的名字以及一切存储在 Etcd 中的 API 对象，都必须使用标准的 DNS 命名（RFC 1123）。用户安装的 kubeadm 和 kubelet 的版本是否匹配？
+ 机器上是不是已经安装了 Kubernetes 的二进制文件？
+ Kubernetes 的工作端口 10250/10251/10252 端口是不是已经被占用？
+ ip、mount 等 Linux 指令是否存在？
+ Docker 是否已经安装？
+ ……

**在通过了 Preflight Checks 之后，kubeadm 要为你做的，是生成 Kubernetes 对外提供服务所需的各种证书和对应的目录。**

Kubernetes 对外提供服务时，除非专门开启“不安全模式”，否则都要通过 HTTPS 才能访问 kube-apiserver。这就需要为 Kubernetes 集群配置好证书文件。

kubeadm 为 Kubernetes 项目生成的证书文件都放在 Master 节点的 /etc/kubernetes/pki 目录下。在这个目录下，最主要的证书文件是 ca.crt 和对应的私钥 ca.key。

此外，用户使用 kubectl 获取容器日志等 streaming 操作时，需要通过 kube-apiserver 向 kubelet 发起请求，这个连接也必须是安全的。kubeadm 为这一步生成的是 apiserver-kubelet-client.crt 文件，对应的私钥是 apiserver-kubelet-client.key。

除此之外，Kubernetes 集群中还有 Aggregate APIServer 等特性，也需要用到专门的证书，这里我就不再一一列举了。需要指出的是，你可以选择不让 kubeadm 为你生成这些证书，而是拷贝现有的证书到如下证书的目录里：

```sh
/etc/kubernetes/pki/ca.{crt,key}
```

这时，kubeadm 就会跳过证书生成的步骤，把它完全交给用户处理

**证书生成后，kubeadm 接下来会为其他组件生成访问 kube-apiserver 所需的配置文件**。这些文件的路径是：/etc/kubernetes/xxx.conf：

```shell
ls /etc/kubernetes/
admin.conf  controller-manager.conf  kubelet.conf  scheduler.conf
```

这些文件里面记录的是，当前这个 Master 节点的服务器地址、监听端口、证书目录等信息。这样，对应的客户端（比如 scheduler，kubelet 等），可以直接加载相应的文件，使用里面的信息与 kube-apiserver 建立安全连接

**接下来，kubeadm 会为 Master 组件生成 Pod 配置文件。**我已经在上一篇文章中和你介绍过 Kubernetes 有三个 Master 组件 kube-apiserver、kube-controller-manager、kube-scheduler，而它们都会被使用 Pod 的方式部署起来。

你可能会有些疑问：这时，Kubernetes 集群尚不存在，难道 kubeadm 会直接执行 docker run 来启动这些容器吗？

当然不是。

在 Kubernetes 中，有一种特殊的容器启动方法叫做“Static Pod”。它允许你把要部署的 Pod 的 YAML 文件放在一个指定的目录里。这样，当这台机器上的 kubelet 启动时，它会自动检查这个目录，加载所有的 Pod YAML 文件，然后在这台机器上启动它们。

从这一点也可以看出，kubelet 在 Kubernetes 项目中的地位非常高，在设计上它就是一个完全独立的组件，而其他 Master 组件，则更像是辅助性的系统容器。

在 kubeadm 中，Master 组件的 YAML 文件会被生成在 /etc/kubernetes/manifests 路径下。比如，kube-apiserver.yaml：

```yml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --authorization-mode=Node,RBAC
    - --runtime-config=api/all=true
    - --advertise-address=10.168.0.2
    ...
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    image: k8s.gcr.io/kube-apiserver-amd64:v1.11.1
    imagePullPolicy: IfNotPresent
    livenessProbe:
      ...
    name: kube-apiserver
    resources:
      requests:
        cpu: 250m
    volumeMounts:
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
    ...
  hostNetwork: true
  priorityClassName: system-cluster-critical
  volumes:
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  ...
```

关于一个 Pod 的 YAML 文件怎么写、里面的字段如何解读，我会在后续专门的文章中为你详细分析。在这里，你只需要关注这样几个信息：

1. 这个 Pod 里只定义了一个容器，它使用的镜像是：k8s.gcr.io/kube-apiserver-amd64:v1.11.1 。这个镜像是 Kubernetes 官方维护的一个组件镜像。
2. 这个容器的启动命令（commands）是 kube-apiserver --authorization-mode=Node,RBAC …，这样一句非常长的命令。其实，它就是容器里 kube-apiserver 这个二进制文件再加上指定的配置参数而已。
3. 如果你要修改一个已有集群的 kube-apiserver 的配置，需要修改这个 YAML 文件
4. 这些组件的参数也可以在部署时指定，我很快就会讲到。

在这一步完成后，kubeadm 还会再生成一个 Etcd 的 Pod YAML 文件，用来通过同样的 Static Pod 的方式启动 Etcd。所以，最后 Master 组件的 Pod YAML 文件如下所示：

```sh
$ ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```

而一旦这些 YAML 文件出现在被 kubelet 监视的 /etc/kubernetes/manifests 目录下，kubelet 就会自动创建这些 YAML 文件中定义的 Pod，即 Master 组件的容器。

Master 容器启动后，kubeadm 会通过检查 localhost:6443/healthz 这个 Master 组件的健康检查 URL，等待 Master 组件完全运行起来。

然后，**kubeadm 就会为集群生成一个 bootstrap token**。在后面，只要持有这个 token，任何一个安装了 kubelet 和 kubadm 的节点，都可以通过 kubeadm join 加入到这个集群当中

这个 token 的值和使用方法，会在 kubeadm init 结束后被打印出来。

**在 token 生成之后，kubeadm 会将 ca.crt 等 Master 节点的重要信息，通过 ConfigMap 的方式保存在 Etcd 当中，供后续部署 Node 节点使用**。这个 ConfigMap 的名字是 cluster-info。

**kubeadm init 的最后一步，就是安装默认插件**。Kubernetes 默认 kube-proxy 和 DNS 这两个插件是必须安装的。它们分别用来提供整个集群的服务发现和 DNS 功能。其实，这两个插件也只是两个容器镜像而已，所以 kubeadm 只要用 Kubernetes 客户端创建两个 Pod 就可以了。

#### **kubeadm join 的工作流程**

这个流程其实非常简单，kubeadm init 生成 bootstrap token 之后，你就可以在任意一台安装了 kubelet 和 kubeadm 的机器上执行 kubeadm join 了。

可是，为什么执行 kubeadm join 需要这样一个 token 呢？

因为，任何一台机器想要成为 Kubernetes 集群中的一个节点，就必须在集群的 kube-apiserver 上注册。可是，要想跟 apiserver 打交道，这台机器就必须要获取到相应的证书文件（CA 文件）。可是，为了能够一键安装，我们就不能让用户去 Master 节点上手动拷贝这些文件。

所以，kubeadm 至少需要发起一次“不安全模式”的访问到 kube-apiserver，从而拿到保存在 ConfigMap 中的 cluster-info（它保存了 APIServer 的授权信息）。而 bootstrap token，扮演的就是这个过程中的安全验证的角色

只要有了 cluster-info 里的 kube-apiserver 的地址、端口、证书，kubelet 就可以以“安全模式”连接到 apiserver 上，这样一个新的节点就部署完成了。

接下来，你只要在其他节点上重复这个指令就可以了。

#### 配置 kubeadm 的部署参数

我在前面讲了 kubeadm 部署 Kubernetes 集群最关键的两个步骤，kubeadm init 和 kubeadm join。相信你一定会有这样的疑问：kubeadm 确实简单易用，可是我又该如何定制我的集群组件参数呢？

比如，我要指定 kube-apiserver 的启动参数，该怎么办？

在这里，我强烈推荐你在使用 kubeadm init 部署 Master 节点时，使用下面这条指令：

```shell
$ kubeadm init --config kubeadm.yaml
```

这时，你就可以给 kubeadm 提供一个 YAML 文件（比如，kubeadm.yaml），它的内容如下所示（我仅列举了主要部分）：

```yml
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.11.0
api:
  advertiseAddress: 192.168.0.102
  bindPort: 6443
  ...
etcd:
  local:
    dataDir: /var/lib/etcd
    image: ""
imageRepository: k8s.gcr.io
kubeProxy:
  config:
    bindAddress: 0.0.0.0
    ...
kubeletConfiguration:
  baseConfig:
    address: 0.0.0.0
    ...
networking:
  dnsDomain: cluster.local
  podSubnet: ""
  serviceSubnet: 10.96.0.0/12
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  ...
```

通过制定这样一个部署参数配置文件，你就可以很方便地在这个文件里填写各种自定义的部署参数了。比如，我现在要指定 kube-apiserver 的参数，那么我只要在这个文件里加上这样一段信息

```yml
...
apiServerExtraArgs:
  advertise-address: 192.168.0.103
  anonymous-auth: false
  enable-admission-plugins: AlwaysPullImages,DefaultStorageClass
  audit-log-path: /home/johndoe/audit.log
```

然后，kubeadm 就会使用上面这些信息替换 /etc/kubernetes/manifests/kube-apiserver.yaml 里的 command 字段里的参数了

而这个 YAML 文件提供的可配置项远不止这些。比如，你还可以修改 kubelet 和 kube-proxy 的配置，修改 Kubernetes 使用的基础镜像的 URL（默认的k8s.gcr.io/xxx镜像 URL 在国内访问是有困难的），指定自己的证书文件，指定特殊的容器运行时等等。这些配置项，就留给你在后续实践中探索了。

#### 总结

在今天的这次分享中，我重点介绍了 kubeadm 这个部署工具的工作原理和使用方法。紧接着，我会在下一篇文章中，使用它一步步地部署一个完整的 Kubernetes 集群。

从今天的分享中，你可以看到，kubeadm 的设计非常简洁。并且，它在实现每一步部署功能时，都在最大程度地重用 Kubernetes 已有的功能，这也就使得我们在使用 kubeadm 部署 Kubernetes 项目时，非常有“原生”的感觉，一点都不会感到突兀。

而 kubeadm 的源代码，直接就在 kubernetes/cmd/kubeadm 目录下，是 Kubernetes 项目的一部分。其中，app/phases 文件夹下的代码，对应的就是我在这篇文章中详细介绍的每一个具体步骤。

看到这里，你可能会猜想，kubeadm 的作者一定是 Google 公司的某个“大神”吧。

实际上，kubeadm 几乎完全是一位高中生的作品。他叫 Lucas Käldström，芬兰人，今年只有 18 岁。kubeadm，是他 17 岁时用业余时间完成的一个社区项目。

所以说，开源社区的魅力也在于此：一个成功的开源项目，总能够吸引到全世界最厉害的贡献者参与其中。尽管参与者的总体水平参差不齐，而且频繁的开源活动又显得杂乱无章难以管控，但一个有足够热度的社区最终的收敛方向，却一定是代码越来越完善、Bug 越来越少、功能越来越强大。

最后，我再来回答一下我在今天这次分享开始提到的问题：kubeadm 能够用于生产环境吗？

到目前为止（2018 年 9 月），这个问题的答案是：不能。

因为 kubeadm 目前最欠缺的是，一键部署一个高可用的 Kubernetes 集群，即：Etcd、Master 组件都应该是多节点集群，而不是现在这样的单点。这，当然也正是 kubeadm 接下来发展的主要方向。

另一方面，Lucas 也正在积极地把 kubeadm phases 开放给用户，即：用户可以更加自由地定制 kubeadm 的每一个部署步骤。这些举措，都可以让这个项目更加完善，我对它的发展走向也充满了信心。

当然，如果你有部署规模化生产环境的需求，我推荐使用kops或者 SaltStack 这样更复杂的部署工具。但，在本专栏接下来的讲解中，我都会以 kubeadm 为依据进行讲述。

+ 一方面，作为 Kubernetes 项目的原生部署工具，kubeadm 对 Kubernetes 项目特性的使用和集成，确实要比其他项目“技高一筹”，非常值得我们学习和借鉴；
+ 另一方面，kubeadm 的部署方法，不会涉及到太多的运维工作，也不需要我们额外学习复杂的部署工具。而它部署的 Kubernetes 集群，跟一个完全使用二进制文件搭建起来的集群几乎没有任何区别

因此，使用 kubeadm 去部署一个 Kubernetes 集群，对于你理解 Kubernetes 组件的工作方式和架构，最好不过了

**思考题**

1. 在 Linux 上为一个类似 kube-apiserver 的 Web Server 制作证书，你知道可以用哪些工具实现吗？
2. 回忆一下我在前面文章中分享的 Kubernetes 架构，你能够说出 Kubernetes 各个功能组件之间（包含 Etcd），都有哪些建立连接或者调用的方式吗？（比如：HTTP/HTTPS，远程调用等等）



**国内通过kubeadm安装**

```
环境

master01:192.168.1.110 （最少2核CPU）

node01:192.168.1.100

规划

services网络：10.96.0.0/12

pod网络：10.244.0.0/16

 

1.配置hosts解析各主机

vim /etc/hosts

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.110 master01
192.168.1.100 node01
2.同步各主机时间

yum install -y ntpdate
ntpdate time.windows.com
14 Mar 16:51:32 ntpdate[46363]: adjust time server 13.65.88.161 offset -0.001108 sec
3.关闭SWAP，关闭selinux

swapoff -a
复制代码
vim /etc/selinux/config

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
复制代码
4.安装docker-ce

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum -y install docker-ce
Docker 安装后出现：WARNING: bridge-nf-call-iptables is disabled 的解决办法

复制代码
vim /etc/sysctl.conf

# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-arptables=1
复制代码
systemctl enable docker && systemctl start docker
5.安装kubernetes

复制代码
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
复制代码
6.初始化集群

注意:这是我自己写的:需要修改
查看k8s安装需要的镜像
kubeadm config images list
然后上述过程镜像已经拉取了,需要重新命名这些镜像,打上标记
docker tag source[:tag] target[:source]


kubeadm init --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.13.1 --pod-network-cidr=10.244.0.0/16
复制代码
Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 192.168.1.110:6443 --token wgrs62.vy0trlpuwtm5jd75 --discovery-token-ca-cert-hash sha256:6e947e63b176acf976899483d41148609a6e109067ed6970b9fbca8d9261c8d0
复制代码
7.手动部署flannel

flannel网址：https://github.com/coreos/flannel

for Kubernetes v1.7+

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
复制代码
podsecuritypolicy.extensions/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds-amd64 created
daemonset.extensions/kube-flannel-ds-arm64 created
daemonset.extensions/kube-flannel-ds-arm created
daemonset.extensions/kube-flannel-ds-ppc64le created
daemonset.extensions/kube-flannel-ds-s390x created
复制代码
8.node配置

安装docker kubelet kubeadm

docker安装同步骤4，kubelet kubeadm安装同步骤5

9.node加入到master

kubeadm join 192.168.1.110:6443 --token wgrs62.vy0trlpuwtm5jd75 --discovery-token-ca-cert-hash sha256:6e947e63b176acf976899483d41148609a6e109067ed6970b9fbca8d9261c8d0
kubectl get nodes  #查看node状态

NAME                    STATUS     ROLES    AGE     VERSION
localhost.localdomain   NotReady   <none>   130m    v1.13.4
master01                Ready      master   4h47m   v1.13.4
node01                  Ready      <none>   94m     v1.13.4
kubectl get cs  #查看组件状态

NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok                   
controller-manager   Healthy   ok                   
etcd-0               Healthy   {"health": "true"}  
kubectl get ns  #查看名称空间

NAME          STATUS   AGE
default       Active   4h41m
kube-public   Active   4h41m
kube-system   Active   4h41m
复制代码
kubectl get pods -n kube-system  #查看pod状态

NAME                               READY   STATUS    RESTARTS   AGE
coredns-78d4cf999f-bszbk           1/1     Running   0          4h44m
coredns-78d4cf999f-j68hb           1/1     Running   0          4h44m
etcd-master01                      1/1     Running   0          4h43m
kube-apiserver-master01            1/1     Running   1          4h43m
kube-controller-manager-master01   1/1     Running   2          4h43m
kube-flannel-ds-amd64-27x59        1/1     Running   1          126m
kube-flannel-ds-amd64-5sxgk        1/1     Running   0          140m
kube-flannel-ds-amd64-xvrbw        1/1     Running   0          91m
kube-proxy-4pbdf                   1/1     Running   0          91m
kube-proxy-9fmrl                   1/1     Running   0          4h44m
kube-proxy-nwkl9                   1/1     Running   0          126m
kube-scheduler-master01            1/1     Running   2          4h43m
复制代码
```

### 从0到1：搭建一个完整的Kubernetes集群

不过，首先需要指出的是，本篇搭建指南是完全的手工操作，细节比较多，并且有些外部链接可能还会遇到特殊的“网络问题”。所以，对于只关心学习 Kubernetes 本身知识点、不太关注如何手工部署 Kubernetes 集群的同学，可以略过本节，直接使用 MiniKube 或者 Kind，来在本地启动简单的 Kubernetes 集群进行后面的学习即可。如果是使用 MiniKube 的话，阿里云还维护了一个国内版的 MiniKube，这对于在国内的同学来说会比较友好。

在上一篇文章中，我介绍了 kubeadm 这个 Kubernetes 半官方管理工具的工作原理。既然 kubeadm 的初衷是让 Kubernetes 集群的部署不再让人头疼，那么这篇文章，我们就来使用它部署一个完整的 Kubernetes 集群吧。

> 备注：这里所说的“完整”，指的是这个集群具备 Kubernetes 项目在 GitHub 上已经发布的所有功能，并能够模拟生产环境的所有使用需求。但并不代表这个集群是生产级别可用的：类似于高可用、授权、多租户、灾难备份等生产级别集群的功能暂时不在本篇文章的讨论范围。目前，kubeadm 的高可用部署已经有了第一个发布。但是，这个特性还没有 GA（生产可用），所以包括了大量的手动工作，跟我们所预期的一键部署还有一定距离。GA 的日期预计是 2018 年底到 2019 年初。届时，如果有机会我会再和你分享这部分内容。

这次部署，我不会依赖于任何公有云或私有云的能力，而是完全在 Bare-metal 环境中完成。这样的部署经验会更有普适性。而在后续的讲解中，如非特殊强调，我也都会以本次搭建的这个集群为基础。

#### 准备工作

首先，准备机器。最直接的办法，自然是到公有云上申请几个虚拟机。当然，如果条件允许的话，拿几台本地的物理服务器来组集群是最好不过了。这些机器只要满足如下几个条件即可：

1. 满足安装 Docker 项目所需的要求，比如 64 位的 Linux 操作系统、3.10 及以上的内核版本；
2. x86 或者 ARM 架构均可；
3. 机器之间网络互通，这是将来容器之间网络互通的前提；
4. 有外网访问权限，因为需要拉取镜像；
5. 能够访问到gcr.io、quay.io这两个 docker registry，因为有小部分镜像需要在这里拉取；
6. 单机可用资源建议 2 核 CPU、8 GB 内存或以上，再小的话问题也不大，但是能调度的 Pod 数量就比较有限了；
7. 30 GB 或以上的可用磁盘空间，这主要是留给 Docker 镜像和日志文件用的。

在本次部署中，我准备的机器配置如下：

1. 2 核 CPU、 7.5 GB 内存；
2. 30 GB 磁盘；
3. Ubuntu 16.04；
4. 内网互通；
5. 外网访问权限不受限制。

> 备注：在开始部署前，我推荐你先花几分钟时间，回忆一下 Kubernetes 的架构。

然后，我再和你介绍一下今天实践的目标：

1. 在所有节点上安装 Docker 和 kubeadm；
2. 部署 Kubernetes Master；
3. 部署容器网络插件；
4. 部署 Kubernetes Worker；
5. 部署 Dashboard 可视化插件；
6. 部署容器存储插件。

好了，现在，就来开始这次集群部署之旅吧！

#### 安装 kubeadm 和 Docker

我在上一篇文章《 Kubernetes 一键部署利器：kubeadm》中，已经介绍过 kubeadm 的基础用法，它的一键安装非常方便，我们只需要添加 kubeadm 的源，然后直接使用 apt-get 安装即可，具体流程如下所示：

> 备注：为了方便讲解，我后续都会直接在 root 用户下进行操作。

```sh
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
$ cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
$ apt-get update
$ apt-get install -y docker.io kubeadm
```

> 提示：如果 apt.kubernetes.io 因为网络问题访问不到，可以换成中科大的 Ubuntu 镜像源 deb http://mirrors.ustc.edu.cn/kubernetes/apt kubernetes-xenial main。 

在上述安装 kubeadm 的过程中，kubeadm 和 kubelet、kubectl、kubernetes-cni 这几个二进制文件都会被自动安装好

另外，这里我直接使用 Ubuntu 的 docker.io 的安装源，原因是 Docker 公司每次发布的最新的 Docker CE（社区版）产品往往还没有经过 Kubernetes 项目的验证，可能会有兼容性方面的问题。

#### 部署 Kubernetes 的 Master 节点

在上一篇文章中，我已经介绍过 kubeadm 可以一键部署 Master 节点。不过，在本篇文章中既然要部署一个“完整”的 Kubernetes 集群，那我们不妨稍微提高一下难度：通过配置文件来开启一些实验性功能。

所以，这里我编写了一个给 kubeadm 用的 YAML 文件（名叫：kubeadm.yaml）：

```yml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
controllerManagerExtraArgs:
  horizontal-pod-autoscaler-use-rest-clients: "true"
  horizontal-pod-autoscaler-sync-period: "10s"
  node-monitor-grace-period: "10s"
apiServerExtraArgs:
  runtime-config: "api/all=true"
kubernetesVersion: "stable-1.11"
```

这个配置中，我给 kube-controller-manager 设置了：

```yml
horizontal-pod-autoscaler-use-rest-clients: "true"
```

这意味着，将来部署的 kube-controller-manager 能够使用自定义资源（Custom Metrics）进行自动水平扩展。这是我后面文章中会重点介绍的一个内容。

其中，“stable-1.11”就是 kubeadm 帮我们部署的 Kubernetes 版本号，即：Kubernetes release 1.11 最新的稳定版，在我的环境下，它是 v1.11.1。你也可以直接指定这个版本，比如：kubernetesVersion: “v1.11.1”。

然后，我们只需要执行一句指令：

```sh
$ kubeadm init --config kubeadm.yaml
```

就可以完成 Kubernetes Master 的部署了，这个过程只需要几分钟。部署完成后，kubeadm 会生成一行指令：

```sh
kubeadm join 10.168.0.2:6443 --token 00bwbx.uvnaa2ewjflwu1ry --discovery-token-ca-cert-hash sha256:00eb62a2a6020f94132e3fe1ab721349bbcd3e9b94da9654cfe15f2985ebd711
```

这个 kubeadm join 命令，就是用来给这个 Master 节点添加更多工作节点（Worker）的命令。我们在后面部署 Worker 节点的时候马上会用到它，所以找一个地方把这条命令记录下来。

此外，kubeadm 还会提示我们第一次使用 Kubernetes 集群所需要的配置命令：

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

而需要这些配置命令的原因是：Kubernetes 集群默认需要加密方式访问。所以，这几条命令，就是将刚刚部署生成的 Kubernetes 集群的安全配置文件，保存到当前用户的.kube 目录下，kubectl 默认会使用这个目录下的授权信息访问 Kubernetes 集群。

如果不这么做的话，我们每次都需要通过 export KUBECONFIG 环境变量告诉 kubectl 这个安全配置文件的位置。

现在，我们就可以使用 kubectl get 命令来查看当前唯一一个节点的状态了：

```sh
$ kubectl get nodes

NAME      STATUS     ROLES     AGE       VERSION
master    NotReady   master    1d        v1.11.1
```

可以看到，这个 get 指令输出的结果里，Master 节点的状态是 NotReady，这是为什么呢？

在调试 Kubernetes 集群时，最重要的手段就是用 **kubectl describe** 来查看这个节点（Node）对象的详细信息、状态和事件（Event），我们来试一下：

```sh
$ kubectl describe node master

...
Conditions:
...

Ready   False ... KubeletNotReady  runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
```

通过 kubectl describe 指令的输出，我们可以看到 NodeNotReady 的原因在于，我们尚未部署任何网络插件。

另外，我们还可以通过 kubectl 检查这个节点上各个系统 Pod 的状态，其中，kube-system 是 Kubernetes 项目预留的系统 Pod 的工作空间（Namepsace，注意它并不是 Linux Namespace，它只是 Kubernetes 划分不同工作空间的单位）：

```sh
$ kubectl get pods -n kube-system

NAME               READY   STATUS   RESTARTS  AGE
coredns-78fcdf6894-j9s52     0/1    Pending  0     1h
coredns-78fcdf6894-jm4wf     0/1    Pending  0     1h
etcd-master           1/1    Running  0     2s
kube-apiserver-master      1/1    Running  0     1s
kube-controller-manager-master  0/1    Pending  0     1s
kube-proxy-xbd47         1/1    NodeLost  0     1h
kube-scheduler-master      1/1    Running  0     1s
```

可以看到，CoreDNS、kube-controller-manager 等依赖于网络的 Pod 都处于 Pending 状态，即调度失败。这当然是符合预期的：因为这个 Master 节点的网络尚未就绪。

#### 部署网络插件

在 Kubernetes 项目“一切皆容器”的设计理念指导下，部署网络插件非常简单，只需要执行一句 kubectl apply 指令，以 Weave 为例：

```sh
$ kubectl apply -f https://git.io/weave-kube-1.6
```

部署完成后，我们可以通过 kubectl get 重新检查 Pod 的状态：

```sh
$ kubectl get pods -n kube-system

NAME                             READY     STATUS    RESTARTS   AGE
coredns-78fcdf6894-j9s52         1/1       Running   0          1d
coredns-78fcdf6894-jm4wf         1/1       Running   0          1d
etcd-master                      1/1       Running   0          9s
kube-apiserver-master            1/1       Running   0          9s
kube-controller-manager-master   1/1       Running   0          9s
kube-proxy-xbd47                 1/1       Running   0          1d
kube-scheduler-master            1/1       Running   0          9s
weave-net-cmk27                  2/2       Running   0          19s
```

可以看到，所有的系统 Pod 都成功启动了，而刚刚部署的 Weave 网络插件则在 kube-system 下面新建了一个名叫 weave-net-cmk27 的 Pod，一般来说，这些 Pod 就是容器网络插件在每个节点上的控制组件。

Kubernetes 支持容器网络插件，使用的是一个名叫 CNI 的通用接口，它也是当前容器网络的事实标准，市面上的所有容器网络开源项目都可以通过 CNI 接入 Kubernetes，比如 Flannel、Calico、Canal、Romana 等等，它们的部署方式也都是类似的“一键部署”。关于这些开源项目的实现细节和差异，我会在后续的网络部分详细介绍。

至此，Kubernetes 的 Master 节点就部署完成了。如果你只需要一个单节点的 Kubernetes，现在你就可以使用了。不过，在默认情况下，Kubernetes 的 Master 节点是不能运行用户 Pod 的，所以还需要额外做一个小操作。在本篇的最后部分，我会介绍到它。

#### 部署 Kubernetes 的 Worker 节点

Kubernetes 的 Worker 节点跟 Master 节点几乎是相同的，它们运行着的都是一个 kubelet 组件。唯一的区别在于，在 kubeadm init 的过程中，kubelet 启动后，Master 节点上还会自动运行 kube-apiserver、kube-scheduler、kube-controller-manger 这三个系统 Pod。

所以，相比之下，部署 Worker 节点反而是最简单的，只需要两步即可完成

第一步，在所有 Worker 节点上执行“安装 kubeadm 和 Docker”一节的所有步骤。

第二步，执行部署 Master 节点时生成的 kubeadm join 指令：

```sh
$ kubeadm join 10.168.0.2:6443 --token 00bwbx.uvnaa2ewjflwu1ry --discovery-token-ca-cert-hash sha256:00eb62a2a6020f94132e3fe1ab721349bbcd3e9b94da9654cfe15f2985ebd711
```

#### 通过 Taint/Toleration 调整 Master 执行 Pod 的策略

我在前面提到过，默认情况下 Master 节点是不允许运行用户 Pod 的。而 Kubernetes 做到这一点，依靠的是 Kubernetes 的 Taint/Toleration 机制。

它的原理非常简单：一旦某个节点被加上了一个 Taint，即被“打上了污点”，那么所有 Pod 就都不能在这个节点上运行，因为 Kubernetes 的 Pod 都有“洁癖”。

除非，有个别的 Pod 声明自己能“容忍”这个“污点”，即声明了 Toleration，它才可以在这个节点上运行。

其中，为节点打上“污点”（Taint）的命令是：

```sh
$ kubectl taint nodes node1 foo=bar:NoSchedule
```

这时，该 node1 节点上就会增加一个键值对格式的 Taint，即：foo=bar:NoSchedule。其中值里面的 NoSchedule，意味着这个 Taint 只会在调度新 Pod 时产生作用，而不会影响已经在 node1 上运行的 Pod，哪怕它们没有 Toleration。

那么 Pod 又如何声明 Toleration 呢？

我们只要在 Pod 的.yaml 文件中的 spec 部分，加入 tolerations 字段即可：

```sh
apiVersion: v1
kind: Pod
...
spec:
  tolerations:
  - key: "foo"
    operator: "Equal"
    value: "bar"
    effect: "NoSchedule"
```

这个 Toleration 的含义是，这个 Pod 能“容忍”所有键值对为 foo=bar 的 Taint（ operator: “Equal”，“等于”操作）。

现在回到我们已经搭建的集群上来。这时，如果你通过 kubectl describe 检查一下 Master 节点的 Taint 字段，就会有所发现了：

```sh
$ kubectl describe node master

Name:               master
Roles:              master
Taints:             node-role.kubernetes.io/master:NoSchedule
```

可以看到，Master 节点默认被加上了node-role.kubernetes.io/master:NoSchedule这样一个“污点”，其中“键”是node-role.kubernetes.io/master，而没有提供“值”。

此时，你就需要像下面这样用“Exists”操作符（operator: “Exists”，“存在”即可）来说明，该 Pod 能够容忍所有以 foo 为键的 Taint，才能让这个 Pod 运行在该 Master 节点上：

```sh
apiVersion: v1
kind: Pod
...
spec:
  tolerations:
  - key: "foo"
    operator: "Exists"
    effect: "NoSchedule"
```

当然，如果你就是想要一个单节点的 Kubernetes，删除这个 Taint 才是正确的选择：

```sh
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

如上所示，我们在“node-role.kubernetes.io/master”这个键后面加上了一个短横线“-”，这个格式就意味着移除所有以“node-role.kubernetes.io/master”为键的 Taint。

到了这一步，一个基本完整的 Kubernetes 集群就部署完毕了。是不是很简单呢？

有了 kubeadm 这样的原生管理工具，Kubernetes 的部署已经被大大简化。更重要的是，像证书、授权、各个组件的配置等部署中最麻烦的操作，kubeadm 都已经帮你完成了。

接下来，我们再在这个 Kubernetes 集群上安装一些其他的辅助插件，比如 Dashboard 和存储插件。

#### 部署 Dashboard 可视化插件

在 Kubernetes 社区中，有一个很受欢迎的 Dashboard 项目，它可以给用户提供一个可视化的 Web 界面来查看当前集群的各种信息。毫不意外，它的部署也相当简单：

```sh
$ kubectl apply -f 
$ $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc6/aio/deploy/recommended.yaml
```

部署完成之后，我们就可以查看 Dashboard 对应的 Pod 的状态了：

```sh
$ kubectl get pods -n kube-system

kubernetes-dashboard-6948bdb78-f67xk   1/1       Running   0          1m
```

需要注意的是，由于 Dashboard 是一个 Web Server，很多人经常会在自己的公有云上无意地暴露 Dashboard 的端口，从而造成安全隐患。所以，1.7 版本之后的 Dashboard 项目部署完成后，默认只能通过 Proxy 的方式在本地访问。具体的操作，你可以查看 Dashboard 项目的官方文档。

而如果你想从集群外访问这个 Dashboard 的话，就需要用到 Ingress，我会在后面的文章中专门介绍这部分内容

#### 部署容器存储插件

接下来，让我们完成这个 Kubernetes 集群的最后一块拼图：容器持久化存储。

我在前面介绍容器原理时已经提到过，很多时候我们需要用数据卷（Volume）把外面宿主机上的目录或者文件挂载进容器的 Mount Namespace 中，从而达到容器和宿主机共享这些目录或者文件的目的。容器里的应用，也就可以在这些数据卷中新建和写入文件。

可是，如果你在某一台机器上启动的一个容器，显然无法看到其他机器上的容器在它们的数据卷里写入的文件。这是容器最典型的特征之一：**无状态**。

而容器的持久化存储，就是用来保存容器存储状态的重要手段：存储插件会在容器里挂载一个基于网络或者其他机制的远程数据卷，使得在容器里创建的文件，实际上是保存在远程存储服务器上，或者以分布式的方式保存在多个节点上，而与当前宿主机没有任何绑定关系。这样，无论你在其他哪个宿主机上启动新的容器，都可以请求挂载指定的持久化存储卷，从而访问到数据卷里保存的内容。这就是“**持久化**”的含义。

由于 Kubernetes 本身的松耦合设计，绝大多数存储项目，比如 Ceph、GlusterFS、NFS 等，都可以为 Kubernetes 提供持久化存储能力。在这次的部署实战中，我会选择部署一个很重要的 Kubernetes 存储插件项目：Rook

Rook 项目是一个基于 Ceph 的 Kubernetes 存储插件（它后期也在加入对更多存储实现的支持）。不过，不同于对 Ceph 的简单封装，Rook 在自己的实现中加入了水平扩展、迁移、灾难备份、监控等大量的企业级功能，使得这个项目变成了一个完整的、生产级别可用的容器存储插件。

得益于容器化技术，用几条指令，Rook 就可以把复杂的 Ceph 存储后端部署起来：

```sh
$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/common.yaml

$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator.yaml

$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/cluster.yaml
```

在部署完成后，你就可以看到 Rook 项目会将自己的 Pod 放置在由它自己管理的两个 Namespace 当中：

```sh
$ kubectl get pods -n rook-ceph-system
NAME                                  READY     STATUS    RESTARTS   AGE
rook-ceph-agent-7cv62                 1/1       Running   0          15s
rook-ceph-operator-78d498c68c-7fj72   1/1       Running   0          44s
rook-discover-2ctcv                   1/1       Running   0          15s

$ kubectl get pods -n rook-ceph
NAME                   READY     STATUS    RESTARTS   AGE
rook-ceph-mon0-kxnzh   1/1       Running   0          13s
rook-ceph-mon1-7dn2t   1/1       Running   0          2s
```

这样，一个基于 Rook 持久化存储集群就以容器的方式运行起来了，而接下来在 Kubernetes 项目上创建的所有 Pod 就能够通过 Persistent Volume（PV）和 Persistent Volume Claim（PVC）的方式，在容器里挂载由 Ceph 提供的数据卷了。

而 Rook 项目，则会负责这些数据卷的生命周期管理、灾难备份等运维工作。关于这些容器持久化存储的知识，我会在后续章节中专门讲解。

这时候，你可能会有个疑问：为什么我要选择 Rook 项目呢？

其实，是因为这个项目很有前途。

如果你去研究一下 Rook 项目的实现，就会发现它巧妙地依赖了 Kubernetes 提供的编排能力，合理的使用了很多诸如 Operator、CRD 等重要的扩展特性（这些特性我都会在后面的文章中逐一讲解到）。这使得 Rook 项目，成为了目前社区中基于 Kubernetes API 构建的最完善也最成熟的容器存储插件。我相信，这样的发展路线，很快就会得到整个社区的推崇。

> 备注：其实，在很多时候，大家说的所谓“云原生”，就是“Kubernetes 原生”的意思。而像 Rook、Istio 这样的项目，正是贯彻这个思路的典范。在我们后面讲解了声明式 API 之后，相信你对这些项目的设计思想会有更深刻的体会。

#### 总结

在本篇文章中，我们完全从 0 开始，在 Bare-metal 环境下使用 kubeadm 工具部署了一个完整的 Kubernetes 集群：这个集群有一个 Master 节点和多个 Worker 节点；使用 Weave 作为容器网络插件；使用 Rook 作为容器持久化存储插件；使用 Dashboard 插件提供了可视化的 Web 界面。

这个集群，也将会是我进行后续讲解所依赖的集群环境，并且在后面的讲解中，我还会给它安装更多的插件，添加更多的新能力。

另外，这个集群的部署过程并不像传说中那么繁琐，这主要得益于：

1. kubeadm 项目大大简化了部署 Kubernetes 的准备工作，尤其是配置文件、证书、二进制文件的准备和制作，以及集群版本管理等操作，都被 kubeadm 接管了。
2. Kubernetes 本身“一切皆容器”的设计思想，加上良好的可扩展机制，使得插件的部署非常简便。

上述思想，也是开发和使用 Kubernetes 的重要指导思想，即：基于 Kubernetes 开展工作时，你一定要优先考虑这两个问题：

1. 我的工作是不是可以容器化？
2. 我的工作是不是可以借助 Kubernetes API 和可扩展机制来完成？

而一旦这项工作能够基于 Kubernetes 实现容器化，就很有可能像上面的部署过程一样，大幅简化原本复杂的运维工作。对于时间宝贵的技术人员来说，这个变化的重要性是不言而喻的。

#### 思考题

1. 你是否使用其他工具部署过 Kubernetes 项目？经历如何？
2. 你是否知道 Kubernetes 项目当前（v1.11）能够有效管理的集群规模是多少个节点？你在生产环境中希望部署或者正在部署的集群规模又是多少个节点呢？

### 我的第一个容器化应用

在开始实践之前，我先给你讲解一下 Kubernetes 里面与开发者关系最密切的几个概念。

作为一个应用开发者，你首先要做的，是制作容器的镜像。这一部分内容，我已经在容器基础部分《白话容器基础（三）：深入理解容器镜像》重点讲解过了。

而有了容器镜像之后，你需要按照 Kubernetes 项目的规范和要求，将你的镜像组织为它能够“认识”的方式，然后提交上去。

那么，**什么才是 Kubernetes 项目能“认识”的方式呢**？

这就是使用 Kubernetes 的必备技能：编写配置文件。

> 备注：这些配置文件可以是 YAML 或者 JSON 格式的。为方便阅读与理解，在后面的讲解中，我会统一使用 YAML 文件来指代它们。

Kubernetes 跟 Docker 等很多项目最大的不同，就在于它不推荐你使用命令行的方式直接运行容器（虽然 Kubernetes 项目也支持这种方式，比如：kubectl run），而是希望你用 YAML 文件的方式，即：把容器的定义、参数、配置，统统记录在一个 YAML 文件中，然后用这样一句指令把它运行起来：

```sh
$ kubectl create -f 我的配置文件
```

这么做最直接的好处是，你会有一个文件能记录下 Kubernetes 到底“run”了什么。比如下面这个例子：

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

像这样的一个 YAML 文件，对应到 Kubernetes 中，就是一个 API Object（API 对象）。当你为这个对象的各个字段填好值并提交给 Kubernetes 之后，Kubernetes 就会负责创建出这些对象所定义的容器或者其他类型的 API 资源。

可以看到，这个 YAML 文件中的 Kind 字段，指定了这个 API 对象的类型（Type），是一个 Deployment。

所谓 Deployment，是一个定义多副本应用（即多个副本 Pod）的对象，我在前面的文章中（也是第 9 篇文章《从容器到容器云：谈谈 Kubernetes 的本质》）曾经简单提到过它的用法。此外，Deployment 还负责在 Pod 定义发生变化时，对每个副本进行滚动更新（Rolling Update）。

在上面这个 YAML 文件中，我给它定义的 Pod 副本个数 (spec.replicas) 是：2。

而这些 Pod 具体的又长什么样子呢？

为此，我定义了一个 Pod 模版（spec.template），这个模版描述了我想要创建的 Pod 的细节。在上面的例子里，这个 Pod 里只有一个容器，这个容器的镜像（spec.containers.image）是 nginx:1.7.9，这个容器监听端口（containerPort）是 80。

关于 Pod 的设计和用法我已经在第 9 篇文章《从容器到容器云：谈谈 Kubernetes 的本质》中简单的介绍过。而在这里，你需要记住这样一句话：

> Pod 就是 Kubernetes 世界里的“应用”；而一个应用，可以由多个容器组成。

需要注意的是，像这样使用一种 API 对象（Deployment）管理另一种 API 对象（Pod）的方法，在 Kubernetes 中，叫作“控制器”模式（controller pattern）。在我们的例子中，Deployment 扮演的正是 Pod 的控制器的角色。关于 Pod 和控制器模式的更多细节，我会在后续编排部分做进一步讲解。

你可能还注意到，这样的每一个 API 对象都有一个叫作 Metadata 的字段，这个字段就是 API 对象的“标识”，即元数据，它也是我们从 Kubernetes 里找到这个对象的主要依据。这其中最主要使用到的字段是 Labels

顾名思义，Labels 就是一组 key-value 格式的标签。而像 Deployment 这样的控制器对象，就可以通过这个 Labels 字段从 Kubernetes 中过滤出它所关心的被控制对象。

比如，在上面这个 YAML 文件中，Deployment 会把所有正在运行的、携带“app: nginx”标签的 Pod 识别为被管理的对象，并确保这些 Pod 的总数严格等于两个。

而这个过滤规则的定义，是在 Deployment 的“spec.selector.matchLabels”字段。我们一般称之为：Label Selector

另外，在 Metadata 中，还有一个与 Labels 格式、层级完全相同的字段叫 Annotations，它专门用来携带 key-value 格式的内部信息。所谓内部信息，指的是对这些信息感兴趣的，是 Kubernetes 组件本身，而不是用户。所以大多数 Annotations，都是在 Kubernetes 运行过程中，被自动加在这个 API 对象上。

一个 Kubernetes 的 API 对象的定义，大多可以分为 Metadata 和 Spec 两个部分。前者存放的是这个对象的元数据，对所有 API 对象来说，这一部分的字段和格式基本上是一样的；而后者存放的，则是属于这个对象独有的定义，用来描述它所要表达的功能。

在了解了上述 Kubernetes 配置文件的基本知识之后，我们现在就可以把这个 YAML 文件“运行”起来。正如前所述，你可以使用 kubectl create 指令完成这个操作：

```sh
$ kubectl create -f nginx-deployment.yaml
```

然后，通过 kubectl get 命令检查这个 YAML 运行起来的状态是不是与我们预期的一致：

```sh
$ kubectl get pods -l app=nginx
NAME                                READY     STATUS    RESTARTS   AGE
nginx-deployment-67594d6bf6-9gdvr   1/1       Running   0          10m
nginx-deployment-67594d6bf6-v6j7w   1/1       Running   0          10m
```

kubectl get 指令的作用，就是从 Kubernetes 里面获取（GET）指定的 API 对象。可以看到，在这里我还加上了一个 -l 参数，即获取所有匹配 app: nginx 标签的 Pod。**需要注意的是，在命令行中，所有 key-value 格式的参数，都使用“=”而非“:”表示**。

从这条指令返回的结果中，我们可以看到现在有两个 Pod 处于 Running 状态，也就意味着我们这个 Deployment 所管理的 Pod 都处于预期的状态。

此外， 你还可以使用 kubectl describe 命令，查看一个 API 对象的细节，比如：

```sh
$ kubectl describe pod nginx-deployment-67594d6bf6-9gdvr
Name:               nginx-deployment-67594d6bf6-9gdvr
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               node-1/10.168.0.3
Start Time:         Thu, 16 Aug 2018 08:48:42 +0000
Labels:             app=nginx
                    pod-template-hash=2315082692
Annotations:        <none>
Status:             Running
IP:                 10.32.0.23
Controlled By:      ReplicaSet/nginx-deployment-67594d6bf6
...
Events:

  Type     Reason                  Age                From               Message

  ----     ------                  ----               ----               -------
  
  Normal   Scheduled               1m                 default-scheduler  Successfully assigned default/nginx-deployment-67594d6bf6-9gdvr to node-1
  Normal   Pulling                 25s                kubelet, node-1    pulling image "nginx:1.7.9"
  Normal   Pulled                  17s                kubelet, node-1    Successfully pulled image "nginx:1.7.9"
  Normal   Created                 17s                kubelet, node-1    Created container
  Normal   Started                 17s                kubelet, node-1    Started container
```

在 kubectl describe 命令返回的结果中，你可以清楚地看到这个 Pod 的详细信息，比如它的 IP 地址等等。其中，有一个部分值得你特别关注，它就是 **Events（事件）**。

在 Kubernetes 执行的过程中，对 API 对象的所有重要操作，都会被记录在这个对象的 Events 里，并且显示在 kubectl describe 指令返回的结果中。

比如，对于这个 Pod，我们可以看到它被创建之后，被调度器调度（Successfully assigned）到了 node-1，拉取了指定的镜像（pulling image），然后启动了 Pod 里定义的容器（Started container）

所以，这个部分正是我们将来进行 Debug 的重要依据。如果有异常发生，**你一定要第一时间查看这些 Events，往往可以看到非常详细的错误信息。**

接下来，如果我们要对这个 Nginx 服务进行升级，把它的镜像版本从 1.7.9 升级为 1.8，要怎么做呢？

很简单，我们只要修改这个 YAML 文件即可。

```yml
...    
    spec:
      containers:
      - name: nginx
        image: nginx:1.8 #这里被从1.7.9修改为1.8
        ports:
      - containerPort: 80
```

可是，这个修改目前只发生在本地，如何让这个更新在 Kubernetes 里也生效呢？

我们可以使用 kubectl replace 指令来完成这个更新：

```sh

 $ kubectl replace -f nginx-deployment.yaml
```

不过，在本专栏里，我推荐你使用 **kubectl apply** 命令，来统一进行 Kubernetes 对象的创建和更新操作，具体做法如下所示：

```sh

$ kubectl apply -f nginx-deployment.yaml

# 修改nginx-deployment.yaml的内容

$ kubectl apply -f nginx-deployment.yaml
```

这样的操作方法，是 Kubernetes“声明式 API”所推荐的使用方法。也就是说，作为用户，你不必关心当前的操作是创建，还是更新，你执行的命令始终是 kubectl apply，而 Kubernetes 则会根据 YAML 文件的内容变化，自动进行具体的处理。

而这个流程的好处是，它有助于帮助开发和运维人员，围绕着可以版本化管理的 YAML 文件，而不是“行踪不定”的命令行进行协作，从而大大降低开发人员和运维人员之间的沟通成本。

举个例子，一位开发人员开发好一个应用，制作好了容器镜像。那么他就可以在应用的发布目录里附带上一个 Deployment 的 YAML 文件。

而运维人员，拿到这个应用的发布目录后，就可以直接用这个 YAML 文件执行 kubectl apply 操作把它运行起来。

这时候，如果开发人员修改了应用，生成了新的发布内容，那么这个 YAML 文件，也就需要被修改，并且成为这次变更的一部分。

而接下来，运维人员可以使用 git diff 命令查看到这个 YAML 文件本身的变化，然后继续用 kubectl apply 命令更新这个应用。

所以说，如果通过容器镜像，我们能够保证应用本身在开发与部署环境里的一致性的话，那么现在，Kubernetes 项目通过这些 YAML 文件，就保证了应用的“部署参数”在开发与部署环境中的一致性。

**而当应用本身发生变化时，开发人员和运维人员可以依靠容器镜像来进行同步；当应用部署参数发生变化时，这些 YAML 文件就是他们相互沟通和信任的媒介。**

以上，就是 Kubernetes 发布应用的最基本操作了。

在 Kubernetes 中，Volume 是属于 Pod 对象的一部分。所以，我们就需要修改这个 YAML 文件里的 template.spec 字段，如下所示：

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.8
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: nginx-vol
      volumes:
      - name: nginx-vol
        emptyDir: {}
```

可以看到，我们在 Deployment 的 Pod 模板部分添加了一个 volumes 字段，定义了这个 Pod 声明的所有 Volume。它的名字叫作 nginx-vol，类型是 emptyDir。

那什么是 emptyDir 类型呢？

它其实就等同于我们之前讲过的 Docker 的隐式 Volume 参数，即：不显式声明宿主机目录的 Volume。所以，Kubernetes 也会在宿主机上创建一个临时目录，这个目录将来就会被绑定挂载到容器所声明的 Volume 目录上。

> 备注：不难看到，Kubernetes 的 emptyDir 类型，只是把 Kubernetes 创建的临时目录作为 Volume 的宿主机目录，交给了 Docker。这么做的原因，是 Kubernetes 不想依赖 Docker 自己创建的那个 _data 目录。

而 Pod 中的容器，使用的是 volumeMounts 字段来声明自己要挂载哪个 Volume，并通过 mountPath 字段来定义容器内的 Volume 目录，比如：/usr/share/nginx/html。

当然，Kubernetes 也提供了显式的 Volume 定义，它叫作 hostPath。比如下面的这个 YAML 文件：

```yml
...   
	volumes:
        - name: nginx-vol
          hostPath:
            path: "/home/vagrant/mykube/firstapp/html"

```

这样，容器 Volume 挂载的宿主机目录，就变成了 /var/data。

在上述修改完成后，我们还是使用 kubectl apply 指令，更新这个 Deployment:

```sh

$ kubectl apply -f nginx-deployment.yaml
```

接下来，你可以通过 kubectl get 指令，查看两个 Pod 被逐一更新的过程：

```sh

$ kubectl get pods
NAME                                READY     STATUS              RESTARTS   AGE
nginx-deployment-5c678cfb6d-v5dlh   0/1       ContainerCreating   0          4s
nginx-deployment-67594d6bf6-9gdvr   1/1       Running             0          10m
nginx-deployment-67594d6bf6-v6j7w   1/1       Running             0          10m
$ kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
nginx-deployment-5c678cfb6d-lg9lw   1/1       Running   0          8s
nginx-deployment-5c678cfb6d-v5dlh   1/1       Running   0          19s
```

从返回结果中，我们可以看到，新旧两个 Pod，被交替创建、删除，最后剩下的就是新版本的 Pod。这个滚动更新的过程，我也会在后续进行详细的讲解。

然后，你可以使用 kubectl describe 查看一下最新的 Pod，就会发现 Volume 的信息已经出现在了 Container 描述部分：

```sh

...
Containers:
  nginx:
    Container ID:   docker://07b4f89248791c2aa47787e3da3cc94b48576cd173018356a6ec8db2b6041343
    Image:          nginx:1.8
    ...
    Environment:    <none>
    Mounts:
      /usr/share/nginx/html from nginx-vol (rw)
...
Volumes:
  nginx-vol:
    Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
```

> 备注：作为一个完整的容器化平台项目，Kubernetes 为我们提供的 Volume 类型远远不止这些，在容器存储章节里，我将会为你详细介绍这部分内容。

最后，你还可以使用 kubectl exec 指令，进入到这个 Pod 当中（即容器的 Namespace 中）查看这个 Volume 目录：

```sh

$ kubectl exec -it nginx-deployment-5c678cfb6d-lg9lw -- /bin/bash
# ls /usr/share/nginx/html
```

此外，你想要从 Kubernetes 集群中删除这个 Nginx Deployment 的话，直接执行：

```sh

$ kubectl delete -f nginx-deployment.yaml
```

#### 总结

在今天的分享中，我通过一个小案例，和你近距离体验了 Kubernetes 的使用方法。

可以看到，Kubernetes 推荐的使用方式，是用一个 YAML 文件来描述你所要部署的 API 对象。然后，统一使用 kubectl apply 命令完成对这个对象的创建和更新操作

而 Kubernetes 里“最小”的 API 对象是 Pod。Pod 可以等价为一个应用，所以，Pod 可以由多个紧密协作的容器组成。

在 Kubernetes 中，我们经常会看到它通过一种 API 对象来管理另一种 API 对象，比如 Deployment 和 Pod 之间的关系；而由于 Pod 是“最小”的对象，所以它往往都是被其他对象控制的。这种组合方式，正是 Kubernetes 进行容器编排的重要模式。

而像这样的 Kubernetes API 对象，往往由 Metadata 和 Spec 两部分组成，其中 Metadata 里的 Labels 字段是 Kubernetes 过滤对象的主要手段。

在这些字段里面，容器想要使用的数据卷，也就是 Volume，正是 Pod 的 Spec 字段的一部分。而 Pod 里的每个容器，则需要显式的声明自己要挂载哪个 Volume。

上面这些基于 YAML 文件的容器管理方式，跟 Docker、Mesos 的使用习惯都是不一样的，而从 docker run 这样的命令行操作，向 kubectl apply YAML 文件这样的声明式 API 的转变，是每一个容器技术学习者，必须要跨过的第一道门槛。

所以，如果你想要快速熟悉 Kubernetes，请按照下面的流程进行练习：

+ 首先，在本地通过 Docker 测试代码，制作镜像；
+ 然后，选择合适的 Kubernetes API 对象，编写对应 YAML 文件（比如，Pod，Deployment）；
+ 最后，在 Kubernetes 上部署这个 YAML 文件。

更重要的是，在部署到 Kubernetes 之后，接下来的所有操作，要么通过 kubectl 来执行，要么通过修改 YAML 文件来实现，**就尽量不要再碰 Docker 的命令行了**。

#### 思考题

在实际使用 Kubernetes 的过程中，相比于编写一个单独的 Pod 的 YAML 文件，我一定会推荐你使用一个 replicas=1 的 Deployment。请问，这两者有什么区别呢？

```txt
推荐使用replica=1而不使用单独pod的主要原因是pod所在的节点出故障的时候 pod可以调度到健康的节点上，单独的pod只能在节点健康的情况下由kubelet保证pod的健康状况吧
```

## 容器编排与Kubernetes作业管理

### 为什么我们需要Pod？

我详细介绍了在 Kubernetes 里部署一个应用的过程。在这些讲解中，我提到了这样一个知识点：Pod，是 Kubernetes 项目中最小的 API 对象。如果换一个更专业的说法，我们可以这样描述：**Pod，是 Kubernetes 项目的原子调度单位。**

不过，我相信你在学习和使用 Kubernetes 项目的过程中，已经不止一次地想要问这样一个问题：**为什么我们会需要 Pod？**

是啊，我们在前面已经花了很多精力去解读 Linux 容器的原理、分析了 Docker 容器的本质，终于，“Namespace 做隔离，Cgroups 做限制，rootfs 做文件系统”这样的“三句箴言”可以朗朗上口了，**为什么 Kubernetes 项目又突然搞出一个 Pod 来呢？**

要回答这个问题，我们还是要一起回忆一下我曾经反复强调的一个问题：容器的本质到底是什么？

你现在应该可以不假思索地回答出来：容器的本质是进程。

没错。容器，就是未来云计算系统中的进程；容器镜像就是这个系统里的“.exe”安装包。那么 Kubernetes 呢？

你应该也能立刻回答上来：Kubernetes 就是操作系统！

非常正确

现在，就让我们登录到一台 Linux 机器里，执行一条如下所示的命令：

```sh

$ pstree -g
```

这条命令的作用，是展示当前系统中正在运行的进程的树状结构。它的返回结果如下所示：

```sh

systemd(1)-+-accounts-daemon(1984)-+-{gdbus}(1984)
           | `-{gmain}(1984)
           |-acpid(2044)
          ...      
           |-lxcfs(1936)-+-{lxcfs}(1936)
           | `-{lxcfs}(1936)
           |-mdadm(2135)
           |-ntpd(2358)
           |-polkitd(2128)-+-{gdbus}(2128)
           | `-{gmain}(2128)
           |-rsyslogd(1632)-+-{in:imklog}(1632)
           |  |-{in:imuxsock) S 1(1632)
           | `-{rs:main Q:Reg}(1632)
           |-snapd(1942)-+-{snapd}(1942)
           |  |-{snapd}(1942)
           |  |-{snapd}(1942)
           |  |-{snapd}(1942)
           |  |-{snapd}(1942)
```

不难发现，在一个真正的操作系统里，进程并不是“孤苦伶仃”地独自运行的，而是以进程组的方式，“有原则地”组织在一起。比如，这里有一个叫作 rsyslogd 的程序，它负责的是 Linux 操作系统里的日志处理。可以看到，rsyslogd 的主程序 main，和它要用到的内核日志模块 imklog 等，同属于 1632 进程组。这些进程相互协作，共同完成 rsyslogd 程序的职责。

> 注意：我在本篇中提到的“进程”，比如，rsyslogd 对应的 imklog，imuxsock 和 main，严格意义上来说，其实是 Linux 操作系统语境下的“线程”。这些线程，或者说，轻量级进程之间，可以共享文件、信号、数据内存、甚至部分代码，从而紧密协作共同完成一个程序的职责。所以同理，我提到的“进程组”，对应的也是 Linux 操作系统语境下的“线程组”。这种命名关系与实际情况的不一致，是 Linux 发展历史中的一个遗留问题。对这个话题感兴趣的同学，可以阅读这篇技术文章来了解一下。

而 Kubernetes 项目所做的，其实就是将“进程组”的概念映射到了容器技术中，并使其成为了这个云计算“操作系统”里的“一等公民”

Kubernetes 项目之所以要这么做的原因，我在前面介绍 Kubernetes 和 Borg 的关系时曾经提到过：在 Borg 项目的开发和实践过程中，Google 公司的工程师们发现，他们部署的应用，往往都存在着类似于“进程和进程组”的关系。更具体地说，就是这些应用之间有着密切的协作关系，使得它们必须部署在同一台机器上。

而如果事先没有“组”的概念，像这样的运维关系就会非常难以处理。

我还是以前面的 rsyslogd 为例子。已知 rsyslogd 由三个进程组成：一个 imklog 模块，一个 imuxsock 模块，一个 rsyslogd 自己的 main 函数主进程。这三个进程一定要运行在同一台机器上，否则，它们之间基于 Socket 的通信和文件交换，都会出现问题。

现在，我要把 rsyslogd 这个应用给容器化，由于受限于容器的“单进程模型”，这三个模块必须被分别制作成三个不同的容器。而在这三个容器运行的时候，它们设置的内存配额都是 1 GB。

> 再次强调一下：容器的“单进程模型”，并不是指容器里只能运行“一个”进程，而是指容器没有管理多个进程的能力。这是因为容器里 PID=1 的进程就是应用本身，其他的进程都是这个 PID=1 进程的子进程。可是，用户编写的应用，并不能够像正常操作系统里的 init 进程或者 systemd 那样拥有进程管理的功能。比如，你的应用是一个 Java Web 程序（PID=1），然后你执行 docker exec 在后台启动了一个 Nginx 进程（PID=3）。可是，当这个 Nginx 进程异常退出的时候，你该怎么知道呢？这个进程退出后的垃圾收集工作，又应该由谁去做呢？

假设我们的 Kubernetes 集群上有两个节点：node-1 上有 3 GB 可用内存，node-2 有 2.5 GB 可用内存。

这时，假设我要用 Docker Swarm 来运行这个 rsyslogd 程序。为了能够让这三个容器都运行在同一台机器上，我就必须在另外两个容器上设置一个 affinity=main（与 main 容器有亲密性）的约束，即：它们俩必须和 main 容器运行在同一台机器上。

然后，我顺序执行：“docker run main”“docker run imklog”和“docker run imuxsock”，创建这三个容器。

这样，这三个容器都会进入 Swarm 的待调度队列。然后，main 容器和 imklog 容器都先后出队并被调度到了 node-2 上（这个情况是完全有可能的）

可是，当 imuxsock 容器出队开始被调度时，Swarm 就有点懵了：node-2 上的可用资源只有 0.5 GB 了，并不足以运行 imuxsock 容器；可是，根据 affinity=main 的约束，imuxsock 容器又只能运行在 node-2 上。

这就是一个典型的成组调度（gang scheduling）没有被妥善处理的例子。

在工业界和学术界，关于这个问题的讨论可谓旷日持久，也产生了很多可供选择的解决方案

比如，Mesos 中就有一个资源囤积（resource hoarding）的机制，会在所有设置了 Affinity 约束的任务都达到时，才开始对它们统一进行调度。而在 Google Omega 论文中，则提出了使用乐观调度处理冲突的方法，即：先不管这些冲突，而是通过精心设计的回滚机制在出现了冲突之后解决问题。

可是这些方法都谈不上完美。资源囤积带来了不可避免的调度效率损失和死锁的可能性；而乐观调度的复杂程度，则不是常规技术团队所能驾驭的。

但是，到了 Kubernetes 项目里，这样的问题就迎刃而解了：Pod 是 Kubernetes 里的原子调度单位。这就意味着，Kubernetes 项目的调度器，是统一按照 Pod 而非容器的资源需求进行计算的。

所以，像 imklog、imuxsock 和 main 函数主进程这样的三个容器，正是一个典型的由三个容器组成的 Pod。Kubernetes 项目在调度时，自然就会去选择可用内存等于 3 GB 的 node-1 节点进行绑定，而根本不会考虑 node-2

像这样容器间的紧密协作，我们可以称为**“超亲密关系**”。这些具有“超亲密关系”容器的典型特征包括但不限于：**互相之间会发生直接的文件交换**、**使用 localhost 或者 Socket 文件进行本地通信**、**会发生非常频繁的远程调用**、**需要共享某些 Linux Namespace**（比如，一个容器要加入另一个容器的 Network Namespace）等等。

这也就意味着，并不是所有有“关系”的容器都属于同一个 Pod。比如，PHP 应用容器和 MySQL 虽然会发生访问关系，但并没有必要、也不应该部署在同一台机器上，它们更适合做成两个 Pod。

不过，相信此时你可能会有第二个疑问：

对于初学者来说，一般都是先学会了用 Docker 这种单容器的工具，才会开始接触 Pod

而如果 Pod 的设计只是出于调度上的考虑，那么 Kubernetes 项目似乎完全没有必要非得把 Pod 作为“一等公民”吧？这不是故意增加用户的学习门槛吗？

没错，如果只是处理“超亲密关系”这样的调度问题，有 Borg 和 Omega 论文珠玉在前，Kubernetes 项目肯定可以在调度器层面给它解决掉。

不过，Pod 在 Kubernetes 项目里还有更重要的意义，那就是：**容器设计模式**

为了理解这一层含义，我就必须先给你介绍一下Pod 的实现原理。

**首先，关于 Pod 最重要的一个事实是：它只是一个逻辑概念**

也就是说，Kubernetes 真正处理的，还是宿主机操作系统上 Linux 容器的 Namespace 和 Cgroups，而并不存在一个所谓的 Pod 的边界或者隔离环境。

那么，Pod 又是怎么被“创建”出来的呢？

答案是：Pod，其实是一组共享了某些资源的容器。

具体的说：**Pod 里的所有容器，共享的是同一个 Network Namespace，并且可以声明共享同一个 Volume。**

那这么来看的话，一个有 A、B 两个容器的 Pod，不就是等同于一个容器（容器 A）共享另外一个容器（容器 B）的网络和 Volume 的玩儿法么？

这好像通过 docker run --net --volumes-from 这样的命令就能实现嘛，比如：

```sh

$ docker run --net=B --volumes-from=B --name=A image-A ...
```

但是，你有没有考虑过，如果真这样做的话，容器 B 就必须比容器 A 先启动，这样一个 Pod 里的多个容器就不是对等关系，而是拓扑关系了。

所以，在 Kubernetes 项目里，Pod 的实现需要使用一个中间容器，这个容器叫作 Infra 容器。在这个 Pod 中，Infra 容器永远都是第一个被创建的容器，而其他用户定义的容器，则通过 Join Network Namespace 的方式，与 Infra 容器关联在一起。这样的组织关系，可以用下面这样一个示意图来表达：

![img](https://static001.geekbang.org/resource/image/8c/cf/8c016391b4b17923f38547c498e434cf.png)

如上图所示，这个 Pod 里有两个用户容器 A 和 B，还有一个 Infra 容器。很容易理解，在 Kubernetes 项目里，Infra 容器一定要占用极少的资源，所以它使用的是一个非常特殊的镜像，叫作：k8s.gcr.io/pause。这个镜像是一个用汇编语言编写的、永远处于“暂停”状态的容器，解压后的大小也只有 100~200 KB 左右。

而在 Infra 容器“Hold 住”Network Namespace 后，用户容器就可以加入到 Infra 容器的 Network Namespace 当中了。所以，如果你查看这些容器在宿主机上的 Namespace 文件（这个 Namespace 文件的路径，我已经在前面的内容中介绍过），它们指向的值一定是完全一样的。

这也就意味着，对于 Pod 里的容器 A 和容器 B 来说：

+ 它们看到的网络设备跟 Infra 容器看到的完全一样；
+ 一个 Pod 只有一个 IP 地址，也就是这个 Pod 的 Network Namespace 对应的 IP 地址；
+ 当然，其他的所有网络资源，都是一个 Pod 一份，并且被该 Pod 中的所有容器共享；
+ Pod 的生命周期只跟 Infra 容器一致，而与容器 A 和 B 无关。  

而对于同一个 Pod 里面的所有用户容器来说，它们的进出流量，也可以认为都是通过 Infra 容器完成的。**这一点很重要，因为将来如果你要为 Kubernetes 开发一个网络插件时，应该重点考虑的是如何配置这个 Pod 的 Network Namespace，而不是每一个用户容器如何使用你的网络配置，这是没有意义的。**

这就意味着，如果你的网络插件需要在容器里安装某些包或者配置才能完成的话，是不可取的：Infra 容器镜像的 rootfs 里几乎什么都没有，没有你随意发挥的空间。当然，这同时也意味着你的网络插件完全不必关心用户容器的启动与否，而只需要关注如何配置 Pod，也就是 Infra 容器的 Network Namespace 即可。

有了这个设计之后，共享 Volume 就简单多了：Kubernetes 项目只要把所有 Volume 的定义都设计在 Pod 层级即可。

这样，一个 Volume 对应的宿主机目录对于 Pod 来说就只有一个，Pod 里的容器只要声明挂载这个 Volume，就一定可以共享这个 Volume 对应的宿主机目录。比如下面这个例子：

```yml

apiVersion: v1
kind: Pod
metadata:
  name: two-containers
spec:
  restartPolicy: Never
  volumes:
  - name: shared-data
    hostPath:      
      path: /data
  containers:
  - name: nginx-container
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: debian-container
    image: debian
    volumeMounts:
    - name: shared-data
      mountPath: /pod-data
    command: ["/bin/sh"]
    args: ["-c", "echo Hello from the debian container > /pod-data/index.html"]
```

在这个例子中，debian-container 和 nginx-container 都声明挂载了 shared-data 这个 Volume。而 shared-data 是 hostPath 类型。所以，它对应在宿主机上的目录就是：/data。而这个目录，其实就被同时绑定挂载进了上述两个容器当中。

这就是为什么，nginx-container 可以从它的 /usr/share/nginx/html 目录中，读取到 debian-container 生成的 index.html 文件的原因。

明白了 Pod 的实现原理后，我们再来讨论“容器设计模式”，就容易多了。

Pod 这种“超亲密关系”容器的设计思想，实际上就是希望，当用户想在一个容器里跑多个功能并不相关的应用时，应该优先考虑它们是不是更应该被描述成一个 Pod 里的多个容器。

为了能够掌握这种思考方式，你就应该尽量尝试使用它来描述一些用单个容器难以解决的问题。

#### **第一个最典型的例子是：WAR 包与 Web 服务器。**

我们现在有一个 Java Web 应用的 WAR 包，它需要被放在 Tomcat 的 webapps 目录下运行起来。

假如，你现在只能用 Docker 来做这件事情，那该如何处理这个组合关系呢？

+ 一种方法是，把 WAR 包直接放在 Tomcat 镜像的 webapps 目录下，做成一个新的镜像运行起来。可是，这时候，如果你要更新 WAR 包的内容，或者要升级 Tomcat 镜像，就要重新制作一个新的发布镜像，非常麻烦。
+ 另一种方法是，你压根儿不管 WAR 包，永远只发布一个 Tomcat 容器。不过，这个容器的 webapps 目录，就必须声明一个 hostPath 类型的 Volume，从而把宿主机上的 WAR 包挂载进 Tomcat 容器当中运行起来。不过，这样你就必须要解决一个问题，即：如何让每一台宿主机，都预先准备好这个存储有 WAR 包的目录呢？这样来看，你只能独立维护一套分布式存储系统了。

实际上，有了 Pod 之后，这样的问题就很容易解决了。我们可以把 WAR 包和 Tomcat 分别做成镜像，然后把它们作为一个 Pod 里的两个容器“组合”在一起。这个 Pod 的配置文件如下所示：

```yml

apiVersion: v1
kind: Pod
metadata:
  name: javaweb-2
spec:
  initContainers:
  - image: geektime/sample:v2
    name: war
    command: ["cp", "/sample.war", "/app"]
    volumeMounts:
    - mountPath: /app
      name: app-volume
  containers:
  - image: geektime/tomcat:7.0
    name: tomcat
    command: ["sh","-c","/root/apache-tomcat-7.0.42-v2/bin/start.sh"]
    volumeMounts:
    - mountPath: /root/apache-tomcat-7.0.42-v2/webapps
      name: app-volume
    ports:
    - containerPort: 8080
      hostPort: 8001 
  volumes:
  - name: app-volume
    emptyDir: {}
```

在这个 Pod 中，我们定义了两个容器，第一个容器使用的镜像是 geektime/sample:v2，这个镜像里只有一个 WAR 包（sample.war）放在根目录下。而第二个容器则使用的是一个标准的 Tomcat 镜像。

不过，你可能已经注意到，WAR 包容器的类型不再是一个普通容器，而是一个 Init Container 类型的容器。

在 Pod 中，所有 Init Container 定义的容器，都会比 spec.containers 定义的用户容器先启动。并且，Init Container 容器会按顺序逐一启动，而直到它们都启动并且退出了，用户容器才会启动。

所以，这个 Init Container 类型的 WAR 包容器启动后，我执行了一句"cp /sample.war /app"，把应用的 WAR 包拷贝到 /app 目录下，然后退出。

而后这个 /app 目录，就挂载了一个名叫 app-volume 的 Volume。

接下来就很关键了。Tomcat 容器，同样声明了挂载 app-volume 到自己的 webapps 目录下

所以，等 Tomcat 容器启动时，它的 webapps 目录下就一定会存在 sample.war 文件：这个文件正是 WAR 包容器启动时拷贝到这个 Volume 里面的，而这个 Volume 是被这两个容器共享的。

像这样，我们就用一种“组合”方式，解决了 WAR 包与 Tomcat 容器之间耦合关系的问题。

实际上，这个所谓的“组合”操作，正是容器设计模式里最常用的一种模式，它的名字叫：sidecar。

顾名思义，sidecar 指的就是我们可以在一个 Pod 中，启动一个辅助容器，来完成一些独立于主进程（主容器）之外的工作。

比如，在我们的这个应用 Pod 中，Tomcat 容器是我们要使用的主容器，而 WAR 包容器的存在，只是为了给它提供一个 WAR 包而已。所以，我们用 Init Container 的方式优先运行 WAR 包容器，扮演了一个 sidecar 的角色。

#### 第二个例子，则是容器的日志收集。

比如，我现在有一个应用，需要不断地把日志文件输出到容器的 /var/log 目录中。

这时，我就可以把一个 Pod 里的 Volume 挂载到应用容器的 /var/log 目录上。

然后，我在这个 Pod 里同时运行一个 sidecar 容器，它也声明挂载同一个 Volume 到自己的 /var/log 目录上。

这样，接下来 sidecar 容器就只需要做一件事儿，那就是不断地从自己的 /var/log 目录里读取日志文件，转发到 MongoDB 或者 Elasticsearch 中存储起来。这样，一个最基本的日志收集工作就完成了。

跟第一个例子一样，这个例子中的 sidecar 的主要工作也是使用共享的 Volume 来完成对文件的操作。

但不要忘记，Pod 的另一个重要特性是，它的所有容器都共享同一个 Network Namespace。这就使得很多与 Pod 网络相关的配置和管理，也都可以交给 sidecar 完成，而完全无须干涉用户容器。这里最典型的例子莫过于 Istio 这个微服务治理项目了。

Istio 项目使用 sidecar 容器完成微服务治理的原理，我在后面很快会讲解到

> 备注：Kubernetes 社区曾经把“容器设计模式”这个理论，整理成了一篇小论文，你可以点击链接浏览。

#### 总结

在本篇文章中我重点分享了 Kubernetes 项目中 Pod 的实现原理。

Pod 是 Kubernetes 项目与其他单容器项目相比最大的不同，也是一位容器技术初学者需要面对的第一个与常规认知不一致的知识点。

事实上，直到现在，仍有很多人把容器跟虚拟机相提并论，他们把容器当做性能更好的虚拟机，喜欢讨论如何把应用从虚拟机无缝地迁移到容器中。

但实际上，无论是从具体的实现原理，还是从使用方法、特性、功能等方面，容器与虚拟机几乎没有任何相似的地方；也不存在一种普遍的方法，能够把虚拟机里的应用无缝迁移到容器中。因为，容器的性能优势，必然伴随着相应缺陷，即：它不能像虚拟机那样，完全模拟本地物理机环境中的部署方法

所以，这个“上云”工作的完成，最终还是要靠深入理解容器的本质，即：进程。

实际上，一个运行在虚拟机里的应用，哪怕再简单，也是被管理在 systemd 或者 supervisord 之下的**一组进程，而不是一个进程**。这跟本地物理机上应用的运行方式其实是一样的。这也是为什么，从物理机到虚拟机之间的应用迁移，往往并不困难。

可是对于容器来说，一个容器永远只能管理一个进程。更确切地说，一个容器，就是一个进程。这是容器技术的“天性”，不可能被修改。所以，将一个原本运行在虚拟机里的应用，“无缝迁移”到容器中的想法，实际上跟容器的本质是相悖的。

这也是当初 Swarm 项目无法成长起来的重要原因之一：一旦到了真正的生产环境上，Swarm 这种单容器的工作方式，就难以描述真实世界里复杂的应用架构了。

所以，你现在可以这么理解 Pod 的本质：

> Pod，实际上是在扮演传统基础设施里“虚拟机”的角色；而容器，则是这个虚拟机里运行的用户程序。

所以下一次，当你需要把一个运行在虚拟机里的应用迁移到 Docker 容器中时，一定要仔细分析到底有哪些进程（组件）运行在这个虚拟机里

然后，你就可以把整个虚拟机想象成为一个 Pod，把这些进程分别做成容器镜像，把有顺序关系的容器，定义为 Init Container。这才是更加合理的、松耦合的容器编排诀窍，也是从传统应用架构，到“微服务架构”最自然的过渡方式。

> 注意：Pod 这个概念，提供的是一种编排思想，而不是具体的技术方案。所以，如果愿意的话，你完全可以使用虚拟机来作为 Pod 的实现，然后把用户容器都运行在这个虚拟机里。比如，Mirantis 公司的virtlet 项目就在干这个事情。甚至，你可以去实现一个带有 Init 进程的容器项目，来模拟传统应用的运行方式。这些工作，在 Kubernetes 中都是非常轻松的，也是我们后面讲解 CRI 时会提到的内容。

相反的，如果强行把整个应用塞到一个容器里，甚至不惜使用 Docker In Docker 这种在生产环境中后患无穷的解决方案，恐怕最后往往会得不偿失。

### 深入解析Pod对象（一）：基本概念

现在，你已经非常清楚：Pod，而不是容器，才是 Kubernetes 项目中的最小编排单位。将这个设计落实到 API 对象上，容器（Container）就成了 Pod 属性里的一个普通的字段。那么，一个很自然的问题就是：到底哪些属性属于 Pod 对象，而又有哪些属性属于 Container 呢？

要彻底理解这个问题，你就一定要牢记我在上一篇文章中提到的一个结论：Pod 扮演的是传统部署环境里“虚拟机”的角色。这样的设计，是为了使用户从传统环境（虚拟机环境）向 Kubernetes（容器环境）的迁移，更加平滑。

而如果你能把 Pod 看成传统环境里的“机器”、把容器看作是运行在这个“机器”里的“用户程序”，那么很多关于 Pod 对象的设计就非常容易理解了。

比如，凡是**调度、网络、存储，以及安全相关的属性，基本上是 Pod 级别的**。

这些属性的共同特征是，它们描述的是“机器”这个整体，而不是里面运行的“程序”。比如，配置这个“机器”的网卡（即：Pod 的网络定义），配置这个“机器”的磁盘（即：Pod 的存储定义），配置这个“机器”的防火墙（即：Pod 的安全定义）。更不用说，这台“机器”运行在哪个服务器之上（即：Pod 的调度）。

接下来，我就先为你介绍 Pod 中几个重要字段的含义和用法

**NodeSelector：是一个供用户将 Pod 与 Node 进行绑定的字段**，用法如下所示：

```yml

apiVersion: v1
kind: Pod
...
spec:
 nodeSelector:
   disktype: ssd
```

这样的一个配置，意味着这个 Pod 永远只能运行在携带了“disktype: ssd”标签（Label）的节点上；否则，它将调度失败

**NodeName：**一旦 Pod 的这个字段被赋值，Kubernetes 项目就会被认为这个 Pod 已经经过了调度，调度的结果就是赋值的节点名字。所以，这个字段一般由调度器负责设置，但用户也可以设置它来“骗过”调度器，当然这个做法一般是在测试或者调试的时候才会用到。

**HostAliases：**定义了 Pod 的 hosts 文件（比如 /etc/hosts）里的内容，用法如下：

```yml

apiVersion: v1
kind: Pod
...
spec:
  hostAliases:
  - ip: "10.1.2.3"
    hostnames:
    - "foo.remote"
    - "bar.remote"
...
```

在这个 Pod 的 YAML 文件中，我设置了一组 IP 和 hostname 的数据。这样，这个 Pod 启动后，/etc/hosts 文件的内容将如下所示：

```sh

cat /etc/hosts
# Kubernetes-managed hosts file.
127.0.0.1 localhost
...
10.244.135.10 hostaliases-pod
10.1.2.3 foo.remote
10.1.2.3 bar.remote
```

其中，最下面两行记录，就是我通过 HostAliases 字段为 Pod 设置的。需要指出的是，在 Kubernetes 项目中，**如果要设置 hosts 文件里的内容，一定要通过这种方法**。否则，如果直接修改了 hosts 文件的话，在 Pod 被删除重建之后，kubelet 会自动覆盖掉被修改的内容。

除了上述跟“机器”相关的配置外，你可能也会发现，**凡是跟容器的 Linux Namespace 相关的属性，也一定是 Pod 级别的**。这个原因也很容易理解：Pod 的设计，就是要让它里面的容器尽可能多地共享 Linux Namespace，仅保留必要的隔离和限制能力。这样，Pod 模拟出的效果，就跟虚拟机里程序间的关系非常类似了

举个例子，在下面这个 Pod 的 YAML 文件中，我定义了

shareProcessNamespace=true：

```yml

apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  shareProcessNamespace: true
  containers:
  - name: nginx
    image: nginx
  - name: shell
    image: busybox
    stdin: true
    tty: true
```

这就意味着这个 Pod 里的容器要共享 PID Namespace。

而在这个 YAML 文件中，我还定义了两个容器：一个是 nginx 容器，一个是开启了 tty 和 stdin 的 shell 容器。

我在前面介绍容器基础时，曾经讲解过什么是 tty 和 stdin。而在 Pod 的 YAML 文件里声明开启它们俩，其实等同于设置了 docker run 里的 -it（-i 即 stdin，-t 即 tty）参数。

如果你还是不太理解它们俩的作用的话，可以直接认为 tty 就是 Linux 给用户提供的一个常驻小程序，用于接收用户的标准输入，返回操作系统的标准输出。当然，为了能够在 tty 中输入信息，你还需要同时开启 stdin（标准输入流）。

于是，这个 Pod 被创建后，你就可以使用 shell 容器的 tty 跟这个容器进行交互了。我们一起实践一下：

```sh

$ kubectl create -f nginx.yaml
```

接下来，我们使用 kubectl attach 命令，连接到 shell 容器的 tty 上：

```sh

$ kubectl attach -it nginx -c shell
```

这样，我们就可以在 shell 容器里执行 ps 指令，查看所有正在运行的进程：

```sh

$ kubectl attach -it nginx -c shell
/ # ps ax
PID   USER     TIME  COMMAND
    1 root      0:00 /pause
    8 root      0:00 nginx: master process nginx -g daemon off;
   14 101       0:00 nginx: worker process
   15 root      0:00 sh
   21 root      0:00 ps ax
```

可以看到，在这个容器里，我们不仅可以看到它本身的 ps ax 指令，还可以看到 nginx 容器的进程，以及 Infra 容器的 /pause 进程。这就意味着，整个 Pod 里的每个容器的进程，对于所有容器来说都是可见的：它们共享了同一个 PID Namespace。

类似地，**凡是 Pod 中的容器要共享宿主机的 Namespace，也一定是 Pod 级别的定义**，比如：

```yml

apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  hostNetwork: true
  hostIPC: true
  hostPID: true
  containers:
  - name: nginx
    image: nginx
  - name: shell
    image: busybox
    stdin: true
    tty: true
```

在这个 Pod 中，我定义了共享宿主机的 Network、IPC 和 PID Namespace。这就意味着，这个 Pod 里的所有容器，会直接使用宿主机的网络、直接与宿主机进行 IPC 通信、看到宿主机里正在运行的所有进程。

当然，除了这些属性，Pod 里最重要的字段当属“Containers”了。而在上一篇文章中，我还介绍过“Init Containers”。其实，这两个字段都属于 Pod 对容器的定义，内容也完全相同，只是 Init Containers 的生命周期，会先于所有的 Containers，并且严格按照定义的顺序执行。

Kubernetes 项目中对 Container 的定义，和 Docker 相比并没有什么太大区别。我在前面的容器技术概念入门系列文章中，和你分享的 Image（镜像）、Command（启动命令）、workingDir（容器的工作目录）、Ports（容器要开发的端口），以及 volumeMounts（容器要挂载的 Volume）都是构成 Kubernetes 项目中 Container 的主要字段。不过在这里，还有这么几个属性值得你额外关注。

**首先，是 ImagePullPolicy 字段**。它定义了镜像拉取的策略。而它之所以是一个 Container 级别的属性，是因为容器镜像本来就是 Container 定义中的一部分

ImagePullPolicy 的值默认是 Always，即每次创建 Pod 都重新拉取一次镜像。另外，当容器的镜像是类似于 nginx 或者 nginx:latest 这样的名字时，ImagePullPolicy 也会被认为 Always。

而如果它的值被定义为 Never 或者 IfNotPresent，则意味着 Pod 永远不会主动拉取这个镜像，或者只在宿主机上不存在这个镜像时才拉取

**其次，是 Lifecycle 字段。它定义的是 Container Lifecycle Hooks**。顾名思义，Container Lifecycle Hooks 的作用，是在容器状态发生变化时触发一系列“钩子”。我们来看这样一个例子：

```yml

apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
      preStop:
        exec:
          command: ["/usr/sbin/nginx","-s","quit"]
```

这是一个来自 Kubernetes 官方文档的 Pod 的 YAML 文件。它其实非常简单，只是定义了一个 nginx 镜像的容器。不过，在这个 YAML 文件的容器（Containers）部分，你会看到这个容器分别设置了一个 postStart 和 preStop 参数。这是什么意思呢？

先说 postStart 吧。它指的是，在容器启动后，立刻执行一个指定的操作。需要明确的是，postStart 定义的操作，虽然是在 Docker 容器 ENTRYPOINT 执行之后，但它并不严格保证顺序。也就是说，在 postStart 启动时，ENTRYPOINT 有可能还没有结束

当然，如果 postStart 执行超时或者错误，Kubernetes 会在该 Pod 的 Events 中报出该容器启动失败的错误信息，导致 Pod 也处于失败的状态。

而类似地，preStop 发生的时机，则是容器被杀死之前（比如，收到了 SIGKILL 信号）。而需要明确的是，preStop 操作的执行，是同步的。所以，它会阻塞当前的容器杀死流程，直到这个 Hook 定义操作完成之后，才允许容器被杀死，这跟 postStart 不一样。

所以，在这个例子中，我们在容器成功启动之后，在 /usr/share/message 里写入了一句“欢迎信息”（即 postStart 定义的操作）。而在这个容器被删除之前，我们则先调用了 nginx 的退出指令（即 preStop 定义的操作），从而实现了容器的“优雅退出”。

在熟悉了 Pod 以及它的 Container 部分的主要字段之后，**我再和你分享一下这样一个的 Pod 对象在 Kubernetes 中的生命周期。**