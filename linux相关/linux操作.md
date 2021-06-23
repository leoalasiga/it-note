# Linux常用操作

## mkdir 命令

> Linux mkdir（英文全拼：make directory）命令用于创建目录。

### 语法

```sh
mkdir [-p] dirName
```

**参数说明**：

- -p 确保目录名称存在，不存在的就建一个。

### 实例

在工作目录下，建立一个名为 runoob 的子目录 :

```
mkdir runoob
```

在工作目录下的 runoob2 目录中，建立一个名为 test 的子目录。

若 runoob2 目录原本不存在，则建立一个。（注：本例若不加 -p 参数，且原本 runoob2 目录不存在，则产生错误。）

```
mkdir -p runoob2/test
```

## netstat命令

> Linux netstat 命令用于显示网络状态。

利用 netstat 指令可让你得知整个 Linux 系统的网络情况。

### 语法

```sh
netstat [-acCeFghilMnNoprstuvVwx][-A<网络类型>][--ip]
```

**参数说明**：

- -a或--all 显示所有连线中的Socket。
- -A<网络类型>或--<网络类型> 列出该网络类型连线中的相关地址。
- -c或--continuous 持续列出网络状态。
- -C或--cache 显示路由器配置的快取信息。
- -e或--extend 显示网络其他相关信息。
- -F或--fib 显示路由缓存。
- -g或--groups 显示多重广播功能群组组员名单。
- -h或--help 在线帮助。
- -i或--interfaces 显示网络界面信息表单。
- -l或--listening 显示监控中的服务器的Socket。
- -M或--masquerade 显示伪装的网络连线。
- -n或--numeric 直接使用IP地址，而不通过域名服务器。
- -N或--netlink或--symbolic 显示网络硬件外围设备的符号连接名称。
- -o或--timers 显示计时器。
- -p或--programs 显示正在使用Socket的程序识别码和程序名称。
- -r或--route 显示Routing Table。
- -s或--statistics 显示网络工作信息统计表。
- -t或--tcp 显示TCP传输协议的连线状况。
- -u或--udp 显示UDP传输协议的连线状况。
- -v或--verbose 显示指令执行过程。
- -V或--version 显示版本信息。
- -w或--raw 显示RAW传输协议的连线状况。
- -x或--unix 此参数的效果和指定"-A unix"参数相同。
- --ip或--inet 此参数的效果和指定"-A inet"参数相同。

### 实例

显示详细的网络状况

```sh
# netstat -a
```

显示当前户籍UDP连接状况

```sh
# netstat -nu
```

显示UDP端口号的使用情况

```sh
# netstat -apu
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address        Foreign Address       State    PID/Program name  
udp    0   0 *:32768           *:*                   -          
udp    0   0 *:nfs            *:*                   -          
udp    0   0 *:641            *:*                   3006/rpc.statd   
udp    0   0 192.168.0.3:netbios-ns   *:*                   3537/nmbd      
udp    0   0 *:netbios-ns        *:*                   3537/nmbd      
udp    0   0 192.168.0.3:netbios-dgm   *:*                   3537/nmbd      
udp    0   0 *:netbios-dgm        *:*                   3537/nmbd      
udp    0   0 *:tftp           *:*                   3346/xinetd     
udp    0   0 *:999            *:*                   3366/rpc.rquotad  
udp    0   0 *:sunrpc          *:*                   2986/portmap    
udp    0   0 *:ipp            *:*                   6938/cupsd     
udp    0   0 *:1022           *:*                   3392/rpc.mountd   
udp    0   0 *:638            *:*                   3006/rpc.statd
```

显示网卡列表

```sh
# netstat -i
Kernel Interface table
Iface    MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0    1500  0  181864   0   0   0  141278   0   0   0 BMRU
lo    16436  0   3362   0   0   0   3362   0   0   0 LRU
```

显示组播组的关系

```sh
# netstat -g
IPv6/IPv4 Group Memberships
Interface    RefCnt Group
--------------- ------ ---------------------
lo       1   ALL-SYSTEMS.MCAST.NET
eth0      1   ALL-SYSTEMS.MCAST.NET
lo       1   ff02::1
eth0      1   ff02::1:ff0a:b0c
eth0      1   ff02::1
```

显示网络统计信息

```sh
# netstat -s
Ip:
  184695 total packets received
  0 forwarded
  0 incoming packets discarded
  184687 incoming packets delivered
  143917 requests sent out
  32 outgoing packets dropped
  30 dropped because of missing route
Icmp:
  676 ICMP messages received
  5 input ICMP message failed.
  ICMP input histogram:
    destination unreachable: 44
    echo requests: 287
    echo replies: 345
  304 ICMP messages sent
  0 ICMP messages failed
  ICMP output histogram:
    destination unreachable: 17
    echo replies: 287
Tcp:
  473 active connections openings
  28 passive connection openings
  4 failed connection attempts
  11 connection resets received
  1 connections established
  178253 segments received
  137936 segments send out
  29 segments retransmited
  0 bad segments received.
  336 resets sent
Udp:
  5714 packets received
  8 packets to unknown port received.
  0 packet receive errors
  5419 packets sent
TcpExt:
  1 resets received for embryonic SYN_RECV sockets
  ArpFilter: 0
  12 TCP sockets finished time wait in fast timer
  572 delayed acks sent
  3 delayed acks further delayed because of locked socket
  13766 packets directly queued to recvmsg prequeue.
  1101482 packets directly received from backlog
  19599861 packets directly received from prequeue
  46860 packets header predicted
  14541 packets header predicted and directly queued to user
  TCPPureAcks: 12259
  TCPHPAcks: 9119
  TCPRenoRecovery: 0
  TCPSackRecovery: 0
  TCPSACKReneging: 0
  TCPFACKReorder: 0
  TCPSACKReorder: 0
  TCPRenoReorder: 0
  TCPTSReorder: 0
  TCPFullUndo: 0
  TCPPartialUndo: 0
  TCPDSACKUndo: 0
  TCPLossUndo: 0
  TCPLoss: 0
  TCPLostRetransmit: 0
  TCPRenoFailures: 0
  TCPSackFailures: 0
  TCPLossFailures: 0
  TCPFastRetrans: 0
  TCPForwardRetrans: 0
  TCPSlowStartRetrans: 0
  TCPTimeouts: 29
  TCPRenoRecoveryFail: 0
  TCPSackRecoveryFail: 0
  TCPSchedulerFailed: 0
  TCPRcvCollapsed: 0
  TCPDSACKOldSent: 0
  TCPDSACKOfoSent: 0
  TCPDSACKRecv: 0
  TCPDSACKOfoRecv: 0
  TCPAbortOnSyn: 0
  TCPAbortOnData: 1
  TCPAbortOnClose: 0
  TCPAbortOnMemory: 0
  TCPAbortOnTimeout: 3
  TCPAbortOnLinger: 0
  TCPAbortFailed: 3
  TCPMemoryPressures: 0
```

显示监听的套接口

```sh
# netstat -l
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address        Foreign Address       State   
tcp    0   0 *:32769           *:*             LISTEN   
tcp    0   0 *:nfs            *:*             LISTEN   
tcp    0   0 *:644            *:*             LISTEN   
tcp    0   0 *:1002           *:*             LISTEN   
tcp    0   0 *:netbios-ssn        *:*             LISTEN   
tcp    0   0 *:sunrpc          *:*             LISTEN   
tcp    0   0 vm-dev:ipp         *:*             LISTEN   
tcp    0   0 *:telnet          *:*             LISTEN   
tcp    0   0 *:601            *:*             LISTEN   
tcp    0   0 *:microsoft-ds       *:*             LISTEN   
tcp    0   0 *:http           *:*             LISTEN   
tcp    0   0 *:ssh            *:*             LISTEN   
tcp    0   0 *:https           *:*             LISTEN   
udp    0   0 *:32768           *:*                   
udp    0   0 *:nfs            *:*                   
udp    0   0 *:641            *:*                   
udp    0   0 192.168.0.3:netbios-ns   *:*                   
udp    0   0 *:netbios-ns        *:*                   
udp    0   0 192.168.0.3:netbios-dgm   *:*                   
udp    0   0 *:netbios-dgm        *:*                   
udp    0   0 *:tftp           *:*                   
udp    0   0 *:999            *:*                   
udp    0   0 *:sunrpc          *:*                   
udp    0   0 *:ipp            *:*                   
udp    0   0 *:1022           *:*                   
udp    0   0 *:638            *:*                   
Active UNIX domain sockets (only servers)
Proto RefCnt Flags    Type    State     I-Node Path
unix 2   [ ACC ]   STREAM   LISTENING   10621 @/tmp/fam-root-
unix 2   [ ACC ]   STREAM   LISTENING   7096  /var/run/acpid.socket
unix 2   [ ACC ]   STREAM   LISTENING   9792  /tmp/.gdm_socket
unix 2   [ ACC ]   STREAM   LISTENING   9927  /tmp/.X11-unix/X0
unix 2   [ ACC ]   STREAM   LISTENING   10489 /tmp/ssh-lbUnUf4552/agent.4552
unix 2   [ ACC ]   STREAM   LISTENING   10558 /tmp/ksocket-root/kdeinit__0
unix 2   [ ACC ]   STREAM   LISTENING   10560 /tmp/ksocket-root/kdeinit-:0
unix 2   [ ACC ]   STREAM   LISTENING   10570 /tmp/.ICE-unix/dcop4664-1270815442
unix 2   [ ACC ]   STREAM   LISTENING   10843 /tmp/.ICE-unix/4735
unix 2   [ ACC ]   STREAM   LISTENING   10591 /tmp/ksocket-root/klauncherah3arc.slave-socket
unix 2   [ ACC ]   STREAM   LISTENING   7763  /var/run/iiim/.iiimp-unix/9010
unix 2   [ ACC ]   STREAM   LISTENING   11047 /tmp/orbit-root/linc-1291-0-1e92c8082411
unix 2   [ ACC ]   STREAM   LISTENING   11053 /tmp/orbit-root/linc-128e-0-dc070659cbb3
unix 2   [ ACC ]   STREAM   LISTENING   8020  /var/run/dbus/system_bus_socket
unix 2   [ ACC ]   STREAM   LISTENING   58927 /tmp/mcop-root/vm-dev-2c28-4beba75f
unix 2   [ ACC ]   STREAM   LISTENING   7860  /tmp/.font-unix/fs7100
unix 2   [ ACC ]   STREAM   LISTENING   7658  /dev/gpmctl
unix 2   [ ACC ]   STREAM   LISTENING   10498 @/tmp/dbus-s2MLJGO5Ci
```

## kill命令

>  kill 命令用于删除执行中的程序或工作

kill 可将指定的信息送至程序。预设的信息为 SIGTERM(15)，可将指定程序终止。若仍无法终止该程序，可使用 SIGKILL(9) 信息尝试强制删除程序。程序或工作的编号可利用 ps 指令或 jobs 指令查看。

### 语法

```shell
kill [-s <信息名称或编号>][程序]　或　kill [-l <信息编号>]
```

**参数说明**：

- -l <信息编号> 　若不加<信息编号>选项，则 -l 参数会列出全部的信息名称。
- -s <信息名称或编号> 　指定要送出的信息。
- [程序] 　[程序]可以是程序的PID或是PGID，也可以是工作编号。

使用 kill -l 命令列出所有可用信号。

最常用的信号是：

- 1 (HUP)：重新加载进程。
- 9 (KILL)：杀死一个进程。
- 15 (TERM)：正常停止一个进程。

### 实例

杀死进程

```shell
# kill 12345
```

强制杀死进程

```shell
# kill -KILL 123456
```

发送SIGHUP信号，可以使用一下信号

```shell
# kill -HUP pid
```

彻底杀死进程

```shell
# kill -9 123456
```

显示信号

```shell
# kill -l
1) SIGHUP     2) SIGINT     3) SIGQUIT     4) SIGILL     5) SIGTRAP
6) SIGABRT     7) SIGBUS     8) SIGFPE     9) SIGKILL    10) SIGUSR1
11) SIGSEGV    12) SIGUSR2    13) SIGPIPE    14) SIGALRM    15) SIGTERM
16) SIGSTKFLT    17) SIGCHLD    18) SIGCONT    19) SIGSTOP    20) SIGTSTP
21) SIGTTIN    22) SIGTTOU    23) SIGURG    24) SIGXCPU    25) SIGXFSZ
26) SIGVTALRM    27) SIGPROF    28) SIGWINCH    29) SIGIO    30) SIGPWR
31) SIGSYS    34) SIGRTMIN    35) SIGRTMIN+1    36) SIGRTMIN+2    37) SIGRTMIN+3
38) SIGRTMIN+4    39) SIGRTMIN+5    40) SIGRTMIN+6    41) SIGRTMIN+7    42) SIGRTMIN+8
43) SIGRTMIN+9    44) SIGRTMIN+10    45) SIGRTMIN+11    46) SIGRTMIN+12    47) SIGRTMIN+13
48) SIGRTMIN+14    49) SIGRTMIN+15    50) SIGRTMAX-14    51) SIGRTMAX-13    52) SIGRTMAX-12
53) SIGRTMAX-11    54) SIGRTMAX-10    55) SIGRTMAX-9    56) SIGRTMAX-8    57) SIGRTMAX-7
58) SIGRTMAX-6    59) SIGRTMAX-5    60) SIGRTMAX-4    61) SIGRTMAX-3    62) SIGRTMAX-2
63) SIGRTMAX-1    64) SIGRTMAX
```

杀死指定用户所有进程

```shell
#kill -9 $(ps -ef | grep hnlinux) //方法一 过滤出hnlinux用户进程 
#kill -u hnlinux //方法二
```







## xargs 命令

> xargs（英文全拼： eXtended ARGuments）是给命令传递参数的一个过滤器，也是组合多个命令的一个工具。

xargs 可以将管道或标准输入（stdin）数据转换成命令行参数，也能够从文件的输出中读取数据。

xargs 也可以将单行或多行文本输入转换为其他格式，例如多行变单行，单行变多行。

xargs 默认的命令是 echo，这意味着通过管道传递给 xargs 的输入将会包含换行和空白，不过通过 xargs 的处理，换行和空白将被空格取代。

xargs 是一个强有力的命令，它能够捕获一个命令的输出，然后传递给另外一个命令。

之所以能用到这个命令，关键是由于很多命令不支持|管道来传递参数，而日常工作中有有这个必要，所以就有了 xargs 命令，例如

```shell
find /sbin -perm +700 |xargs ls -l   #这样才是正确的
```

xargs 一般是和管道一起使用

### 命令格式：

```shell
somecommand |xargs -item  command
```

**参数：**

- -a file 从文件中读入作为 stdin
- -e flag ，注意有的时候可能会是-E，flag必须是一个以空格分隔的标志，当xargs分析到含有flag这个标志的时候就停止。
- -p 当每次执行一个argument的时候询问一次用户。
- -n num 后面加次数，表示命令在执行的时候一次用的argument的个数，默认是用所有的。
- -t 表示先打印命令，然后再执行。
- -i 或者是-I，这得看linux支持了，将xargs的每项名称，一般是一行一行赋值给 {}，可以用 {} 代替。
- -r no-run-if-empty 当xargs的输入为空的时候则停止xargs，不用再去执行了。
- -s num 命令行的最大字符数，指的是 xargs 后面那个命令的最大命令行字符数。
- -L num 从标准输入一次读取 num 行送给 command 命令。
- -l 同 -L。
- -d delim 分隔符，默认的xargs分隔符是回车，argument的分隔符是空格，这里修改的是xargs的分隔符。
- -x exit的意思，主要是配合-s使用。。
- -P 修改最大的进程数，默认是1，为0时候为as many as it can ，这个例子我没有想到，应该平时都用不到的吧。

### 实例

xargs 用作替换工具，读取输入数据重新格式化后输出。

定义一个测试文件，内有多行文本数据：

```shell
# cat test.txt

a b c d e f g
h i j k l m n
o p q
r s t
u v w x y z
```

多行输入单行输出：

```shell
# cat test.txt | xargs
a b c d e f g h i j k l m n o p q r s t u v w x y z
```

-n 选项多行输出：

```shell
# cat test.txt | xargs -n3

a b c
d e f
g h i
j k l
m n o
p q r
s t u
v w x
y z
```

-d 选项可以自定义一个定界符：

```shell
# echo "nameXnameXnameXname" | xargs -dX

name name name name
```

结合 -n 选项使用：

```shell
# echo "nameXnameXnameXname" | xargs -dX -n2

name name
name name
```

读取 stdin，将格式化后的参数传递给命令

假设一个命令为 sk.sh 和一个保存参数的文件 arg.txt：

```shell
#!/bin/bash
#sk.sh命令内容，打印出所有参数。

echo $*
```

arg.txt文件内容：

```shell
# cat arg.txt

aaa
bbb
ccc
```

xargs 的一个选项 -I，使用 -I 指定一个替换字符串 {}，这个字符串在 xargs 扩展时会被替换掉，当 -I 与 xargs 结合使用，每一个参数命令都会被执行一次：

```shell
# cat arg.txt | xargs -I {} ./sk.sh -p {} -l

-p aaa -l
-p bbb -l
-p ccc -l
```

复制所有图片文件到 /data/images 目录下：

```shell
ls *.jpg | xargs -n1 -I {} cp {} /data/images
```

xargs 结合 find 使用

用 rm 删除太多的文件时候，可能得到一个错误信息：**/bin/rm Argument list too long.** 用 xargs 去避免这个问题：

```shell
find . -type f -name "*.log" -print0 | xargs -0 rm -f
```

xargs -0 将 \0 作为定界符。

统计一个源代码目录中所有 php 文件的行数：

```shell
find . -type f -name "*.php" -print0 | xargs -0 wc -l
```

查找所有的 jpg 文件，并且压缩它们：

```shell
find . -type f -name "*.jpg" -print | xargs tar -czvf images.tar.gz
```

xargs 其他应用

假如你有一个文件包含了很多你希望下载的 URL，你能够使用 xargs下载所有链接：

```shell
# cat url-list.txt | xargs wget -c
```

## top命令

Linux top命令用于实时显示 process 的动态。

使用权限：所有使用者。

### 语法

```shell
top [-] [d delay] [q] [c] [S] [s] [i] [n] [b]
```

**参数说明**：

- d : 改变显示的更新速度，或是在交谈式指令列( interactive command)按 s
- q : 没有任何延迟的显示速度，如果使用者是有 superuser 的权限，则 top 将会以最高的优先序执行
- c : 切换显示模式，共有两种模式，一是只显示执行档的名称，另一种是显示完整的路径与名称
- S : 累积模式，会将己完成或消失的子行程 ( dead child process ) 的 CPU time 累积起来
- s : 安全模式，将交谈式指令取消, 避免潜在的危机
- i : 不显示任何闲置 (idle) 或无用 (zombie) 的行程
- n : 更新的次数，完成后将会退出 top
- b : 批次档模式，搭配 "n" 参数一起使用，可以用来将 top 的结果输出到档案内

### 实例

显示进程信息

```shell
# top
```

显示完整命令

```shell
# top -c
```

以批处理模式显示程序信息

```shell
# top -b
```

以累积模式显示程序信息

```shell
# top -S
```

设置信息更新次数

```shell
top -n 2
#表示更新两次后终止更新显示
```

设置信息更新时间

```shell
# top -d 3

#表示更新周期为3秒
```

显示指定的进程信息

```shell
# top -p 139

#显示进程号为139的进程信息，CPU、内存占用率等
```

显示更新十次后退出

```shell
top -n 10
```

使用者将不能利用交谈式指令来对行程下命令

```shell
top -s
```

