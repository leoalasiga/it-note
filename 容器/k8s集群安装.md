# 通过kubeadm离线安装k8s集群v1.15

 发表于 2019-12-08  更新于 2020-04-25  分类于 [Kubernetes](https://finolo.gy/categories/Kubernetes/)  阅读次数： 1319  评论数： [4](https://finolo.gy/2019/12/通过kubeadm离线安装k8s集群v1-15/#valine-comments)

通过kubeadm离线安装k8s集群v1.15。最近有网友提到 `gcr.azk8s.cn` 被关闭的问题，解决方案请查阅 [K8S国内的镜像源](https://finolo.gy/2019/12/K8S国内的镜像源/)

# 安装说明

这篇文章将描述在生产环境中，如何搭建k8s集群。

## 为什么使用`kubeadm`来安装

`kubeadm`是官方社区推出的一个用于快速部署kubernetes集群的工具。这个工具能通过两条指令快速完成一个kubernetes集群的部署。

网上很多人说通过二进制安装能了解到配置的细节，其实通过`kubeadm`安装也能查看到配置的细节。

可以自动生成证书，对初学者带来了不少便利。

## 网络环境

我们完全模拟生产环境中，不可以访问外部互联网的情况。

基础的yum源是有提供的，像什么docker-ce、kubernetes的源是没有的。

k8s.gcr.io、quay.io这些域名也是不可以访问的。

# 准备环境

如果没有特殊提及，安装及操作需要在所有master及node节点上执行。

## 机器网络及配置

复制三台虚拟机。

| 主机名     | IP            | 节点类型   | 最低配置              |
| :--------- | :------------ | :--------- | :-------------------- |
| k8s-master | 172.16.64.233 | master节点 | CPU 2Core, Memory 1GB |
| k8s-node1  | 172.16.64.232 | node节点   | CPU 1Core, Memory 1GB |
| k8s-node2  | 172.16.64.235 | node节点   | CPU 1Core, Memory 1GB |

master节点需要至少2个CPU，不然会报如错误：

```
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR NumCPU]: the number of available CPUs 1 is less than the required 2
```

## 关闭防火墙

```
systemctl stop firewalld
systemctl disable firewalld
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
```

## 关闭selinux

把`SELINUX=enforcing`替换成`SELINUX=disabled`

```
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
setenforce 0
```

查看一下selinux的状态。

```
getenforce
Permissive
```

## 关闭Swap

```
swapoff -a
cp /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak | grep -v swap > /etc/fstab
```

`grep -v swap`是查找不包含`swap`的行。

查看一下swap的情况，Swap已经全部为0了。

```
free -m
              total        used        free      shared  buff/cache   available
Mem:            972         142         715           7         114         699
Swap:             0           0           0
```

## 设置主机名

在master节点上设置主机名。

```
hostnamectl set-hostname k8s-master
```

在node1节点上设置主机名。

```
hostnamectl set-hostname k8s-node1
```

在node2节点上设置主机名。

```
hostnamectl set-hostname k8s-node2
```

在master上查看主机名。

```
hostname
k8s-master
```

## 设置hosts

\>>表示文件末尾追加记录。

```
cat >> /etc/hosts <<EOF
172.16.64.233   k8s-master
172.16.64.232   k8s-node1
172.16.64.235   k8s-node2
EOF
```

## 修改sysctl.conf

暂时未修改，装docker的时候会自动修改。可以暂时先跳过这一步。

如果未修改成功，在执行`docker info`命令时，会显示如下提示信息。

```
WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
cat /proc/sys/net/bridge/bridge-nf-call-iptables
0
cat /proc/sys/net/bridge/bridge-nf-call-ip6tables
0
```

可通过以下方法来做修改。

```
# 修改 /etc/sysctl.conf
# 如果有配置，则修改
sed -i "s#^net.ipv4.ip_forward.*#net.ipv4.ip_forward=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
# 可能没有，追加
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sysctl -p
```

也就是在`/etc/sysctl.conf`末尾加上如下内容：

```
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

同时让配置生效`sysctl -p`

# 安装Docker

## 下载docker

由于我们在生产环境中是没法连接互联网的，所以要提前准备好docker rpm包。

我们在另一台可以联网的机器上下载安装所需的软件。

### 添加docker yum源

在联网的机器上，下载docker

配置docker-ce源

```
cd /etc/yum.repos.d/
wget https://download.docker.com/linux/centos/docker-ce.repo
```

### 查看docker所有版本

```
yum list docker-ce --showduplicates
...
docker-ce.x86_64                            18.06.3.ce-3.el7                                   docker-ce-stable
docker-ce.x86_64                            3:18.09.0-3.el7                                    docker-ce-stable
...
```

我们选择安装docker-ce.18.06.3.ce-3.el7

### 下载

```
yum install --downloadonly --downloaddir ~/k8s/docker docker-ce-18.06.3.ce-3.el7
```

docker及其依赖会下载到~/docker文件夹中。

我们可以看到只有`docker-ce`是来自`docker-ce-stable`源的。

```
===============================================================================================================
 Package                          架构             版本                       源                          大小
===============================================================================================================
正在安装:
 docker-ce                        x86_64           18.06.3.ce-3.el7           docker-ce-stable            41 M
为依赖而安装:
 audit-libs-python                x86_64           2.8.5-4.el7                base                        76 k
 checkpolicy                      x86_64           2.5-8.el7                  base                       295 k
 container-selinux                noarch           2:2.107-3.el7              extras                      39 k
 libcgroup                        x86_64           0.41-21.el7                base                        66 k
 libseccomp                       x86_64           2.3.1-3.el7                base                        56 k
 libsemanage-python               x86_64           2.5-14.el7                 base                       113 k
 libtool-ltdl                     x86_64           2.4.2-22.el7_3             base                        49 k
 policycoreutils-python           x86_64           2.5-33.el7                 base                       457 k
 python-IPy                       noarch           0.75-6.el7                 base                        32 k
 setools-libs                     x86_64           3.3.8-4.el7                base                       620 k
```

所以，我们只需要把`docker-ce-18.06.3.ce-3.el7.x86_64.rpm`拷贝到master及node节点里面。

在master及node节点里创建`~/k8s/docker`目录，用于存放docker安装rpm包。

```
mkdir -p ~/k8s/docker
```

### 拷贝到k8s集群

通过scp命令拷贝。

```
scp docker-ce-18.06.3.ce-3.el7.x86_64.rpm root@172.16.64.233:~/k8s/docker/
scp docker-ce-18.06.3.ce-3.el7.x86_64.rpm root@172.16.64.232:~/k8s/docker/
scp docker-ce-18.06.3.ce-3.el7.x86_64.rpm root@172.16.64.235:~/k8s/docker/
```

## 安装Docker

yum本地安装

```
yum install k8s/docker/docker-ce-18.06.3.ce-3.el7.x86_64.rpm
```

设置开机启动

```
systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
```

我们可以查看一下安装包到底生成了哪些文件。

```
rpm -ql docker-ce
```

或者

```
rpm -qpl k8s/docker/docker-ce-18.06.3.ce-3.el7.x86_64.rpm
```

## 启动Docker

```
systemctl start docker
```

查看docker服务信息。

```
docker info
...
Cgroup Driver: cgroupfs
...
```

呆会儿我们还需要修改这个值。

# 安装k8s组件

由于kubeadm是依赖kubelet, kubectl的，所以我们只需要下载kubeadm的rpm，其依赖就自动下载下来了。但是版本可能不是我们想要的，所以可能需要单独下载。比如我下载kubeadm-1.15.6，它依赖的可能是kubelet-1.16.x。

## 下载k8s组件

我们需要安装kubeadm, kubelet, kubectl，版本需要一致。在可以连外网的机器上下载组件，同上面docker。

### 添加kubernetes yum源

```
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes Repo
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
enabled=1
EOF
```

### 查看kubeadm版本

```
yum list kubeadm --showduplicates

kubeadm.x86_64                                                         1.15.6-0                                                           kubernetes
```

### 下载

下载`kubeadm-1.15.6`

```
yum install --downloadonly --downloaddir ~/k8s/kubernetes kubeadm-1.15.6
```

根据如下依赖关系

```
====================================================================================================================================================
 Package                                    架构                       版本                                    源                              大小
====================================================================================================================================================
正在安装:
 kubeadm                                    x86_64                     1.15.6-0                                kubernetes                     8.9 M
为依赖而安装:
 conntrack-tools                            x86_64                     1.4.4-5.el7_7.2                         updates                        187 k
 cri-tools                                  x86_64                     1.13.0-0                                kubernetes                     5.1 M
 kubectl                                    x86_64                     1.16.3-0                                kubernetes                      10 M
 kubelet                                    x86_64                     1.16.3-0                                kubernetes                      22 M
 kubernetes-cni                             x86_64                     0.7.5-0                                 kubernetes                      10 M
 libnetfilter_cthelper                      x86_64                     1.0.0-10.el7_7.1                        updates                         18 k
 libnetfilter_cttimeout                     x86_64                     1.0.0-6.el7_7.1                         updates                         18 k
 libnetfilter_queue                         x86_64                     1.0.2-2.el7_2                           base                            23 k
 socat                                      x86_64                     1.7.3.2-2.el7                           base                           290 k
```

我们只需要把来自`kubernetes`源的`kubeadm`和4个依赖`cri-tools`, `kubectl`, `kubelet`和`kubernetes-cni`拷贝到master和node节点。

下载`kubelet-1.15.6`

```
yum install --downloadonly --downloaddir ~/k8s/kubernetes kubelet-1.15.6
```

下载`kubectl-1.15.6`

```
yum install --downloadonly --downloaddir ~/k8s/kubernetes kubectl-1.15.6
```

### 拷贝到k8s集群

在master及node节点里创建`~/k8s/kubernetes`目录，用于存放k8s组件安装的rpm包。

```
mkdir -p ~/k8s/kubernetes
```

kubeadm

```

```

cri-tools

```
scp 14bfe6e75a9efc8eca3f638eb22c7e2ce759c67f95b43b16fae4ebabde1549f3-cri-tools-1.13.0-0.x86_64.rpm root@172.16.64.233:~/k8s/kubernetes/
scp 14bfe6e75a9efc8eca3f638eb22c7e2ce759c67f95b43b16fae4ebabde1549f3-cri-tools-1.13.0-0.x86_64.rpm root@172.16.64.232:~/k8s/kubernetes/
scp 14bfe6e75a9efc8eca3f638eb22c7e2ce759c67f95b43b16fae4ebabde1549f3-cri-tools-1.13.0-0.x86_64.rpm root@172.16.64.235:~/k8s/kubernetes/
```

kubectl

```
scp 5181c2b7eee876b8ce205f0eca87db2b3d00ffd46d541882620cb05b738d7a80-kubectl-1.15.6-0.x86_64.rpm root@172.16.64.233:~/k8s/kubernetes/
scp 5181c2b7eee876b8ce205f0eca87db2b3d00ffd46d541882620cb05b738d7a80-kubectl-1.15.6-0.x86_64.rpm root@172.16.64.232:~/k8s/kubernetes/
scp 5181c2b7eee876b8ce205f0eca87db2b3d00ffd46d541882620cb05b738d7a80-kubectl-1.15.6-0.x86_64.rpm root@172.16.64.235:~/k8s/kubernetes/
```

kubelet

```
scp e9e7cc53edd19d0ceb654d1bde95ec79f89d26de91d33af425ffe8464582b36e-kubelet-1.15.6-0.x86_64.rpm root@172.16.64.233:~/k8s/kubernetes/
scp e9e7cc53edd19d0ceb654d1bde95ec79f89d26de91d33af425ffe8464582b36e-kubelet-1.15.6-0.x86_64.rpm root@172.16.64.232:~/k8s/kubernetes/
scp e9e7cc53edd19d0ceb654d1bde95ec79f89d26de91d33af425ffe8464582b36e-kubelet-1.15.6-0.x86_64.rpm root@172.16.64.235:~/k8s/kubernetes/
```

kubernetes-cni

```
scp 548a0dcd865c16a50980420ddfa5fbccb8b59621179798e6dc905c9bf8af3b34-kubernetes-cni-0.7.5-0.x86_64.rpm root@172.16.64.235:~/k8s/kubernetes/
```

## 安装k8s组件

```
yum install ~/k8s/kubernetes/*.rpm
```

这样，kubeadm, kubectl, kubelet就已经安装好了。

设置kubelet的开机启动。我们并不需要启动kubelet，就算启动，也是不能成功的。执行kubeadm命令，会生成一些配置文件 ，这时才会让kubelet启动成功的。

```
systemctl enable kubelet
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/lib/systemd/system/kubelet.service.
```

# 拉取镜像

执行kubeadm时，需要用到一些镜像，我们需要提前准备。

## 查看需要依赖哪些镜像

```
kubeadm config images list
W1207 18:53:23.129020   10255 version.go:98] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://dl.k8s.io/release/stable-1.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
W1207 18:53:23.129433   10255 version.go:99] falling back to the local client version: v1.15.6
k8s.gcr.io/kube-apiserver:v1.15.6
k8s.gcr.io/kube-controller-manager:v1.15.6
k8s.gcr.io/kube-scheduler:v1.15.6
k8s.gcr.io/kube-proxy:v1.15.6
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.3.10
k8s.gcr.io/coredns:1.3.1
```

在生产环境，是肯定访问不了k8s.gcr.io这个地址的。在有大陆联网的机器上，也是无法访问的。所以我们需要使用国内镜像先下载下来。

镜像地址，请参考 [K8S国内的镜像源](https://finolo.gy/2019/12/K8S国内的镜像源/)

## 拉取镜像

在三台机器上拉取如下镜像。

```
docker pull gcr.azk8s.cn/google-containers/kube-apiserver:v1.15.6
docker pull gcr.azk8s.cn/google-containers/kube-controller-manager:v1.15.6
docker pull gcr.azk8s.cn/google-containers/kube-scheduler:v1.15.6
docker pull gcr.azk8s.cn/google-containers/kube-proxy:v1.15.6
docker pull gcr.azk8s.cn/google-containers/pause:3.1
docker pull gcr.azk8s.cn/google-containers/etcd:3.3.10
docker pull gcr.azk8s.cn/google-containers/coredns:1.3.1
```

查看拉取镜像。

```
docker images
REPOSITORY                                               TAG                 IMAGE ID            CREATED             SIZE
gcr.azk8s.cn/google-containers/kube-proxy                v1.15.6             d756327a2327        3 weeks ago         82.4MB
gcr.azk8s.cn/google-containers/kube-apiserver            v1.15.6             9f612b9e9bbf        3 weeks ago         207MB
gcr.azk8s.cn/google-containers/kube-controller-manager   v1.15.6             83ab61bd43ad        3 weeks ago         159MB
gcr.azk8s.cn/google-containers/kube-scheduler            v1.15.6             502e54938456        3 weeks ago         81.1MB
gcr.azk8s.cn/google-containers/coredns                   1.3.1               eb516548c180        10 months ago       40.3MB
gcr.azk8s.cn/google-containers/etcd                      3.3.10              2c4adeb21b4f        12 months ago       258MB
gcr.azk8s.cn/google-containers/pause                     3.1                 da86e6ba6ca1        23 months ago       742kB
```

## tag镜像

为了让kubeadm程序能找到`k8s.gcr.io`下面的镜像，需要把刚才下载的镜像名称重新打一下tag。

```
docker images | grep gcr.azk8s.cn/google-containers | sed 's/gcr.azk8s.cn\/google-containers/k8s.gcr.io/' | awk '{print "docker tag " $3 " " $1 ":" $2}' | sh
```

删除旧的镜像，当然，你留着也不会占用太多空间。

```
docker images | grep gcr.azk8s.cn/google-containers | awk '{print "docker rmi " $1 ":" $2}' | sh
```

## 查看镜像

```
docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-proxy                v1.15.6             d756327a2327        3 weeks ago         82.4MB
k8s.gcr.io/kube-apiserver            v1.15.6             9f612b9e9bbf        3 weeks ago         207MB
k8s.gcr.io/kube-controller-manager   v1.15.6             83ab61bd43ad        3 weeks ago         159MB
k8s.gcr.io/kube-scheduler            v1.15.6             502e54938456        3 weeks ago         81.1MB
k8s.gcr.io/coredns                   1.3.1               eb516548c180        10 months ago       40.3MB
k8s.gcr.io/etcd                      3.3.10              2c4adeb21b4f        12 months ago       258MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        23 months ago       742kB
```

镜像搞定了。

# 部署k8s集群

## 初始化master节点

在master节点上执行`kubeadm init`命令。

我们接下来首先会使用flannel网络，所以参数中必须设置`--pod-network-cidr=10.244.0.0/16`，这个IP地址是固定的。

```
kubeadm init \
--apiserver-advertise-address=172.16.64.233 \
--pod-network-cidr=10.244.0.0/16

W1207 21:18:48.257967   10859 version.go:98] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://dl.k8s.io/release/stable-1.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
W1207 21:18:48.258448   10859 version.go:99] falling back to the local client version: v1.15.6
[init] Using Kubernetes version: v1.15.6
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.16.64.233]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [172.16.64.233 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [172.16.64.233 127.0.0.1 ::1]
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 36.504799 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 1czxp7.4tt0x3lxdcus8wer
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.64.233:6443 --token 1czxp7.4tt0x3lxdcus8wer \
    --discovery-token-ca-cert-hash sha256:abb676401e56a48f07675ff802f1abedd512cce0523190b2e0f636ee6d70d8b4
```

## 解决WARNING

我们看到上面的消息中有一句

```
[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
```

还记得前面我在查看`docker info`时，有提到要修改cgroup driver么？现在就来修改吧。

修改或创建`/etc/docker/daemon.json`，添加如下内容：

```
{
	"exec-opts": ["native.cgroupdriver=systemd"]
}
```

重启docker

```
systemctl restart docker
```

查看修改结果，如果Cgroup Driver改为systemd后就表示成功了。

```
docker info
...
Cgroup Driver: systemd
...
```

重置

```
kubeadm reset

[reset] Reading configuration from the cluster...
[reset] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
W1207 22:12:18.285935   27649 reset.go:98] [reset] Unable to fetch the kubeadm-config ConfigMap from cluster: failed to get config map: Get https://172.16.64.233:6443/api/v1/namespaces/kube-system/configmaps/kubeadm-config: dial tcp 172.16.64.233:6443: connect: connection refused
[reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
[reset] Are you sure you want to proceed? [y/N]: y
[preflight] Running pre-flight checks
W1207 22:12:19.569005   27649 removeetcdmember.go:79] [reset] No kubeadm config, using etcd pod spec to get data directory
[reset] Stopping the kubelet service
[reset] Unmounting mounted directories in "/var/lib/kubelet"
[reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
[reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]
[reset] Deleting contents of stateful directories: [/var/lib/etcd /var/lib/kubelet /etc/cni/net.d /var/lib/dockershim /var/run/kubernetes]

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually.
For example:
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

The reset process does not clean your kubeconfig files and you must remove them manually.
Please, check the contents of the $HOME/.kube/config file.
```

## 再次初始化Master节点

`apiserver-advertise-address`和`pod-network-cidr`参数都可以省略掉。

```
kubeadm init \
--apiserver-advertise-address=172.16.64.233 \
--pod-network-cidr=10.244.0.0/16

...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.64.233:6443 --token duof19.l9q3dsh4ccen4ya0 \
    --discovery-token-ca-cert-hash sha256:66fad0ed5f46f5ea9a394276a77db16d26d60465ec9930f8c21aa924a5df9bb5
```

提示信息和上面初始化时的信息一样，只是少了刚才的WARNING。

按照信息提示，执行如下命令，目前登录的就是root用户，所以也不需要用sudo了。

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

查看节点信息，节点状态为`NotReady`:

```
kubectl get no
NAME         STATUS     ROLES    AGE     VERSION
k8s-master   NotReady   master   2m22s   v1.15.6
```

## 往集群里面加入node节点

在节点node1上，按上面的提示执行命令：

```
kubeadm join 172.16.64.233:6443 --token duof19.l9q3dsh4ccen4ya0 \
    --discovery-token-ca-cert-hash sha256:66fad0ed5f46f5ea9a394276a77db16d26d60465ec9930f8c21aa924a5df9bb5
    
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.15" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

在Master节点上（control-plane)上查看节点信息

```
kubectl get no
NAME         STATUS     ROLES    AGE   VERSION
k8s-master   NotReady   master   7m    v1.15.6
k8s-node1    NotReady   <none>   65s   v1.15.6
```

我们看到了多了一个节点，虽然现在都是NotReady状态。

## Token过期后再加入节点

过了一段时间后，再加入节点，这个时候会提示token已经过期了。我们可以这样拿到token和hash值。

```
kubeadm token create
kubeadm token list
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

## 安装Network插件

这里我们先安装flannel网络插件。

### 查看安装方法

查看flannel的官网`https://github.com/coreos/flannel`，找到安装方法。

```
For Kubernetes v1.7+ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### 下载yml文件

在有网络的机器上下载kube-flannel.yml文件

```
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

把下载好的yml文件分发到k8s集群的三台机器里面。

### 下载镜像

```
cat kube-flannel.yml | grep image
        image: quay.io/coreos/flannel:v0.11.0-amd64
        ...
```

还记得前面方法么？不记得就回到上面再看看吧。

```
docker pull quay.azk8s.cn/coreos/flannel:v0.11.0-amd64
docker tag ff281650a721 quay.io/coreos/flannel:v0.11.0-amd64
docker rmi quay.azk8s.cn/coreos/flannel:v0.11.0-amd64
```

### 安装flannel

我们也可以选择安装Calico网络插件。

在Master节点执行：

```
kubectl apply -f kube-flannel.yml

podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds-amd64 created
daemonset.apps/kube-flannel-ds-arm64 created
daemonset.apps/kube-flannel-ds-arm created
daemonset.apps/kube-flannel-ds-ppc64le created
daemonset.apps/kube-flannel-ds-s390x created
```

## 查看节点信息

```
kubectl get no
NAME         STATUS   ROLES    AGE   VERSION
k8s-master   Ready    master   33m   v1.15.6
k8s-node1    Ready    <none>   28m   v1.15.6
k8s-node2    Ready    <none>   17m   v1.15.6
```

这一下所有节点都已经ready了。

## 查看进程

### Master节点

```
ps -ef | grep kube
root       1652      1  3 15:13 ?        00:00:04 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1
root       1973   1909  8 15:13 ?        00:00:12 kube-apiserver --advertise-address=172.16.64.233 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --insecure-port=0 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-cluster-ip-range=10.96.0.0/12 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
root       1980   1915  1 15:13 ?        00:00:01 kube-scheduler --bind-address=127.0.0.1 --kubeconfig=/etc/kubernetes/scheduler.conf --leader-elect=true
root       1995   1936  2 15:13 ?        00:00:03 etcd --advertise-client-urls=https://172.16.64.233:2379 --cert-file=/etc/kubernetes/pki/etcd/server.crt --client-cert-auth=true --data-dir=/var/lib/etcd --initial-advertise-peer-urls=https://172.16.64.233:2380 --initial-cluster=k8s-master=https://172.16.64.233:2380 --key-file=/etc/kubernetes/pki/etcd/server.key --listen-client-urls=https://127.0.0.1:2379,https://172.16.64.233:2379 --listen-peer-urls=https://172.16.64.233:2380 --name=k8s-master --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt --peer-client-cert-auth=true --peer-key-file=/etc/kubernetes/pki/etcd/peer.key --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt --snapshot-count=10000 --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
root       2002   1951  2 15:13 ?        00:00:03 kube-controller-manager --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf --bind-address=127.0.0.1 --client-ca-file=/etc/kubernetes/pki/ca.crt --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt --cluster-signing-key-file=/etc/kubernetes/pki/ca.key --controllers=*,bootstrapsigner,tokencleaner --kubeconfig=/etc/kubernetes/controller-manager.conf --leader-elect=true --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --root-ca-file=/etc/kubernetes/pki/ca.crt --service-account-private-key-file=/etc/kubernetes/pki/sa.key --use-service-account-credentials=true
root       2263   2244  0 15:13 ?        00:00:00 /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/config.conf --hostname-override=k8s-master
root       3907   3888  0 15:14 ?        00:00:00 /usr/bin/kube-controllers
```

### Worker节点

```
ps -ef | grep kube
root       1355      1  1 15:05 ?        00:00:06 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1
root       1669   1620  0 15:13 ?        00:00:00 /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/config.conf --hostname-override=k8s-node1
```

# 测试k8s集群

安装一个nginx。

## 创建一个部署(deployment)

在master节点（Control Plane）安装一个叫nginx-deployment的deployment：

```
kubectl create deploy nginx-deployment --image=nginx
deployment.apps/nginx-deployment created
```

## 查看deployment状态

```
kubectl get deploy
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   0/1     1            0           44s
```

发现没有READY。

## 查看pod状态

```
kubectl get po
NAME                                READY   STATUS              RESTARTS   AGE
nginx-deployment-6f77f65499-htdps   0/1     ContainerCreating   0          111s
```

也是没有READY。继续查看详细信息。

```
kubectl describe po nginx-deployment-6f77f65499-htdps

...
Events:
  Type    Reason     Age    From                Message
  ----    ------     ----   ----                -------
  Normal  Scheduled  2m18s  default-scheduler   Successfully assigned default/nginx-deployment-6f77f65499-htdps to k8s-node1
  Normal  Pulling    2m17s  kubelet, k8s-node1  Pulling image "nginx"
```

初步判断应该是拉取镜像拉不下来，或者速度非常慢。

## 配置docker源

在生产环境，肯定是有内部的镜像源的，在这里，我就模拟把源配置为阿里的镜像源了。

`/etc/docker/daemon.json`内容如下：

```
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"registry-mirrors": ["http://hub-mirror.c.163.com"]
}
```

重启docker

```
systemctl restart docker
```

这个时候，镜像就容易拉取了。

## 测试pod

再次查看deploy, pod，状态已经变为READY了。

```
kubectl get po -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
nginx-deployment-6f77f65499-htdps   1/1     Running   0          26m   10.244.1.3   k8s-node1   <none>           <none>
```

我们看到pod的IP为10.244.1.3。还记得我们在初始化master节点时设置的参数`--pod-network-cidr=10.244.0.0/16`么？

在集群内的三个节点访问nginx，能成功访问。

```
curl 10.244.1.3

...
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
...
```

## 创建Service

我们把deployment暴露出来。

```
kubectl expose deploy nginx-deployment --port=80 --type=NodePort
service/nginx-deployment exposed
```

查看状态

```
kubectl get svc
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP        71m
nginx-deployment   NodePort    10.109.145.67   <none>        80:32538/TCP   32s
```

在三个节点内访问nginx

```
curl 10.109.145.67

...
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
...
```

在集群外访问nginx

```
curl 172.16.64.233:32538
curl 172.16.64.232:32538
curl 172.16.64.235:32538

...
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
...
```

至此，一个k8s集群在生产环境的模拟安装，就结束了。